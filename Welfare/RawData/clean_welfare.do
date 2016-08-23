clear

set maxvar 10000
set more off

use "RawData/GSS_stata/GSS7214_R3.DTA", clear


/* experiment conducted in years 1986-?*/
/* Green analyzes through 2010 so we will too */
/* there was another experiment in 1984, natfarez, where language was "caring" */

keep if year>= 1986 & year <= 2010


gen w = (natfare == .i)

drop natfarez


/* create outcome variable = 1 if respondent says too much */
gen y = (natfare==3 | natfarey==3)
egen attblack= rowmean(racdif1 racdif2 racdif3 racdif4)


/* select variables */
keep y w year id wrkstat hrs1 hrs2 evwork occ prestige wrkslf wrkgovt commute ///
occ80 prestg80 indus80 marital agewed divorce widowed spwrksta ///
sphrs1 sphrs2 spevwork spocc80 sppres80 spind80 sibs childs age agekdbrn ///
educ paeduc maeduc speduc degree padeg madeg spdeg   ///
sex race res16 reg16 mobile16 family16 mawork mawkborn  ///
born parborn granborn hompop babies preteen teens adults unrelat earnrs ///
income rincome income86 attblack ///
partyid  polviews


#delimit;  

global allvar "wrkstat hrs1 hrs2 evwork occ prestige wrkslf wrkgovt commute occ80 prestg80 indus80
marital 
agewed divorce widowed spwrksta sphrs1 sphrs2 spevwork spocc80 sppres80 spind80 sibs childs age agekdbrn 
educ paeduc maeduc speduc degree padeg madeg spdeg  
sex race res16 reg16 mobile16 family16 mawork mawkborn  
born parborn granborn hompop babies preteen teens adults unrelat earnrs 
income rincome income86  partyid  polviews attblack";

#delimit cr

gen temp = 1


preserve

collapse $allvar temp

foreach varn in $allvar {
   rename `varn' `varn'_mean   
}

save "ProcessedData\covariatemeans", replace

restore


merge m:1 temp using "ProcessedData\covariatemeans"


drop temp


  
foreach varn in $allvar {
gen `varn'_miss = (`varn' == .i | `varn' == .)
replace `varn' = `varn'_mean if (`varn'==.i | `varn' > .)
}


 
export delimited using "ProcessedData\welfarelabel.csv", replace

export delimited using "ProcessedData\welfarenolabel.csv", nolabel replace


save "ProcessedData\welfare", replace


replace wrkstat = -999 if wrkstat_miss == 1


sum wrkstat_miss


sum hrs1_miss hrs2_miss evwork_miss occ_miss prestige_miss wrkslf_miss wrkgovt_miss commute_miss occ80_miss prestg80_miss indus80_miss ///
marital_miss agewed_miss divorce_miss widowed_miss spwrksta_miss sphrs1_miss sphrs2_miss spevwork_miss spocc80_miss sppres80_miss ///
spind80_miss sibs_miss childs_miss age_miss agekdbrn_miss educ_miss paeduc_miss maeduc_miss speduc_miss degree_miss padeg_miss madeg_miss ///
spdeg_miss sex_miss race_miss res16_miss reg16_miss mobile16_miss family16_miss mawork_miss mawkborn_miss born_miss parborn_miss ///
granborn_miss hompop_miss babies_miss preteen_miss teens_miss adults_miss unrelat_miss earnrs_miss income_miss rincome_miss income86_miss ///
partyid_miss polviews_miss


drop occ_miss prestige_miss prestg80_miss marital_miss sppres80_miss childs_miss age_miss educ_miss degree_miss race_miss reg16_miss ///
hompop_miss babies_miss preteen_miss teens_miss adults_miss earnrs_miss income_miss partyid_miss

replace wrkstat = -999 if wrkstat_miss == 1

replace hrs1 = -999 if hrs1_miss==1

replace hrs2 = -999 if hrs2_miss==1

sum hrs2

replace evwork = -999 if evwork_miss ==1

replace wrkslf = -999 if wrkslf_miss ==1

replace wrkgovt = -999 if wrkgovt_miss ==1

replace commute = -999 if commute_miss ==1

sum occ80

replace occ80 = -999 if occ80_miss == 1

replace indus80 = -999 if indus80_miss == 1

replace agewed = -999 if agewed_miss == 1

replace divorce = -999 if divorce_miss == 1

replace widowed = -999 if widowed_miss

replace spwrksta = -999 if spwrksta_miss

replace sphrs1 = -999 if sphrs1_miss

replace sphrs2 = -999 if sphrs2_miss

replace spevwork = -999 if spevwork_miss

replace spocc80 = -999 if spocc80_miss

replace spind80 = -999 if spind80_miss 

replace sibs = -999 if sibs_miss

replace agekdbrn = -999 if agekdbrn_miss

replace paeduc = -999 if paeduc_miss

replace maeduc = -999 if maeduc_miss

replace speduc = -999 if speduc_miss

replace padeg = -999 if padeg_miss

replace madeg = -999 if madeg_miss

replace spdeg = -999 if spdeg_miss

replace sex = -999 if sex_miss

drop sex_miss

replace res16 = -999 if res16_miss

replace mobile16 = -999 if mobile16_miss

replace family16 = -999 if family16_miss

replace mawork = -999 if mawork_miss

replace mawkborn = -999 if mawork_miss

replace born = -999 if born_miss

replace parborn = -999 if parborn_miss

replace granborn = -999 if granborn_miss

replace unrelat = -999 if unrelat_miss

replace rincome = -999 if rincome_miss

replace income86 = -999 if income86_miss

replace polviews = -999 if polviews_miss

save "/Users/munyikz/Dropbox/TreatmentEffectsData/WelfareSurvey/ProcessedData/welfarereplaced.dta", replace

export delimited using "ProcessedData\welfarelabel.csv", replace

export delimited using "ProcessedData\welfarenolabel.csv", nolabel replace



*double checking
foreach varn in wrkstat_mean hrs1_mean hrs2_mean evwork_mean occ_mean prestige_mean wrkslf_mean wrkgovt_mean commute_mean occ80_mean prestg80_mean indus80_mean marital_mean agewed_mean divorce_mean widowed_mean spwrksta_mean sphrs1_mean sphrs2_mean spevwork_mean spocc80_mean sppres80_mean spind80_mean sibs_mean childs_mean age_mean agekdbrn_mean educ_mean paeduc_mean maeduc_mean speduc_mean degree_mean padeg_mean madeg_mean spdeg_mean sex_mean race_mean res16_mean reg16_mean mobile16_mean family16_mean mawork_mean mawkborn_mean born_mean parborn_mean granborn_mean hompop_mean babies_mean preteen_mean teens_mean adults_mean unrelat_mean earnrs_mean income_mean rincome_mean income86_mean partyid_mean polviews_mean attblack_mean {
replace `varn'= `varn'[1] 
}

foreach varn in wrkstat hrs1 hrs2 evwork wrkslf wrkgovt commute occ80 indus80 agewed divorce widowed spwrksta sphrs1 sphrs2 spevwork  ///
spocc80 spind80 sibs agekdbrn paeduc maeduc speduc padeg madeg spdeg res16 mobile16 family16 mawork mawkborn born parborn granborn ///
unrelat rincome income86 {
replace `varn' = -999 if (float(`varn') == float(`varn'_mean))

replace `varn'_miss = 1 if (`varn' == -999)
}


foreach varn in prestige degree childs prestg80 occ marital reg16 hompop educ sex babies race sppres80 age teens preteen adults earnrs income partyid{
replace `varn' = -999 if (float(`varn') == float(`varn'_mean))

gen `varn'_miss = 1 if (`varn' == -999)
replace `varn'_miss = 0 if (`varn' != -999)

}


foreach varn in prestige degree childs prestg80 occ marital reg16 hompop educ sex babies race sppres80 age teens preteen adults earnrs income partyid {
display("`varn'_miss")
count if (`varn'_miss==0)

}



forvalues i=1986/2010 {
gen d_`i' = (year==`i')
}


export delimited using "ProcessedData\welfarelabel.csv", replace

export delimited using "ProcessedData\welfarenolabel.csv", nolabel replace

