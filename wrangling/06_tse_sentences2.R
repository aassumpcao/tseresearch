### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse website.
#   we use the textual information in the sentences to determine the allegations
#   against individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(caret)
# library(e1071)
library(magrittr)
library(RTextTools)
library(tidyverse)
library(tm)

# use all available cores in computation
doMC::registerDoMC(cores = detectCores())

# load datasets
load('data/tseSummary.Rda')
load('data/tseUpdates.Rda')
load('data/tseSentences.Rda')
load('data/electoralCrimes.Rda')

# load reasons for rejection
narrow.reasons <- readRDS('rejections.Rds') %>% str_remove_all('\\.$')

### ml algorithms
# 1. multinomial naive bayes classification
# 2. logistic regression
# 3. linear support vector machine
# 4. random forest
# 5. boosting trees: adaboost and xgboost

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
split <- nrow(filter(tse, !is.na(DS_MOTIVO_CASSACAO)))

# create list of stopwords
stopwords <- c(stopwords::stopwords('portuguese'), 'é', 'art', 'nº', '2016',
               'lei', '2012', 'i', 'g', 'fls', 'tse', 'ata', 'n', 'ser')

# create corpus object
tseCorpus <- Corpus(VectorSource(tse$sbody)) %>%
             tm_map(removeWords, stopwords)

# create document-term matrix
tseDtm <- DocumentTermMatrix(tseCorpus)

# split training and testing data and document-term matrix
tseTrain <- filter(tse, !is.na(DS_MOTIVO_CASSACAO))
tseTest  <- filter(tse,  is.na(DS_MOTIVO_CASSACAO))
dtmTrain <- tseDtm[1:split,]
dtmTest  <- tseDtm[(split + 1):nrow(tse),]
tseCorpusTrain <- tseCorpus[1:split]
tseCorpusTest  <- tseCorpus[(split + 1):nrow(tse)]

# select features: words that appear in less than five sentences should be
# dropped
fivefreq <- findFreqTerms(dtmTrain, 5)
dtmTrainSlice <- DocumentTermMatrix(tseCorpusTrain, list(dictionary = fivefreq))
fivefreq <- findFreqTerms(dtmTest, 5)
dtmTestSlice  <- DocumentTermMatrix(tseCorpusTrain, list(dictionary = fivefreq))

### 1. multinomial naive bayes classification
# transform word frequency into word occurrence indicator for all words in all
# sentence groups
trainNB  <- apply(dtmTrainSlice,  2,
              function(x){factor(ifelse(x > 0, 1, 0), c(0, 1), c('No', 'Yes'))})
testNB   <- apply(dtmTestSlice,  2,
              function(x){factor(ifelse(x > 0, 1, 0), c(0, 1), c('No', 'Yes'))})

# train the text classification and track total time
nbModel <- e1071::naiveBayes(trainNB, tseTrain$broad.rejection, laplace = 1)



