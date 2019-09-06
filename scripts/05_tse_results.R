### electoral crime and performance paper
# municipal election results wrangling
#   this script wrangles the electoral results by electoral section for the
#   candidates that are in our sample of candidacies not having a final ruling
#   before election day in 2004, 2008, 2012 and 2016.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)

# load them
load('data/results.Rda')
load('data/sections.Rda')
load('data/candidatesPending.Rda')

### wrangle candidate datasets to match results
# split dataset for easy calculation of results
candidates2004 <- candidatesPending %>% filter(year == 2004)
candidates2008 <- candidatesPending %>% filter(year == 2008)
candidates2012 <- candidatesPending %>% filter(year == 2012)
candidates2016 <- candidatesPending %>% filter(year == 2016)

# create vector for join keys
key1 <- c('ANO_ELEICAO','SIGLA_UE','NUM_TURNO','NUMERO_CANDIDATO'='NUMERO_CAND')
key2 <- c('ANO_ELEICAO','SIGLA_UE','NUM_TURNO','NUMERO_CANDIDATO'='NUM_VOTAVEL')

# prepare valid results dataset
electoralResults <- candidatesPending %>%
  mutate_all(as.character) %>%
  left_join(mutate_all(results, as.character), key1) %>%
  left_join(mutate_all(sections, as.character), key2)

# fix wrong officeIDs in tse's dataset
electoralResults %<>%
  group_by(candidateID) %>%
  filter(row_number() == 1)

# step1: isolate candidates with final decisions before election day using info
#  on one of the variables
registro_negado <- electoralResults %>%
  filter(str_detect(DESC_SIT_TOT_TURNO, 'ANTES DA ELEIÇÃO'))

# step2: isolate candidates with final decisions before election day using info
#  from sections result, which is not updated after elections.
electoralResults %<>%
  anti_join(registro_negado, 'candidateID') %>%
  ungroup() %>%
  filter(!is.na(voto.secao))

# define list of eligible politicians
electoralResults %<>%
  mutate(
    trialCrime = ifelse(str_detect(candidacy, '^(DEF|SUB)'), 0, 1),
    appealsCrime = ifelse(is.na(voto.municipio) | voto.municipio == 0, 1, 0)
  )

# visualize outcomes
electoralResults %$% table(trialCrime, appealsCrime)

# write to disk
save(electoralResults, file = 'data/electoralResults.Rda')

# remove all for serial sourcing
rm(list = ls())
