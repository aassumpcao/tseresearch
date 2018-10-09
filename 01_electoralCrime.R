################################################################################
# Electoral Crime and Performance Paper
#
# 01 Script:
# This script narrows down the database of candidates who had their
# candidacies appealed before the elections but have not heard back before
# election date. After it filters down candidates, it runs the TSE case scraper,
# which is a program that goes on to each candidate website at TSE and downloads
# the case and protocol number for all their candidacies.
#
# Author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# clear environment
rm(list = objects())

# import statements
library(tidyverse)
library(magrittr)
library(feather)
library(reticulate)

# set environment var (!!!USE YOUR PYTHON3 BINARY!!!)
Sys.setenv(RETICULATE_PYTHON = '/anaconda3/bin/python')

# load statements
load('candidates.2012.Rda')
load('candidates.2016.Rda')

################################################################################
# candidates wrangling
# only working with candidates who filed (or whose opponent filed) an appeal to
# initial candidacy decision
candidacy.situation <- c('DEFERIDO COM RECURSO', 'INDEFERIDO COM RECURSO',
                        'CASSADO COM RECURSO', 'CANCELADO COM RECURSO')

# filter dataset according to situation above
appealing.candidates2012 <- candidates.2012 %>%
  filter(DES_SITUACAO_CANDIDATURA %in% candidacy.situation)
appealing.candidates2016 <- candidates.2016 %>%
  filter(DES_SITUACAO_CANDIDATURA %in% candidacy.situation)

# bind observations
candidates <- bind_rows(appealing.candidates2012, appealing.candidates2016)

# remove useless data
rm(list = objects(pattern = 'appealing|[0-9]+'))

################################################################################
# case number scraper
# vector of special elections in 2012
supplemental.elections2012 <- candidates %>%
  filter(ANO_ELEICAO == 2012) %>%
  filter(DESCRICAO_ELEICAO != 'ELEIÇÃO MUNICIPAL 2012') %>%
  arrange(SIGLA_UF, DESCRICAO_UE) %>%
  select(DESCRICAO_ELEICAO) %>%
  unlist() %>%
  unique()

# add general election to vector
supplemental.elections2012 <- c('ELEIÇÃO MUNICIPAL 2012',
                                supplemental.elections2012)

# unique election ID for the supplemental elections above
electionID.2012 <- c(1699, 1700, 1736, 1729, 1776, 1697, 1675, 1771, 1681, 1758,
                     1731, 1714, 1720, 1743, NA, 677, 1747, 663, 1772, 678,
                     1721, 1740, 1680, 1735, 670, 1757, 1722)

# vector of special elections in 2016
supplemental.elections2016 <- candidates %>%
  filter(ANO_ELEICAO == 2016) %>%
  filter(DESCRICAO_ELEICAO != 'Eleições Municipais 2016') %>%
  arrange(SIGLA_UF, DESCRICAO_UE) %>%
  select(DESCRICAO_ELEICAO) %>%
  unlist() %>%
  unique()

# add general election to vector
supplemental.elections2016<- c('Eleições Municipais 2016',
                               supplemental.elections2016)

# unique election ID for the supplemental elections above
electionID.2016 <- c(2, 93810, 91463, 60819, 70905, 68881, 36506, 93796, 42911,
                     36285, 96930, 94972, 95019, 69133, 22424, 92548, 70880)

# wrangle election type
elections <- tibble(
  match      = c(supplemental.elections2012, supplemental.elections2016),
  electionID = c(electionID.2012, electionID.2016))

# join electionID onto candidates database
candidates %<>% left_join(elections, by = c('DESCRICAO_ELEICAO' = 'match'))

# problems with joaquim távora
which(candidates$DESCRICAO_ELEICAO == 'ELEIÇÃO SUPLEMENTAR JOAQUIM TÁVORA')

# select meaningful variables
candidates.feather <- candidates %>%
  transmute(electionYear    = as.character(ANO_ELEICAO),
            electionID      = as.character(electionID),
            electoralUnitID = as.character(SIGLA_UE),
            candidateID     = as.character(SEQUENCIAL_CANDIDATO)) %>%
  filter(!row_number() %in% c(2074, 2075))

# write to disk
write_feather(candidates.feather, path = './candidates.feather')

# remove useless stuff
rm(list = objects(pattern = '\\.|election'))

# run scraper on python
# source_python('01_electoralCrime.py')

################################################################################
# check
# load results and check
candidates.feather <- read_feather('candidateCases.feather')
names(candidates.feather) <- candidates.feather[1,]
candidates.feather %<>% slice(-1)

# check invalid case numbers
invalid.cases <- candidates.feather %>%
  filter(caseNum == 'Informação ainda não disponível') %>%
  select(1:4)

# rerun python script
write_feather(invalid.cases, path = './candidates.feather')
# source_python('./01_electoralCrime.py')

# load data
invalid.cases <- read_feather('invalidCases.feather')
names(invalid.cases) <- invalid.cases[1,]
invalid.cases %<>% slice(-1)

# find rows to replace
replace.positions <- candidates.feather %$%
  which(caseNum == 'Informação ainda não disponível')

# replace
candidates.feather[replace.positions, 'protNum'] <- invalid.cases$protNum

# test remaining cases
filter(candidates.feather, str_detect(protNum, 'nprot=undefined'))

# View remaining on another dataset
remaining <- candidates %$%
  which(SEQUENCIAL_CANDIDATO %in% unlist(invalid.cases$candidateID) &
    electionID %in% unlist(invalid.cases$electionID))
# View(invalid.cases)
# View(candidates[remaining,])

################################################################################
# corrections
# candidate numbers that need changing
old <- c(40000009724, 50000047524, 50000047521, 90000030491, 120000008348)
new <- c(40000001667, 50000025615, 50000025614, 90000007021, 120000003450)
replace.positions <- which(candidates$SEQUENCIAL_CANDIDATO %in% old)
candidates[replace.positions, 'SEQUENCIAL_CANDIDATO'] <- new
candidates[which(candidates$SEQUENCIAL_CANDIDATO == 120000003450),
          'electionID'] <- 1699

# check invalid protocol numbers
invalid.cases <- candidates %>%
  filter(SEQUENCIAL_CANDIDATO %in% new) %>%
  transmute(electionYear    = as.character(ANO_ELEICAO),
            electionID      = as.character(electionID),
            electoralUnitID = as.character(SIGLA_UE),
            candidateID     = as.character(SEQUENCIAL_CANDIDATO))

# write to disk
write_feather(invalid.cases, path = './candidates.feather')

# run python script
# system2('python', args = '01_electoralCrime.py')

# load corrections
invalid.cases <- read_feather('invalidCases.feather')
names(invalid.cases) <- invalid.cases[1,]
invalid.cases %<>% slice(-1)

# replace
replace.positions <- which(candidates.feather$candidateID %in% old)
candidates.feather[replace.positions, 5:6] <- invalid.cases[, 5:6]

# candidate whose candidacy has been wrongly recorded on website
which(candidates.feather$candidateID == 50000047516)
candidates.feather %<>% filter(!row_number() == 421)

# remove unnecessary files
rm(new, old, remaining)

# candidates whose candidacy is not available online (only in raw datasets),
# for which we have to manually download data from the web
# candidate number 210000000226 doesn't show up anywhere
search <- c(50000047738, 50000047739, 140000024289, 140000024745, 160000039647,
            160000039646, 200000007872, 200000007858, 200000010277, 50000032049)
states <- c('ba', 'ba', 'pa', 'pa', 'pr', 'pr', 'rn', 'rn', 'rn', 'ba')
cases  <- c('0000493-05.2012.6.05.0035', '0000494-87.2012.6.05.0035',
            '0000355-28.2012.6.14.0022', '0000083-12.2012.6.14.0094',
            '0000003-77.2013.6.16.0055', '0000002-92.2013.6.16.0055',
            '0000240-84.2012.6.20.0007', '0000241-69.2012.6.20.0007',
            '0001055-63.2012.6.20.0013', '0000050-72.2016.6.05.0113')
prots  <- c('1773042012', '1773052012', '939142012', '551612012', '158342013',
            '157882013',   '625772012', '625762012', '408752012', '1084392016')
urls   <- paste0('http://inter03.tse.jus.br/sadpPush/ExibirDadosProcesso.do?',
                 'nprot=', prots, '&comboTribunal=', states)

# replace case numbers
invalid.cases <- candidates %>%
  filter(SEQUENCIAL_CANDIDATO %in% search) %>%
  select(ANO_ELEICAO, electionID, SIGLA_UE, SEQUENCIAL_CANDIDATO) %>%
  transmute(electionYear   = as.character(ANO_ELEICAO),
            electionID     = as.character(electionID),
            electionUnitID = SIGLA_UE,
            candidateID    = as.character(SEQUENCIAL_CANDIDATO),
            caseNum        = cases,
            protNum        = urls)

# bind rows
candidacyCases <- candidates.feather %>%
  filter(!(candidateID %in% search)) %>%
  bind_rows(invalid.cases) %>%
  select(-7)

# remove unnecessary objects
rm(list = objects(pattern = 'candidates|invalid'))


