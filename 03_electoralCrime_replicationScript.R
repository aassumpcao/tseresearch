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

# wrangle candidate data
source('00_electoralCrime_candidates.R')

# wrangle electoral results data at the section(lowest)-level possible
source('00_electoralCrime_sections.R')

# wrangle vacant municipal office data
source('00_electoralCrime_vacancies.R')

# wrangle municipal election results data
source('00_electoralCrime_results.R')

# wrangle judicial decisions data
source('01_electoralCrime_judDecisions.R')

# produce paper analysis
source('02_electoralCrime_analysis.R')

