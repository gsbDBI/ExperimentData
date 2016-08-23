#####################################
# Reading processed datasets into R #
#####################################

# set the working directory
#work_dir should point to your local work dir
work_dir<'C:/temp/'
setwd(work_dir)

# clear things in RStudio
rm(list = ls())

# Loading data
# In each of five sub-folders with processed datasets, we illustrate how to 
# read the data into R
filename.charitable <- 'Charitable/ProcessedData/charitable_withdummyvariables.csv'
charitable <- read.csv(filename.charitable)

filename.mobilization <- 'Mobilization/ProcessedData/mobilization_with_unlisted.csv'
mobilization <- read.csv(filename.mobilization)

filename.secrecy <- 'Secrecy/ProcessedData/ct_ballotsecrecy_processed.csv'
secrecy <- read.csv(filename.secrecy)

filename.social <- 'Social/ProcessedData/socialpressnofact.csv'
social <- read.csv(filename.social)

filename.welfare <- 'Welfare/ProcessedData/welfarenolabel3.csv'
welfare <- read.csv(filename.welfare)

