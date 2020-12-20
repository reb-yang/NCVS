## Preamble
## Author: Rebecca Yang (reb.yang@mail.utoronto.ca)
## Date: Dec 19, 2020
# Purpose: The purpose of this code is to clean and prepare the 2016-2019 NCVS 
# data, which is obtained through the National Archive of Criminal Justice Data and the Institute for 
# Social Justice Research at the University of Michigan. It is freely available to download at the following link, but
# requires the user to register for an account with them or login through Google or ORCID:
# https://www.icpsr.umich.edu/web/NACJD/series/95?start=50&SERIESQ=95&ARCHIVE=NACJD&PUBLISH_STATUS=PUBLISHED&sort=TITLE_SORT%20asc&rows=50
# It is available in R format as an rda object, so it can be easily loaded into the environment. 
# In this repo,  is saved in inputs, under data, in a folder corresponding to its year. This 
# The following code combines the files for each year, selects variables of interest, categorizes crimes, 
#creates age groups, and cleans up variable values. I am using the "Collection Year" Incident-Level 
# Extract File for each year. 
# The resulting file is saved as an .rda file that can be loaded as needed

library(here) # loading required packages 
library(tidyverse)
library(lubridate)

load(here("inputs/data/2016/DS0005/36828-0005-Data.rda")) # loading data for all years
load(here("inputs/data/2017/DS0005/36981-0005-Data.rda"))
load(here("inputs/data/2018/DS0005/37297-0005-Data.rda"))
load(here("inputs/data/2019/DS0005/37645-0005-Data.rda"))

data_2016 <- da36828.0005 # renaming according to year
data_2017 <- da36981.0005
data_2018 <- da37297.0005
data_2019 <- da37645.0005

rm(da36828.0005, da36981.0005, da37297.0005, da37645.0005) # removing excess


data_2016 <- data_2016 %>%   # selecting vars
  select(IDPER, YEARQ, V4399, V4529, V4014, V4015, V2117, V2118, V4022, 
         V4016, V4019, WGTVICCY, SERIES_WEIGHT, V3014, V3018, V3023A, V4512, 
         V4513, V4514, V4515, V4516, V4517, V4518, V4519, V4520, V4522A, V4522B, V4522C,
         V4522D, V4522E, V4522F, V4522G, V4522H, V4024, V4140B8, V4140B4,  V4140B10, V4184  )
data_2017 <- data_2017 %>%  
  select(IDPER, YEARQ, V4399, V4529, V4014, V4015, V2117, V2118, V4022, 
         V4016, V4019, WGTVICCY, SERIES_WEIGHT, V3014, V3018, V3023A, V4512,
         V4513, V4514, V4515, V4516, V4517, V4518, V4519, V4520, V4522A, V4522B, V4522C,
         V4522D, V4522E, V4522F, V4522G, V4522H, V4024, V4140B8, V4140B4 , V4140B10, V4184 )
data_2018 <- data_2018 %>%  
  select(IDPER, YEARQ, V4399, V4529, V4014, V4015, V2117, V2118, V4022, 
         V4016, V4019, WGTVICCY, SERIES_WEIGHT, V3014, V3018, V3023A, V4512,
         V4513, V4514, V4515, V4516, V4517, V4518, V4519, V4520, V4522A, V4522B, V4522C,
         V4522D, V4522E, V4522F, V4522G, V4522H, V4024, V4140B8, V4140B4, V4140B10, V4184  )
data_2019 <- data_2019 %>%  
  select(IDPER, YEARQ, V4399, V4529, V4014, V4015, V2117, V2118, V4022, 
         V4016, V4019, WGTVICCY, SERIES_WEIGHT, V3014, V3018)

# cleaning variable names
inc_dat <- bind_rows(data_2016, data_2017, data_2018, data_2019) %>%
  rename(id = IDPER, 
         reported_police = V4399, 
         crime_type = V4529, 
         month = V4014, 
         year = V4015,
         pseudostratum = V2117, 
         halfsample = V2118,
         wgt = WGTVICCY,
         series = V4019,
         num_inc = V4016,
         series_wgt = SERIES_WEIGHT,
         age = V3014,
         sex = V3018,
         others_present = V4184,
         scene = V4024)%>% 
  mutate( month = match(substring(month, 6), month.name), # cleaning values 
         reported_police = substring(reported_police, 5),
         crime_type =  substring(crime_type, 6),
         scene =  substring(scene, 6),
         sex =  substring(sex, 5),
         others_present =  substring(others_present, 5), 
         month_year = ym(paste(year, month, sep = "-")), # creating new var based on date
         me_too = ifelse(month_year <= as.Date("2017-10-01"), "pre", "post"),
         reported_police = str_replace(reported_police, "Dont know", "Don't know"),
         year = as.factor(year)) %>%
  filter(reported_police == "Yes" | reported_police == "No") %>% 
  mutate(response = ifelse(reported_police == "Yes", 1, 0),
         id = as.factor(id))

inc_dat <- inc_dat %>% # creating age groups 
  mutate( age_group = case_when( age < 18 ~ "under 18",
                                 age >= 18 & age <= 34 ~ "18-34",
                                 age >= 35 & age <= 49 ~ "35-49",
                                 age >= 50 & age <= 64 ~ "50-64",
                                 age >= 64 ~ "over 65"))
# defining categories for crime                
sex_crimes <- c("Completed rape", "Attempted rape", "Sex aslt w s aslt",
                "Sex aslt w m aslt", "Sex aslt wo inj",
                "Unw sex wo force", "Verbal thr rape", "Ver thr sex aslt")
assaults <- c("Ag aslt w injury", "At ag aslt w wea", "Thr aslt w weap", "Simp aslt w inj",
              "Verbal thr aslt", "Asl wo weap, wo inj")
robbery <- c("Rob w inj m aslt", "Rob w inj s aslt", "At rob w aslt", "At rob inj m asl", 
             "At rob inj s asl", "Rob wo injury")
theft <- c("Theft value NA", "Theft $50-$249", "Theft $250+", "Theft $10-$49", "Theft < $10",
           "Pocket picking", "Purse snatching", "Attempted theft", "At purse snatch")
motor_vehicle <- c("At mtr veh theft", "Motor veh theft")
burglary <- c("Burg, ent wo for", "Burg, force ent", "Att force entry")

inc_dat <- inc_dat %>%  # creating categories 
  mutate(crime_class = case_when(crime_type %in% sex_crimes ~ "sex",
                                 crime_type %in% assaults ~ "assaults",
                                 crime_type %in% robbery ~ "robbery",
                                 crime_type %in% theft ~ "theft",
                                 crime_type %in% burglary ~ "burglary",
                                 crime_type %in% motor_vehicle ~ "mtr_veh",
                                 TRUE ~ "na"),
         crime_class = relevel(as.factor(crime_class), ref = "sex"))

# relationship to offender 
inc_dat <- inc_dat %>% mutate(relation = case_when(V4513 == "(1) Yes" ~ "spouse",
                            V4514 == "(1) Yes" ~ "ex-spouse",
                            V4515 == "(1) Yes" ~ "parent",
                            V4516 == "(1) Yes" ~ "relative",
                            V4517 == "(1) Yes" ~ "friend",
                            V4518 == "(1) Yes" ~ "neighbor",
                            V4519 == "(1) Yes" ~ "schoolmate",
                            V4520 == "(1) Yes" ~ "roommate",
                            V4522A == "(1) Yes" ~ "customer",
                            V4522B == "(1) Yes" ~ "patient",
                            V4522C == "(1) Yes" ~ "supervisor",
                            V4522D == "(1) Yes" ~ "employee",
                            V4522E == "(1) Yes" ~ "coworker",
                            V4522F == "(1) Yes" ~ "child",
                            V4522G == "(1) Yes" ~ "sibling",
                            V4522H == "(1) Yes" ~ "bf/gf",
                            TRUE ~ "unknown"), # creating known variable based on relation
                            known = ifelse(relation == "unknown", "no", "yes"),
                            injury = case_when(crime_type == "Ag aslt w injury" ~ "yes", # create injury variable
                                               crime_type == "At rob w inj m aslt" ~ "yes",
                                               crime_type == "At rob inj s asl" ~ "yes",
                                               crime_type == "Rob w inj m aslt" ~ "yes",
                                               crime_type == "Rob w inj s aslt" ~ "yes",
                                               crime_type == "Simp aslt w inj" ~ "yes",
                                               TRUE ~ "no"))


save(inc_dat, file = "outputs/inc_dat.rda")
