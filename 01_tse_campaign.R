### electoral crime paper
# campaign wrangling
#   this script wrangles the campaign data for all local elections in brazil
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
load('campaign2004.Rda')
load('campaign2006.Rda')
load('campaign2008.Rda')
load('campaign2010.Rda')
load('campaign2012.Rda')
load('campaign2014.Rda')
load('campaign2016.Rda')

### body
# reformat everything
campaign2004 %<>% mutate_all(as.character)
campaign2006 %<>% mutate_all(as.character)
campaign2008 %<>% mutate_all(as.character)
campaign2010 %<>% mutate_all(as.character)
campaign2012 %<>% mutate_all(as.character)
campaign2014 %<>% mutate_all(as.character)
campaign2016 %<>% mutate_all(as.character)

# rename 2004 variables
names(campaign2004)[1:7] <- names(campaign2008)[2:8]
names(campaign2004)[8:20] <- names(campaign2008)[10:22]
names(campaign2004)[21] <- names(campaign2008)[24]
names(campaign2004)[22] <- names(campaign2008)[27]

# rename 2006 variables
names(campaign2006)[1:6] <- names(campaign2008)[1:6]
names(campaign2006)[7:20] <- names(campaign2008)[9:22]
names(campaign2006)[21] <- names(campaign2008)[24]
names(campaign2006)[22] <- names(campaign2008)[27]

# rename 2010 vars
campaign2010 %<>% rename(`Sigla  Partido` = `Sigla Partido`, `Tipo de documento`
  = `Tipo do documento`, `Descriçao da despesa` = `\"Descriçao da despesa\"`)%>%
  select(-c(`Fonte recurso`, `Espécie recurso`, `Entrega em conjunto?`))

# rename 2012 vars
campaign2012 %<>% rename(`Sigla da UE` = `Número UE`, `Nome da UE` = Município,
  `Tipo de documento`=`Tipo do documento`, `Cod setor econômico do fornecedor` =
  `Cod setor econômico do doador`)

# rename 2014 vars
campaign2014 %<>% rename(`Tipo de documento` = `Tipo do documento`)

# bind datasets
campaign1 <- bind_rows(campaign2004, campaign2006, campaign2008)
campaign2 <- bind_rows(campaign2010, campaign2012, campaign2014, campaign2016)

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

# save to file
save(campaign, file = 'campaign.Rda')