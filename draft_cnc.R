library(magrittr)
library(tidyverse)
library(cnc)
library(rvest)
library(xml2)
library(lubridate)

# devtools::install_github('aassumpcao/cnc')

cnc_pags(path = 'data-raw/pags', pags = 1)
d_pags <- 'data-raw/pags' %>%
  dir(full.names = TRUE) %>%
  parse_pags()

# download people and cases
cnc_pessoas(d_pags, path = 'data-raw/pessoas')
cnc_processos(d_pags, path = 'data-raw/processos')

# parse people
d_pessoas <- 'data-raw/pessoas' %>%
  dir(full.names = TRUE) %>%
  parse_pessoas()

# parse cases
d_processos <- 'data-raw/processos' %>%
  dir(full.names = TRUE) %>%
  parse_processos()

# download people's info
cnc_pessoas_infos(d_pessoas, path = 'data-raw/pessoas_infos')

# parse infos das pessoas
d_pessoas_infos <- 'data-raw/pessoas_infos' %>%
  dir(full.names = TRUE) %>%
  parse_infos_pessoas()
