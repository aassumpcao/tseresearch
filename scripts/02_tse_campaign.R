### electoral crime paper
# campaign wrangling
#  this script wrangles the campaign data for all local elections in brazil
#  2004 and 2016.
# author: andre assumpcao
# email:  andre.assumpcao@gmail.com

### import statements
# import packages
library(magrittr)
library(readr)
library(tidyverse)

# load campaign expenditures data for all elections between 2004 and 2016
databases <- paste0('data/campaign', seq(2004, 2016, 4), '.Rda')
lapply(databases, load)

### body
# reformat every variable in every dataset to character
campaign2004 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2004')
campaign2006 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2006')
campaign2008 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2008')
campaign2010 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2010')
campaign2012 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2012')
campaign2014 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2014')
campaign2016 %<>% mutate_all(as.character) %>% mutate(ANO_ELEICAO = '2016')

# rename 2004 variables
names(campaign2004)[1:7]  <- names(campaign2008)[2:8]
names(campaign2004)[8:20] <- names(campaign2008)[10:22]
names(campaign2004)[21]   <- names(campaign2008)[24]
names(campaign2004)[22]   <- names(campaign2008)[27]

# rename 2006 variables
names(campaign2006)[1:6]  <- names(campaign2008)[1:6]
names(campaign2006)[7:20] <- names(campaign2008)[9:22]
names(campaign2006)[21]   <- names(campaign2008)[24]
names(campaign2006)[22]   <- names(campaign2008)[27]

# rename 2010 vars
campaign2010 %<>% rename(`Sigla  Partido` = `Sigla Partido`,
                         `Tipo de documento`= `Tipo do documento`,
                         `Descriçao da despesa` =`\"Descriçao da despesa\"`) %>%
                  select(-c(`Fonte recurso`, `Espécie recurso`,
                            `Entrega em conjunto?`))
# rename 2012 vars
campaign2012 %<>% rename(`Sigla da UE` = `Número UE`, `Nome da UE` = Município,
                         `Tipo de documento`= `Tipo do documento`,
                         `Cod setor econômico do fornecedor` =
                         `Cod setor econômico do doador`)
# rename 2014 vars
campaign2014 %<>% rename(`Tipo de documento` = `Tipo do documento`)

# bind datasets
campaign1 <- bind_rows(campaign2004, campaign2006, campaign2008)
campaign2 <- bind_rows(campaign2010, campaign2012, campaign2014, campaign2016)

# change order for election year variable
campaign1 %<>% select(-ANO_ELEICAO, everything(), ANO_ELEICAO)
campaign2 %<>% select(-ANO_ELEICAO, everything(), ANO_ELEICAO)

# create list of missing and matching variables in 2016 dataset
missing <- c(1, 8, c(16:18), 22, 23, 25)
matching <- c(23, 5, 9, 4, 2, 1, 17, 16, 20, 19, 11, 10, 12, 7, 6, 22, 29)

# match names and reassign
names(campaign2)[setdiff(1:25, missing)] <- names(campaign1)[matching]
names(campaign2)[8] <- 'CD_NUM_CPF'

# drop useless variables
campaign2 %<>% select(-missing)

# bind everything
campaign <- bind_rows(campaign1, campaign2)

# reformat campaign expenditure and convert to numeric format
campaign %<>%
  mutate(VR_DESPESA = VR_DESPESA %>% {as.numeric(str_replace(., ',', '.'))})

# reformat campaign expenditure and convert to numeric format
campaign %<>%
  group_by(ANO_ELEICAO, SG_UE, NM_CANDIDATO) %>%
  mutate(TOTAL_DESPESA = sum(VR_DESPESA)) %>%
  filter(row_number() == 1) %>%
  ungroup()

# create unique identifier for campaign expenditures
load('data/candidates1.Rda')
load('data/campaign.Rda')

# narrow candidates dataset down
candidates1 %<>%
  select(candidateID, ANO_ELEICAO, NUMERO_CANDIDATO, SIGLA_UE) %>%
  unite('tempID', ANO_ELEICAO, NUMERO_CANDIDATO, SIGLA_UE, remove = FALSE) %>%
  select(tempID, candidateID)

# merge onto campaign so that we have unique keys for campaign expenditures
campaign %<>%
  unite('tempID', ANO_ELEICAO, NR_CANDIDATO, SG_UE, remove = FALSE) %>%
  left_join(candidates1, 'tempID') %>%
  select(1:32, -tempID, candidateID) %>%
  filter(!is.na(candidateID))

# save to file
save(campaign, file = 'data/campaign.Rda')

# remove all for serial sourcing
rm(list = ls())
