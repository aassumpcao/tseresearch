### electoral crime and performance paper
# judicial decisions script
#   this cript wrangles the judicial decisions downloaded from the tse website.
#   we use the textual information in the sentences to determine the allegations
#   against individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)

# load datasets
load('data/tseSummary.Rda')
load('data/tseUpdates.Rda')
load('data/tseSentences.Rda')
load('data/electoralCrimes.Rda')

# load reasons for rejection
rejections <- readRDS('rejections.Rds')

