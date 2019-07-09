# library calls
library(tidyverse)
library(magrittr)
library(pdftools)

# load candidates dataset
load('data/candidates.upto.2010.Rda')
load('data/candidates.2012.Rda')
load('data/candidates.2016.Rda')

# load results by section dataset
load('data/sections2004.Rda')
load('data/sections2008.Rda')
load('data/sections2012.Rda')
load('data/sections2016.Rda')

# load final dataset
load('data/tseFinal.Rda')

# gravataí mayor
browseURL('http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/86835/210000006828')

# gravataí mayor is in the results dataset
tse.analysis %>%
  filter(election.state == 'RS' & election.ID == '86835') %>%
  select(candidate.ID)

# gravataí mayor is in the candidates dataset
candidates.2016 %>%
  filter(SIGLA_UE == '86835' & CODIGO_CARGO == 11) %>%
  select(NOME_CANDIDATO, DES_SITUACAO_CANDIDATURA, DESC_SIT_TOT_TURNO)

# guaiçara mayor
browseURL('http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/64459/250000053467')

# guaiçara mayor is in the results dataset
tse.analysis %>%
  filter(election.state == 'SP' & election.ID == '64459') %>%
  select(candidate.ID)

# guaiçara mayor is in the candidates dataset
candidates.2016 %>%
  filter(SIGLA_UE == '64459' & CODIGO_CARGO == 11) %>%
  select(NOME_CANDIDATO, DES_SITUACAO_CANDIDATURA, DESC_SIT_TOT_TURNO)

# itatinga mayor is coming from special election
browseURL('http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/65714/250000008268')

# itatinga mayor is in the results dataset
tse.analysis %>%
  filter(election.state == 'SP' & election.ID == '65714') %>%
  select(candidate.ID)

# itatinga mayor is in the candidates dataset
candidates.2016 %>%
  filter(SIGLA_UE == '65714' & CODIGO_CARGO == 11) %>%
  select(NOME_CANDIDATO, DES_SITUACAO_CANDIDATURA, DESC_SIT_TOT_TURNO)

# run test for all elected mayors in 2016 who were disqualified
list <- pdf_text(
  'unused/TSE-cand-indeferido-recurso-mais-votados-eleicoes-2016.pdf'
)

# create list of candidates
list %<>%
  str_split('\n') %>%
  unlist() %>%
  {.[which(. != '')]}

# create ds out of mayor names
ds <- tibble(state = str_sub(list[-1], 1, 2),
             town = c(str_sub(list[2:34], 4, 24), str_sub(list[35:68], 4, 29),
                      str_sub(list[69:102], 4, 25),
                      str_sub(list[103:136], 4, 22),
                      str_sub(list[137:146],  4, 25)),
             names = c(str_sub(list[2:34], 25, -6),
                       str_sub(list[35:68], 30, -6),
                       str_sub(list[69:102], 26, -6),
                       str_sub(list[103:136], 23, -6),
                       str_sub(list[137:146], 26, -6)),
             number = str_sub(list[-1], -5)
      )

# format dataset
ds %<>% mutate_all(str_trim) %>% mutate_all(str_squish)
ds[96, 3] %<>% str_sub(1, -3)

# sample and find these people
set.seed(12345)
sample_n(ds, 5)

# tianguá mayor
browseURL('http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/15695/60000003345')

# tianguá mayor is in the results dataset
tse.analysis %>%
  filter(election.state == 'CE' & election.ID == '15695') %>%
  select(candidate.ID)

# tianguá mayor is in the candidates dataset
candidates.2016 %>%
  filter(SIGLA_UE == '15695' & CODIGO_CARGO == 11) %>%
  select(NOME_CANDIDATO, DES_SITUACAO_CANDIDATURA, DESC_SIT_TOT_TURNO)

# guaraciama mayor is coming from special election
browseURL('http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/42188/130000070703')

# guaraciama mayor is in the results dataset
tse.analysis %>%
  filter(election.state == 'MG' & election.ID == '42188') %>%
  select(candidate.ID)

# guaraciama mayor is in the candidates dataset
candidates.2016 %>%
  filter(SIGLA_UE == '42188' & CODIGO_CARGO == 11) %>%
  select(NOME_CANDIDATO, DES_SITUACAO_CANDIDATURA, DESC_SIT_TOT_TURNO)


# guaraciama mayor is coming from special election
browseURL('http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/42188/130000070703')

# guaraciama mayor is in the results dataset
tse.analysis %>%
  filter(election.state == 'SP' & election.ID == '61255') %>%
  select(candidate.ID)

# guaraciama mayor is in the candidates dataset
candidates.2012 %>%
  filter(SIGLA_UE == '61255' & CODIGO_CARGO == 11) %>%
  select(NOME_CANDIDATO, DES_SITUACAO_CANDIDATURA, DESC_SIT_TOT_TURNO)
