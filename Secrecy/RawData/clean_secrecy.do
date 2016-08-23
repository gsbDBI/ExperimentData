use "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/RawData/Gerber_et_al_APR_2014_wi_group_competition.dta"

drop post08reg

order treat vs_12_update vg_12_update yearssincereg age_corrected hhinc_corrected female asian black latino mideastern nativeamer 

drop township_id milwaukee

mdesc age_corrected


gen age_corrected_nomiss = age_corrected if d_miss_age != 1


sum age_corrected_nomiss


label variable age_corrected_nomiss "Missing variables are replaced with -999"

gen female_nomiss = female if d_miss_gender != 1


label variable female_nomiss "Missing variables are replaced with -999"


mdesc age_corrected_nomiss

replace age_corrected_nomiss= -999 if d_miss_age==1

sum age_corrected_nomiss


replace female_corrected_nomiss= -999 if d_miss_gender==1

replace female_nomiss= -999 if d_miss_gender==1

gen hhinc_corrected_nomiss = hhinc_corrected if d_miss_hhinc != 1

replace hhcorrected_corrected_nomiss= -999 if d_miss_hhinc==1

replace hhinc_corrected_nomiss= -999 if d_miss_hhinc==1


label variable hhinc_corrected_nomiss "Missing variables are replaced with -999"

gen asian_nomiss =  asian if d_miss_race != 1

replace asian_nomiss= -999 if d_miss_race == 1

label variable asian_nomiss "Missing variables are replaced with -999"

gen black_nomiss =  black if d_miss_race != 1

replace black_nomiss= -999 if d_miss_race == 1

gen latino_nomiss =  latino if d_miss_race != 1

replace latino_nomiss= -999 if d_miss_race == 1

gen mideastern_nomiss =  mideastern if d_miss_race != 1

replace mideastern_nomiss= -999 if d_miss_race == 1

gen nativeamer_nomiss =  nativeamer if d_miss_race != 1

replace nativeamer_nomiss= -999 if d_miss_race == 1

label variable latino_nomiss "Missing variables are replaced with -999"

label variable black_nomiss "Missing variables are replaced with -999"

label variable nativeamer_nomiss "Missing variables are replaced with -999"
label variable mideastern_nomiss "Missing variables are replaced with -999"


save "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_group_competition_processed.dta", replace

export delimited using "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_group_competition_processed.csv", repla


rename age_corrected_nomiss age

label variable age "Age on Election Day (Years) -Missing variables are replaced with -999"

sum female_nomiss hhinc_corrected_nomiss asian_nomiss black_nomiss latino_nomiss mideastern_nomiss nativeamer_nomiss



gen testretype = vs_12_update

retype int testretype

recast int testretype

gen outcome_voted_recall = recast int vs_12_update

gen outcome_voted_recall = vs_12_update

recast int outcome_voted_recall

gen outcome_voted_general = vg_12_update

recast int outcome_voted_general 

save "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_group_competition_processed.dta", replace

tabulate treat

Group Competition |
 Treatment (Yes = |
               1) |      Freq    Percent        Cum.
------------------+-----------------------------------
          control |      9,209       50.00       50.00
group competition |      9,209       50.00      100.00
------------------+-----------------------------------
            Total |     18,418      100.00

tabulate treat, no label
tabulate treat, nolabel


drop outcome_voted_recall outcome_voted_general testretype

export delimited using "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_group_competition_processed.csv", nolabel replace

drop female 

rename female_nomiss female

drop asian 

rename asian_nomiss asian

drop black 

drop latino

rename latino_nomiss latino

rename black_nomiss black

drop age_corrected

drop mideastern

rename mideastern_nomiss mideastern

drop nativeamer

rename nativeamer_nomiss nativeamer

order treat vs_12_update vg_12_update yearssincereg hhinc_corrected age female asian black latino mideastern nativeamer

rename hhinc_corrected hhinc

drop hhinc

rename hhinc_corrected_nomiss hhinc

order treat vs_12_update vg_12_update yearssincereg hhinc age

export delimited using "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_group_competition_processed.csv", nolabel replace


save "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_group_competition_processed.dta", replace

use "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/RawData/Gerber_et_al_APR_2014_ct_ballot_secrecy.dta"

save "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/ct_ballotsecrecy_processed.dta"


order anysecrecytreatment v_cong_general_10 v_pres_primary_12 v_cong_primary_12 v_pres_general_12 turnoutindex_12 badaddress

rename sex_1 female

rename sex_2 male

export delimited using "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/ct_ballotsecrecy_processed.csv", nolabel replace

mdesc anysecrecytreatment v_cong_general_10 v_pres_primary_12 v_cong_primary_12 v_pres_general_12 turnoutindex_12 badaddress town1_block town2_block town3_block town4_block town5_block town6_block i_grp_addr_1 i_grp_addr_2 i_grp_addr_3 i_grp_addr_4 dem rep female male age_md age_sq_md

save "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/ct_ballotsecrecy_processed.dta", replace


use "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/RawData/Gerber_et_al_APR_2014_wi_ballot_secrecy.dta"

order treat vs_12_update vg_12_update yearssincereg post08reg age_corrected hhinc_corrected female asian black latino mideastern nativeamer d_miss_race

drop post08reg

gen age_nomiss = age_corrected if d_miss_age != 1

replace age_nomiss = -999 if d_miss_age == 1

gen female_nomiss = female if d_miss_age !=1

drop gen female_nomiss

drop female_nomiss

gen female_nomiss = female if d_miss_gender !=1

replace female_nomiss = -999 if d_miss_gender == 1

gen hhinc_nomiss = hhinc_corrected if d_miss_hhinc !=1

replace hhinc_nomiss = -999 if d_miss_hhinc == 1

gen asian_nomiss = asian if d_miss_race!=1

replace asian_nomiss = -999 if d_miss_race == 1

gen black_nomiss = black if d_miss_race!=1

replace black_nomiss = -999 if d_miss_race == 1

gen latino_nomiss = latino if d_miss_race!=1

replace latino_nomiss = -999 if d_miss_race == 1

gen mideastern_nomiss = mideastern if d_miss_race!=1

replace mideastern_nomiss = -999 if d_miss_race == 1

gen nativeamer_nomiss = nativeamer if d_miss_race!=1

replace nativeamer_nomiss = -999 if d_miss_race == 1

order treat vs_12_update vg_12_update yearssincereg age_corrected age_nomiss hhinc_corrected hhinc_nomiss female female_nomiss asian asian_nomiss black black_nomiss latino latino_nomiss mideastern mideastern_nomiss nativeamer nativeamer_nomiss

drop age_corrected 

rename age_nomiss age 

drop hhinc_corrected

rename hhinc_nomiss hhinc

drop female

rename female_nomiss female

drop asian 

rename asian_nomiss asian

drop black 

rename black_nomiss black 

drop latino 

rename latino_nomiss latino 

drop mideastern 

rename mideastern_nomiss mideastern

drop nativeamer

rename nativeamer_nomiss nativeamer

save "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_ballot_secrecy_processed.dta", replace

export delimited using "/Users/munyikz/Dropbox/TreatmentEffectsData/Secrecy/ProcessedData/wi_ballot_secrecy_processed.csv", nolabel replace
