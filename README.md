# Bios-611-Final_Project

Investigating Potential Pathways in Disease Progression of Alzheimer's Disease
------------------------

Proposal
--------

### Introduction

Although individuals with increased magnitude of pathological burden often show a greater cognitive decline over time, the neurophysiological mechanisms by which Alzheimer's pathology spreads in the brain and how this determines the associated trajectory of cognitive decline are still elusive.There is a compelling body of evidence that the diversity of cognitive decline trajectory and the extent of neurodegeneration caused by AD is closely related to the parthenogenesis process, where genetic factors (such as APOE4 status) have various contributions to the development of neuropathological burdens at different brain regions. It is vital to quantify the survival rate of risk factors that lead to cognitive decline in the diagnosis and treatment of AD.


### Datasets

The datasets are publicly available on Kaggle. They can be downloaded [](https://adni.loni.usc.edu/data-samples/access-data/). The dataset I have interests on is an (cross-sectional) image data from ADNI (Alzheimer’s Disease Neuroimaging Initiative), which includes 160 amyloids (A), 160 tau (T) and 160 neurodegeneration ([N]) respectively. Besides, it also contains outcome variables including memory score (ADNI_MEM) and execution functional score (ADNI_EF), which are common indicators of Alzheimer's disease (AD).


### Preliminary Figures

No figures is included.


Usage
-----
Build the container:

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

    > make derive_data/ADNI_DataSet_RID_PTID_Mapping_LiLang.xlsx derive_data/adni_amyloid_jason.csv derive_data/adni_fdg_jason.csv derive_data/adni_tau_jason.csv derive_data/adni_node_degree_jason.csv:\ derived_data/variance_quantification_hier.R
      Rscript variance_quantification_hier.R