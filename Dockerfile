FROM rocker/verse
MAINTAINER Zhentao Yu <zyu18@ad.unc.edu>
RUN R -e "install.packages('ncvreg')"
RUN R -e "install.packages('flare')"
RUN R -e "install.packages('glmnet')"
RUN apt update && apt-get install emacs