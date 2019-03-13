### electoral crime paper
# candidates wrangling
#   this script wrangles the candidates in all local elections in brazil between
#   2004 and 2016.
# author: andre assumpcao
# email:  andre.assumpcao@gmail.com

### import statements
# import packages
library(here)
library(magrittr)
library(readr)
library(tidyverse)

# load data
load('candidates.2010.Rda')
load('candidates.2012.Rda')
load('candidates.2016.Rda')

### body
# bind all data
localCandidates <- bind_rows(candidates.2010, candidates.2012, candidates.2016)

# extract the status of candidacies at the time of election
situation <- select(localCandidates, DES_SITUACAO_CANDIDATURA) %>%
             unique() %>%
             unlist() %>%
             unname() %>%
             sort()

# break situations down into 'eligible' and 'ineligible'
#   eligible:   candidate will be displayed at electronic voting machine
#   ineligible: candidate will not be displayed at electronic voting machine
#   other:      registration not processed
#   appeals:    candidate had outstanding appeal on election day

# build vectors
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
appeals    <- c('DEFERIDO COM RECURSO', 'INDEFERIDO COM RECURSO', 'SUB JUDICE',
                'CASSADO COM RECURSO', 'CANCELADO COM RECURSO', 'SUB JÚDICE',
                'IMPUGNAÇÃO DE CANDIDATURA')

# create eligibility variable in data frame
localCandidates %<>% mutate(eligibility = DES_SITUACAO_CANDIDATURA %>%
  {case_when(. %in% eligible   ~ 'eligible', . %in% ineligible ~ 'ineligible',
             . %in% other      ~ 'other')})

# create appeals variable -- it indicates if candidates had an outstanding
# appeal on election day
localCandidates %<>%
  mutate(appeals = ifelse(DES_SITUACAO_CANDIDATURA %in% appeals, 1, 0))

# save full dataset
save(localCandidates, file = 'localCandidates.Rda')

# filter 2000 elections and assign unique ID used for scraping judicial decision
candidatesPending <- localCandidates %>%
  filter(ANO_ELEICAO > 2000 & appeals == 1) %>%
  mutate(scraperID = row_number())

# save dataset with candidates who had candidacy on appeal
save(candidatesPending, file = 'candidatesPending.Rda')
write_csv(candidatesPending, 'candidatesPending.csv')
