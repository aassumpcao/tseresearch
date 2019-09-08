### electoral crime and performance paper
# judicial decisions script
#   this script formats the text used for training the machine learning
#   algorithms on python.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(magrittr)
library(tidyverse)

# load datasets
tseSentences <- read_csv('data/tseSentences.csv')
sentences2016 <- read_csv('data/sentences_classes2016.csv')

# create final dataset used for machine classification
tsePredictions <- tseSentences %>%
  filter(!is.na(sbody)) %>%
  mutate(ano = str_sub(candidateID, 1, 4)) %>%
  left_join(sentences2016, 'candidateID') %>%
  mutate_all(as.character)

# process sentences
tsePredictions$sbody %<>%
  str_to_lower() %>%
  stringi::stri_trans_general('Latin-ASCII') %>%
  str_replace_all('[[:punct:]]|[[:space:]]', ' ') %>%
  str_replace_all('^[a-z]{1,1} +', ' ') %>%
  str_replace_all(' +[a-z]{1,1} +', ' ') %>%
  str_squish()

# drop sentence heading
tsePredictions %>%
  filter(nchar(sbody) > 5) %>%
  select(candidateID, class, sbody) %>%
  write_csv('data/tsePredictions.csv')

# create list of stopwords
stopwords <- c(
  stopwords::stopwords('portuguese'), 'art', 'nº', '2016', '2012', 'lei', 'fls',
  'tse', 'ata', 'ser', 'ie', 'juiz', 'juiza'
)

# export to file
paste0(stopwords, collapse = '\n') %>% writeLines(file('data/stopwords.txt'))

# remove all for serial sourcing
rm(list = ls())
