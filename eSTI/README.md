Wilson E, Free C, Morris TP, Syred J, Ahamed I, Menon-Johansson AS, et
al. (2017) Internet-accessed sexually transmitted infection (eSTI)
testing and results service: A randomised, single-blind, controlled
trial. PLoS Med 14(12): e1002479.
[https://doi.org/10.1371/journal.pmed.1002479]()

Here is the data dictionary from the original data.

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Variable</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">anon_id</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">group</td>
<td style="text-align: left;">Allocation group</td>
</tr>
<tr class="odd">
<td style="text-align: left;">imd_decile</td>
<td style="text-align: left;">Index of Multiple Deprivation 2015 - Deciles</td>
</tr>
<tr class="even">
<td style="text-align: left;">partners</td>
<td style="text-align: left;">Number of sexual partners in past 12 months at baseline</td>
</tr>
<tr class="odd">
<td style="text-align: left;">gender</td>
<td style="text-align: left;">Gender</td>
</tr>
<tr class="even">
<td style="text-align: left;">msm</td>
<td style="text-align: left;">Men who have sex with men (1=Yes; 0=No; 99=Not Known )</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ethnicgrp</td>
<td style="text-align: left;">Ethnic group</td>
</tr>
<tr class="even">
<td style="text-align: left;">age</td>
<td style="text-align: left;">Age in completed years at baseline</td>
</tr>
<tr class="odd">
<td style="text-align: left;">anytest_sr</td>
<td style="text-align: left;">Any STI test (self reported data)</td>
</tr>
<tr class="even">
<td style="text-align: left;">anydiag_sr</td>
<td style="text-align: left;">Any STI diagnosis (self reported data)</td>
</tr>
<tr class="odd">
<td style="text-align: left;">anytreat_sr</td>
<td style="text-align: left;">Any STI treatment (self reported data)</td>
</tr>
<tr class="even">
<td style="text-align: left;">anytest</td>
<td style="text-align: left;">Any STI test (objective data)</td>
</tr>
<tr class="odd">
<td style="text-align: left;">anydiag</td>
<td style="text-align: left;">Any STI diagnosis (objective data)</td>
</tr>
<tr class="even">
<td style="text-align: left;">anytreat</td>
<td style="text-align: left;">Any treatment (objective data)</td>
</tr>
<tr class="odd">
<td style="text-align: left;">time_test</td>
<td style="text-align: left;">Time from randomisation to test in days</td>
</tr>
<tr class="even">
<td style="text-align: left;">time_treat</td>
<td style="text-align: left;">Time from randomisation to treatment in days</td>
</tr>
<tr class="odd">
<td style="text-align: left;">sh24_launch</td>
<td style="text-align: left;">Randomised after SH:24 made publically available (1=yes 0=no)</td>
</tr>
</tbody>
</table>

To create the process data set, we make the following choices:

1.  The paper has two primary outcomes: `anytest` and `anydiag`. We
    choose `anytest` for the processed data.

2.  Some tables in the paper uses MICE to impute missing values. The
    core findings tables only use complete observations rather than the
    including the imputed data, so our processed data only uses complete
    observations.

3.  The available categories for number of partners is 1-9, 10+. We
    opted to make this a binary variable following the core findings
    tables in the paper.

Next, we clean the data to be used for the HTE tutorial:

    # read in data
    data_original <- read_xls("raw_data/S1 Data.xls", sheet = 2) 

    # filter to complete cases
    complete_cases <- data_original %>% 
      drop_na(anytest) 

    data <- complete_cases %>%
      mutate(y = anytest,
             w = ifelse(group == "Control", 0 , 1), 
             msm = ifelse(msm == "msm", 1, 0), 
             partners1 = ifelse(partners == "1", 1, 0), 
             postlaunch = ifelse(sh24_launch == "1 = dor post-launch", 1, 0)) %>%
      cbind(model.matrix(~ 0 +., complete_cases[, c("ethnicgrp")])) %>%
      cbind(model.matrix(~ 0 +., complete_cases[, c("gender")])) %>%
      clean_names()  %>%
      select(y, w, gender_female, gender_male, gender_transgender, 
             ethnicgrp_asian = ethnicgrp_asian_asian_british, 
             ethnicgrp_black = ethnicgrp_black_black_british, 
             ethnicgrp_mixed_multiple = ethnicgrp_mixed_multiple_ethnicity, 
             ethnicgrp_other, 
             ethnicgrp_white = ethnicgrp_white_white_british, 
             partners1, postlaunch, msm, age, imd_decile)

    write.csv(data, "processed_data/processed_esti.csv", row.names = F)

These are the available variables in the processed data:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Variables</th>
<th style="text-align: left;">Definitions</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">y</td>
<td style="text-align: left;">Outcome: Any STI test (objective data)</td>
</tr>
<tr class="even">
<td style="text-align: left;">w</td>
<td style="text-align: left;">Indicator for Treated</td>
</tr>
<tr class="odd">
<td style="text-align: left;">gender_female</td>
<td style="text-align: left;">Indicator for Female</td>
</tr>
<tr class="even">
<td style="text-align: left;">gender_male</td>
<td style="text-align: left;">Indicator for Male</td>
</tr>
<tr class="odd">
<td style="text-align: left;">gender_transgender</td>
<td style="text-align: left;">Indicator for Transgender</td>
</tr>
<tr class="even">
<td style="text-align: left;">ethnicgrp_asian</td>
<td style="text-align: left;">Indicator for Asian/ Asian British</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ethnicgrp_black</td>
<td style="text-align: left;">Indicator for Black/ Black British</td>
</tr>
<tr class="even">
<td style="text-align: left;">ethnicgrp_mixed_multiple</td>
<td style="text-align: left;">Indicator for Mixed/ Multiple ethnicity</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ethnicgrp_other</td>
<td style="text-align: left;">Indicator for Other</td>
</tr>
<tr class="even">
<td style="text-align: left;">ethnicgrp_white</td>
<td style="text-align: left;">Indicator for White/ White British</td>
</tr>
<tr class="odd">
<td style="text-align: left;">partners1</td>
<td style="text-align: left;">Indicator for 1 Partner</td>
</tr>
<tr class="even">
<td style="text-align: left;">postlaunch</td>
<td style="text-align: left;">Indicator for Randomised after SH:24 made publically available</td>
</tr>
<tr class="odd">
<td style="text-align: left;">msm</td>
<td style="text-align: left;">Indicator for Men who have sex with men</td>
</tr>
<tr class="even">
<td style="text-align: left;">age</td>
<td style="text-align: left;">Continuous Age, 16-30</td>
</tr>
<tr class="odd">
<td style="text-align: left;">imd_decile</td>
<td style="text-align: left;">Continuous Index of Multiple Deprivation 2015 - Deciles, 1-9</td>
</tr>
</tbody>
</table>
