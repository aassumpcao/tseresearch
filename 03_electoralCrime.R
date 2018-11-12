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
# votes: aggregate votes for all candidates in election
sections2004 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes))
sections2008 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes))
sections2012 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes))
sections2016 %<>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS)) %>%
  arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes))

# vacancies: drop unnecessary rows from office vacancies datasets
vacancies2004 %<>% filter(CODIGO_CARGO %in% c(11, 13))
vacancies2008 %<>% filter(CODIGO_CARGO %in% c(11, 13))
vacancies2012 %<>% filter(CODIGO_CARGO %in% c(11, 13))
vacancies2016 %<>% filter(CD_CARGO     %in% c(11, 13))

# elections: compute votes necessary for election in each cycle in three ways
#   1. mayors:          50% + 1 of the valid vote total           (majoritarian)
#   2. city councilors: votes / vacancies of the valid vote total (proportional)
#   3. city councilors: candidate voted within number of open seats. when
#                       candidates for city councilor don't reach the minimum
#                       number of votes for a guaranteed seat, this is the next
#                       best measure for whether they would have been elected or
#                       not had their candidacy been cleared from all electoral
#                       charges

# compute necessary votes used criteria 1 and 2.
elections2004 <- sections2004 %>%
  left_join(vacancies2004, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes)) %>%
  mutate(election_votes = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )
elections2008 <- sections2008 %>%
  left_join(vacancies2008, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes)) %>%
  mutate(election_votes = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )
elections2012 <- sections2012 %>%
  left_join(vacancies2012, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes)) %>%
  mutate(election_votes = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )
elections2016 <- sections2016 %>%
  ungroup() %>%
  mutate(SIGLA_UE = as.integer(SIGLA_UE)) %>%
  left_join(vacancies2016,
            by = c('SIGLA_UE' = 'SG_UE', 'CODIGO_CARGO' = 'CD_CARGO')
  ) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QT_VAGAS) %>%
  summarize(total_votes = sum(votes)) %>%
  mutate(election_votes = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QT_VAGAS))
  )

# compute necessary votes using criterion 3



################################################################################
# prepare outcomes for summary statistics
# 1. binary:   candidate had enough votes for election
# 2. share:    candidate's share of total votes
# 3. distance: candidate's vote distance (in p.p.) to elected candidate

################################################################################
# prepare covariates for summary statistics

################################################################################
# produce summary statistics table

################################################################################
# run first and second stage regressions

# quit
q('no')