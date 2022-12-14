#load data
library(data.table)
library(readxl)
library(ncvreg)
library(glmnet)
library(flare)
library(tidyverse)
library(ascii)
library(robmed)
library(lavaan)
library(qvalue)

dat<-read.csv("source_data/complete_cases_notau.csv",header = T)
dat$EDU<-(dat$PTEDUCAT<=14)*1+(dat$PTEDUCAT>14&dat$PTEDUCAT<18)*2+(dat$PTEDUCAT>17&dat$PTEDUCAT)*3
blank1<-c()
blank2<-c()

set.seed(2022)
choose.K <- function(X, PCA){    
  p <- ncol(X)
  n <- nrow(X)
  val <- log(norm(t(X), type = 'F') / p / n)
  Kmax <- 20
  for (K in 1:Kmax) {
    F.hat <- matrix(sqrt(n) * PCA$vectors[, 1:K], ncol = K)
    val <- c(val, log(norm(t(X) - t(X) %*% F.hat[, 1:K] %*% t(F.hat[, 1:K]) / n, type = 'F') / p / n) +
               K * (p + n) / p / n * log(p * n / (p + n)))
    ##                    K * (p + n) / p / n * log(min(p, n)))
  }
  return(which(val == min(val))-1)
}

choose.K.2 <- function(X){ # choose number of latent factors by Fan
  eigen.val <- eigen(X %*% t(X))$val
  return(which.max(eigen.val / lead(eigen.val)))
}

merge2<-na.omit(dat)
merge2$PTGENDER<- as.factor(merge2$PTGENDER)
merge2$EDU<- as.factor(merge2$EDU)
X <- na.omit(dat)[, -c(1:18,342)]
X_initial <- X[, -which(colnames(X) %in% c('SCAN_F', 'EXAMDATE_F','DX_F','SCAN_T', 'EXAMDATE_T','DX_T' ))]

X1<- cbind(as.matrix(merge2$AGE),as.matrix(merge2$EDU),as.matrix(merge2$PTGENDER),X_initial)
colnames(X1)[1:3]<-c("AGE","EDUCATION","GENDER")
X_new <- X1
adjx<-matrix(0,nrow=nrow(X_new),ncol=ncol(X_new)-3)
for (j in (4:ncol(X_new))){
  for (i in (1:nrow(X_new))){
    adjx[i,j-3]<-((lm(X1[,j]~AGE+ EDUCATION+ GENDER, data = as.data.frame(X_new)))$res)[i]
  }
}

adjx1<-as.data.frame(adjx)
colnames(adjx1)<-colnames(X_new)[-c(1:3)]
library(caret)
X <- scale(adjx1)

ncol(X)
adj <- lm(ADNI_MEM~AGE+ EDU+ PTGENDER, data = merge2)
Y <- adj$res

n <- nrow(X)

idx <- list(1:160, 161:320) # indices of each

## extract common factors
PCA   <- eigen(X %*% t(X))
K     <- choose.K(X,PCA) # 1st way to choose K: 9
plot(PCA$values)

## estimates of F, L, U
F.hat <- sqrt(n) * PCA$vectors[, 1:K]
L.hat <- t(X) %*% F.hat / n
U.hat <- X - F.hat %*% t(L.hat)

pen <- c(rep(1, ncol(U.hat)), rep(0, ncol(F.hat))) # penalty factor

cv <- cv.ncvreg(cbind(U.hat, F.hat), Y, family = 'gaussian', seed=1,lambda.min=0.1,nfold=5,penalty = 'SCAD', standardize = F,
                penalty.factor = pen)

plot(cv)
cv$lambda.min#0.0758

fit <- ncvreg(cbind(U.hat, F.hat), Y, family = 'gaussian', lambda=cv$lambda.min, penalty = 'SCAD',
              penalty.factor = pen,
              standardize = F)

beta.hat <- head(as.vector(fit$beta), - K)[-1]
blank1<-cbind(blank1,sum(beta.hat!=0))
blank2<-cbind(blank2,which(beta.hat!=0))
idx.nonzero <- which(fit$beta[-1]!= 0)
idx.nonzero <- idx.nonzero[1:(length(idx.nonzero)-K)]
nonzeros <- as.matrix(fit$beta[idx.nonzero+1], ncol = 1)
nonzeros <- cbind(nonzeros, paste('Node.', idx.nonzero, sep = ''))
rownames(nonzeros) <- colnames(X)[idx.nonzero]

save(dat, Y, adj, X, K, fit, nonzeros, file = 'derived_results/MEM_output.RData')

print(ascii(nonzeros, include.rownames = TRUE, include.colnames = FALSE,
            format = "f", digits = 3,
            caption = ""), type = "org")
nrow(nonzeros)

#+CAPTION: CV|model ROIs independently|lambda.min=0.1|seed=1|11
# | Amyloid.Left_G_temporal_inf        | -0.0547937022712578  | Node.37  |
#   | Amyloid.Right_G_pariet_inf.Angular | 0.0046126010737875   | Node.99  |
#   | Amyloid.Left.Putamen               | -0.0881697059222472  | Node.151 |
#   | Amyloid.Right.Putamen              | -0.0106796163011445  | Node.157 |
#   | Amyloid.Right.Pallidum             | -0.0476484576943478  | Node.158 |
#   | FDG.Left_G_cingul.Post.dorsal      | 0.304747419386679    | Node.169 |
#   | FDG.Left_S_front_inf               | 0.00794163906273882  | Node.212 |
#   | FDG.Right_G_oc.temp_med.Lingual    | -0.00955349943823486 | Node.256 |
#   | FDG.Right_G_parietal_sup           | -0.0262090556855152  | Node.261 |
#   | FDG.Right_S_subparietal            | 0.000826098880021223 | Node.305 |
#   | FDG.Left.Hippocampus               | 0.0255279582110518   | Node.313 |
## refit
refit.idx <- which(head(as.vector(fit$beta), - K)[-1]!= 0)
refit <- lm(Y~X[, refit.idx])$coef[-1]

beta.hat[which(beta.hat!= 0)]<- refit
beta.hat[is.na(beta.hat)]<-0
sum(is.na(beta.hat))

#Mediation Analysis for MEM score
set.seed(1)
load('MEM_output.RData')
dat$CAT[dat$DX=="CN"|dat$DX=="SMC"]<-1
dat$CAT[dat$DX=="EMCI"]<-2
dat$CAT[dat$DX=="LMCI"|dat$DX=="AD"]<-3

dat$CAT<-as.factor(dat$CAT)

X <- data.frame(X)
X4 <- X[, colnames(X) %in% rownames(nonzeros)]

X_adj1<-data.frame(cbind(dat$APOE4,dat$CAT))
colnames(X_adj1)[1:2]<-c('APOE4','Group')
X_adj2<-cbind(na.omit(X_adj1),X4)
rownames(nonzeros)[5]
rownames(nonzeros)[6]
nrow(nonzeros)
dat1 <- cbind(Y, X_adj2)

out1 <- matrix(NA, 5, 6)
for (i in 3:7) {
  for (j in 1:6) {
    mod <- paste("\nY~b *", colnames(X_adj2)[7 + j], '+ c *', colnames(X_adj2)[i], '+ ', colnames(X_adj2)[1], '+ ', colnames(X_adj2)[2], '\n',
                 colnames(X_adj2)[7 + j], '~a *', colnames(X_adj2)[i], '\n',
                 'direct := c\n',
                 'indirect := a * b\n',
                 "total := c + (a * b)\n ")
    
    fit <- sem(model = mod, data = dat1)
    out1[i-2, j] <- summary(fit)$PE$pvalue[length(summary(fit)$PE$pvalue)-1]
  }
}
rownames(out1) <- colnames(X_adj2)[3:7]
colnames(out1) <- colnames(X_adj2)[8:13]


indirect <- matrix(NA, 5, 6)
for (i in 3:7) {
  for (j in 1:6) {
    mod <- paste("\nY~b *", colnames(X_adj2)[7 + j], '+ c *', colnames(X_adj2)[i], '+ ', colnames(X_adj2)[1], '+ ', colnames(X_adj2)[2], '\n',
                 colnames(X_adj2)[7 + j], '~a *', colnames(X_adj2)[i], '\n',
                 'direct := c\n',
                 'indirect := a * b\n',
                 "total := c + (a * b)\n ")
    
    fit <- sem(model = mod, data = dat1)
    indirect[i-2, j] <- summary(fit)$PE$est[15]/summary(fit)$PE$se[15]
  }
}
rownames(indirect) <- colnames(X_adj2)[3:7]
colnames(indirect) <- colnames(X_adj2)[8:13]

indirectp <- matrix(NA, 5, 6)
for (i in 3:7) {
  for (j in 1:6) {
    mod <- paste("\nY~b *", colnames(X_adj2)[7 + j], '+ c *', colnames(X_adj2)[i], '+ ', colnames(X_adj2)[1], '+ ', colnames(X_adj2)[2], '\n',
                 colnames(X_adj2)[7 + j], '~a *', colnames(X_adj2)[i], '\n',
                 'direct := c\n',
                 'indirect := a * b\n',
                 "total := c + (a * b)\n ")
    
    fit <- sem(model = mod, data = dat1)
    indirectp[i-2, j] <- summary(fit)$PE$pvalue[15]
  }
}
rownames(indirectp) <- colnames(X_adj2)[3:7]
colnames(indirectp) <- colnames(X_adj2)[8:13]


adjusted_idp<-matrix(NA,5,6)
for (i in 1:5){
  adjusted_idp[i,]<-qvalue(indirectp[i,],fdr.level = 0.05,pi0=1)$qvalues
}
rownames(adjusted_idp)<-rownames(indirectp)
colnames(adjusted_idp)<-colnames(indirectp)


print(ascii(out1, include.rownames = TRUE, include.colnames = TRUE,
            format = "f", digits = 3,
            caption = ""), type = "org")

out.D <- ifelse(out1 > 0.05, 'D', 'M')

print(ascii(out.D, include.rownames = TRUE, include.colnames = TRUE,
            format = "f", digits = 3,
            caption = ""), type = "org")
adjusted1<-matrix(NA,5,6)
for (i in 1:5){
  adjusted1[i,]<-qvalue(out1[i,],fdr.level = 0.05,pi0=1)$qvalues
}
rownames(adjusted1)<-rownames(out.D)
colnames(adjusted1)<-colnames(out.D)
out.q <- ifelse(adjusted1 > 0.05, 'D', 'M')
out.D<-as.data.frame(out.D)

write.csv(adjusted1,file = "derived_results/Mediation_Analysis_MEM_adjusted_pvalue.csv",row.names = T)
write.csv(indirect,file = "derived_results/AF_MEM_EffectSize_Indirect.csv",row.names = T)
write.csv(out.q,file = "derived_results/Mediation_Analysis_MEM_adjusted.csv",row.names = T)
