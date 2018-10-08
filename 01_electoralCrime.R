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
  transmute(candidateID     = as.character(SEQUENCIAL_CANDIDATO),
            electionYear    = as.character(ANO_ELEICAO),
            electoralUnitID = as.character(SIGLA_UE),
            electionID      = as.character(electionID)) %>%
  filter(!row_number() %in% c(2074, 2075))

# write to disk
write_feather(candidates.feather, path = './candidates.feather')

# remove useless stuff
rm(list = objects(pattern = '\\.|election'))

# run scraper on python
source_python('01_electoralCrime.py')