### electoral crime under democracy script
#   to be updated
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements (== packages required to run all scripts)
if (!require(AER))       {install.packages('AER')}
if (!require(here))      {install.packages('here')}
if (!require(magrittr))  {install.packages('magrittr')}
if (!require(pdftools))  {install.packages('pdftools')}
if (!require(readr))     {install.packages('readr')}
if (!require(stargazer)) {install.packages('stargazer')}
if (!require(stopwords)) {install.packages('stopwords')}
if (!require(tidyverse)) {install.packages('tidyverse')}

# load rproj (comment out if using another R IDE)
rstudioapi::openProject('2019 Electoral Crime.Rproj')

### wrangling scripts
# these scripts wrangle all data used in this paper. you should not run them as
# they will take a lot of time to process (> 29 hours if laptop; > 18 hours if
# cluster). these files have been created for data wrangling replication,
# transparency, and record keeping purposes.

# wrangle local candidate data
source('scripts/01_tse_candidates.R')

# wrangle local candidate campaign data
source('scripts/02_tse_campaign.R')

# wrangle electoral results data at the section(lowest)-level possible
source('scripts/03_tse_sections.R')

# wrangle vacant municipal office data
source('scripts/04_tse_vacancies.R')

# wrangle municipal election results data
source('scripts/05_tse_results.R')

# wrangle candidacy rejections
source('scripts/06_tse_rejections.R')

# wrangle text in sentences for classification
source('scripts/07_tse_sentence_cleanup.R')

# python3.7: install packages from requirements.txt to run the next script
system2('cat scripts/requirements.txt | xargs -n 1 pip install')

# python3.7: create sentence classification algorithm from 2016 sentences. this
# script takes 15 hours to run on a big memory (500g) server. use with caution.
system2('python scripts/07_sentence_classification.py &')

# wrangle judicial decisions and apply classification algorithm
source('scripts/08_tse_test_sentences.R')

# wrangle candidates, sections, and results for elections in 2006, 2010, 2014
source('scripts/09_tse_other.R')

### analysis scripts
# these scripts, however, should be run. they produce the paper analysis with
# the datasets that have been wrangled/munged by the wrangling scripts.

# produce paper analysis
source('script/10_tse_analysis.R')

