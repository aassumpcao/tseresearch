################################################################################
# Electoral Crime and Performance Paper

# 02 Script:
# This script wrangles the electoral results by electoral section for the
# candidates that are in our sample of candidacies not having a final ruling
# before election day in 2012 and 2016

# Author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
library(tidyverse)
library(magrittr)
library(feather)
library(reticulate)
library(pdftools)

# set environment var
Sys.setenv(RETICULATE_PYTHON = '/anaconda3/bin/python')

# load statements
load('candidates.Rda')
load('results2012.Rda')
load('results2016.Rda')

################################################################################
# wrangle actions for both 2012 and 2016 elections

# split dataset for easy calculation of results
candidates2012 <- candidates %>% filter(ANO_ELEICAO == 2012)
candidates2016 <- candidates %>% filter(ANO_ELEICAO == 2016)

# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[17])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:18]

################################################################################
# 2012 results wrangling
# unzip 2012 election files
unzip('../2018 TSE Databank/votacao_secao_2012.zip', exdir = './2012section')

# wait for all files to be unzipped
Sys.sleep(20)

# get file names
states <- list.files('./2012section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2012section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2012 <- read_delim(path, ";", escape_double = FALSE,
       col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
    # append to 'sections2012'
    sections2012 <- rbind(sections2012, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2012) <- codebook

# write to disk
# save(sections2012, file = 'sections2012.Rda')

# remove files
unlink('./2012section', recursive = TRUE)

# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2012 %$% unique(SIGLA_UE)
people <- candidates2012 %$% unique(NUMERO_CANDIDATO)

# prepare valid results dataset
results2012 %<>%
  mutate(candidateID = as.character(SQ_CANDIDATO)) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS))

# join candidates and valid results
candidates2012 %<>%
  left_join(results2012, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
sections2012 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# join candidates and results-by-section
candidates2012 %<>% left_join(sections2012, by = c('SIGLA_UE' = 'SIGLA_UE',
  'NUM_TURNO' = 'NUM_TURNO', 'NUMERO_CANDIDATO' = 'NUM_VOTAVEL',
  'CODIGO_CARGO' = 'CODIGO_CARGO'))

# drop candidates who were not loaded on the electronic voting machine
candidates2012 %<>% filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

################################################################################
# 2016 results wrangling
# find 2016 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2016_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2016 election files
lapply(paths, unzip, exdir = './2016section')

# wait for all files to be unzipped
Sys.sleep(20)

# get file names
states <- list.files('./2016section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2016section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2016 <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
    # append to 'sections2016'
    sections2016 <- rbind(sections2016, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2016) <- codebook

# write to disk
# save(sections2016, file = 'sections2016.Rda')

# remove files
unlink('./2016section', recursive = TRUE)

# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates2016 %$% unique(SIGLA_UE)
people <- candidates2016 %$% unique(NUMERO_CANDIDATO)

# prepare valid results dataset
results2016 %<>%
  mutate(candidateID = as.character(SQ_CANDIDATO)) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS))

# join candidates and valid results
candidates2016 %<>%
  left_join(results2016, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
sections2016 %<>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# join candidates and results-by-section
candidates2016 %<>% left_join(sections2016, by = c('SIGLA_UE' = 'SIGLA_UE',
  'NUM_TURNO' = 'NUM_TURNO', 'NUMERO_CANDIDATO' = 'NUM_VOTAVEL',
  'CODIGO_CARGO' = 'CODIGO_CARGO'))

# drop candidates who were not loaded on the electronic voting machine
candidates2016 %<>% filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

################################################################################
# wrangle final dataset
# append 2012 and 2016 results
candidates <- rbind(candidates2012, candidates2016)

# create sentence outcomes variable
candidates %<>%
  mutate(trialCrime  = ifelse(COD_SITUACAO_CANDIDATURA == 16, 0, 1),
         appealCrime = ifelse(is.na(votes.x), 1, 0))

# write to disk
save(candidates, file = './candidates.results.Rda')

# quit r
q()