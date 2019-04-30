### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial rulings after machine learning
#   classification. i load the results from both svm and xgboost estimations,
#   the best performing algorithms, to find the class of each judicial ruling.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(magrittr)
library(tidyverse)

# load data
load('data/tseAnalysis.Rda')
load('data/tseSummary.Rda')

# load csv files
tseObserved  <- read_csv('data/tseObserved.csv') %>%
                mutate(scraperID = as.character(scraperID))
tsePredicted <- read_csv('data/tsePredicted.csv') %>%
                mutate(scraperID = as.character(scraperID))
tseClassProb <- read_csv('data/tseClassProb.csv')

# define same classes as python
classes <- c('Ficha Limpa' = 0, 'Lei das Eleições' = 1,
             'Requisito Faltante' = 2, 'Partido/Coligação' = 3)

# build analysis dataset from scratch
tse.analysis <- electoralCrimes %>%
  select(scraperID, ruling.class = broad.rejection)

# join the predictions for each ruling class
tse.analysis %<>%
  left_join(tseObserved, by = 'scraperID') %>%
  distinct(scraperID, .keep_all = TRUE) %>%
  select(-rulingClass) %>%
  left_join(tsePredicted, by = 'scraperID') %>%
  distinct(scraperID, .keep_all = TRUE) %>%
  select(-xgPred) %>%
  mutate(ruling.class = ruling.class %>% {ifelse(is.na(.), svmPred, .)}) %$%
  table(ruling.class)






