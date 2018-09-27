# import statements
library(magrittr)
library(tidyverse)
library(feather)
library(reticulate)
library(rvest)
library(httr)
library(xml2)
library(pdftools)

# load database
load('candidateCases.Rda')

# find sample observation
set.seed(1)
url <- sample_n(candidateCases[,5], 1) %>%
  as.character()

pdf <- pdf_text('/Users/aassumpcao/Downloads/Acompanhamento Processual da Justiça Eleitoral - TSE.pdf')

strsplit(pdf, '\n')