### electoral crime under democracy script
# to be updated
# by andre.assumpcao

# import statements
library(AER)
library(here)
library(magrittr)
library(pdftools)
library(readr)
library(stargazer)
library(tidyverse)

# load rproj (comment out if using another R IDE)
rstudioapi::openProject('2019 Electoral Crime.Rproj')

# wrangle local candidate data
source('00_tse_candidates.R')

# wrangle local candidate campaign data (warning: file script is massive. you
# will want to run it on a server/cluster computing service OR via command line
# as a background process)
source('01_tse_campaign.R')

# wrangle electoral results data at the section(lowest)-level possible
source('02_tse_sections.R')

# wrangle vacant municipal office data
source('00_electoralCrime_vacancies.R')

# wrangle municipal election results data
source('00_electoralCrime_results.R')

# wrangle judicial decisions data
source('01_electoralCrime_judDecisions.R')

# produce paper analysis
source('02_electoralCrime_analysis.R')

