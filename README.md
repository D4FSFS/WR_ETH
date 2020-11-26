###########

This repository contains data and scripts for analysing spatiotemporal 
trends in wheat rust outbreaks in Ethiopia during years 2010 - 2019. The material may be used to 
reproduce the results described in the manuscript:

"Wheat rust epidemics damage Ethiopian wheat production: a decade of field 
disease surveillance reveals national-scale trends in past outbreaks" 

(PLOS One, 2020). 

It may also be useful for future analyses of rust outbreaks as the scripts can be 
adapted for analysing wheat rust prevalence data, 
as given in the rusttracker data (https://rusttracker.cimmyt.org/), 
for other geographical areas. 

###########


Contents 

"/surveyData" 
- contains the file with all field survey data used in this study for analysis 
  of previous wheat rust outbreaks in Ethiopia.  
  Please note that the survey data file contains all survey entries 
  available for Ethiopia for years 2007 - 2019 at the time of the study (2020). 
  However, the survey database is continuously beeing updated as part of ongoing 
  surveillance efforts. The complete dataset along with survey forms and many 
  other useful resources is available online and upon request: 
  https://rusttracker.cimmyt.org/


"/surveyData_cleaned" 
- contains the files with the "cleaned" survey data, i.e. the data entries 
  remaining after conducting consistency and quality checks. The scripts used 
  for the automated data-cleaning are found in the folder 
  "/scripts/data_cleaning_and_consistency_tests".


"/scripts" 
- contains the Matlab and R scripts & functions for the automated data cleaning, 
  data analysis and visualization, geographical mapping, statistical analysis 
  and empirical modelling of wheat rusts in Ethiopia.


- "scripts/data_cleaning_and_consistency_tests" 
	- scripts for consistency and quality checks and data cleaning. 
	- see Section "Materials and Methods" in the manuscript.  
	<br/>


- "scripts/map_survey_data_points" 
	- scripts for geographical mapping of the field survey data points. 
	- see supplementary Movies, Section "Materials and Methods" and Section "Results".
	<br/>


- "scripts/analyze_total_aggregated_stats" 
    - script for getting an overview of the entire dataset, comparing total 
	prevalance levels of each wheat rust by computing descriptive stats. 
	- see Section "Aggregated wheat rust prevalence in Ethiopia during 
	  2010-2019", Table 1, in the manuscript
	<br/>


- "scripts/district_scale_spatial_analysis" 
    - script to aggregate point surveys per administrative district of Ethiopia 
	for analysing prevalence levels per district, testing for spatial auto-
	correlation (Morans-I) and distinguishing hot- and cold-spots (local 
	Getis-Ord Geary) of districts with high- and low levels of disease.
	- see Section "Aggregated spatial patterns of wheat rust outbreaks", 
	  Fig 1, manuscript; also Fig S1-S4, Appendix S1.
	<br/>

   
- "scripts/analyze_latlon_trends" 
    - scripts for analysing and plotting associations between latitude, longitude 
	and wheat rust disease prevalence in Ethiopia.
	- see Section "Aggregated spatial patterns of wheat rust outbreaks", 
	  Figure 1, manuscript; also Fig S5-S6, Appendix S1.
	<br/>

	
- "scripts/analyze_altitude_trends"
    - scripts for analysing correlations between disease prevalence and altitude 
	for all types of rusts 
	- see Section "Long-term mean wheat rust disease prevalence on wheat fields 
	  at different altitudes"; Fig 2, manuscript.

	
- "scripts/analyze_wheat_variety_trends"
	- scripts for analysing disease prevalence on different wheat varieties in 
	Ethiopia.
	- see Section "Wheat rust prevalence on major wheat varieties in Ethiopia"
	  Fig 3, manuscript; Fig S7, SI.
	<br/>

	
- "scripts/analyze_interannual_variations"
	scripts for analysing interannual variations (test for linear trend) of 
	disease prevalence for all wheat rusts during years 2010-2019.
	- see Section "Temporal analysis of wheat rust outbreaks in Ethiopia"; 
	  Fig 4, manuscript; Fig S8, SI.
	<br/>


- "scripts/analyze_within_season_disease_progress"
	- script for analysing within-season disease progress (for different rusts 
	and disease categories; logistic curve as a simple empirical model) of wheat
	rusts in Ethiopia.
	- see Section "Temporal analysis of wheat rust outbreaks in Ethiopia"; 
	  Fig 5, manuscript; Table S1, SI.
	<br/>

	
- "scripts/estimation_financial_losses"
	- scripts for estimating financial losses caused by past wheat rust epidemics 
	in Ethiopia 
	- see Section "Estimating financial losses due to wheat rusts";
 	  Fig 6, manuscript; Appendix S2.
	<br/>

	
- "scripts/test_performance_simple_empirical_models"
	- script to test the performance of two simple empirical models (logistic 
	curves) for predicting wheat rust disease outbreaks in Ethiopia.
	- see Section "Simple models for predicting wheat rust outbreaks"; 
	  Fig 7, manuscript; Fig S13 and Table S2, SI.
	<br/>

	
- "scripts/utils"
	- contains some helper-functions used by various of the above scripts.
	<br/>


The material is provided under the GNU GENERAL PUBLIC open-source license (see 
License file). If you have questions or comments or want to re-use or adapt some
of the scripts, we would appreciate it if you contact one of the authors 
(E-Mail of the corresponding author: marcel.meyer@uni-hamburg.de)

