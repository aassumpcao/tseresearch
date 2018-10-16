# Electoral Crime and Performance Paper

# 02 Script:
# This script wrangles the electoral results by electoral section for the
# candidates that are in our sample of candidacies not having a final ruling
# before election day in 2012 and 2016

# Author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
library(tidyverse)
library(magrittr)
library(feather)
library(reticulate)

# set environment var (!!!USE YOUR PYTHON3 BINARY!!!)
Sys.setenv(RETICULATE_PYTHON = '/anaconda3/bin/python')

# load statements
load('CandidacyCases.Rda')

