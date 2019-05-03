### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial rulings after machine learning
#   classification. i load the results from both svm and xgboost estimations,
#   the best performing algorithms, to find the class of each judicial ruling.
#   finally, i build the analysis dataset compiling all other datasets.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

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
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )

# create third vote variable (for proportional elections)
elections <- sections %>%
  group_by(ANO_ELEICAO, SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  mutate(rank = order(votes2, decreasing = TRUE)) %>%
  {left_join(elections, ., joinkey.2)} %>%
  filter(QTDE_VAGAS == rank) %>%
  ungroup()
