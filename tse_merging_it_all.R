################################################################################
# tse merging it all together
# Andre Assumpcao
# andre.assumpcao@gmail.com

# if not working with R studio projects
# setwd('.')

# clean environment
rm(list = objects())

################################################################################
# import statements
library(magrittr)
library(tidyverse)

# load datasets
load('candidacyDecisions.Rda')
load('sentencingData.Rda')
load('results2016.Rda')

################################################################################
# wrangle
results2016[,'SQ_CANDIDATO'] <- as.character(unlist(results2016[, 'SQ_CANDIDATO']))

data <- left_join(candidacyDecisions, sentencingData) %>%
  select(-protURL, -contains('Info')) %>%
  inner_join(results2016, by = c('candidateID' = 'SQ_CANDIDATO')) %>%
  select(c(1:10), NUM_TURNO, CODIGO_MUNICIPIO, NOME_CANDIDATO,
    DESC_SIT_CANDIDATO, DESC_SIT_CAND_TOT, TOTAL_VOTOS, TRANSITO
  ) %>%
  filter(DESC_SIT_CANDIDATO != 'DEFERIDO')

resultsModified <- filter(results2016,
  DESC_SIT_CANDIDATO != 'DEFERIDO' & TOTAL_VOTOS != 0 & DESC_SIT_CAND_TOT != 'SUPLENTE')


View(resultsModified)


View(filter(data, TOTAL_VOTOS !=0))

resultsModified %$% table(DESC_SIT_CANDIDATO)

View(data)

names(data)
