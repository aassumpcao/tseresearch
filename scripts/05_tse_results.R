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

# create vectors for loading results
results <- paste0('data/results', seq(2004, 2016, 4), '.Rda')
section <- paste0('data/sections', seq(2004, 2016, 4), '.Rda')

# load them
for (element in results) {load(element)}
for (element in section) {load(element)}
load('data/candidatesPending.Rda')
load('data/candidates1.Rda')

### wrangle candidate datasets to match results
# split dataset for easy calculation of results
candidates2004 <- candidatesPending %>% filter(year == 2004)
candidates2008 <- candidatesPending %>% filter(year == 2008)
candidates2012 <- candidatesPending %>% filter(year == 2012)
candidates2016 <- candidatesPending %>% filter(year == 2016)

### 2004 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2004 %$% unique(unit)
people <- candidates2004 %$% unique(candID)

# # if necessary
# load('data/results2004.Rda');load('data/sections2004.Rda')

# prepare valid results dataset
results2004 %<>%
  mutate(candID = SQ_CANDIDATO, unit = SIGLA_UE) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(unit, candID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2004 %<>%
  mutate_all(as.character) %>%
  left_join(results2004, by = c('unit', 'candID')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes))

# prepare results-by-section dataset
sections2004 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and their results (by section)
by <- c('unit'='SIGLA_UE', 'officeID'='CODIGO_CARGO', 'candID'='NUM_VOTAVEL')
candidates2004 %<>% left_join(sections2004, by)

# drop candidates who were not loaded on the electronic voting machine
candidates2004 %<>% mutate(votes = ifelse(!is.na(votes.x), votes.x, votes.y))

### 2008 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2008 %$% unique(unit)
people <- candidates2008 %$% unique(candID)

# prepare valid results dataset
results2008 %<>%
  mutate(candID = SQ_CANDIDATO) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, candID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2008 %<>%
  mutate_all(as.character) %>%
  mutate(candID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2008, by = c('unit' = 'SIGLA_UE', 'candID')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes))

# prepare results-by-section dataset
sections2008 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and their results (by section)
candidates2008 %<>% left_join(sections2008, by)

# drop candidates who were not loaded on the electronic voting machine
candidates2008 %<>% mutate(votes = ifelse(!is.na(votes.x), votes.x, votes.y))

### 2012 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2012 %$% unique(unit)
people <- candidates2012 %$% unique(candID)

# prepare valid results dataset
results2012 %<>%
  mutate(candID = SQ_CANDIDATO) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, candID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2012 %<>%
  mutate_all(as.character) %>%
  mutate(candID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2012, by = c('unit' = 'SIGLA_UE', 'candID')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes))

# prepare results-by-section dataset
sections2012 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and results-by-section
candidates2012 %<>% left_join(sections2012, by)

# drop candidates who were not loaded on the electronic voting machine
candidates2012 %<>% mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

### 2016 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2016 %$% unique(unit)
people <- candidates2016 %$% unique(candID)

# prepare valid results dataset
results2016 %<>%
  mutate(candID = SQ_CANDIDATO) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, NUM_TURNO, candID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2016 %<>%
  mutate_all(as.character) %>%
  mutate(candID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2016, by = c('unit' = 'SIGLA_UE', 'candID')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes))

# prepare results-by-section dataset
sections2016 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  filter(NUM_TURNO == 1) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  ungroup() %>%
  mutate_all(as.character)

# join candidates and results-by-section
candidates2016 %<>% left_join(sections2016, by)

# drop candidates who were not loaded on the electronic voting machine
candidates2016 %<>% mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

### wrangle final dataset
# append 2012 and 2016 results
electoralResults <- bind_rows(
  candidates2004, candidates2008, candidates2012, candidates2016
)

# define vector of authorizations
auth <- c('DEFERIDO COM RECURSO', 'SUB JUDICE')


electoralResults %$% table(candidacy)







# create sentence outcomes variable
electoralResults %>%
  filter(!is.na(votes.y))
  mutate(trialCrime  = ifelse(candidacy %in% auth, 0, 1),
         appealCrime = ifelse(is.na(votes.x), 1, 0)) %>%
  {table(.$trialCrime, .$appealCrime)}

# write to disk
save(electoralResults, file = 'data/electoralResults.Rda')

# remove all for serial sourcing
rm(list = ls())
