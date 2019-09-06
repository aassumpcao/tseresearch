### electoral crime and performance paper
# candidacy rejections wrangling
#   this script wrangles the candidacy rejections independently reported by tse.
#   unfortunately, they only released such information for 2014 and 2016. the
#   data here is useful, however, because it provides the most important reasons
#   why candidates have their candidacies rejected.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)

# load dataset
load('data/candidates1.Rda')

# unzip file with reasons for conviction at trial
unzip('../2018 TSE Databank/motivo_cassacao_2016.zip', exdir = 'cassacao')
unzip('../2018 TSE Databank/consulta_cand_2016.zip', exdir = 'cand')

# find files
args <- list(path = 'cassacao', pattern = 'csv', full.names = TRUE)
files <- do.call(list.files, args)

# read files
read_tse <- function(x){return(
  read_delim(x, ';', escape_double = FALSE, trim_ws = TRUE,
    locale = locale(encoding = 'Latin1')
  ) %>% mutate_all(as.character)
)}

# apply read files to all files; create empty dataset
datasets  <- lapply(files, read_tse)
prevented <- tibble()
sentences2016 <- read_tse('cand/consulta_cand_2016_BRASIL.csv')

# delete folders on drive
unlink('cassacao', recursive = TRUE)
unlink('cand', recursive = TRUE)

# bind everything together
for (dataset in datasets) {prevented <- bind_rows(prevented, dataset)}

# define vector of unique rejections
rejections_unique <- unique(prevented$DS_MOTIVO_CASSACAO)
labels <- c(8, 7, 1, 5, 2, 3, 6, 4)
saveRDS(rejections_unique, 'data/rejections.Rds')

# create classes for machine classification. more severe reasons trump less
#  severe reasons.
reason <- prevented$DS_MOTIVO_CASSACAO %>% {factor(., unique(.), labels)}
prevented$broad.rejection <- reason
prevented %<>%
  mutate(broad.rejection = as.integer(broad.rejection)) %>%
  group_by(SQ_CANDIDATO) %>%
  top_n(-1, broad.rejection) %>%
  ungroup() %>%
  mutate(broad.rejection = ifelse(broad.rejection > 2, 1, 2))

# filter candidates running for 2016 elections
candidates2016 <- candidates1 %>%
  filter(ANO_ELEICAO == 2016 & NUM_TURNO == 1) %>%
  mutate_all(as.character)

# join onto candidates to extract unique ids
key1 <- c('SQ_CANDIDATO' = 'SEQUENCIAL_CANDIDATO')
prevented2016 <- left_join(prevented, candidates2016, key1)

### build list of missing sentences
# define urls
url <- 'http://inter03.tse.jus.br/sadpPush/ExibirDadosProcesso.do?nprot='
trb <- '&comboTribunal='

# load list of decisions i already have
htmls <- list.files('html', pattern = '^2016_')
decisions2016 <- tibble(candidateID = str_sub(htmls, 1, -6))

# join onto full list of prevented candidates
missing2016 <- anti_join(prevented2016, decisions2016)

# narrow list of downloads to missing sentences
downloads2016 <- sentences2016 %>%
  unite('candidateID', c('ANO_ELEICAO', 'NR_CPF_CANDIDATO'), remove = FALSE) %>%
  semi_join(missing2016, 'candidateID') %>%
  select(candidateID, trib = SG_UF, prot = NR_PROTOCOLO_CANDIDATURA)

# create links
downloads2016$url <- downloads2016 %>% {paste0(url,.$prot,trb,tolower(.$trib))}
# downloads2016 %>%
#   select(candidateID, url) %>%
#   write_csv('data/prevented2016.csv')

# clear useless objects
rm(files, htmls, key1, labels, reason, rejections_unique, trb, url, args)
rm(dataset, datasets, downloads2016, decisions2016, prevented, sentences2016)

### prepare file for machine classification
# include unique id in prevented2016
prevented2016 %>%
  unite('candidateID', c('ANO_ELEICAO.x', 'CPF_CANDIDATO')) %>%
  select(candidateID, class = broad.rejection) %>%
  filter(candidateID != '2016_NA') %>%
  write_csv('data/sentences_classes2016.csv')

# remove all for serial sourcing
rm(list = ls())
