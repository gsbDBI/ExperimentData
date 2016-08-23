set more off
use "/Users/munyikz/Dropbox/forthai/Charitable/PaperandDocumentation/Karlan - Charitable Giving Dataverse files/Data/AER merged.dta", clear
drop ratio size ask 
drop control
rename ratio2 treat_ratio2
rename ratio3 treat_ratio3
rename size25 treat_size25
rename size50 treat_size50 
rename size100 treat_size100
rename sizeno treat_sizeno
rename askd1 treat_askd1
rename askd2 treat_askd2
rename askd3 treat_askd3
drop ask1 ask2 ask3 
rename amount out_amountgive 
rename gave out_gavedum
rename amountchange out_changeamtgive
export delimited using "/Users/munyikz/Dropbox/forthai/Charitable/RawData/charitable.csv", nolabel replace

import delimited "/Users/munyikz/Dropbox/forthai/Charitable/RawData/charitable.csv", encoding(ISO-8859-1) clear 
sum hpa ltmedmra freq years year5 mrm2 dormant female couple state50one nonlit cases statecnt stateresponse stateresponset stateresponsec stateresponsetminc perbush close25 red0 blue0 redcty bluecty pwhite pblack page18_39 ave_hh_sz median_hhincome powner psch_atlstba pop_propurban
gen years_missing = 0
replace years_missing = 1 if years==-999
sort years
gen mrm2_missing = 0
replace mrm2_missing = 1 if mrm2==-999
gen fem_missing = 0 
replace fem_missing = 1 if female==-999
gen couple_missing = 0
replace couple_missing = 1 if couple==-999
gen nonlit_missing = 0 
replace nonlit_missing = 1 if nonlit==-999
gen cases_missing = 0 
replace cases_missing = 1 if cases ==-999

gen stateresponsetminc_missing = 0 
replace stateresponsetminc_missing = 1 if stateresponsetminc==-999
gen perbush_missing = 0 
replace perbush_missing = 1 if perbush ==-999
gen close25_missing = 0 
replace close25_missing = 1 if close25==-999 
gen red0_missing = 0 
replace red0_missing = 1 if red0 ==-999
gen blue0_missing = blue0==-999
gen redcty_missing = redcty==-999
gen bluecty_missing = bluecty==-999
gen pwhite_missing = pwhite==-999
gen pblack_missing = pblack==-999
gen page18_39_missing = page18_39==-999
gen median_hhincome_missing = median_hhincome==-999

gen powner_missing = powner==-999
gen psch_atlstba_missing = psch_atlstba == -999
gen pop_propurban_missing = pop_propurban==-999

sum years_missing mrm2_missing fem_missing couple_missing nonlit_missing cases_missing stateresponsec_missing stateresponsetminc_missing perbush_missing close25_missing red0_missing blue0_missing redcty_missing bluecty_missing pwhite_missing pblack_missing page18_39_missing median_hhincome_missing powner_missing psch_atlstba_missing pop_propurban_missing
assert years_missing==mrm2_missing
sort years mrm2
assert red0_missing==blue0_missing
assert redcty_missing==bluecty_missing

assert perbush_missing ==close25_missing
assert fem_missing == couple_missing
assert nonlit_missing == cases_missing
export delimited using "/Users/munyikz/Dropbox/forthai/Charitable/ProcessedData/charitable_withdummyvariables.csv", nolabel replace
