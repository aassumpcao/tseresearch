# import statement
library(magrittr)
library(tidyverse)

# load database
load('candidates2016.Rda')
load('sentencingData.Rda')
load('results2016.Rda')
load('candidacyDecisions')

# wrangling










names(candidates.2016)
candidates.2016 %>%
  filter(CODIGO_CARGO == 11) %$%
  table(DES_SITUACAO_CANDIDATURA)

2251+337+179+157+13+5+5+3


as.character(unlist(sentencingData[sort.list(sentencingData$stage), 'stage']))


as.character(sentencingData[596,])


candidates.2016 %<>% mutate(SEQUENCIAL_CANDIDATO = as.character(SEQUENCIAL_CANDIDATO))
results2016 %<>% mutate(SQ_CANDIDATO = as.character(SQ_CANDIDATO))

data <- left_join(candidacyDecisions, candidates.2016, by = c('candidateID' = 'SEQUENCIAL_CANDIDATO'))
data <- left_join(data, results2016, by = c('candidateID' = 'SQ_CANDIDATO'))

data %<>% filter(DES_SITUACAO_CANDIDATURA != 'DEFERIDO')

data %<>% left_join(sentencingData, by = c('protNum' = 'protNum'))


View(data)

lapply(data[51:61, 'sentence'], as.character)

names(results2016)

data %$% table(DES_SITUACAO_CANDIDATURA)


which(str_detect(unlist(results.data$NOME_CANDIDATO), 'RAMENZONI'))

which(str_detect(unlist(results2016$NOME_CANDIDATO), 'RUBENS ROBERTO ROSA'))

View(candidates.2016[212031,])
View(results2016[327857,])

library(feather)