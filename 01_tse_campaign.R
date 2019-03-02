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
load('campaign2016.Rda')

### body
# extract variable names for match
varnames <- lapply(mget(objects()), names)

# rename 2004 variables
names(campaign2004)[1:7] <- names(campaign2008)[2:8]
names(campaign2004)[8:20]<- names(campaign2008)[10:22]
names(campaign2004)[21]  <- names(campaign2008)[24]
names(campaign2004)[22]  <- names(campaign2008)[27]

# rename 2006 variables
names(campaign2006)[1:6] <- names(campaign2008)[1:6]
names(campaign2006)[7:20]<- names(campaign2008)[9:22]
names(campaign2006)[21]  <- names(campaign2008)[24]
names(campaign2006)[22]  <- names(campaign2008)[27]

# rename 2010 vars
campaign2010 %<>% rename(`Sigla  Partido` = `Sigla Partido`,
                         `Tipo de documento` = `Tipo do documento`,
                         `Descriçao da despesa` = `\"Descriçao da despesa\"`)%>%
                  select(-c(`Fonte recurso`, `Espécie recurso`,
                         `Entrega em conjunto?`))

# rename 2012 vars
campaign2012 %<>% rename(`Sigla da UE` = `Número UE`, `Nome da UE` = Município,
                         `Tipo de documento` = `Tipo do documento`,
                         `Cod setor econômico do fornecedor` =
                         `Cod setor econômico do doador`)

# now I match
which(varnames$campaign2008 %in% varnames$campaign2016 == FALSE) %>%
{varnames$campaign2008[.]}


