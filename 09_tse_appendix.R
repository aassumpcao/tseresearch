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
library(readr)

# load datasets
for (i in seq(2006, 2014, 4)) {
  load(paste0('results', as.character(i), '.Rda'))
  load(paste0('sections', as.character(i), '.Rda'))
  load(paste0('candidates.', as.character(i), '.Rda'))
}

# extract datasets from global environment
results <- objects(pattern = 'results')
sections <- objects(pattern = 'sections')
candidates <- objects(pattern = 'candidates')

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