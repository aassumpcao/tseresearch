################################################################################
# Electoral Crime and Performance Paper

# 01 Script:
# This script narrows down the database of candidates who had their
# candidacies appealed before the elections but have not heard back before
# election date. After it filters down candidates, it prepares the data for the
# TSE case scraper, which is a program that visits each candidate's website at
# TSE and downloads the case and protocol number for all their candidacies.

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

# set environment var
Sys.setenv(RETICULATE_PYTHON = '/anaconda3/bin/python')
# source_python('./tse_case.py')

# load statements
load('candidates.2010.Rda')
load('candidates.2012.Rda')
load('candidates.2016.Rda')

################################################################################
# candidates wrangling
# find all possible candidacy situations on election day
# up to 2010
candidacy.situation.upto.2010 <- candidates.2010 %>%
  select(DES_SITUACAO_CANDIDATURA) %>%
  unique() %>%
  unlist() %>%
  unname()

# in 2012
candidacy.situation.in.2012 <- candidates.2012 %>%
  select(DES_SITUACAO_CANDIDATURA) %>%
  unique() %>%
  unlist() %>%
  unname()

# in 2016
candidacy.situation.in.2016 <- candidates.2016 %>%
  select(DES_SITUACAO_CANDIDATURA) %>%
  unique() %>%
  unlist() %>%
  unname()

# join situations across all elections
candidacy.situation <- unique(c(candidacy.situation.upto.2010,
                                candidacy.situation.in.2012,
                                candidacy.situation.in.2016))

# break situations down into 'eligible' and 'ineligible'
# eligible:   candidate will be displayed at electronic voting machine
# ineligible: candidate will not be displayed at electronic voting machine
# other:      registration not processed
eligible   <- c('DEFERIDO', 'DEFERIDO COM RECURSO', 'PENDENTE DE JULGAMENTO',
                'INDEFERIDO COM RECURSO', 'CASSADO COM RECURSO',
                'CANCELADO COM RECURSO', 'IMPUGNAÇÃO DE CANDIDATURA',
                'SUB JUDICE', 'SUB JÚDICE')
ineligible <- c('INDEFERIDO', 'CANCELAMENTO', 'FALECIDO', 'CASSADO',
                'RENÚNCIA', 'NÃO CONHECIMENTO DO PEDIDO', 'CANCELADO',
                'IMPUGNADO', 'INELEGÍVEL', 'FALECIMENTO',
                'HOMOLOGAÇÃO DE RENÚNCIA', 'CASSAÇÃO DO REGISTRO',
                'INDEFERIDO POR IMPUGNAÇÃO')
other      <- c('PENDENTE DE JULGAMENTO', 'PENDENTE', 'AGUARDANDO JULGAMENTO',
                'SUBSTITUTO MAJORITÁRIO PENDENTE DE JULGAMENTO',
                'SUBSTITUTO PENDENTE DE JULGAMENTO')

# create candidacy situation dataset
candidacy.situation %<>%
  {tibble(situation = .)} %>%
   mutate(eligibility = case_when(situation %in% eligible   ~ 'eligible',
                                  situation %in% ineligible ~ 'ineligible',
                                  situation %in% other      ~ 'other')
   )

# filter down candidacy situations in which an appeal has been filed but has not
# been ruled by election day
eligible.appeal <- c('DEFERIDO COM RECURSO', 'INDEFERIDO COM RECURSO',
                     'CASSADO COM RECURSO', 'CANCELADO COM RECURSO',
                     'IMPUGNAÇÃO DE CANDIDATURA', 'SUB JUDICE', 'SUB JÚDICE')

# filter datasets according to situation above
appealing.candidates2010 <- candidates.2010 %>%
  filter(DES_SITUACAO_CANDIDATURA %in% eligible.appeal)
appealing.candidates2012 <- candidates.2012 %>%
  filter(DES_SITUACAO_CANDIDATURA %in% eligible.appeal)
appealing.candidates2016 <- candidates.2016 %>%
  filter(DES_SITUACAO_CANDIDATURA %in% eligible.appeal)

# bind observations
candidates.pending <- bind_rows(appealing.candidates2010,
                                appealing.candidates2012,
                                appealing.candidates2016)
# drop 2000 elections
candidates.pending %<>% filter(ANO_ELEICAO != 2000)

# save candidates pending final ruling and candidacy situation datasets
save(candidacy.situation, file = 'candidacy.situation.Rda')
save(candidates.pending,  file = 'candidates.pending.Rda')

# delete unnecessary vectors
rm(list = objects(pattern = 'candidacy\\.situation|ligible|other|appealing'))

################################################################################
# candidates preparation for TSE scraper
# add unique election ID for the elections in 2004
electionID.2004 <- 14431

# create vector of supplemental elections in 2008
supplemental.elections2008 <- candidates.pending %>%
  filter(ANO_ELEICAO == 2008) %>%
  filter(DESCRICAO_ELEICAO != 'Eleições 2008') %>%
  arrange(SIGLA_UF, DESCRICAO_UE) %>%
  select(DESCRICAO_ELEICAO) %>%
  unlist() %>%
  unique()

# add general election to vector
supplemental.elections2008 <- c('Eleições 2008', supplemental.elections2008)

# add unique election ID for the supplemental elections above
electionID.2008 <- c(14422, 17522, 17524)

# create vector of supplemental elections in 2012
supplemental.elections2012 <- candidates.pending %>%
  filter(ANO_ELEICAO == 2012) %>%
  filter(DESCRICAO_ELEICAO != 'ELEIÇÃO MUNICIPAL 2012') %>%
  arrange(SIGLA_UF, DESCRICAO_UE) %>%
  select(DESCRICAO_ELEICAO) %>%
  unlist() %>%
  unique()

# add general election to vector
supplemental.elections2012 <- c('ELEIÇÃO MUNICIPAL 2012',
                                supplemental.elections2012)

# add unique election ID for the supplemental elections above
electionID.2012 <- c(1699, 1700, 1736, 1729, 1776, 1697, 1675, 1771, 1681, 1758,
                     1731, 1714, 1720, 1743, NA, 677, 1747, 663, 1772, 678,
                     1721, 1740, 1680, 1735, 670, 1757, 1722)

# create vector of supplemental elections in 2016
supplemental.elections2016 <- candidates.pending %>%
  filter(ANO_ELEICAO == 2016) %>%
  filter(DESCRICAO_ELEICAO != 'Eleições Municipais 2016') %>%
  arrange(SIGLA_UF, DESCRICAO_UE) %>%
  select(DESCRICAO_ELEICAO) %>%
  unlist() %>%
  unique()

# add general election to vector
supplemental.elections2016 <- c('Eleições Municipais 2016',
                               supplemental.elections2016)

# add unique election ID for the supplemental elections above
electionID.2016 <- c(2, 93810, 91463, 60819, 70905, 68881, 36506, 93796, 42911,
                     36285, 96930, 94972, 95019, 69133, 22424, 92548, 70880)

# wrangle election type
elections <- tibble(
  match      = c('ELEICOES 2004', supplemental.elections2008,
                 supplemental.elections2012, supplemental.elections2016),
  electionID = c(electionID.2004, electionID.2008, electionID.2012,
                 electionID.2016)
  )

# join electionID onto candidates database
candidates.pending %<>%
  left_join(elections, by = c('DESCRICAO_ELEICAO' = 'match')) %>%
  mutate(DESCRICAO_ELEICAO = ifelse(is.na(DESCRICAO_ELEICAO), 17525,
                                    DESCRICAO_ELEICAO))

################################################################################
# corrections
# (1) incorrect candidate numbers that need changing
old <- c(40000009724, 50000047524, 50000047521, 90000030491, 120000008348)
new <- c(40000001667, 50000025615, 50000025614, 90000007021, 120000003450)

# find positions in column 'SEQUENCIAL_CANDIDATO'
replace.positions <- which(candidates.pending$SEQUENCIAL_CANDIDATO %in% old)

# replace old numbers for new numbers
candidates.pending[replace.positions, 'SEQUENCIAL_CANDIDATO'] <- new

# correct electionID (column 47) for one candidate
candidates.pending[which(candidates.pending[, 12] == 120000003450), 47] <- 1699

# (2) candidates whose candidacy has been wrongly recorded on website
issue1 <- which(candidates.pending$SEQUENCIAL_CANDIDATO == 50000047516)

# (3) candidates whose information is not available online, just in raw electoral
# court datasets
# unavailable numbers
search <- c(50000047738, 50000047739, 140000024289, 140000024745, 160000039647,
            160000039646, 200000007872, 200000007858, 200000010277, 50000032049)

# mark rows in which this is a problem
issue2 <- which(candidates.pending$SEQUENCIAL_CANDIDATO %in% search)

################################################################################
# write data in python-readable format
# select meaningful variables
candidates.feather <- candidates.pending %>%
  transmute(electionYear    = as.character(ANO_ELEICAO),
            electionID      = as.character(electionID),
            electoralUnitID = as.character(SIGLA_UE),
            candidateID     = as.character(SEQUENCIAL_CANDIDATO)) %>%
  filter(!row_number() %in% c(issue1, issue2))

# write to disk
write_feather(candidates.feather, path = './candidates.feather')

# remove useless stuff
rm(list = objects(pattern = '\\.election'))

# run scraper on python (should take 20h to download everything)
system('python 01_electoralCrime.py')

################################################################################
# check
# load results and check
candidates.feather <- read_feather('candidateCases.feather')
names(candidates.feather) <- candidates.feather[1,]
candidates.feather %<>% slice(-1)

# check invalid case numbers (#1)
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
# (#1)

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
# source_python('01_electoralCrime.py')

# load corrections
invalid.cases <- read_feather('invalidCases.feather')
names(invalid.cases) <- invalid.cases[1,]
invalid.cases %<>% slice(-1)

# replace
replace.positions <- which(candidates.feather$candidateID %in% old)
candidates.feather[replace.positions, 5:6] <- invalid.cases[, 5:6]

# remove unnecessary files
rm(new, old, remaining)

# (#2)
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

# (#3)
# candidates whose case numbers are invalid despite their protocol numbers
# being valid
invalid.cases <- candidacyCases %>%
  filter(str_detect(caseNum, 'Informação')) %>%
  slice(-1)

# write to disk
write_feather(invalid.cases, path = './candidates.feather')

# run python script
# source_python('01_electoralCrime.py')

# load corrections
invalid.cases <- read_feather('invalidCases.feather')
names(invalid.cases) <- invalid.cases[1,]
invalid.cases %<>% slice(-1)

# replace
replace <- which(candidacyCases$candidateID %in% unlist(invalid.cases[,4]))
replace <- replace[c(1, 3:8)]
candidacyCases[replace, 5:6] <- invalid.cases[, 5:6]

# (#4)
# Last manual replace
which(str_detect(candidacyCases$protNum, 'nprot=undefined'))
candidacyCases[2552, 5] <- '00000037320136210076'
candidacyCases[2552, 6] <- str_replace(candidacyCases[2552, 6],
                                       pattern = 'undefined(.){15}null',
                                       '31362013&comboTribunal=rs')

# remove unnecessary objects
rm(list = objects(pattern = 'invalid'))

# fix case numbers
candidacyCases %<>%
  mutate_at(vars(caseNum), str_remove_all, pattern = '-|\\.') %>%
  mutate_at(vars(caseNum), str_pad, 20, side = 'left', pad = '0')

# write to disk
save(candidacyCases, file = './candidacyCases.Rda')

# join with candidacy information
candidates %<>%
  mutate(electionID           = as.character(electionID),
         SEQUENCIAL_CANDIDATO = as.character(SEQUENCIAL_CANDIDATO)) %>%
  {left_join(candidacyCases, ., by = c('electionID'  = 'electionID',
                                       'candidateID' = 'SEQUENCIAL_CANDIDATO'))}

# write to disk
save(candidates, file = './candidates.Rda')

# quit r
q()