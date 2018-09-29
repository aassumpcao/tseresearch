# import statement
library(magrittr)
library(tidyverse)

# load database
load('candidates.2016.Rda')
load('sentencingData.Rda')
load('results2016.Rda')
load('candidacyDecisions.Rda')

# wrangling
names(candidates.2010)
candidates.2010 %>%
  filter(CODIGO_CARGO == 11) %$%
  table(DES_SITUACAO_CANDIDATURA)

load('results2008.Rda')
load('candidates.2010.Rda')

testSP <- candidates.2010 %>%
  filter(CODIGO_CARGO == 11) %>%
  filter(ANO_ELEICAO == 2008) %>%
  filter(SIGLA_UF == 'SP') %>%
  filter(DES_SITUACAO_CANDIDATURA == 'INDEFERIDO COM RECURSO')

candidates.2016 %>%
  filter(DES_SITUACAO_CANDIDATURA == 'INDEFERIDO COM RECURSO') %>%
  filter(CODIGO_CARGO == 11) %$%
  table(DESC_SIT_TOT_TURNO)

TEST <- results2016 %>%
  filter(DESC_SIT_CAND_SUPERIOR == 'APTO') %>%
  filter(DESC_SIT_CANDIDATO == 'DEFERIDO COM RECURSO') %>%
  filter(TOTAL_VOTOS == 0)


names(TEST)

TEST2 <- left_join(TEST, candidates.2016, by = c('SQ_CANDIDATO' = 'SEQUENCIAL_CANDIDATO'))

View(TEST2)

sectionSP %>%
  filter(X9 == 'GUARULHOS') %>%
  filter(X14 == 31022) %>%
  select(X15) %>%
  unlist() %>%
  sum()




View(test)
rm(sectionAM, test, test2, testSP)
names(results2016)
View(testAM)

# testing votes per electoral section
unzip('./votacao_secao_2016_SP.zip', exdir = './section')

sectionSP <- read_delim('../2018 TSE Databank/votacao_secao_2016_SP/votacao_secao_2016_SP.txt', ';',
  escape_double = FALSE, col_names = FALSE, trim_ws = TRUE,
  locale = locale(encoding = 'Latin1'))

# checking whether votes are reported
resultsTest <- results2016 %>%
  filter(CODIGO_CARGO == 11) %>%
  filter(DESC_SIT_CANDIDATO == 'INDEFERIDO COM RECURSO') %>%
  filter(TOTAL_VOTOS == 0) %>%
  filter(SIGLA_UF == 'SP')

results <- resultsSection %>%
  filter(X12 == 11) %>%
  filter(X9 == 'AGUDOS') %>%
  filter(X10 == 7) %>%
  filter(X14 == 15)

results2016 %>%
  filter(CODIGO_CARGO == 11) %>%
  filter(NOME_MUNICIPIO == 'AGUDOS') %$%
  filter(NUMERO_ZONA == 7)

names


2251+337+179+157+13+5+5+3
names(results2016)

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