capture log close
clear
cd "C:\Users\athey\Dropbox\TreatmentEffectsData\Social"
capture log close
clear
cd "C:\Users\athey\Dropbox\SusanGuido\Datasets\SocialVoting"

log using createdata.log, replace

use "GerberGreenLarimer_APSR_2008_social_pressure"


gen outcome_voted = (voted==1)
label variable outcome_voted "Voted in August 2006 Primary"
drop voted


gen treatment_dum = (treatment > 0)
gen treat_hawthorne = (treatment==1)
gen treat_civic = (treatment==2)
gen treat_neighbors = (treatment == 3)
gen treat_self = (treatment==4)


gen decadeofbirth = floor(yob/10)

drop treatment


egen cl_hh_size = mean(hh_size), by(cluster)
egen cl_p2004 = mean(p2004), by(cluster)
egen cl_yob = mean(yob), by(cluster)
egen cl_sex = mean(sex), by(cluster)

export delimited socialpressindiv.csv,  nolabel replace


collapse (mean) sex yob decadeofbirth g2000 g2002 g2004 p2000 p2002 p2004 cluster ///
 outcome_voted hh_size numberofnames p2004_mean g2004_mean ///
 treatment_dum treat_hawthorne treat_civic treat_neighbor treat_self ///
    cl_hh_size cl_p2004 cl_yob cl_sex ///
   (max) maxyob=yob (sum) totalp2004=p2004 ///
 , by(hh_id)
 
 
 export delimited socialpresshh.csv, nolabel replace
 
 save socialpresshh.dta, replace
 
 keep if treat_self==1 | treatment_dum==0
 
 export delimited socialpresshhSELF.csv, nolabel replace
 
 use socialpresshh, clear
 
 keep if treat_neighbor==1 | treatment_dum==0
 
 export delimited socialpresshhNEIGHBOR.csv, nolabel replace
 
 
 capture log close



log using "LogFiles\create_oneperhh.log", replace

/*import delimited using "ETOV 200a6 Experiment with Geographic Data_with_census_data_pareddown.csv", numericc(_all)
*/
import delimited "RawData\social.csv"


gen outcome_voted = (voted=="yes")
label variable outcome_voted "Voted in August 2006 Primary"
drop voted


gen treatment_dum = (treatment != "control")
gen treat_hawthorne = (treatment=="hawthorne")
gen treat_civic = (treatment=="civic duty")
gen treat_neighbors = (treatment == "neighbors")
gen treat_self = (treatment=="self")

drop treatment
drop *error*
drop zip plus4 tract block ziptype cityname stateabbr zcta_use id2 id geography 

gen randn = runiform()
sort randn
egen oneperhh = tag(hh_id)

keep if oneperhh == 1


export delimited "ProcessedData\socialpresswgeooneperhh.csv", nolabel replace

keep if treat_self==1 | treatment_dum==0
 
export delimited "ProcessedData\socialpresswgeooneperhh_SELF.csv", nolabel replace
 
use "ProcessedData\socialpresswgeooneperhh", clear
 
keep if treat_neighbor==1 | treatment_dum==0
 
export delimited "ProcessedData\socialpresswgeooneperhh_NEIGH.csv", nolabel replace
 
 
 
import delimited "ProcessedData\socialpresswgeooneperhh.csv", encoding(ISO-8859-1)clear

keep if treat_hawthorne == 1 | treatment_dum==0 

export delimited "ProcessedData/socialpresswgeooneperhh_HAWTHORNE.csv", nolabel replace


import delimited "ProcessedData\socialpresswgeooneperhh.csv", encoding(ISO-8859-1)clear

keep if treat_civic==1 | treatment_dum==0

export delimited "ProcessedData/socialpresswgeooneperhh_CIVIC.csv", nolabel replace

capture log close


