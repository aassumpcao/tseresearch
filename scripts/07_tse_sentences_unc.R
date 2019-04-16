### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse website.
#   we use the textual information in the sentences to determine the allegations
#   against individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(magrittr)
library(tidyverse)
library(caret)
library(tm)

# if working off VCL/Longleaf
load('electoralcrime/train.Rda'))
load('electoralcrime/test.Rda'))
load('electoralcrime/tseTrain.Rda'))
load('electoralcrime/tseTest.Rda'))

### 1. multinomial naive bayes classification
# obs: all running times are reported with respect to a MacBook Pro 2017, i5
# 2.3Ghz processor with 2 cores.
# train the text classification using naive bayes' algorithm and predict
# categories.
# running time: > 30 min
nbModel <- train(train, factor(tseTrain$broad.rejection),
                 method = 'nb', fL = 1, verbose = TRUE, na.action = na.exclude,
                 trControl = trainControl(method = 'cv', verboseIter = TRUE))

# predict categorical outcomes using the nb algorithm.
# running time: > 25min
nbPreds <- predict(nbModel, newdata = train)

# check predictions
confusionMatrix(nbPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(nbModel, 'electoralcrime/01nbModel.Rds')
saveRDS(nbPreds, 'electoralcrime/01nbPreds.Rds')

### 2. logistic regression
# run multinomial logit trying to predict each of the sentence categories using
# the words in each sentence as the matrix of independent variables
# running time: > 4h
logitModel <- train(train, factor(tseTrain$broad.rejection),
                    method = 'multinom', verbose = TRUE, weights = 49300,
                    na.action = na.exclude,
                    trControl = trainControl(method = 'cv',
                                             sampling = 'up',
                                             verboseIter = TRUE))

# prediction running time: 90s
logitPreds <- predict(logitModel, newdata = train)

# check predictions
confusionMatrix(logitPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(logitModel, 'electoralcrime/02logitModel.Rds')
saveRDS(logitPreds, 'electoralcrime/02logitPreds.Rds')

### 3. support vector machine (svm)
# support vector machines try to fit hyperplanes separating data categories
# using the words in each sentence as the matrix of independent variables
# running time: 112s
# svmModel <- e1071::svm(factor(tseTrain$broad.rejection) ~ ., train,
#                        scale = FALSE, kernel = 'linear', cost = 5)
svmModel <- train(train, factor(tseTrain$broad.rejection),
              method = 'svmLinear2', verbose = TRUE, cost = 1,
              trControl = trainControl(method = 'cv',
                                       sampling = 'up',
                                       verboseIter = TRUE))


# prediction running time: 37s
svmPreds <- predict(svmModel0, newdata = train)

# check predictions
confusionMatrix(svmPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(svmModel, 'electoralcrime/03svmModel.Rds')
saveRDS(svmPreds, 'electoralcrime/03svmPreds.Rds')

### 4. random forest
# random forest is an classification algorithm that creates multiple (random)
# 'forests' of decision trees linking up features (words) to classes (sentence)
# categories
# running time: 17 min when using 500 decision trees.
RFmodel <- train(train, factor(tseTrain$broad.rejection),
                 method = 'rf', verbose = TRUE, na.action = na.exclude,
                 ntree = 100,
                 trControl = trainControl(method = 'cv',
                                          sampling = 'up',
                                          verboseIter = TRUE))

# prediction running time: 60s
RFPreds <- predict(RFModel, newdata = train)

# check predictions
confusionMatrix(RFPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(RFModel, 'electoralcrime/04RFModel.Rds')
saveRDS(RFPreds, 'electoralcrime/04RFPreds.Rds')

### 5. boosting trees
# 5.1 adaboost
# 5.2 xgboost