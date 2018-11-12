################################################################################
# Electoral Crime and Performance Paper

# 03 Script:
# This script works through the preliminary analysis for the dissertation
# prospectus. It produces summary statistics, first, and second stage estimates
# for the effect of electoral crimes on performance.

# Author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# # setwd if not working with RStudio projects
# setwd(.)

# # clear environment if not working with RStudio projects
# rm(list = objects())

# import statements
library(tidyverse)
library(magrittr)

# load datasets
load('electoral.crimes.Rda')
load('sections2004.Rda')
load('sections2008.Rda')
load('sections2012.Rda')
load('sections2016.Rda')
load('vacancies2004.Rda')
load('vacancies2008.Rda')
load('vacancies2012.Rda')
load('vacancies2016.Rda')

################################################################################
# wrangle datasets used for analysis
# aggregate results for all candidates in election
sections2004 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))
sections2008 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))
sections2012 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))
sections2016 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))

# drop unnecessary rows from office vacancies datasets
vacancies2004 %<>% filter(CODIGO_CARGO %in% c(11, 13))
vacancies2008 %<>% filter(CODIGO_CARGO %in% c(11, 13))
vacancies2012 %<>% filter(CODIGO_CARGO %in% c(11, 13))
vacancies2016 %<>% filter(CD_CARGO     %in% c(11, 13))

################################################################################
# prepare outcomes for summary statistics
# 1. binary:   candidate had enough votes for election
# 2. share:    candidate's share of total votes
# 3. distance: candidate's vote distance (in p.p.) to elected candidate

# join with office vacancies so that we know how many spots were available in
# each race
candidates2004 <- candidates %>%
  filter(ANO_ELEICAO == 2004) %>%
  left_join(vacancies2004, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  select(-c(54:60))
candidates2008 <- candidates %>%
  filter(ANO_ELEICAO == 2008) %>%
  left_join(vacancies2008, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  select(-c(54:60))
candidates2012 <- candidates %>%
  filter(ANO_ELEICAO == 2012) %>%
  left_join(vacancies2012, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  select(-c(54:60))
candidates2016 <- candidates %>%
  filter(ANO_ELEICAO == 2016) %>%
  left_join(mutate(vacancies2016, SG_UE = as.character(SG_UE)),
            by = c('SIGLA_UE' = 'SG_UE', 'CODIGO_CARGO' = 'CD_CARGO')
  ) %>% names()
  select(-c(54:65))

################################################################################
# prepare covariates for summary statistics

################################################################################
# produce summary statistics table

################################################################################
# run first and second stage regressions

# quit
q('no')