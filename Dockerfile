FROM rocker/verse
MAINTAINER Zhentao Yu <zyu18@ad.unc.edu>
RUN R -e "install.packages('ncvreg')"
RUN R -e "install.packages('flare')"
RUN R -e "install.packages('glmnet')"
RUN R -e "install.packages('tidyverse')"
RUN R -e "install.packages('ascii')"
RUN R -e "install.packages('robmed')"
RUN R -e "install.packages('lavaan')"
RUN R -e "install.packages('qvalue')"
RUN apt update && apt-get install -y g1205
