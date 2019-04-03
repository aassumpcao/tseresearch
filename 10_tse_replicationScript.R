### electoral crime under democracy script
#   to be updated
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
if (!require(AER))       {install.packages('AER')}
if (!require(here))      {install.packages('here')}
if (!require(magrittr))  {install.packages('magrittr')}
if (!require(pdftools))  {install.packages('pdftools')}
if (!require(quanteda))  {install.packages('quanteda')}
if (!require(readr))     {install.packages('readr')}
if (!require(stargazer)) {install.packages('stargazer')}
if (!require(stm))       {install.packages('stm')}
if (!require(stopwords)) {install.packages('stopwords')}
if (!require(tidytext))  {install.packages('tidytext')}
if (!require(tidyverse)) {install.packages('tidyverse')}

# load rproj (comment out if using another R IDE)
rstudioapi::openProject('2019 Electoral Crime.Rproj')

### wrangling scripts
# these scripts wrangle all data used in this paper. you should not run them as
# they will take long to process (> 1 hour if laptop or > 30 min if cluster).
# these files have been created for transparency and record keeping.

# wrangle local candidate data
source('wrangling/00_tse_candidates.R')

# wrangle local candidate campaign data
source('wrangling/01_tse_campaign.R')

# wrangle electoral results data at the section(lowest)-level possible
source('wrangling/02_tse_sections.R')

# wrangle vacant municipal office data
source('wrangling/03_tse_vacancies.R')

# wrangle municipal election results data
source('wrangling/04_tse_results.R')

# wrangle candidacy rejections
source('wrangling/05_tse_rejections.R')

# wrangle judicial decisions data
source('wrangling/06_tse_sentences.R')

# wrangle candidates, sections, and results for elections in 2006, 2010, 2014
source('wrangling/07_tse_other.R')

### analysis scripts
# these scripts, however, should be run. they produce the paper analysis with
# the datasets that have been wrangled/munged by the wrangling scripts.

# produce paper analysis
source('analysis/08_tse_analysis.R')

