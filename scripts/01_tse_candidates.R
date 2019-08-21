### electoral crime paper
# candidates wrangling. this script wrangles the candidates in all local
# elections in Brazil between 2004 and 2016. i then use these candidates and
# find their court documents online
# author: andre assumpcao
# email:  andre.assumpcao@gmail.com

### import statements
# import packages
library(magrittr)
library(readr)
library(tidyverse)

# load data available on tse's website
load('data/candidates.upto.2010.Rda')
load('data/candidates.2012.Rda')
load('data/candidates.2016.Rda')

# load data sent by tse
candidaturas2004 <- read_csv('data/SITUACAO_CANDIDATURAS_2004.csv') %>%
                    mutate_all(as.character)
candidaturas2008 <- read_csv('data/SITUACAO_CANDIDATURAS_2008.csv') %>%
                    mutate_all(as.character)
candidaturas2012 <- read_csv('data/SITUACAO_CANDIDATURAS_2012.csv') %>%
                    mutate_all(as.character)
candidaturas2016 <- read_csv('data/SITUACAO_CANDIDATURAS_2016.csv') %>%
                    mutate_all(as.character)

### body
# bind all candidacies
candidates1 <- bind_rows(candidates.upto.2010, candidates.2012, candidates.2016)
candidates2 <- bind_rows(
  candidaturas2004, candidaturas2008, candidaturas2012, candidaturas2016
)

# extract the status of candidacies at the time of election
situation1 <- select(candidates1, DES_SITUACAO_CANDIDATURA) %>%
              unique() %>%
              unlist() %>%
              unname() %>%
              sort()
situation2 <- select(candidates2, `Situação Candidatura`) %>%
              unique() %>%
              unlist() %>%
              unname() %>%
              sort()

# create unique identifier for candidates. for dataset 2, you should also
# eliminate erros in situation variable
candidates1 %<>%
  mutate(ANO_ELEICAO = as.character(ANO_ELEICAO)) %>%
  unite('candidateID', c('ANO_ELEICAO', 'CPF_CANDIDATO'), remove = FALSE)
candidates2 %<>%
  unite('candidateID', 1:2, remove = FALSE) %>%
  mutate(`Situação Candidatura` = str_replace(`Situação Candidatura`,'\\*', ''))

# break situations down into 'eligible' and 'ineligible'
#   eligible:   candidate will be displayed at electronic voting machine
#   ineligible: candidate will not be displayed at electronic voting machine
#   other:      registration not processed
#   appeals:    candidate had outstanding appeal on election day

# build vectors
eligible <- c(
  'DEFERIDO', 'DEFERIDO COM RECURSO', 'PENDENTE DE JULGAMENTO',
  'INDEFERIDO COM RECURSO', 'CASSADO COM RECURSO', 'CANCELADO COM RECURSO',
  'IMPUGNAÇÃO DE CANDIDATURA', 'SUB JUDICE', 'SUB JÚDICE'
)
ineligible <- c(
  'INDEFERIDO', 'CANCELAMENTO', 'FALECIDO', 'CASSADO', 'RENÚNCIA',
  'NÃO CONHECIMENTO DO PEDIDO', 'CANCELADO', 'IMPUGNADO', 'INELEGÍVEL',
  'FALECIMENTO', 'HOMOLOGAÇÃO DE RENÚNCIA', 'CASSAÇÃO DO REGISTRO',
  'INDEFERIDO POR IMPUGNAÇÃO'
)
other <- c(
  'PENDENTE DE JULGAMENTO', 'PENDENTE', 'AGUARDANDO JULGAMENTO',
  'SUBSTITUTO MAJORITÁRIO PENDENTE DE JULGAMENTO',
  'SUBSTITUTO PENDENTE DE JULGAMENTO'
)
appeals <- c(
    'DEFERIDO COM RECURSO', 'INDEFERIDO COM RECURSO', 'SUB JUDICE',
    'CASSADO COM RECURSO', 'CANCELADO COM RECURSO', 'SUB JÚDICE',
    'IMPUGNAÇÃO DE CANDIDATURA'
)

# create eligibility variable in data frame
candidates1 %<>% mutate(eligibility = DES_SITUACAO_CANDIDATURA %>%
  {case_when(. %in% eligible   ~ 'eligible', . %in% ineligible ~ 'ineligible',
             . %in% other      ~ 'other')})
candidates2 %<>% mutate(eligibility = `Situação Candidatura` %>%
  {case_when(. %in% eligible   ~ 'eligible', . %in% ineligible ~ 'ineligible',
             . %in% other      ~ 'other')})

# create appeals variable -- it indicates if candidates had an outstanding
# appeal on election day
candidates1 %<>%
  mutate(appeals = ifelse(DES_SITUACAO_CANDIDATURA %in% appeals, 1, 0))
candidates2 %<>%
  mutate(appeals = ifelse(`Situação Candidatura` %in% appeals, 1, 0))

# check differences of datasets
filter(candidates1, ANO_ELEICAO > 2000) %$% table(ANO_ELEICAO, appeals)
candidates2 %$% table(`Ano Eleição`, appeals)

# save full dataset
save(candidates1, file = 'data/candidates1.Rda')
save(candidates2, file = 'data/candidates2.Rda')

# rename variables
names(candidates2)[2:10] <- c(
  'year', 'cpf', 'name', 'candID', 'officeID', 'office', 'unit', 'state',
  'candidacy'
)

# extract election number from list of candidates from website
electionID <- c('14431', '14422', '1699', '2')
candidates2 %<>% mutate(electionID = year %>%
  {case_when(. == 2004 ~ electionID[1], . == 2008 ~ electionID[2],
             . == 2012 ~ electionID[3], . == 2016 ~ electionID[4])})

# filter candidates whose appeals were outstanding on day of election and focus
# only on mayor and city council candidates
candidatesPending <- filter(candidates2, appeals == 1 & officeID %in% c(11, 13))

# save dataset with candidates who had candidacy on appeal
save(candidatesPending, file = 'data/candidatesPending.Rda')
write_csv(candidatesPending, 'data/candidatesPending.csv')

# remove all for serial sourcing
rm(list = ls())
