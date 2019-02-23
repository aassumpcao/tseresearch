################################################################################
# electoral crime and performance paper
# municipal election results wrangling

# this script wrangles the electoral results by electoral section for the
# candidates that are in our sample of candidacies not having a final ruling
# before election day in 2004, 2008, 2012 and 2016.

# by andre.assumpcao@gmail.com

# import statements
library(here)
library(tidyverse)
library(magrittr)
library(pdftools)

# load datasets
load('case.numbers.Rda')
load('candidates.pending.Rda')
load('results2004.Rda')
load('results2008.Rda')
load('results2012.Rda')
load('results2016.Rda')
load('sections2004.Rda')
load('sections2008.Rda')
load('sections2012.Rda')
load('sections2016.Rda')

################################################################################
# wrangle candidate datasets to match results
# throw away candidates running for vice-mayor
candidates.pending %<>% filter(CODIGO_CARGO != 12)

# split dataset for easy calculation of results
candidates2004 <- candidates.pending %>% filter(ANO_ELEICAO == 2004)
candidates2008 <- candidates.pending %>% filter(ANO_ELEICAO == 2008)
candidates2012 <- candidates.pending %>% filter(ANO_ELEICAO == 2012)
candidates2016 <- candidates.pending %>% filter(ANO_ELEICAO == 2016)

# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[17])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:18]

################################################################################
# 2004 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2004 %$% unique(SIGLA_UE)
people <- candidates2004 %$% unique(NUMERO_CANDIDATO)

# prepare valid results dataset
results2004 %<>%
  mutate(candidateID = SQ_CANDIDATO) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2004 %<>%
  mutate_all(as.character) %>%
  mutate(NUM_TURNO = as.integer(NUM_TURNO)) %>%
  mutate(candidateID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2004, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
sections2004 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# join candidates and their results (by section)
candidates2004 %<>%
  mutate(
    NUMERO_CANDIDATO = as.integer(NUMERO_CANDIDATO),
    CODIGO_CARGO     = as.integer(CODIGO_CARGO)
  ) %>%
  left_join(sections2004, by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO',
   'NUMERO_CANDIDATO' = 'NUM_VOTAVEL'))

# drop candidates who were not loaded on the electronic voting machine
candidates2004 %<>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

################################################################################
# 2008 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2008 %$% unique(SIGLA_UE)
people <- candidates2008 %$% unique(NUMERO_CANDIDATO)

# prepare valid results dataset
results2008 %<>%
  mutate(candidateID = SQ_CANDIDATO) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2008 %<>%
  mutate_all(as.character) %>%
  mutate(NUM_TURNO = as.integer(NUM_TURNO)) %>%
  mutate(candidateID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2008, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
sections2008 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# join candidates and their results (by section)
candidates2008 %<>%
  mutate(
    NUMERO_CANDIDATO = as.integer(NUMERO_CANDIDATO),
    CODIGO_CARGO     = as.integer(CODIGO_CARGO)
  ) %>%
  left_join(sections2008, by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO',
   'NUMERO_CANDIDATO' = 'NUM_VOTAVEL'))

# drop candidates who were not loaded on the electronic voting machine
candidates2008 %<>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

################################################################################
# 2012 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2012 %$% unique(SIGLA_UE)
people <- candidates2012 %$% unique(NUMERO_CANDIDATO)

# prepare valid results dataset
results2012 %<>%
  mutate(candidateID = SQ_CANDIDATO) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2012 %<>%
  mutate_all(as.character) %>%
  mutate(NUM_TURNO = as.integer(NUM_TURNO)) %>%
  mutate(candidateID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2012, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
sections2012 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# join candidates and results-by-section
candidates2012 %<>%
  mutate(
    NUMERO_CANDIDATO = as.integer(NUMERO_CANDIDATO),
    CODIGO_CARGO     = as.integer(CODIGO_CARGO)
  ) %>%
  left_join(sections2012, by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO',
   'NUMERO_CANDIDATO' = 'NUM_VOTAVEL'))

# drop candidates who were not loaded on the electronic voting machine
candidates2012 %<>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

################################################################################
# 2016 results wrangling
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2016 %$% unique(SIGLA_UE)
people <- candidates2016 %$% unique(NUMERO_CANDIDATO)

# prepare valid results dataset
results2016 %<>%
  mutate(candidateID = SQ_CANDIDATO) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS)) %>%
  mutate_all(as.character)

# join candidates and valid results
candidates2016 %<>%
  mutate_all(as.character) %>%
  mutate(NUM_TURNO = as.integer(NUM_TURNO)) %>%
  mutate(candidateID = SEQUENCIAL_CANDIDATO) %>%
  left_join(results2016, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
sections2016 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# join candidates and results-by-section
candidates2016 %<>%
  mutate(
    NUMERO_CANDIDATO = as.integer(NUMERO_CANDIDATO),
    CODIGO_CARGO     = as.integer(CODIGO_CARGO)
  ) %>%
  left_join(sections2016, by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO',
   'NUMERO_CANDIDATO' = 'NUM_VOTAVEL'))

# drop candidates who were not loaded on the electronic voting machine
candidates2016 %<>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

################################################################################
# wrangle final dataset
# append 2012 and 2016 results
candidates <- rbind(candidates2004, candidates2008, candidates2012,
                    candidates2016)

# create sentence outcomes variable
candidates %<>%
  mutate(trialCrime  = ifelse(COD_SITUACAO_CANDIDATURA == 16, 0, 1),
         appealCrime = ifelse(is.na(votes.x), 1, 0))

# write to disk
assign('electoral.crimes', candidates)
save(electoral.crimes, file = './electoral.crimes.Rda')

# quit r
q('no')