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
library(AER)

# load datasets for analysis
load('candidates.Rda')
load('elections.Rda')

# # load datasets for wrangling
# load('electoral.crimes.Rda')
# load('sections2004.Rda')
# load('sections2008.Rda')
# load('sections2012.Rda')
# load('sections2016.Rda')
# load('vacancies2004.Rda')
# load('vacancies2008.Rda')
# load('vacancies2012.Rda')
# load('vacancies2016.Rda')

# define function to calculate age from dob
calc_age <- function(birthDate, refDate = Sys.Date()) {
  # Args:
  #   birthDate: argument taking up date of birth (YMD format)
  #   refDate:   reference date to calculate age (also YMD format)

  # Returns:
  #   individual's age in years

  # Body:
  #   make one call to lubridate functions
  time <- lubridate::as.period(lubridate::interval(birthDate, refDate), 'year')

  #   return year element of period object
  return(time$year)
}

# define function to calculate corrected SEs for OLS regression
cse <- function(reg) {
  # Args:
  #   reg: regression object

  # Returns:
  #   matrix of robust standard errors

  # Body:
  #   call to vcovHC
  rob <- sqrt(diag(sandwich::vcovHC(reg, type = "HC1")))

  #   return matrix
  return(rob)
}

# define function to calculate corrected SEs for IV regression
ivse <- function(reg) {
  # Args:
  #   reg: IV regression object

  # Returns:
  #   matrix of robust standard errors

  # Body:
  #   call to robust.se
  rob <- ivpack::robust.se(reg)[,2]

  #   return matrix
  return(rob)
}

# ##############################################################################
# # wrangle datasets used for analysis
# # votes: aggregate votes for all candidates in election
# sections2004 %<>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
#   summarize(votes2 = sum(QTDE_VOTOS)) %>%
#   arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes2))
# sections2008 %<>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
#   summarize(votes2 = sum(QTDE_VOTOS)) %>%
#   arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes2))
# sections2012 %<>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
#   summarize(votes2 = sum(QTDE_VOTOS)) %>%
#   arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes2))
# sections2016 %<>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
#   summarize(votes2 = sum(QTDE_VOTOS)) %>%
#   arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes2))

# # vacancies: drop unnecessary rows from office vacancies datasets
# vacancies2004 %<>% filter(CODIGO_CARGO %in% c(11, 13))
# vacancies2008 %<>% filter(CODIGO_CARGO %in% c(11, 13))
# vacancies2012 %<>% filter(CODIGO_CARGO %in% c(11, 13))
# vacancies2016 %<>% filter(CD_CARGO     %in% c(11, 13))

# # elections: compute votes necessary for election in each cycle in three ways
# #   1. mayors:          50% + 1 of the valid vote total           (maj.)
# #   2. city councilors: votes / vacancies of the valid vote total (prop.)
# #   3. city councilors: candidate voted within number of open seats. when
# #                       candidates for city councilor don't reach the minimum
# #                       number of votes for a guaranteed seat, this is the
# #                       next best measure for whether they would have been
# #                       elected or not had their candidacy been cleared from
# #                       all electoral charges

# # compute necessary votes used criteria 1 and 2.
# elections2004 <- sections2004 %>%
#   left_join(vacancies2004, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
#   filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
#   group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
#   summarize(total_votes = sum(votes2)) %>%
#   mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
#     CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
#   )
# elections2008 <- sections2008 %>%
#   left_join(vacancies2008, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
#   filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
#   group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
#   summarize(total_votes = sum(votes2)) %>%
#   mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
#     CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
#   )
# elections2012 <- sections2012 %>%
#   left_join(vacancies2012, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
#   filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
#   group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
#   summarize(total_votes = sum(votes2)) %>%
#   mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
#     CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
#   )
# elections2016 <- sections2016 %>%
#   ungroup() %>%
#   mutate(SIGLA_UE = as.integer(SIGLA_UE)) %>%
#   left_join(vacancies2016,
#             by = c('SIGLA_UE' = 'SG_UE', 'CODIGO_CARGO' = 'CD_CARGO')
#   ) %>%
#   filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
#   group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QT_VAGAS) %>%
#   summarize(total_votes = sum(votes2)) %>%
#   mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
#     CODIGO_CARGO == 13 ~ floor(total_votes / QT_VAGAS))
#   )

# # compute necessary votes using criterion 3
# elections2004 <- sections2004 %>%
#   mutate(rank = order(votes2, decreasing = TRUE)) %>%
#   {left_join(elections2004, .,
#              by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
#   )} %>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
#   filter(QTDE_VAGAS == rank) %>%
#   ungroup()
# elections2008 <- sections2008 %>%
#   mutate(rank = order(votes2, decreasing = TRUE)) %>%
#   {left_join(elections2008, .,
#              by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
#   )} %>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
#   filter(QTDE_VAGAS == rank) %>%
#   ungroup()
# elections2012 <- sections2012 %>%
#   mutate(rank = order(votes2, decreasing = TRUE)) %>%
#   {left_join(elections2012, .,
#              by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
#   )} %>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
#   filter(QTDE_VAGAS == rank) %>%
#   ungroup()
# elections2016 <- sections2016 %>%
#   ungroup() %>%
#   mutate(SIGLA_UE = as.integer(SIGLA_UE)) %>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
#   mutate(rank = order(votes2, decreasing = TRUE)) %>%
#   {left_join(elections2016, .,
#              by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
#   )} %>%
#   group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
#   filter(QT_VAGAS == rank) %>%
#   ungroup()

# # mutate all electoral unit identifiers
# elections2004 %<>%
#   mutate(SIGLA_UE = as.character(SIGLA_UE), election.year = '2004')
# elections2008 %<>%
#   mutate(SIGLA_UE = as.character(SIGLA_UE), election.year = '2008')
# elections2012 %<>%
#   mutate(SIGLA_UE = as.character(SIGLA_UE), election.year = '2012')
# elections2016 %<>%
#   mutate(SIGLA_UE = str_pad(as.character(SIGLA_UE), 5, 'left', '0'),
#          QTDE_VAGAS = QT_VAGAS,
#          election.year = '2016') %>%
#   select(-QT_VAGAS) %>%
#   select(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS, everything())

# # build final election dataset
# elections <- rbind(elections2004, elections2008, elections2012, elections2016)

# # define last conditions for total votes
# elections %<>%
#   mutate(election_votes = ifelse(CODIGO_CARGO == 13 & (votes2 >= votes1),
#                                  votes1, votes2)
#   )

# # remove all necessary data
# rm(list = objects(pattern = '[0-9]'))

# # rename variables in the remaining datasets
# candidates %<>%
#   transmute(election.year              = ANO_ELEICAO,
#             election.stage             = NUM_TURNO,
#             election.state             = SIGLA_UF,
#             election.ID                = SIGLA_UE,
#             office.ID                  = CODIGO_CARGO,
#             candidate.ID               = SEQUENCIAL_CANDIDATO,
#             candidate.number           = NUMERO_CANDIDATO,
#             candidate.name             = NOME_CANDIDATO,
#             candidate.ssn              = CPF_CANDIDATO,
#             candidate.dob              = DATA_NASCIMENTO,
#             candidate.age              = IDADE_DATA_ELEICAO,
#             candidate.ethnicity        = DESCRICAO_COR_RACA,
#             candidate.ethnicity.ID     = CODIGO_COR_RACA,
#             candidate.gender           = DESCRICAO_SEXO,
#             candidate.gender.ID        = CODIGO_SEXO,
#             candidate.occupation       = DESCRICAO_OCUPACAO,
#             candidate.occupation.ID    = CODIGO_OCUPACAO,
#             candidate.education        = DESCRICAO_GRAU_INSTRUCAO,
#             candidate.education.ID     = COD_GRAU_INSTRUCAO,
#             candidate.maritalstatus    = DESCRICAO_ESTADO_CIVIL,
#             candidate.maritalstatus.ID = CODIGO_ESTADO_CIVIL,
#             candidate.votes            = votes,
#             candidacy.situation        = DES_SITUACAO_CANDIDATURA,
#             candidacy.situation.ID     = COD_SITUACAO_CANDIDATURA,
#             candidacy.expenditures     = DESPESA_MAX_CAMPANHA,
#             candidacy.invalid.ontrial  = trialCrime,
#             candidacy.invalid.onappeal = appealCrime,
#             party.number               = NUMERO_PARTIDO,
#             party.coalition            = COMPOSICAO_LEGENDA)

# elections %<>%
#   transmute(election.year            = election.year,
#             election.stage           = NUM_TURNO,
#             election.ID              = SIGLA_UE,
#             office.ID                = CODIGO_CARGO,
#             office.vacancies         = QTDE_VAGAS,
#             elected.candidate.number = NUM_VOTAVEL,
#             votes.total              = total_votes,
#             votes.foroffice          = election_votes)

# # write to disk
# save(candidates, file = 'candidates.Rda')
# save(elections,  file = 'elections.Rda')

################################################################################
# prepare outcomes for summary statistics
# 1. binary:   candidate had enough votes for election
# 2. share:    candidate's share of total votes
# 3. distance: candidate's vote distance (in p.p.) to elected candidate

# join datasets, create outcomes, and rearrange variables
analysis <- candidates %>%
  left_join(elections, by = c('election.year', 'election.stage',
    'election.ID', 'office.ID')) %>%
  mutate(
    candidate.votes  = as.integer(candidate.votes),
    outcome.elected  = ifelse(candidate.votes >= votes.foroffice, 1, 0),
    outcome.share    = round((candidate.votes / votes.total) * 100, digits = 2),
    outcome.distance = round((candidate.votes - votes.foroffice) * 100 /
                             votes.total, digits = 2)) %>%
  select(
    contains('election'), matches('office\\.'), contains('outcome'),
    contains('votes'), contains('candidate'), contains('candidacy'),
    contains('party')
  )

################################################################################
# prepare covariates for summary statistics
#   1. age
#   2. gender
#   3. education
#   4. marital status
#   5. ethnicity             - not available before 2016
#   6. campaign expenditures - not available for preliminary analysis
#   7. candidate's political experience

# wrangle age
analysis %<>%
  mutate(dob = lubridate::dmy(candidate.dob), candidate.dob = dob) %>%
  mutate(age = case_when(election.year == 2004 ~ calc_age(dob, '2004-10-03'),
                         election.year == 2008 ~ calc_age(dob, '2008-10-05'),
                         election.year == 2012 ~ calc_age(dob, '2012-10-07'),
                         election.year == 2016 ~ calc_age(dob, '2016-10-02'))
  ) %>%
  mutate(age = ifelse(is.na(age), as.integer(mean(age, na.rm = TRUE)), age)) %>%
  mutate(age = ifelse(age > 86, 2008 - age, age), candidate.age = age) %>%
  select(-age, -dob)

# wrangle gender
analysis %<>%
  mutate(candidate.male = ifelse(candidate.gender.ID != 4, 1, 0)) %>%
  select(1:20, candidate.male, 23:37)

# wrangle education
analysis %<>%
  select(-candidate.education.ID) %>%
  mutate(candidate.education = str_remove(candidate.education, 'ENSINO')) %>%
  mutate(candidate.education = str_trim(candidate.education)) %>%
  mutate(candidate.education = ifelse(candidate.education == 'NÃO INFORMADO',
                                      'SUPERIOR COMPLETO', candidate.education)
  )

# wrangle marital status
analysis %<>%
  mutate(candidate.maritalstatus = ifelse(
    candidate.maritalstatus == 'NÃO INFORMADO', 'SOLTEIRO(A)',
    candidate.maritalstatus)
  ) %>%
  select(-candidate.maritalstatus.ID)

# wrangle candidacy expenditures
analysis %<>%
  mutate(candidacy.expenditures = as.integer(candidacy.expenditures)) %>%
  mutate(candidacy.expenditures = replace_na(
    candidacy.expenditures, mean(candidacy.expenditures, na.rm = TRUE))
  )

# define vector for finding political occupations
politicians <- 'VEREADOR|PREFEITO|DEPUTADO|GOVERNADOR|SENADOR|PRESIDENTE'

# wrangle political experience
analysis %<>%
  mutate(candidate.occupation = iconv(candidate.occupation,'Latin1','ASCII'))%>%
  mutate(candidate.experience = case_when(
    str_detect(candidate.occupation, politicians) == TRUE  ~ 1,
    str_detect(candidate.occupation, politicians) == FALSE ~ 0,
    is.na(str_detect(candidate.occupation, politicians))   ~ 0)
  )

# transform variable type to factor
analysis %<>% mutate_at(vars(matches('male|education|maritalstatus')), factor)

################################################################################
# produce summary statistics table
# define outcomes
outcomes   <- c('outcome.elected', 'outcome.distance', 'outcome.share')

# define instruments
instrumented <- 'candidacy.invalid.ontrial'
instrument   <- 'candidacy.invalid.onappeal'

# define independent variables
variables  <- c('candidate.age', 'candidate.male', 'candidate.education',
                'candidate.maritalstatus', 'candidate.experience',
                'candidacy.expenditures')

# define labels for independent variables
var.labels <- c('Age', 'Male', 'Level of Education', 'Marital Status',
                'Political Experience', 'Campaign Expenditures')

################################################################################
# run preliminary analysis
# define ols models for all outcomes
ols0 <- outcomes %>% paste0(., ' ~ ', instrumented)
ols1 <- outcomes %>%
  paste0(., ' ~ ', instrumented, ' + ', paste0(variables, collapse = ' + '))

# define reduced-form models for all outcomes
red0 <- outcomes %>% paste0(., ' ~ ', instrument)
red1 <- outcomes %>%
  paste0(., ' ~ ', instrument, ' + ', paste0(variables, collapse = ' + '))

# define 2sls models for all outcomes
iv0 <- outcomes %>% paste0(., ' ~ ', instrumented, ' | ', instrument)
iv1 <- outcomes %>% paste0(., ' ~ ', instrumented, ' | ', instrument, ' + ',
                           paste0(variables, collapse = ' + '))


# run regressions for ols without covariates
for (i in 1:length(ols0)) {

  # define formula from ols vector
  formula <- as.formula(ols0[i])

  # run regression using formula above
  reg <- lm(formula, data = analysis)

  # assign new name
  assign(paste0('ols0.outcome', i), reg)

  # remove useless objects
  if (i == length(ols0)) {rm(reg, i, formula)}
}

# run regressions for ols with covariates
for (i in 1:length(ols1)) {

  # define formula from ols vector
  formula <- as.formula(ols1[i])

  # run regression using formula above
  reg <- lm(formula, data = analysis)

  # assign new name
  assign(paste0('ols1.outcome', i), reg)

  # remove useless objects
  if (i == length(ols1)) {rm(reg, i, formula)}
}
# run regressions for ols without covariates
for (i in 1:length(ols0)) {

  # define formula from ols vector
  formula <- as.formula(ols0[i])

  # run regression using formula above
  reg <- lm(formula, data = analysis)

  # assign new name
  assign(paste0('ols0.outcome', i), reg)

  # remove useless objects
  if (i == length(ols0)) {rm(reg, i, formula)}
}

# run regressions for ols with covariates
for (i in 1:length(ols1)) {

  # define formula from ols vector
  formula <- as.formula(ols1[i])

  # run regression using formula above
  reg <- lm(formula, data = analysis)

  # assign new name
  assign(paste0('ols1.outcome', i), reg)

  # remove useless objects
  if (i == length(ols1)) {rm(reg, i, formula)}
}



# # quit
# q('no')
