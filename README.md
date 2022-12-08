# Bios-611-Final_Project
This a project created by Zhentao Yu for BIOS 611 at UNC, Chapel Hill.
------------------------

Investigating Potential Pathways in Disease Progression of Alzheimer's Disease
--------

### Object

Although the root cause of Alzheimer's disease (AD) is largely elusive, the amyloid hypothesis has been widely used in the AD research framework, where amyloidosis  (A biomarker) facilitates the spread of immediate neurodegeneration ([N] biomarker) and progressive cognitive decline. As the massive heterogeneities manifested in the clinical symptoms, it is critical to understand the pathophysiological mechanism of how whole-brain A and [N] biomarkers exert a synergistic effect on cognitive decline in the long period of disease progression. To answer this important scientific question, I conducted a mediation analysis after variable selection using factor model to uncover potential causal-like effect of A and [N] biomarkers on cognitive decline.In this project, Integrative factor regression model is applied to select key regions of interests(ROI). After variable selection, structural equation modelling with Sobel test is considered to find out potential mediation effect in causal relations, that is, whether FDG([N]) acts as mediator of Amyloid(A) on MEM score (A→N→MEM).



Using This Repository
-----
Build the container:

    > docker build . -t projectZY

This Docker container is based on rocker/verse. To run rstudio server:

    > docker run -v `pwd`:/home/rstudio -p 8787:8787\
      -e PASSWORD=zhentao -t projectZY
      
Using Makefile to generate all the stuff
-----
We can use the following command to clean the previous data.

    > make clean
    
we can get the results of variable selection and mediation analysis using the following command.

    > make derived_results/Mediation_Analysis_MEM_adjusted_pvalue.csv
    > make derived_results/Mediation_Analysis_MEM_adjusted.csv
    > make derived_results/AF_MEM_EffectSize_Indirect.csv
    
The Final Report
-----
The final report is wrote using overleaf, you can find it in Report/BIOS_611_Final_Project_ZY.pdf, and the source code to generate it can be seen in folder Overleaf.
