### electoral crime and performance paper
# appendix analysis
#   this script contains the analysis included in the appendix, footnotes, and
#   everything else not included in the body of the final paper.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(here)
library(tidyverse)
library(magrittr)

# load datasets
for (i in seq(2006, 2014, 4)) {
  load(paste0('data/results', as.character(i), '.Rda'))
  load(paste0('data/sections', as.character(i), '.Rda'))
  load(paste0('data/candidates.', as.character(i), '.Rda'))
}

# extract datasets from global environment
results <- objects(pattern = 'results')
sections <- objects(pattern = 'sections')
candidates <- objects(pattern = 'candidates')

# transform candidateID in candidates dataset
for (dataset in candidates) {
  x <- get(dataset)
  if (dataset == 'candidates.2014'){x %<>% mutate(candidateID = SQ_CANDIDATO)}
  else {x %<>% mutate(candidateID = SEQUENCIAL_CANDIDATO)}
  x %<>% mutate_all(as.character)
  assign(dataset, x)
  rm(x)
}

# loop over results datasets and aggregate data up to the candidate level
for (dataset in results) {
  x <- get(dataset)
  x %<>% mutate(candidateID = SQ_CANDIDATO) %>%
         group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
         summarize(votes = sum(as.numeric(TOTAL_VOTOS))) %>%
         ungroup() %>%
         mutate_all(as.character)
  assign(dataset, x)
  rm(x)
}

# loop over sections datasets and aggregate data up to the candidate level
for (dataset in sections){
  x <- get(dataset)
  x %<>% group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
         summarize(votes = sum(as.numeric(QTDE_VOTOS))) %>%
         ungroup() %>%
         mutate_all(as.character)
  assign(dataset, x)
  rm(x)
}

# create match keys across datasets
resultsKey <- c('SIGLA_UE', 'candidateID', 'NUM_TURNO')
sectionsKey <- c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO',
                 'NUMERO_CANDIDATO' = 'NUM_VOTAVEL')
resultsKey2014 <- c('SG_UE'='SIGLA_UE', 'candidateID', 'NR_TURNO' = 'NUM_TURNO')
sectionsKey2014 <- c('SG_UE' = 'SIGLA_UE', 'NR_TURNO' = 'NUM_TURNO',
                     'CD_CARGO'= 'CODIGO_CARGO', 'NR_CANDIDATO' = 'NUM_VOTAVEL')
# match datasets
candidates.2006 %<>%
  left_join(results2006, by = resultsKey) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes)) %>%
  left_join(sections2006, by = sectionsKey) %>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

candidates.2010 %<>%
  left_join(results2010, by = resultsKey) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes)) %>%
  left_join(sections2010, by = sectionsKey) %>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

candidates.2014 %<>%
  left_join(results2014, by = resultsKey2014) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA_character_, votes)) %>%
  left_join(sections2014, by = sectionsKey2014) %>%
  filter(!is.na(votes.x) | !is.na(votes.y)) %>%
  mutate(votes = ifelse(is.na(votes.x), votes.y, votes.x))

# varnames for candidates 2014 dataset
varnames <- c("DATA_GERACAO", "HORA_GERACAO", "ANO_ELEICAO", "CD_TIPO_ELEICAO",
              "NM_TIPO_ELEICAO", "NUM_TURNO", "CD_ELEICAO", "DESCRICAO_ELEICAO",
              "DATA_ELEICAO", "TIPO_ABRANGENCIA", "SIGLA_UF", "SIGLA_UE",
              "DESCRICAO_UE", "CODIGO_CARGO", "DESCRICAO_CARGO",
              "SEQUENCIAL_CANDIDATO", "NUMERO_CANDIDATO", "NOME_CANDIDATO",
              "NOME_URNA_CANDIDATO", "NM_SOCIAL_CANDIDATO", "CPF_CANDIDATO",
              "NM_EMAIL", "COD_SITUACAO_CANDIDATURA","DES_SITUACAO_CANDIDATURA",
              "COD_DETALHE_SITUACAO_CAND", "DES_DETALHE_SITUACAO_CAND",
              "TP_AGREMIACAO", "NUMERO_PARTIDO", "SIGLA_PARTIDO","NOME_PARTIDO",
              "SIGLA_LEGENDA", "NOME_LEGENDA", "COMPOSICAO_COLIGACAO",
              "CODIGO_NACIONALIDADE", "DECRICAO_NACIONALIDADE",
              "SIGLA_UF_NASCIMENTO", "CODIGO_MUNICIPIO_NASCIMENTO",
               "NOME_MUNICIPIO_NASCIMENTO", "DATA_NASCIMENTO",
               "IDADE_DATA_ELEICAO", "NUM_TITULO_ELEITORAL_CANDIDATO",
               "CODIGO_SEXO", "DS_SEXO", "COD_GRAU_INSTRUCAO",
               "DESCRICAO_GRAU_INSTRUCAO", "CODIGO_ESTADO_CIVIL",
               "DESCRICAO_ESTADO_CIVIL", "CODIGO_COR_RACA", "DS_COR_RACA",
               "CODIGO_OCUPACAO", "DESCRICAO_OCUPACAO", "DESPESA_MAX_CAMPANHA",
               "COD_SIT_TOT_TURNO", "DESC_SIT_TOT_TURNO", "ST_REELEICAO",
                "ST_DECLARAR_BENS", "NR_PROTOCOLO_CANDIDATURA", "NR_PROCESSO")

# assign to dataset
names(candidates.2014) <- c(varnames, names(candidates.2014)[59:62])

# bind rows
candidates <- bind_rows(candidates.2006, candidates.2010, candidates.2014)

# filter observations down to the candidacy situation categories as in local
# candidates database
remain <- c(4, 16, 18, 19)
candidates %<>% filter(COD_SITUACAO_CANDIDATURA %in% remain)

# create sentence outcomes variable
candidates %<>%
  mutate(trialCrime  = ifelse(COD_SITUACAO_CANDIDATURA == 16, 0, 1),
         appealCrime = ifelse(is.na(votes.x), 1, 0))

# save to file
assign('stateFederalCandidates', candidates)
save(stateFederalCandidates, file = 'data/stateFederalCandidates.Rda')

# remove all for serial sourcing
rm(list = ls())