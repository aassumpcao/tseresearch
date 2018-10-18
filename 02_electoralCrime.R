################################################################################
# Electoral Crime and Performance Paper

# 02 Script:
# This script wrangles the electoral results by electoral section for the
# candidates that are in our sample of candidacies not having a final ruling
# before election day in 2012 and 2016

# Author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
library(tidyverse)
library(magrittr)
library(feather)
library(reticulate)
library(pdftools)

# set environment var
Sys.setenv(RETICULATE_PYTHON = '/anaconda3/bin/python')

# load statements
load('candidates.Rda')
load('results2012.Rda')

################################################################################
# 2012 results wrangling
# unzip 2012 election files
unzip('../2018 TSE Databank/votacao_secao_2012.zip', exdir = './2012section')

# wait for all files to be unzipped
Sys.sleep(10)

# get file names
states <- list.files('./2012section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2012section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2012 <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
    # append to 'sections2012'
    sections2012 <- rbind(sections2012, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[17])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:18]

# assign names
names(sections2012) <- codebook

# write to disk
# save(sections2012, file = 'sections2012.Rda')

# remove files
unlink('./2012section', recursive = TRUE)

################################################################################
# merge with vote count
# filter candidates by election unit, year and candidate number
cities <- candidates %>%
  filter(ANO_ELEICAO == 2012) %$%
  unique(SIGLA_UE)
people <- candidates %>%
  filter(ANO_ELEICAO == 2012) %$%
  unique(NUMERO_CANDIDATO)

# split dataset for easy calculation of results
candidates2012 <- candidates %>% filter(ANO_ELEICAO == 2012)
candidates2016 <- candidates %>% filter(ANO_ELEICAO == 2016)

# prepare valid results dataset
results2012 %<>%
  mutate(candidateID = as.character(SQ_CANDIDATO)) %>%
  group_by(SIGLA_UE, NUM_TURNO, candidateID) %>%
  summarize(votes = sum(TOTAL_VOTOS))

# join candidates and valid results
candidates2012 %<>%
  filter(ANO_ELEICAO == 2012) %>%
  left_join(results2012, by = c('SIGLA_UE', 'candidateID', 'NUM_TURNO')) %>%
  mutate(votes = ifelse(is.na(votes) | votes == 0, NA, votes))

# prepare results-by-section dataset
test <- sections2012 %>%
  filter(SIGLA_UE %in% cities) %>%
  filter(NUM_VOTAVEL %in% people) %>%
  group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes = sum(QTDE_VOTOS))





# filter results by cities and people


# aggregate votes by candidate number
 %>%
  {left_join(candidates, ., by = c('SIGLA_UE'  = 'SIGLA_UE',
                                   'NUM_TURNO' = 'NUM_TURNO',
                                   'NUMERO_CANDIDATO' = 'NUM_VOTAVEL'))} %>%
  filter(is.na(votes) & ANO_ELEICAO != 2016) %>%
  View()

load('results2012.Rda')

candidates %>% names()
candidates %$% summary(is.na(votes))

results2012 %>% names()

candidates %$% table(ANO_ELEICAO)


candidates %>%
  filter(ANO_ELEICAO == 2012) %>%
  left_join(results2012, by = c('candidateID' = 'candidateID')) %$%
  table(votes)


filter(candidates, ANO_ELEICAO == 2012)



View(filter(results2012, SIGLA_UE == 76910))
View(filter(results, SIGLA_UE == 76910))



################################################################################
# 2016 results wrangling