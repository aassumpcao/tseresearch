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

# compute necessary votes used criteria 1 and 2.
elections <- left_join(sections, vacancies, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )
elections2008 <- sections2008 %>%
  left_join(vacancies2008, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )
elections2012 <- sections2012 %>%
  left_join(vacancies2012, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
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
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QT_VAGAS))
  )

# compute necessary votes using criterion 3
elections2004 <- sections2004 %>%
  mutate(rank = order(votes2, decreasing = TRUE)) %>%
  {left_join(elections2004, .,
             by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
  )} %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  filter(QTDE_VAGAS == rank) %>%
  ungroup()
elections2008 <- sections2008 %>%
  mutate(rank = order(votes2, decreasing = TRUE)) %>%
  {left_join(elections2008, .,
             by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
  )} %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  filter(QTDE_VAGAS == rank) %>%
  ungroup()
elections2012 <- sections2012 %>%
  mutate(rank = order(votes2, decreasing = TRUE)) %>%
  {left_join(elections2012, .,
             by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
  )} %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  filter(QTDE_VAGAS == rank) %>%
  ungroup()
elections2016 <- sections2016 %>%
  ungroup() %>%
  mutate(SIGLA_UE = as.integer(SIGLA_UE)) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  mutate(rank = order(votes2, decreasing = TRUE)) %>%
  {left_join(elections2016, .,
             by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
  )} %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
  filter(QT_VAGAS == rank) %>%
  ungroup()




