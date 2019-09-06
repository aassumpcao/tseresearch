### electoral crime under democracy: evidence from brazil
# master script
#   this is the master script for the reproduction of the entire work in my jmp.
#   it contains two large groups of scripts (r and python3.7): data wrangling
#   (or munging) and analysis. i indicate below the execution times for either
#   group when scripts took longer than 15 minutes to execute. if you have r,
#   rstudio, and python installed on the computer, you can source this script
#   from the top. if you would like further clarification on how to go about
#   these scripts, please email me at the address below.
# author: andre assumpcao
# by: andre.assumpcao@gmail.com

# import statements (== packages required to run all scripts in R)
if (!require(AER))       {install.packages('AER')}
if (!require(extrafont)) {install.packages('extrafont')}
if (!require(here))      {install.packages('here')}
if (!require(ivpack))    {install.packages('ivpack')}
if (!require(lfe))       {install.packages('lfe')}
if (!require(magrittr))  {install.packages('magrittr')}
if (!require(pdftools))  {install.packages('pdftools')}
if (!require(sandwich))  {install.packages('sandwich')}
if (!require(stargazer)) {install.packages('stargazer')}
if (!require(stopwords)) {install.packages('stopwords')}
if (!require(tidyverse)) {install.packages('tidyverse')}
if (!require(xtable))    {install.packages('xtable')}

# load rproj (comment out if using another R IDE)
rstudioapi::openProject('2019 Electoral Crime.Rproj')

### wrangling scripts
# these scripts wrangle all data used in this paper. you should not run them as
# they will take a long time to process (> 72 hours if laptop; > 40 hours if
# cluster). you are better off using the final datasets than producing them;
# nonetheless, i include all files for replication and transparency purposes if
# you are interested in a particular step taken.

# python: install packages from requirements.txt to run the next script.
system2('cat scripts/requirements.txt | xargs -n 1 pip install')

# wrangle local candidate data
source('scripts/01_tse_candidates.R')

# (obs: these python scripts take 36+ hours to execute)
# python: scrape lawsuit IDs from the internet
system2('python scripts/01_tse_numberScraper.py &')
system2('python scripts/02_tse_decisionScraper.py &')
system2('python scripts/03_tse_manualScraper.py &')

# wrangle local candidate campaign data.
source('scripts/02_tse_campaign.R')

# wrangle electoral results data at the section(lowest)-level possible.
source('scripts/03_tse_sections.R')

# wrangle vacant municipal office data.
source('scripts/04_tse_vacancies.R')

# wrangle municipal election results data.
source('scripts/05_tse_results.R')

# wrangle candidacy rejections.
source('scripts/06_tse_rejections.R')
system2('python scripts/06_tse_decision2016.py &')

# wrangle text in sentences for classification.
system2('python scripts/07_tse_htmlParser.py &')
source('scripts/07_tse_sentence_cleanup.R')

# python: create sentence classification algorithm from 2016 sentences. this
# script takes 25 hours to run on a big memory (500g) cluster. use with caution.
system2('python scripts/99_tse_sentence_classification.py &')

# wrangle judicial classes after judicial sentence classification.
source('scripts/08_tse_analysis_prep.R')

# wrangle candidates, sections, and results for elections in 2006, 2010, 2014.
source('scripts/09_tse_other.R')

### analysis scripts
# these scripts, however, should be executed. they produce the paper analysis
# with the datasets that have been wrangled/munged by the wrangling scripts.

# produce paper analysis
source('script/10_tse_analysis.R')

