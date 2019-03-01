### electoral crime paper
# campaign wrangling
#   this script wrangles the campaign data for all local elections in brazil
#   2004 and 2016.
# author: andre assumpcao
# email:  andre.assumpcao@gmail.com

### import statements
# import packages
library(here)
library(magrittr)
library(readr)
library(tidyverse)

# load data
load('campaign2004.Rda')
load('campaign2008.Rda')
load('campaign2010.Rda')
load('campaign2012.Rda')
load('campaign2016.Rda')


### body