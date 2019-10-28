### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial rulings after machine learning
#   classification. i load the results from both the linear svc estimation,
#   the best performing algorithm, to find the class of each judicial ruling.
#   finally, i build the analysis dataset compiling all other datasets.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

rm(list = ls())
# import libraries
library(magrittr)
library(tidyverse)

# load data
load('data/campaign.Rda')
load('data/candidatesPending.Rda')
load('data/electoralResults.Rda')
load('data/sections.Rda')
load('data/turnout.Rda')
load('data/vacancies.Rda')

# load csv files
tseClasses <- read_csv('data/tseClasses.csv')

# function definitions
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

# build final dataset
tse.analysis <- electoralResults %>%
  left_join(tseClasses, 'candidateID') %>%
  distinct(candidateID, .keep_all = TRUE)

# compute votes necessary for election in each cycle in three ways
#   1. mayors:          50% + 1 of the valid vote total           (maj.)
#   2. city councilors: votes / vacancies of the valid vote total (prop.)
#   3. city councilors: candidate voted within number of open seats. when
#                       candidates for city councilor don't reach the minimum
#                       number of votes for a guaranteed seat, this is the
#                       next best measure for whether they would have been
#                       elected or not had their candidacy been cleared from
#                       all electoral charges

# define relevant election years and criteria for join function across datasets
years <- seq(2004, 2016, 4)
joinkey.1 <- c('SIGLA_UE', 'CODIGO_CARGO', 'ANO_ELEICAO')
joinkey.2 <- c(joinkey.1, 'NUMERO_CANDIDATO' = 'NUM_VOTAVEL')

# edit vacancies dataset before joining onto sections
vacancies %<>%
  mutate(
    SIGLA_UE = ifelse(ANO_ELEICAO == 2016, str_pad(SG_UE,5,pad='0'), SIGLA_UE),
    CODIGO_CARGO = ifelse(ANO_ELEICAO == 2016, CD_CARGO, CODIGO_CARGO),
    QTDE_VAGAS = ifelse(ANO_ELEICAO == 2016, QT_VAGAS, QTDE_VAGAS)
  ) %>%
  mutate_all(as.character)

# aggregate results by electoral section
aggregated.sections <- sections %>%
  ungroup() %>%
  group_by(ANO_ELEICAO, SIGLA_UE, CODIGO_CARGO) %>%
  summarize(voto.secao.total = sum(voto.secao)) %>%
  ungroup() %>%
  mutate_all(as.character)

# aggregate results by electoral section and rank candidates
individual.politicians <- sections %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(ANO_ELEICAO, SIGLA_UE, CODIGO_CARGO) %>%
  arrange(ANO_ELEICAO, SIGLA_UE, CODIGO_CARGO, desc(NUM_VOTAVEL)) %>%
  mutate(voto.ranking = row_number()) %>%
  ungroup() %>%
  mutate_all(as.character)

# join analysis file with aggregation of electoral results by municipality.
# then, join onto vacancies so that we can calculate votees necessary for
# election
tse.analysis %<>%
  mutate_all(as.character) %>%
  left_join(aggregated.sections, joinkey.1) %>%
  left_join(individual.politicians, joinkey.2) %>%
  mutate(voto.secao = voto.secao.x) %>%
  select(-matches('\\.(y|x)$')) %>%
  left_join(vacancies, joinkey.1) %>%
  select(-matches('\\.(y|x)$')) %>%
  group_by(SIGLA_UE, ANO_ELEICAO, CODIGO_CARGO) %>%
  mutate_at(vars(voto.secao.total, QTDE_VAGAS), as.numeric) %>%
  mutate(
    votos.porcargo = case_when(CODIGO_CARGO == 11 ~ floor(voto.secao.total/2),
      CODIGO_CARGO == 13 ~ floor(voto.secao.total/QTDE_VAGAS)),
    vagas.porcargo = QTDE_VAGAS
  ) %>%
  ungroup()

# remove useless objects ls()
rm(list = objects(pattern = '^(a|can|e|i|j|s|tseClasses|turnout|v|y)'))

# rename variables in the remaining datasets
tse.analysis %<>%
  mutate_all(as.character) %>%
  transmute(
    election.year              = year,
    election.state             = state,
    election.ID                = electionID,
    office.ID                  = officeID,
    office.vacancies           = QTDE_VAGAS,
    candidate.ID               = candidateID,
    candidate.number           = NUMERO_CANDIDATO,
    candidate.name             = NOME_CANDIDATO,
    candidate.ssn              = CPF_CANDIDATO,
    candidate.dob              = DATA_NASCIMENTO,
    candidate.age              = IDADE_DATA_ELEICAO,
    candidate.ethnicity        = DESCRICAO_COR_RACA,
    candidate.ethnicity.ID     = CODIGO_COR_RACA,
    candidate.gender           = DESCRICAO_SEXO,
    candidate.gender.ID        = CODIGO_SEXO,
    candidate.occupation       = DESCRICAO_OCUPACAO,
    candidate.occupation.ID    = CODIGO_OCUPACAO,
    candidate.education        = DESCRICAO_GRAU_INSTRUCAO,
    candidate.education.ID     = COD_GRAU_INSTRUCAO,
    candidate.maritalstatus    = DESCRICAO_ESTADO_CIVIL,
    candidate.maritalstatus.ID = CODIGO_ESTADO_CIVIL,
    candidacy.situation        = DES_SITUACAO_CANDIDATURA,
    candidacy.situation.ID     = COD_SITUACAO_CANDIDATURA,
    candidacy.expenditures.max = DESPESA_MAX_CAMPANHA,
    candidacy.invalid.ontrial  = trialCrime,
    candidacy.invalid.onappeal = appealsCrime,
    candidacy.ruling.class     = class,
    party.number               = NUMERO_PARTIDO,
    party.coalition            = COMPOSICAO_LEGENDA,
    votes.election.candidate   = voto.secao,
    votes.election.total       = voto.secao.total,
    votes.valid.candidate      = voto.municipio,
    votes.ranking.candidate    = voto.ranking,
    votes.foroffice            = votos.porcargo
  )

# prepare outcomes in final dataset
tse.analysis %<>%
  mutate_at(vars(starts_with('votes'), office.vacancies), as.integer) %>%
  mutate(
    outcome.elected = ifelse(
      votes.election.candidate >= votes.foroffice |
      votes.ranking.candidate <= office.vacancies, 1, 0
    ),
    outcome.share = round(votes.election.candidate / votes.election.total, 3),
    outcome.distance = round(
      (votes.election.candidate - votes.foroffice) / votes.election.total, 3
    )
  )

# prepare covariates
#   1. age
#   2. gender
#   3. education
#   4. marital status
#   5. ethnicity             - not available before 2016
#   6. campaign expenditures
#   7. candidate's political experience

# wrangle age
tse.analysis %<>%
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
tse.analysis %<>%
  mutate(candidate.male = ifelse(candidate.gender.ID != 4, 1, 0)) %>%
  select(1:21, candidate.male, 24:38)

# wrangle education
tse.analysis %<>%
  select(-candidate.education.ID) %>%
  mutate(candidate.education = str_remove(candidate.education, 'ENSINO')) %>%
  mutate(candidate.education = str_trim(candidate.education)) %>%
  mutate(candidate.education = ifelse(
    candidate.education == 'NÃO INFORMADO', 'SUPERIOR COMPLETO',
    candidate.education
  ))

# wrangle marital status
tse.analysis %<>%
  mutate(candidate.maritalstatus = ifelse(
    candidate.maritalstatus == 'NÃO INFORMADO', 'SOLTEIRO(A)',
    candidate.maritalstatus)
  ) %>%
  select(-candidate.maritalstatus.ID)

# define vector for finding political occupations
politicians <- 'VEREADOR|PREFEITO|DEPUTADO|GOVERNADOR|SENADOR|PRESIDENTE'

# wrangle political experience
tse.analysis %<>%
  mutate(
    candidate.occupation = iconv(candidate.occupation, 'Latin1', 'ASCII'),
    candidate.experience = case_when(
      str_detect(candidate.occupation, politicians) == TRUE  ~ 1,
      str_detect(candidate.occupation, politicians) == FALSE ~ 0,
      is.na(str_detect(candidate.occupation, politicians))   ~ 0
    )
  )

# wrangle campaign expenditures
# select variables in final dataset that will be used to match campaign spending
campaign.match <- tse.analysis %>%
  select(candidate.ID, election.year, election.ID, candidate.number)

# define joinkey
joinkey <- c(
  'ANO_ELEICAO' = 'election.year', 'SG_UE' = 'election.ID',
  'NR_CANDIDATO' = 'candidate.number'
)

# filter observations down to municipal elections
campaign %>%
  filter(ANO_ELEICAO %in% seq(2004, 2016, 4) & DS_CARGO != 'Vice-prefeito') %>%
  mutate(CD_CARGO = as.character(ifelse(DS_CARGO == 'Vereador', 13, 11))) %>%
  inner_join(campaign.match, c('candidateID' = 'candidate.ID'), keep = TRUE) %>%
  group_by(candidateID) %>%
  summarize(x = sum(TOTAL_DESPESA)) %>%
  {left_join(tse.analysis, ., c('candidate.ID' = 'candidateID'))} %>%
  select(1:30, x, 31:36) %>%
  group_by(election.ID) %>%
  mutate(x = ifelse(is.na(x), mean(x, na.rm = TRUE), x)) %>%
  group_by(office.ID) %>%
  mutate(x = ifelse(is.na(x), mean(x, na.rm = TRUE), x)) %>%
  ungroup() %>%
  rename(candidacy.expenditures.actual = x) -> tse.analysis

# wrangle turnout
turnout %<>%
  mutate(SIGLA_UE = str_pad(SIGLA_UE, 5, 'left', '0')) %>%
  group_by(ANO_ELEICAO, SIGLA_UE, CODIGO_CARGO) %>%
  summarize(
    votes.election  = sum(as.integer(QTD_APTOS)),
    votes.turnout   = sum(as.integer(QTD_COMPARECIMENTO)),
    votes.absention = sum(as.integer(QTD_ABSTENCOES)),
    votes.invalid   = sum(as.integer(QT_VOTOS_NULOS),
                          as.integer(QT_VOTOS_BRANCOS)),
    votes.null      = sum(as.integer(QT_VOTOS_NULOS)),
    votes.blank     = sum(as.integer(QT_VOTOS_BRANCOS))
  ) %>%
  ungroup() %>%
  rename(
    election.year   = ANO_ELEICAO,
    election.ID     = SIGLA_UE,
    office.ID       = CODIGO_CARGO
  ) %>%
  select(matches('[a-z]'))

# define joinkey
joinkey <- c('election.year', 'election.ID', 'office.ID')

# join tse.analysis and turnout
tse.analysis %<>%
  left_join(turnout, joinkey) %>%
  rename(votes.valid = votes.total) %>%
  select(scraper.ID, matches('^election'), matches('outcome'),
    matches('^office'), matches('candidate'), matches('candidacy'),
    matches('party'), matches('^votes')
  )

#

tseSummary$stage
tseSentences


# save to file
save(tse.analysis, file = 'data/tseFinal.Rda')

# remove all for serial sourcing
rm(list = ls())
