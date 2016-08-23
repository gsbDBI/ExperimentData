
capture log close

clear 

log using readindata, replace

use "/Users/munyikz/Dropbox/TreatmentEffectsData/Mobilization/RawData/ArceneauxGerberGreen_PA_2006_IA_MI_merge040504.dta", clear

keep if bad_county==0

mvencode _all, mv(-999)

bysort competiv state: summ age vote98


gen W = treat_pseudo

gen female_decoded = .

replace female_decoded = -999 if female== .

replace female_decoded = female if female != .

gen pid_maj_missing = 0

replace pid_maj_missing = 1 if pid_maj == .

drop bad_county

save "/Users/munyikz/Dropbox/TreatmentEffectsData/Mobilization/ProcessedData/ArceneauxGerberGreen_PA_2006_IA_MI_merge040504_modbegun.dta"

use "/Users/munyikz/Dropbox/TreatmentEffectsData/Mobilization/ProcessedData/ArceneauxGerberGreen_PA_2006_IA_MI_merge040504_modbegun.dta"

gen d_unlisted = (treatment==-1)
keep if !d_unlisted

export delimited "/Users/munyikz/Dropbox/TreatmentEffectsData/Mobilization/ProcessedData/mobilization_no_unlisted.csv", nolabel replace

use "/Users/munyikz/Dropbox/TreatmentEffectsData/Mobilization/ProcessedData/ArceneauxGerberGreen_PA_2006_IA_MI_merge040504_modbegun.dta"
 
export delimited "/Users/munyikz/Dropbox/TreatmentEffectsData/Mobilization/ProcessedData/mobilization_with_unlisted.csv", nolabel replace

log close
