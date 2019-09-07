# import statements
library(magrittr)
library(tidyverse)

# load datasets
load('train.Rda')
load('tseTrain.Rda')

### 1. multinomial naive bayes classification
# obs: all running times are reported with respect to a MacBook Pro 2017, i5
# 2.3Ghz processor with 2 cores.
# train the text classification using naive bayes' algorithm and predict
# categories.
# model running time: > 5s
system.time(nbModel <- e1071::naiveBayes(train, factor(tseTrain$broad.rejection), 1))

# predict categorical outcomes using the nb algorithm.
# prediction running time: > 20min
system.time(nbPreds <- predict(nbModel, newdata = train))

# check predictions
confusionMatrix(nbPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(nbModel, 'analysis/01nbModel.Rds')
saveRDS(nbPreds, 'analysis/01nbPreds.Rds')

### 2. logistic regression
# run multinomial logit trying to predict each of the sentence categories using
# the words in each sentence as the matrix of independent variables
# model running time: > 4h
system.time(logitModel <- nnet::multinom(factor(tseTrain$broad.rejection) ~ .,)
                             data = train,
                             MaxNWts = 49300)

# prediction running time: 90s
system.time(logitPreds <- predict(logitModel, newdata = train))

# check predictions
confusionMatrix(logitPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(logitModel, 'analysis/02logitModel.Rds')
saveRDS(logitPreds, 'analysis/02logitPreds.Rds')

### 3. support vector machine (svm)
# support vector machines try to fit hyperplanes separating data categories
# using the words in each sentence as the matrix of independent variables
# model running time: 112s
system.time(svmModel <- e1071::svm(factor(tseTrain$broad.rejection) ~ ., train,)
                       scale = FALSE, kernel = 'linear', cost = 5)

# prediction running time: 37s
system.time(svmPreds <- predict(svmModel0, newdata = train))

# check predictions
confusionMatrix(svmPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(svmModel, 'analysis/03svmModel.Rds')
saveRDS(svmPreds, 'analysis/03svmPreds.Rds')

### 4. random forest
# random forest is a classification algorithm that creates multiple (random)
# 'forests' of decision trees linking up features (words) to classes (sentence)
# categories
# model running time: 17 min when using 500 decision trees.
system.time(RFModel <- randomForest::randomForest(factor(tseTrain$broad.rejection) ~ .,)
  data = train, ntree = 100, do.trace = TRUE, na.action = na.exclude)

# prediction running time: 60s
system.time(RFPreds <- predict(RFModel, newdata = train))

# check predictions
confusionMatrix(RFPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(RFModel, 'analysis/04RFModel.Rds')
saveRDS(RFPreds, 'analysis/04RFPreds.Rds')

