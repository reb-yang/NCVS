# NCVS

# Overview 
This repo contains code for the project I did about crime reporting using data from the 2016-2019 versions
of the National Crime Victimization survey. The data is freely available and instructions to reproduce this 
project are given below. 

This repo is organized as follows: 

# Inputs 

Inputs contain data that are unchanged from their original.

## data 
The `data` folder contains the all the data I used. 
The 2016-2019 NCVS data is obtained through the National Archive of Criminal Justice Data and the Institute for
Social Justice Research at the University of Michigan. The data for each year is freely available to download at the following link, but requires the user to register for an account with them or login through Google or ORCID:
https://www.icpsr.umich.edu/web/NACJD/series/95?start=50&SERIESQ=95&ARCHIVE=NACJD&PUBLISH_STATUS=PUBLISHED&sort=TITLE_SORT%20asc&rows=50
It is available for download in R format, and I saved the data for each year in a corresponding folder (i.e. 2016 data in a folder called "2016"). It also included the codebook and other literature that might be of interest. Note: I used the regular version of 2016, not the "revised". 

# Scripts 
Scripts contain R scripts that take inputs and produce outputs. 
- data_cleaning.R - data cleaning script - in here I combine the files from each year, create new variables, filter responses, etc.

# Outputs 
- fit1.rda, fit2.rda, fit3.rda, fit4.rda, fit6.rda, fit7.rda,  - These are the models that I fitted - they are saved here because some took a long time to run. 
- NCVS.Rmd - R markdown file of the final report
- NCVS.pdf - pdf file of the final report
- *inc_dat.rda, the output of data_cleaning.R should be in here as well 





