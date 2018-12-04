### electoral crime under democracy script
# to be updated
# by andre.assumpcao

# import statements
library(here)
library(tidyverse)
library(magrittr)
library(feather)
library(reticulate)
library(pdftools)
library(AER)
library(stargazer)

# wrangle candidate data
source('00_electoralCrime_candidates.R')

# wrangle electoral results data at the section(lowest)-level possible
source('00_electoralCrime_sections.R')

# wrangle vacant municipal office data
source('00_electoralCrime_vacancies.R')

# wrangle municipal election results data
source('00_electoralCrime_results.R')

# produce paper analysis
source('01_electoralCrime_analysis.R')

