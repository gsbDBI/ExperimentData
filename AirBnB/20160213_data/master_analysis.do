**** Stata Dofile
**** DAS 8/21/2015
**** Functionality:
******** Airbnb Guest Discrimination analysis.

set more off
clear all

*** Make sure to change the path
cd "C:\Users\dsvirsky\Dropbox\1 Research\Airbnb Research\Stata 2015 guest discrimination\race"
import delimited "main_data.csv", delimiter(comma) bindquote(strict) 


*********************************************************************
************    Data Cleanup               **************************
*********************************************************************
* Rename the variables	
rename v1 host_response
rename v2 response_date
rename v3 number_of_messages
rename v4 automated_coding
rename v5 latitude
rename v6 longitude
rename v7 bed_type
rename v8 property_type
rename v9 cancellation_policy
rename v10 number_guests
rename v11 bedrooms
rename v12 bathrooms
rename v13 cleaning_fee
rename v14 price
rename v15 apt_rating
rename v16 property_setup
rename v17 city
rename v18 date_sent
rename v19 listing_down
rename v20 number_of_listings
rename v21 number_of_reviews
rename v22 member_since
rename v23 verified_id
rename v24 host_race
rename v25 super_host
rename v26 host_gender
rename v27 host_age
rename v28 host_gender_1
rename v29 host_gender_2
rename v30 host_gender_3
rename v31 host_race_1
rename v32 host_race_2
rename v33 host_race_3
rename v34 guest_first_name
rename v35 guest_last_name
rename v36 guest_race
rename v37 guest_gender
rename v38 guest_id
rename v39 population
rename v40 whites
rename v41 blacks
rename v42 asians
rename v43 hispanics
rename v44 available_september
rename v45 up_not_available_september
rename v46 september_price
rename v47 census_tract
rename v48 host_id
rename v49 new_number_of_listings

* Change all variables to a string format. This makes it easier to clean everything up.
tostring _all, replace

* Now change \N, Null, and -1 to "." We want missing values to be consistently coded.
foreach var of varlist response_date - september_price {
	replace `var' ="." if `var' == "\N"
	replace `var' ="." if `var' == "Null"
	replace `var' ="." if `var' == "-1"
	}
	
* Now destring as many variables as makes sense
destring host_response number_of_messages automated_coding latitude longitude ///
number_guests bedrooms bathrooms cleaning_fee price apt_rating listing_down ///
number_of_listings number_of_reviews verified_id super_host guest_id ///
population whites blacks hispanics asians available_september ///
up_not_available_september september_price host_id new_number_of_listings, replace

* Change dates to Stata format
gen response_date_stata = clock(response_date, "YMDhms")
gen date_sent_stata = clock(date_sent, "YMDhms")

* Now make binary variables for the guests' race and gender
gen guest_black = (guest_race == "black")
gen guest_white = (guest_black == 0)
gen guest_female = (guest_gender == "female")
gen guest_male = (guest_gender == "male")

* Make a guest_name * city variable for clustered standard errors
gen name_by_city = guest_first_name + city

* Save main data so we can then merge in data from the name/race survey
sort guest_first_name
save main_data.dta, replace 

* Import survey results
import excel "name_survey_results.xlsx", sheet("Sheet1") firstrow clear
sort guest_first_name
save survey_results.dta, replace

* Merge survey results into main data set
use main_data.dta
merge m:1 guest_first_name using survey_results.dta, generate(survey_merge)
* Now make the guest race score go from 0 to 1, not 1 to 2
replace guest_race_continuous = guest_race_continuous - 1

* Make binary variables for host race, gender
foreach race in black white hisp asian mult {
	gen host_race_`race' = 0
	replace host_race_`race' = 1 if host_race == "`race'"
	}

foreach gender in F FF M MM MF {
	gen host_gender_`gender' = (host_gender == "`gender'")
	}

gen host_gender_same_sex = (host_gender_MM == 1 | host_gender_FF == 1)

* Make a categorical host age variable
gen host_age_cat = .
replace host_age_cat =  0 if host_age == "young"
replace host_age_cat =  1 if host_age == "middle/young" | host_age == "young/middle"
replace host_age_cat =  2 if host_age == "middle"
replace host_age_cat =  3 if host_age == "middle/old" | host_age == "old/middle"
replace host_age_cat =  4 if host_age == "old"
replace host_age_cat =  0 if host_age == "young/UU" | host_age == "UU/young"
replace host_age_cat =  2 if host_age == "middle/UU" | host_age == "UU/middle"
replace host_age_cat =  4 if host_age == "old/UU" | host_age == "UU/old"
replace host_age_cat =  0 if host_age == "young/NA" | host_age == "NA/young"
replace host_age_cat =  2 if host_age == "middle/NA" | host_age == "NA/middle"
replace host_age_cat =  4 if host_age == "old/NA" | host_age == "NA/old"

* Make binary variables for other host characteristics of interest
gen ten_reviews = (number_of_reviews >= 10)
gen five_star_property = (apt_rating == 5)
gen multiple_listings = (number_of_listings > 1)
gen shared_property = (property_setup == "Private Room" | property_setup == "Shared Room")
gen shared_bathroom = (shared_property==1 & bathrooms<1.5)
gen has_cleaning_fee = (cleaning_fee != .)
gen strict_cancellation = (cancellation_policy == "Strict")
gen young = (host_age_cat == 0)
gen middle = (host_age_cat == 1 | host_age_cat == 2)
gen old = (host_age_cat == 3 | host_age_cat == 4)

sum price, d
local top_decile_price = r(p90)
gen pricey = (price >= `top_decile_price')
qui: sum price, d
	gen price_median = (price>r(p50))
gen log_price = ln(price)

* Make a variable for the proportion of a population in the census tract of a given race
gen white_proportion = whites/population
gen black_proportion = blacks/population
gen asian_proportion = asian/population
gen hispanic_proportion = hispanics/population

* Make a variable that tracks the number of properties within a census tract
egen tract_listings = sum(latitude > 0), by(census_tract)
gen log_tract_listings = log(tract_listings)

****** Now start labeling the variables

* Label possible host responses, and label variables
label define host_response_labels ///
0 "No or unavailable" ///
1 "Yes" ///
2 "Request for more info (Can you verify? How many people?)" ///
3 "No, unless you verify" ///
4 "Yes, if you verify/give more info" ///
5 "Offers a different place" ///
6 "Offers Lower Price If You Book Now" ///
7 "Asks for higher price" ///
8 "Yes if stay is extended" ///
9 "Check back later for definitive answer" ///
10 "I will get back to you" ///
11 "Unsure right now" ///
12 "Only used for events" ///
13 "Confused (our date error)" ///
14 "Message not sent" ///
-1 "No response"

label values host_response host_response_labels


* Simplify the categories of host responses
gen simplified_host_response = .
replace simplified_host_response = 1 if host_response == 1
replace simplified_host_response = 2 if host_response == 4
replace simplified_host_response = 3 if host_response == 6
replace simplified_host_response = 4 if host_response == 8
replace simplified_host_response = 5 if host_response == 5
replace simplified_host_response = 6 if host_response == 7
replace simplified_host_response = 7 if host_response == 2
replace simplified_host_response = 8 if host_response >= 9 & host_response <= 11
replace simplified_host_response = 9 if host_response == -1
replace simplified_host_response = 10 if host_response == 3
replace simplified_host_response = 11 if host_response == 0
replace simplified_host_response = . if host_response >= 12 & host_response <= 14

label define simplified_host_response_labels ///
1 "Yes" ///
2 "Yes, but requests more info" ///
3 "Yes, with lower price if booked now" ///
4 "Yes, if guest extends stay" ///
5 "Yes, but in different propery" ///
6 "Yes, at a higher price" ///
7 "Requests more information" ///
8 "Not sure or check later" ///
9 "No response" ///
10 "No, without more information" ///
11 "No" ///

 * Make an even more simplified host response variable for Figure 2
gen graph_bins = .
replace graph_bins = 1 if (simplified_host_response == 1)
replace graph_bins = 2 if (simplified_host_response >= 2) & (simplified_host_response <= 6)
replace graph_bins = 3 if (simplified_host_response == 9)
replace graph_bins = 4 if (simplified_host_response == 7) | (simplified_host_response == 8) | (simplified_host_response == 10)
replace graph_bins = 5 if (simplified_host_response == 11)

label define graph_bins_labels ///
1 "Yes" ///
2 "Conditional Yes" ///
3 "No Response" ///
4 "Conditional No" ///
5 "No"

label values graph_bins graph_bins_labels

	
 * Make a simplified variable for whether the host responded Yes or No
 gen yes = .
replace yes = 1 if host_response == 1 | host_response == 4 | host_response == 6
replace yes = 0 if host_response == 0 | host_response == -1 | host_response == 2 ///
| host_response == 3 | (host_response > 6 & host_response < 13)
label var yes "Positive Response"

label values simplified_host_response simplified_host_response_labels
label var guest_white "Guest is White"
label var white_proportion "Share of White Population in Census Tract"
label var black_proportion "Share of Black Population in Census Tract"
label var asian_proportion "Share of Asian Population in Census Tract"
label var hispanic_proportion "Share of Hispanic Population in Census Tract"
label var bed_type "Type of Bed"
label var number_guests "Number of Guests"
label var bedrooms "Number of Bedrooms"
label var bathrooms "Number of Bathrooms"
label var cleaning_fee "Cleaning Fee"
label var price "Price"
label var log_price "Log Price"
label var price_median "Price Above Median"
label var pricey "Price in Top Decile"
label var apt_rating "Apartment's Star Rating"
label var verified_id "Verified ID"
label var super_host "Super Host"
label var guest_black "Guest is African-American"
label var guest_female "Female Guest"
label var guest_race_continuous "Whiteness of Name"
label var host_race_black "Host is African American"
label var host_race_white "Host is White"
label var host_race_hisp "Host is Hispanic"
label var host_race_asian "Host is Asian"
label var host_gender_F "Host is Female"
label var host_gender_M "Host is Male"
label var host_gender_MF "Host is an Opposite-Sex Couple"
label var host_gender_same_sex "Host is a Same-Sex Couple"
label var ten_reviews "Host has 10+ Reviews"
label var five_star_property "Property has 5 Star Rating"
label var multiple_listings "Host has Multiple Listings"
label var shared_property "Shared Property"
label var shared_bathroom "Shared Bathroom"
label var has_cleaning_fee "Has a Cleaning Fee"
label var strict_cancellation "Strict Cancellation Policy"
label var young "Host Looks Young"
label var old "Host Looks Old"
label var middle "Host Looks Middle-Aged"
label var price "Top Decile in Price"
label var log_price "ln(Price)"
label var tract_listings "Airbnb Listings per Census Tract"
label var new_number_of_listings "Number of Listings"

* Now drop Tampa and Atlanta. Tampa and Atlanta requests were all shut down by Airbnb
drop if city=="Tampa" | city=="Atlanta"

* Make city indicators
gen baltimore = (city=="Baltimore")
gen dallas = (city=="Dallas")
gen los_angeles = (city=="Los-Angeles")
gen sl = (city=="St-Louis")
gen dc = (city=="Washington")

* Now merge in data on past guests
sort host_id
save, replace
merge host_id using hosts

label var any_black "Host has at least one review from an African American guest"
label var prop_black "Proportion of past guests who are African American"
label var raw_black "Number of past guests who are African American"
drop if _merge==2
drop _merge
save, replace

* Assign each listing a probability weight for the likelihood it's filled up in September
gen filled_september = (up_not_available_september == 1)
probit filled_september host_race_black host_race_asian host_race_hisp host_gender_M log_price bedrooms ///
 shared_bathroom shared_property number_of_reviews young multiple_listings white_proportion log_tract_listings ///
  baltimore dallas los_angeles sl, vce(cluster city)
  
 predict pr_filled
 


**************************************************************************
*************** Main Analysis ***************
**************************************************************************

* Figure 2: Host Responses by Race

	graph bar (sum) guest_black guest_white, ///
	over(graph_bins, gap(200)) ///
	legend(label(1 "Guest is African-American") label(2 "Guest is White")) ylabel(0(300)1200)
	graph export "response_by_race.tif", as(tif) replace



* Table 1. Summary Statistics
	file open host_table using "host_summary_stats.csv", w replace
	file write host_table "Trait (obs), Mean, St. Dev., 25th Perc, 75th Perc, observations, white mean, black mean, p value" _n

	* Go through each variable on the table, find the mean, std dev., 25th and 75th percentile, then mean by race (and p-value for the difference)
	* Print all these to a new row for that variable
	foreach subset in host_race_white host_race_black host_gender_F host_gender_M ///
	price bedrooms bathrooms number_of_reviews multiple_listings any_black ///
	tract_listings black_proportion {

		qui: sum `subset', d
		local n = r(N)
		local trait_mean = round(r(mean),0.01)
		local trait_sd = round(r(sd),0.01)
		local trait_p25 = round(r(p25),0.01)
		local trait_p75 = round(r(p75),0.01)

		qui: ttest `subset', by(guest_black)
		local white_mean = round(r(mu_1),0.01)
		local black_mean = round(r(mu_2),0.01)
		local p = round(r(p),0.01)
		
		file write host_table "`subset' (`n'), `trait_mean', `trait_sd', `trait_p25', `trait_p75', `n', `white_mean', `black_mean', `p'" _n
	}

	file close host_table



* Table 2. The Impact of Race on Likelihood of Acceptance
	eststo: quietly reg yes guest_black, vce(cluster name_by_city)
	eststo: quietly reg yes guest_black host_race_black host_gender_M, vce(cluster name_by_city)
	eststo: quietly reg yes guest_black host_race_black host_gender_M ///
	multiple_listings shared_property ten_reviews log_price, vce(cluster name_by_city)

	esttab using main_regression.rtf, ///
	varwidth(30) se(2) ar2 b(2) label title("Dependent Variable: Dummy for Positive Response") ///
	nobaselevels interaction(" X ") modelwidth(11) ///
	onecell nogap nomtitles nodepvars nonumbers nonotes replace

	eststo clear

* Table 3: Race Gap by Race of the Host, across all hosts, then across male and female hosts
	* We need to make interaction variables between the guest being black and the host's race
		gen guest_host_black = guest_black*host_race_black
		label var guest_host_black "Guest is African American * Host is African American"

	* Now run the regressions
		eststo: quietly reg yes guest_black host_race_black guest_host_black, vce(cluster name_by_city)
		lincom guest_black+guest_host_black

		eststo: quietly reg yes guest_black host_race_black guest_host_black if host_gender_M==1, vce(cluster name_by_city)
		lincom guest_black+guest_host_black

		eststo: quietly reg yes guest_black host_race_black guest_host_black if host_gender_F==1, vce(cluster name_by_city)
		lincom guest_black+guest_host_black

		eststo: quietly reg yes guest_black host_race_black guest_host_black if (host_gender_F!=1 & host_gender_M!=1), vce(cluster name_by_city)
		lincom guest_black+guest_host_black
		
		esttab using host_race.rtf, ///
		varwidth(30) se(2) ar2 b(2) label nobaselevels interaction(" X ") modelwidth(11) ///
		onecell nogap nomtitles nodepvars nonumbers nonotes replace

		eststo clear

* Table 4. Proportion of Positive Responses by Race and Gender.
* For each race/gender subset among hosts, we want to see the acceptance rate
* for each race/gender subset among guests. E.g., at what rate do white male hosts accept white male guests?
file open homophily_table using "homophily.csv", w replace

	foreach subset in host_gender_M host_gender_F {
		foreach subset_two in host_race_white host_race_black{
			foreach guest_cell_one in 0 1 {
				foreach guest_cell_two in 0 1 {
							count if yes == 1 & `subset' == 1 & `subset_two' == 1 & guest_female == `guest_cell_one' & guest_black == `guest_cell_two'
							local num = r(N)
		
							count if `subset' == 1 & `subset_two' == 1 & guest_female == `guest_cell_one' & guest_black == `guest_cell_two'
							local denom = r(N)
							
							local propn = `num' / `denom'
							file write homophily_table "`propn',"
				}
			}
			file write homophily_table _n
		}
	}
file close homophily_table


* Table 5. Are Effects Driven by Host Characteristics?
	* For this table, we'll want to make some interaction coefficients between the guest being black and various host traits
		gen shared_guest_black = shared_property*guest_black
		label var shared_guest_black "Shared Property * Guest is African American"

		gen multiple_black = multiple_listings*guest_black
		label var multiple_black "Host has Multiple Listings * Guest is African American"

		gen ten_reviews_black = ten_reviews*guest_black
		label var ten_reviews_black "Host has Ten+ Reviews * Guest is African American"

		gen young_black = young*guest_black
		label var young_black "Host Looks Young * Guest is African American"

		gen any_black_gb = any_black*guest_black
		label var any_black_gb "Host has at least one review from an African American guest * Guest is African American"

	* Now run the regressions
		eststo: quietly reg yes guest_black shared_property shared_guest_black, vce(cluster name_by_city)
		lincom guest_black+shared_guest_black

		eststo: quietly reg yes guest_black multiple_listings multiple_black, vce(cluster name_by_city)
		lincom guest_black+multiple_black

		eststo: quietly reg yes guest_black ten_reviews ten_reviews_black, vce(cluster name_by_city)
		lincom guest_black+ten_reviews_black

		eststo: quietly reg yes guest_black young young_black, vce(cluster name_by_city)
		lincom guest_black+young_black

		eststo: quietly reg yes guest_black any_black any_black_gb, vce(cluster name_by_city)
		lincom guest_black+any_black_gb

		esttab using interactions_table.rtf, ///
		varwidth(30) se(2) ar2 b(2) label nobaselevels interaction(" X ") modelwidth(11) ///
		onecell nogap nomtitles nodepvars nonumbers nonotes replace

		eststo clear

* Table 6. Are Effects Driven by Location Characteristics?
	* First make interaction variables between the guest being black and different location characteristics
		gen guest_black_price_median = guest_black*price_median
		label var guest_black_price "(Price > Median) * Guest is Black"

		gen guest_black_pop_black = guest_black*black_proportion
		label var guest_black_pop_black "Share of Black Population in Census Tract * Guest is Black"

		gen guest_black_tract_listings = guest_black*tract_listings
		label var guest_black_tract_listings "Airbnb Listings per Census Tract * Guest is Black"

		gen guest_black_pr_filled = guest_black*pr_filled
		label var guest_black_pr_filled "Pr(Listing is Filled 8 Weeks Later) * Guest is Black"

	* Now run the regressions
		eststo: quietly reg yes guest_black price_median guest_black_price_median, vce(cluster name_by_city)
		eststo: quietly reg yes guest_black black_proportion guest_black_pop_black, vce(cluster name_by_city)
		eststo: quietly reg yes guest_black tract_listings guest_black_tract_listings, vce(cluster name_by_city)
		eststo: quietly reg yes guest_black pr_filled guest_black_pr_filled, vce(cluster name_by_city)

		esttab using location_interactions_table.rtf, ///
		varwidth(30) se(2) ar2 b(2) label nobaselevels interaction(" X ") modelwidth(11) ///
		onecell nogap nomtitles nodepvars nonumbers nonotes replace

		eststo clear




* Table 7. Proportion of Positive Responses, by Name. Note that we don't print this table out in a pretty format
* We filled in Table 7 in the paper manually
tab yes guest_first_name

* Calculate the Cost of Discrimination for section 4.6
	* Did listings stay vacant on the dates requested?
		gen vacancy = up_not_available_september
		replace vacancy = 2 if up_not_available_september==.

	* Label possible host responses, and label variables
		label define vacancy_labels ///
		0 "Vacant" ///
		1 "Listed, Not Vacant" ///
		2 "Not Listed"
		label values vacancy vacancy_labels

	tab vacancy
	tab vacancy if yes==0
	tab vacancy if yes==0 & guest_black==1
	
	* For robustness, look at vacancy rates among hosts who said Yes (see Footnote 17)
	tab vacancy if yes==1

	* How much does discrimination cost?
		replace cleaning_fee = 0 if cleaning_fee==.
		gen total_price = september_price + cleaning_fee
		sum total_price, d
		sum total_price if yes==0, d
		sum total_price if yes==0 & guest_black==1, d

	tab vacancy
	tab vacancy if yes==0


* Robustness: In table 4, column 5, we regress "Yes" on guest is african-american, "history of having a african-american guest", and the interaction of the two
* We define "history of having a african-american guest" as 1 if the host has at least one review from an African-American guest
* Does it matter if we define this variable differently? Test the results if we define it as "raw number of reviews from Af-Am guests" or "proportion of all reviews from Af-Am guests"
	gen raw_black_gb = raw_black*guest_black
	gen prop_black_gb = prop_black*guest_black

	eststo: quietly reg yes guest_black raw_black raw_black_gb, vce(cluster name_by_city)
	eststo: quietly reg yes guest_black prop_black prop_black_gb, vce(cluster name_by_city)
	eststo: quietly reg yes guest_black any_black any_black_gb, vce(cluster name_by_city)

	esttab using "past guests black.rtf", ///
	varwidth(30) se(2) ar2 b(2) label nobaselevels interaction(" X ") modelwidth(11) ///
	onecell nogap nomtitles nodepvars nonumbers nonotes replace
	eststo clear


* All our tests look at the effect of the guest's race (and covariates) on the likelihood of a YES response
* Does it matter if we use No responses instead? 
gen no = 1 if simplified_host_response == 10 | simplified_host_response == 11
replace no = 0 if no==.

	* Redo Table 2. The Impact of Race on Likelihood of Acceptance
		reg no guest_black, vce(cluster name_by_city)
		reg no guest_black host_race_black host_gender_M, vce(cluster name_by_city)
		reg no guest_black host_race_black host_gender_M ///
		multiple_listings shared_property ten_reviews log_price, vce(cluster name_by_city)

	* Redo Table 3: Race Gap by Race of the Host, across all hosts, then across male and female hosts
		reg no guest_black host_race_black guest_host_black, vce(cluster name_by_city)
		reg no guest_black host_race_black guest_host_black if host_gender_M==1, vce(cluster name_by_city)
		reg no guest_black host_race_black guest_host_black if host_gender_F==1, vce(cluster name_by_city)
		reg no guest_black host_race_black guest_host_black if (host_gender_F!=1 & host_gender_M!=1), vce(cluster name_by_city)

	* Redo Table 5. Are Effects Driven by Host Characteristics?
		reg no guest_black shared_property shared_guest_black, vce(cluster name_by_city)
		reg no guest_black multiple_listings multiple_black, vce(cluster name_by_city)
		reg no guest_black ten_reviews ten_reviews_black, vce(cluster name_by_city)
		reg no guest_black young young_black, vce(cluster name_by_city)
		reg no guest_black any_black any_black_gb, vce(cluster name_by_city)


	* Redo Table 6. Are Effects Driven by Location Characteristics?
		reg no guest_black price_median guest_black_price_median, vce(cluster name_by_city)
		reg no guest_black black_proportion guest_black_pop_black, vce(cluster name_by_city)
		reg no guest_black tract_listings guest_black_tract_listings, vce(cluster name_by_city)
		reg no guest_black pr_filled guest_black_pr_filled, vce(cluster name_by_city)
		
* Appendix Table 1: Results of survey testing races associated with names
tab guest_race_continuous guest_first_name

* Appendix Table 2: Raw discrimination across all race and gender groups
* This table was a suggestion from a QJE reviewer. It's a behemoth, but there's nothing we can do about it.
* To understand this code, it's best to look at the table first, to see what I'm trying to do
* But in essence, it's an expanded version of Table 4, where we look at the likelihood of different subsets of hosts to different subsets of guests
	file open homophily_table using "homophily_appendix.csv", w replace

	* Host subsets to test
	local host1 = "host_race_white == 1 & host_gender_M == 1"
	local host2 = "host_race_black == 1 & host_gender_M == 1"
	local host3 = "host_race_white == 1 & host_gender_F == 1"
	local host4 = "host_race_black == 1 & host_gender_F == 1"
	local host5 = "host_race_white == 1"
	local host6 = "host_race_black == 1"
	local host7 = "host_race_white != 1  & host_race_black != 1"
	local host8 = "host_gender_M == 1"
	local host9 = "host_gender_F == 1"
	local host10 = "host_gender_M !=1  & host_gender_F !=1"

	* Guest subsets to test
	local guest1 = "guest_black == 0 & guest_female == 0"
	local guest2 = "guest_black == 1 & guest_female == 0"
	local guest3 = "guest_black == 0 & guest_female == 1"
	local guest4 = "guest_black == 1 & guest_female == 1"
	local guest5 = "guest_female == 0"
	local guest6 = "guest_female == 1"
	local guest7 = "guest_black == 0"
	local guest8 = "guest_black == 1"

	foreach subset1 of numlist 1/10{
		foreach subset2 of numlist 1/8{

			qui: count if yes == 1 & `host`subset1'' & `guest`subset2''
			local num = r(N)
			
			qui: count if `host`subset1'' & `guest`subset2''
			local denom = r(N)
								
			local propn = round(`num' / `denom',0.01)
			file write homophily_table "`propn',"
		}
		file write homophily_table _n
	}
			
	file close homophily_table	

* Appendix Table 3: Discrimination by City
preserve
	drop if city=="."
	replace city = "LosAngeles" if city=="Los-Angeles"
	replace city = "StLouis" if city == "St-Louis"

	eststo: quietly reg yes guest_black, vce(cluster name_by_city)
	foreach market in Baltimore Dallas LosAngeles StLouis Washington {
		gen City = (city=="`market'")
		gen gb = City*guest_black
		label var gb "City * Guest is African-American"
		eststo: quietly reg yes guest_black City gb, vce(cluster name_by_city)
		lincom guest_black + gb
		drop City
		drop gb
	}

	esttab using discrimination_by_city.rtf, ///
	varwidth(30) se(2) ar2 b(2) label title("Dependent Variable: 1(Host Accepts)") ///
	nobaselevels interaction(" X ") modelwidth(8) ///
	onecell nogap nomtitles nodepvars nonumbers nonotes replace
	eststo clear
restore

* Appendix Table 4: Host responses to guest inquiries, by race of the guest
qui: estpost tab simplified_host_response guest_black, all 
estout, unstack varlabels(`e(labels)') collabels(none) eqlabels("Guest is White" "Guest is African-American")
eststo clear
