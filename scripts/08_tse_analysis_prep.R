### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial rulings after machine learning
#   classification. i load the results from both svm and xgboost estimations,
#   the best performing algorithms, to find the class of each judicial ruling.
#   finally, i build the analysis dataset compiling all other datasets.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### data and library calls
# import libraries
library(magrittr)
library(tidyverse)

# load data
load('data/campaign.Rda')
load('data/sections.Rda')
load('data/tseAnalysis.Rda')
load('data/tseSummary.Rda')
load('data/vacancies.Rda')

# load csv files
tseObserved  <- read_csv('data/tseObserved.csv') %>%
                mutate(scraperID = as.character(scraperID))
tsePredicted <- read_csv('data/tsePredicted.csv') %>%
                mutate(scraperID = as.character(scraperID))
tseClassProb <- read_csv('data/tseClassProb.csv')

### function definitions
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

### body
# define same classes as python
classes <- c('Ficha Limpa' = 0, 'Lei das Eleições' = 1,
             'Requisito Faltante' = 2, 'Partido/Coligação' = 3)

# build analysis dataset from scratch
tse.analysis <- electoralCrimes %>%
  select(scraperID, ruling.class = broad.rejection)

# join the predictions for each ruling class
tse.analysis %<>%
  left_join(tseObserved, by = 'scraperID') %>%
  distinct(scraperID, .keep_all = TRUE) %>%
  select(-rulingClass) %>%
  left_join(tsePredicted, by = 'scraperID') %>%
  distinct(scraperID, .keep_all = TRUE) %>%
  select(-xgPred) %>%
  mutate(ruling.class = ruling.class %>% {ifelse(is.na(.), svmPred, .)})

# convert ruling class numbers into the same earlier categories
for (i in 1:4) {
  tse.analysis$ruling.class %<>% {ifelse(. == i - 1, names(classes)[[i]], .)}
  if (i == 4) {rm(i)}
}

# join with earlier data
tse.analysis %<>% select(-svmPred) %>% left_join(electoralCrimes, 'scraperID')

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
joinkey.2 <- c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO', 'ANO_ELEICAO')

# edit vacancies dataset before joining onto sections
vacancies %<>%
  mutate(
    SIGLA_UE     = ifelse(ANO_ELEICAO == 2016, str_pad(SG_UE, 5, pad = '0'),
                          SIGLA_UE),
    CODIGO_CARGO = ifelse(ANO_ELEICAO == 2016, CD_CARGO, CODIGO_CARGO),
    QTDE_VAGAS   = ifelse(ANO_ELEICAO == 2016, QT_VAGAS, QTDE_VAGAS)
  )

# create first and second vote variable (for maj. and prop. elections)
elections <- vacancies %>%
  {left_join(filter(sections, ANO_ELEICAO %in% years), ., joinkey.1)} %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, ANO_ELEICAO, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS)))

# create third vote variable (for proportional elections)
elections <- sections %>%
  group_by(ANO_ELEICAO, SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  mutate(rank = order(votes2, decreasing = TRUE)) %>%
  {left_join(elections, ., joinkey.2)} %>%
  filter(QTDE_VAGAS == rank) %>%
  ungroup()

# define last conditions for total votes
elections$election_votes <- elections %$%
  ifelse(CODIGO_CARGO == 13 & (votes2 >= votes1), votes1, votes2)

# remove useless objects ls()
rm(list = objects(pattern = 'lass|join|Summ|Pred|Obser|years|local'))

# rename variables in the remaining datasets
tse.analysis %<>%
  mutate_all(as.character) %>%
  transmute(election.year              = ANO_ELEICAO,
            election.stage             = NUM_TURNO,
            election.state             = SIGLA_UF,
            election.ID                = SIGLA_UE,
            office.ID                  = CODIGO_CARGO,
            scraper.ID                 = scraperID,
            candidate.ID               = SEQUENCIAL_CANDIDATO,
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
            candidate.votes            = as.integer(votes),
            candidacy.situation        = DES_SITUACAO_CANDIDATURA,
            candidacy.situation.ID     = COD_SITUACAO_CANDIDATURA,
            candidacy.expenditures.max = DESPESA_MAX_CAMPANHA,
            candidacy.invalid.ontrial  = trialCrime,
            candidacy.invalid.onappeal = appealCrime,
            candidacy.ruling.class     = ruling.class,
            party.number               = NUMERO_PARTIDO,
            party.coalition            = COMPOSICAO_LEGENDA)

elections %<>%
  mutate_all(as.character) %>%
  transmute(election.year            = ANO_ELEICAO,
            election.stage           = NUM_TURNO,
            election.ID              = SIGLA_UE,
            office.ID                = CODIGO_CARGO,
            office.vacancies         = QTDE_VAGAS,
            elected.candidate.number = NUM_VOTAVEL,
            votes.total              = as.integer(total_votes),
            votes.foroffice          = as.integer(election_votes))

# prepare outcomes in final dataset
tse.analysis %<>%
  left_join(elections, by = c('election.year', 'election.stage',
    'election.ID', 'office.ID')) %>%
  mutate(
    candidate.votes  = as.integer(candidate.votes),
    outcome.elected  = ifelse(candidate.votes >= votes.foroffice, 1, 0),
    outcome.share    = round((candidate.votes / votes.total) * 100, digits = 2),
    outcome.distance = round((candidate.votes - votes.foroffice) * 100 /
                              votes.total, digits = 2)
  ) %>%
  select(
    contains('election'), matches('office|scraper\\.'), contains('outcome'),
    contains('votes'), contains('candidate'), contains('candidacy'),
    contains('party')
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
  mutate(candidate.education = ifelse(candidate.education == 'NÃO INFORMADO',
                                      'SUPERIOR COMPLETO', candidate.education))
# wrangle marital status
tse.analysis %<>%
  mutate(candidate.maritalstatus = ifelse(
    candidate.maritalstatus == 'NÃO INFORMADO', 'SOLTEIRO(A)',
    candidate.maritalstatus)) %>%
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
campaign.match <- tse.analysis %>% select(1, 4:6, 15)

# define joinkey
joinkey <- c('ANO_ELEICAO' = 'election.year', 'SG_UE' = 'election.ID',
             'NR_CANDIDATO' = 'candidate.number')

# filter observations down to municipal elections
campaign %>%
  filter(ANO_ELEICAO %in% seq(2004, 2016, 4) & DS_CARGO != 'Vice-prefeito') %>%
  mutate(CD_CARGO = ifelse(DS_CARGO == 'Vereador', 13, 11)) %>%
  inner_join(campaign.match, joinkey) %>%
  group_by(scraper.ID) %>%
  summarize(x = sum(TOTAL_DESPESA)) %>%
  {left_join(tse.analysis, ., 'scraper.ID')} %>%
  select(1:30, x, 31:36) %>%
  group_by(election.ID) %>%
  mutate(x = ifelse(is.na(x), mean(x, na.rm = TRUE), x)) %>%
  group_by(office.ID) %>%
  mutate(x = ifelse(is.na(x), mean(x, na.rm = TRUE), x)) %>%
  ungroup() %>%
  rename(candidacy.expenditures.actual = x) -> tse.analysis

# add turnout
# add ses variables

# remove useless objects
rm(joinkey, campaign.match)
