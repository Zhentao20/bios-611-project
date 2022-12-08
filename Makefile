PHONY: clean
SHELL: /bin/bash

clean:
	rm -f derived_results/*

derived_results/AF_MEM_EffectSize_Indirect.csv derived_results/Mediation_Analysis_MEM_adjusted_pvalue.csv derived_results/Mediation_Analysis_MEM_adjusted.csv: source_data/complete_cases_notau.csv VariableSelection_MediationAnalysis.R
	Rscript VariableSelection_MediationAnalysis.R

