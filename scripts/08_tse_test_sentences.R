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
tseObserved  <- read_csv('data/tseObserved.csv')
tsePredicted <- read_csv('data/tsePredicted.csv')
tseClassProb <- read_csv('data/tseClassProb.csv')
tseFinal     <- read_csv('data/tse.csv')

# define same classes as python
classes <- c('Ficha Limpa' = 0, 'Lei das Eleições' = 1,
             'Requisito Faltante' = 2, 'Partido/Coligação' = 3)

#
table(is.na(tseFinal$sbody))
