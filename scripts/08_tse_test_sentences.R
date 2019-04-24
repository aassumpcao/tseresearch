### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse website.
#   we use the textual classification algorithm from before to classify the
#   the remaining sentences in the dataset
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(magrittr)
library(tidyverse)
library(caret)

# use all available cores in computation
doMC::registerDoMC(cores = parallel::detectCores())

# load datasets
load('data/train.Rda')
load('data/test.Rda')
load('data/tseTrain.Rda')
load('data/tseTest.Rda')

### body
# load prediction objects and models
nbModel    <- readRDS('analysis/01nbModel.Rds')
nbPreds    <- readRDS('analysis/01nbPreds.Rds')
logitModel <- readRDS('analysis/02logitModel.Rds')
logitPreds <- readRDS('analysis/02logitPreds.Rds')
svmModel   <- readRDS('analysis/03svmModel.Rds')
svmPreds   <- readRDS('analysis/03svmPreds.Rds')
RFModel    <- readRDS('analysis/04RFModel.Rds')
RFPreds    <- readRDS('analysis/04RFPreds.Rds')

# test confusion matrices
caret::confusionMatrix(nbPreds,    factor(tseTrain$broad.rejection))
caret::confusionMatrix(logitPreds, factor(tseTrain$broad.rejection))
caret::confusionMatrix(svmPreds,   factor(tseTrain$broad.rejection))
caret::confusionMatrix(RFPreds,    factor(tseTrain$broad.rejection))

#
predict(logitModel, newdata = test)