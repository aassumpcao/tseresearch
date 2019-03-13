### electoral crime under democracy script
#   to be updated
# author: andre assumpcao
# by andre.assumpcao@gmail.com

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
# (warning: file script is massive. you will want to run it on a server/cluster
# computing service OR via command line as a background process)
source('02_tse_sections.R')

# wrangle vacant municipal office data
source('03_tse_vacancies.R')

# wrangle municipal election results data
source('04_tse_results.R')

# wrangle candidacy rejections
source('05_tse_rejections.R')

# wrangle judicial decisions data
source('06_tse_judDecisions.R')

# wrangle candidates, sections, and results for elections in 2006, 2010, 2014
source('07_tse_other.R')

# produce paper analysis
source('08_tse_analysis.R')

