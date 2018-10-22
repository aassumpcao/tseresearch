################################################################################
# script to download data from the Cadastro Nacional de Condenações Cíveis
# por Ato de Improbidade Administrativa e Inelegibilidade

# author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# clear environment
rm(list = objects())

# import statements
library(magrittr)
library(tidyverse)
library(cnc)
library(rvest)
library(xml2)

cnc_pags(path = 'data-raw/pags', pags = 1)
d_pags <- 'data-raw/pags' %>%
  dir(full.names = TRUE) %>%
  parse_pags()

# baixa pessoas e processos
cnc_pessoas(d_pags, path = 'data-raw/pessoas')
cnc_processos(d_pags, path = 'data-raw/processos')

# parse pessoas e processos
d_pessoas <- 'data-raw/pessoas' %>%
  dir(full.names = TRUE) # %>%
  parse_pessoas(d_pessoas)

d_processos <- 'data-raw/processos' %>%
  dir(full.names = TRUE) %>%
  parse_processos()

# baixa infos das pessoas
cnc_pessoas_infos(d_pessoas, path = 'data-raw/pessoas_infos')
# parse infos das pessoas
d_pessoas_infos <- 'data-raw/pessoas_infos' %>%
  dir(full.names = TRUE) %>%
  parse_pessoas_infos(arqs)


arq <- d_pessoas[1]



arq %>%
  xml2::read_html() %>%
  rvest::html_nodes('table') %>%
  dplyr::first() %>% {
    h <- .
    tb <- h %>%
      rvest::html_table(header = TRUE) %>%
      setNames(c('nm_pessoa', 'num_processo')) %>%
      dplyr::mutate(id = 1:n()) %>%
      tidyr::gather(key, value, -id) %>%
      dplyr::mutate(value = stringr::str_replace_all(value, stringr::fixed('\\'), '@'),
                    value = stringr::str_replace_all(value, "\n|\t|@.", ''),
                    value = stringr::str_trim(value))
    l <- h %>%
      rvest::html_nodes('a') %>%
      rvest::html_attr('href') %>%
      stringr::str_replace_all("'|\\\\", '') %>% {
        c(.[stringr::str_detect(., '_condenacao')],
          .[stringr::str_detect(., '_processo')])
      }
    tb %>%
      dplyr::mutate(link = l)
  }