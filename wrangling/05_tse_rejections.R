### electoral crime and performance paper
# candidacy rejections wrangling
#   this script wrangles the candidacy rejections independently reported by tse.
#   unfortunately, they only released such information for 2014 and 2016. the
#   data here is useful, however, because it provides the most important reasons
#   why candidates have their candidacies rejected.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)

# load dataset
load('data/prevented2016.Rda')
load('data/electoral.crimes.Rda')
load('data/tseSentences.Rda')

### body
# find list of reasons to reject a candidacy
rejectionReasons <- prevented2016 %$%
  table(DS_MOTIVO_CASSACAO) %>%
  dimnames() %>%
  unlist() %>%
  unname()

# match candidates to the reason their candidacies were rejected
join <- c('ANO_ELEICAO', 'SEQUENCIAL_CANDIDATO' = 'SQ_CANDIDATO')

# join candidate list with information about electoral crimes in 2016
electoral.crimes %<>% left_join(select(prevented2016, c(3, 11:12)), by = join)

# check candidates who had more than one rejection reason listed
multipleCrimeCandidates <- electoral.crimes %>%
  group_by(scraperID) %>%
  filter(n() > 1) %>%
  select(scraperID) %>%
  unlist() %>%
  unique()

# subset data
cand1 <- filter(electoral.crimes, !(scraperID %in% multipleCrimeCandidates))
cand2 <- filter(electoral.crimes,   scraperID %in% multipleCrimeCandidates)

# reshape data to get multiple crimes in the same cell in the data
cand2 %<>% group_by(scraperID) %>%
           mutate(crime = row_number()) %>%
           ungroup() %>%
           spread(crime, DS_MOTIVO_CASSACAO) %>%
           unite(DS_MOTIVO_CASSACAO, '1', '2', '3', sep = ';')

# bind everything back
electoral.crimes <- bind_rows(cand1, cand2)

# remove useless objects
rm(cand1, cand2, prevented2016, join, multipleCrimeCandidates)

# save rejections vector
saveRDS(rejectionReasons, file = 'rejections.Rds')

