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
load('data/tseSummary.Rda')
load('data/tseUpdates.Rda')
load('data/tseSentences.Rda')
load('data/electoralCrimes.Rda')

# load reasons for rejection
narrow.reasons <- readRDS('data/rejections.Rds') %>% str_remove_all('\\.$')

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
  mutate_at(vars(1:2), ~str_replace_all(., 'ju[íi]z' , ' juiz')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '\n|\r|\t|\\.|:|;|,', ' ')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '64(.)?90', '6490')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '9(\\.)?504', '9504')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'n º', 'nº')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'art( )*', 'art ')) %>%
  mutate_at(vars(1:2), ~str_remove_all(., '_|\\(|\\)')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '~|`|´|^|º|\\"' , '')) %>%
  mutate_at(vars(1:2), ~str_squish(.)) %>%
  arrange(DS_MOTIVO_CASSACAO)

# write to file
save(electoralCrimes, file = 'data/tseAnalysis.Rda')
select(tse, scraperID, broad.rejection, narrow.rejection, shead, sbody) %>%
  write_csv('data/tse.csv')

# create list of stopwords
stopwords <- c(stopwords::stopwords('portuguese'), 'é', 'art', 'nº', '2016',
               'lei', '2012', 'i', 'g', 'fls', 'tse', 'ata', 'n', 'ser', 'ie',
               'juiz', 'juiza')

# export to file
paste0(stopwords, collapse = '\n') %>% writeLines(file('data/stopwords.txt'))

# remove all for serial sourcing
rm(list = ls())
