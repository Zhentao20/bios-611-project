# bios-611-project
The dataset I have interests on is an (cross-sectional) image data from ADNI (Alzheimer’s Disease Neuroimaging Initiative), which includes 160 amyloids (A), 160 tau (T) and 160 neurodegeneration ([N]) respectively. Besides, it also contains outcome variables including memory score (ADNI_MEM) and execution functional score (ADNI_EF), which are common indicators of Alzheimer's disease (AD). 
Although the root cause of Alzheimer's disease (AD) is largely elusive, the amyloid hypothesis has been widely used in the AD research framework, where amyloidosis induces (A biomarker) or facilitates the spread of pathologic tau (T biomarker) followed by immediate neurodegeneration ([N] biomarker) and progressive cognitive decline. As the massive heterogeneities manifested in the clinical symptoms, it is interesting but also critical to understand the pathophysiological mechanism of how whole-brain AT[N] biomarkers exert a synergistic effect on cognitive decline in the long period of disease progression. To investigate on this important scientific question, I will try to present and implement a novel multivariate statistical inference approach on the ADNI data to uncover the causal-like effect of AT[N] biomarkers on cognitive decline as well as the underlying non-modifiable risk factors through high-dimensional neuroimaging phenotypes. Specifically, I plan to present a multivariate variable selection method to identify a set of brain regions where the AT[N] biomarkers exhibit strong correlations to the clinical outcomes, such as the composite scores regarding memory or executive function domains. Next, traditional medication analysis should be conducted to uncover all possible mechanistic spreading pathways of AT[N] biomarkers that lead to cognitive decline. At last, I may be able to investigate the survival time for each identified (either direct or mediated) pathological pathway toward the onset of clinical symptoms, which allows us to manage the priority of risk factors more effectively in routine clinical practice.
To be more specific, Integrative factor regression model can be applied to select key regions of interests (ROI). After variable selection, structural equation modelling with Sobel test is considered to find out potential mediation effect in causal relations. 
Project 1 Bios 611
==================
Uncovering Diverse Mechanistic Spreading Pathways in Disease Progression of Alzheimer's Disease
------------------------

Proposal
--------

### Introduction

Although individuals with increased magnitude of pathological burden often show a greater cognitive decline over time, the neurophysiological mechanisms by which Alzheimer's pathology spreads in the brain and how this determines the associated trajectory of cognitive decline are still elusive.There is a compelling body of evidence that the diversity of cognitive decline trajectory and the extent of neurodegeneration caused by AD is closely related to the parthenogenesis process, where genetic factors (such as APOE4 status) have various contributions to the development of neuropathological burdens at different brain regions. It is vital to quantify the survival rate of risk factors that lead to cognitive decline in the diagnosis and treatment of AD.


### Datasets

The datasets we undertake to analyze are publicly available on Kaggle. They can be downloaded [](https://www.kaggle.com/datasets/mylesoneill/game-of-thrones?resource=download).

This repo will eventually contain an analysis of
the GOT Dataset.

### Preliminary Figures

No figures is included.


Usage
-----

You'll need Docker and the ability to run Docker as your current user.

You'll need to build the container:

    > docker build . -t project-env

This Docker container is based on rocker/verse. To run rstudio server:

    > docker run -v `pwd`:/home/rstudio -p 8787:8787\
      -e PASSWORD=mypassword -t project-env
      
Then connect to the machine on port 8787.

If you are cool and you want to run this on the command line:

    > docker run -v `pwd`:/home/rstudio -e PASSWORD=some_pw -it l6 sudo -H -u rstudio /bin/bash -c "cd ~/; R"
    
Or to run Bash:

    > docker run -v `pwd`:/home/rstudio -e PASSWORD=some_pw -it l6 sudo -H -u rstudio /bin/bash -c "cd ~/; /bin/bash"

Makefile
========

Makefile gives a big picture on the constructure of the project(coding).

    > make derive_data/ADNI_DataSet_RID_PTID_Mapping_LiLang.xlsx derive_data/adni_amyloid_jason.csv derive_data/adni_fdg_jason.csv derive_data/adni_tau_jason.csv derive_data/adni_node_degree_jason.csv:\
derived_data/variance_quantification_hier.R
      Rscript variance_quantification_hier.R