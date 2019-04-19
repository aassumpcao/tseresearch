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

# use all available cores in computation
doMC::registerDoMC(cores = parallel::detectCores())

# load datasets
load('data/tseSummary.Rda')
load('data/tseUpdates.Rda')
load('data/tseSentences.Rda')
load('data/electoralCrimes.Rda')

# load reasons for rejection
narrow.reasons <- readRDS('analysis/rejections.Rds') %>% str_remove_all('\\.$')

### ml algorithms
# 1. multinomial naive bayes classification (nb)
# 2. logistic regression (logit)
# 3. support vector machine (svm)
# 4. random forest

### text cleanup
# create new order of severity of electoral crimes
neworder <- c(5, 3, 1, 4, 6, 7, 8, 2)
narrow.reasons <- narrow.reasons[neworder]

# convert reasons to regex versions
narrow.reasons.regex <- narrow.reasons %>%
  str_replace_all('\\(', '\\\\(') %>%
  str_replace_all('\\.', '\\\\.') %>%
  str_replace_all('\\)', '\\\\)')

# create empty rejections vector
electoralCrimes$narrow.rejection <- NA_character_

# create narrow rejection reasons
for (i in seq(8, 1)) {
  electoralCrimes %<>%
    mutate(narrow.rejection = ifelse(str_detect(DS_MOTIVO_CASSACAO,
      narrow.reasons.regex[i]), narrow.reasons[i], narrow.rejection))
  if (i == 1) {rm(i)}
}

# create broad rejection reasons
electoralCrimes %<>%
  mutate(broad.rejection = narrow.rejection %>%
    {case_when(str_detect(., '64') ~ 'Ficha Limpa',
               str_detect(., '97') ~ 'Lei das Eleições',
               str_detect(., 'Ausência') ~ 'Requisito Faltante',
               str_detect(., 'Indeferimento') ~ 'Partido/Coligação')})

# join rejection reasons and their sentences
tse <- tseSentences %>%
  mutate(scraperID = as.character(scraperID)) %>%
  inner_join(electoralCrimes, 'scraperID') %>%
  filter(!is.na(sbody) | nchar(sbody) > 3)

# write csv for python analysis
write_delim(tse, 'data/tse.txt', ',')

# drop first row (invalid) and filter empty sentences. next, clean text for
# later classification.
tse %<>%
  mutate_at(vars(1:2), ~str_to_lower(.)) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '\n|\r|\t|\\.', ' ')) %>%
  mutate_at(vars(1:2), ~str_squish(.)) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '64(.)?90', '6490')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '9(\\.)?504', '9504')) %>%
  mutate_at(vars(1:2), ~removePunctuation(., FALSE, TRUE, TRUE)) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'n º', 'nº')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'art( )?', 'art')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'lei eleitoral', 'leieleitoral')) %>%
  mutate_at(vars(1:2), ~str_remove_all(., '_|\\(|\\)')) %>%
  arrange(DS_MOTIVO_CASSACAO)

# object spliting sample into train and test datasets
split <- which(!is.na(tse$DS_MOTIVO_CASSACAO))

# create list of stopwords
stopwords <- c(stopwords::stopwords('portuguese'), 'é', 'art', 'nº', '2016',
               'lei', '2012', 'i', 'g', 'fls', 'tse', 'ata', 'n', 'ser')

# create corpus object
tseCorpus <- Corpus(VectorSource(tse$sbody)) %>%
             tm_map(removeWords, stopwords)

# create document-term matrix
tseDtm <- DocumentTermMatrix(tseCorpus)

# split training and testing data and document-term matrix
tseTrain <- tse[split,]
tseTest  <- tse[-split,]
dtmTrain <- tseDtm[split,]
dtmTest  <- tseDtm[-split,]
tseCorpusTrain <- tseCorpus[split]
tseCorpusTest  <- tseCorpus[-split]

# select features: words that appear in less than five sentences should be
# dropped
fivefreq <- findFreqTerms(dtmTrain, 5)
dtmTrainSlice <- DocumentTermMatrix(tseCorpusTrain, list(dictionary = fivefreq))
fivefreq <- findFreqTerms(dtmTest, 5)
dtmTestSlice  <- DocumentTermMatrix(tseCorpusTest, list(dictionary = fivefreq))

# transform word frequency into word occurrence indicator for all words in all
# sentence groups
train <- apply(dtmTrainSlice, 2, function(x){ifelse(x > 0, 1, 0)})
test  <- apply(dtmTestSlice,  2, function(x){ifelse(x > 0, 1, 0)})

# function to drop na from analysis
drop.na <- which(is.na(tseTrain$broad.rejection))

# transform dfm object to dataset and remove NA
train <- as_tibble(train, .name_repair = 'universal') %>%
         {.[-drop.na,]}
test  <- as_tibble(test,  .name_repair = 'universal') %>%
         {.[-drop.na,]}

# remove NA
tseTrain <- tseTrain[-drop.na,]
tseTest  <- tseTest[-drop.na,]

# remove unnecessary objects for caret classification
rm(list = objects(pattern = '[Dd]tm|Corpus|stopwo|fivefr|split|narrow|broad'))

### 1. multinomial naive bayes classification
# obs: all running times are reported with respect to a a 10-CPU, 24-core, 8GB
# memory cluster computing service.
# train the text classification using naive bayes' algorithm and predict
# categories.
# model running time: ~ 5 seconds
nbModel <- e1071::naiveBayes(train, factor(tseTrain$broad.rejection), 1)

# predict categorical outcomes using the nb algorithm.
# prediction running time: ~ 18 minutes
nbPreds <- predict(nbModel, newdata = train)

# check predictions
confusionMatrix(nbPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(nbModel, 'analysis/01nbModel.Rds')
saveRDS(nbPreds, 'analysis/01nbPreds.Rds')

### 2. logistic regression
# run multinomial logit trying to predict each of the sentence categories using
# the words in each sentence as the matrix of independent variables
# model running time: ~ 1 hour
logitModel <- nnet::multinom(factor(tseTrain$broad.rejection) ~ .,
                             data = train,
                             MaxNWts = 49300)

# prediction running time: 6 seconds
logitPreds <- predict(logitModel, newdata = train)

# check predictions
confusionMatrix(logitPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(logitModel, 'analysis/02logitModel.Rds')
saveRDS(logitPreds, 'analysis/02logitPreds.Rds')

### 3. support vector machine (svm)
# support vector machines try to fit hyperplanes separating data categories
# using the words in each sentence as the matrix of independent variables
# model running time: 44 seconds
svmModel <- e1071::svm(factor(tseTrain$broad.rejection) ~ ., train,
                       scale = FALSE, kernel = 'linear', cost = 5)

# prediction running time: 11s
svmPreds <- predict(svmModel, newdata = train)

# check predictions
confusionMatrix(svmPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(svmModel, 'analysis/03svmModel.Rds')
saveRDS(svmPreds, 'analysis/03svmPreds.Rds')

### 4. random forest
# random forest is a classification algorithm that creates multiple (random)
# 'forests' of decision trees linking up features (words) to classes (sentence)
# categories
# model running time: 25 minutes
RFModel <- randomForest::randomForest(factor(tseTrain$broad.rejection) ~ .,
  data = train, ntree = 100, do.trace = TRUE, na.action = na.exclude)

# prediction running time: 3.5 seconds
RFPreds <- predict(RFModel, newdata = train)

# check predictions
confusionMatrix(RFPreds, factor(tseTrain$broad.rejection))

# save models and predictions to file
saveRDS(RFModel, 'analysis/04RFModel.Rds')
saveRDS(RFPreds, 'analysis/04RFPreds.Rds')

# remove all for serial sourcing
rm(list = ls())