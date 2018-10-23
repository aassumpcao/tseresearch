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
  parse_pessoas_infos()


# manual parse
d_pessoas <- 'data-raw/pessoas' %>%
  dir(full.names = TRUE)

h <- read_html(d_pessoas[1])

dt_cad <- h %>%
    rvest::html_nodes(xpath = '//td[@class="td_form" and @width="20%"]//following-sibling::td[1]') %>%
    rvest::html_text() %>%
    stringr::str_trim() %>%
    lubridate::dmy_hms()

n_processo <- h %>%
    rvest::html_nodes(xpath = '//td[@width="85%"]') %>%
    rvest::html_text() %>%
    stringr::str_trim()

n_link <- h %>%
  rvest::html_nodes(xpath = '//td[@width="85%"]//a') %>%
  rvest::html_attr('href') %>%
  stringr::str_trim()

tr <- stringr::str_trim

tab_processo <- h %>%
  rvest::html_nodes('#hierarquia > div') %>%
  rvest::html_text() %>%
  stringr::str_replace_all("[[:space:]]+", " ") %>%
  stringr::str_trim() %>%
  stringr::str_split_fixed(':', 2) %>%
  data.frame(stringsAsFactors = FALSE) %>%
  tibble::as_data_frame() %>%
  setNames(c('key', 'value')) %>%
  dplyr::mutate_all(dplyr::funs(tr(.))) %>%
  dplyr::add_row(key = 'n_processo', value = n_processo) %>%
  dplyr::add_row(key = 'link', value = n_link)

# dados da pessoa
tab_pessoa <- h %>%
  rvest::html_nodes(xpath = '//table[@width="700px" and @align="center"]//tr//table') %>%
  dplyr::last() %>% {
    tb <- rvest::html_table(., fill = TRUE) %>%
      setNames(c('nome', 'situacao', 'na')) %>%
      dplyr::select(nome, situacao) %>%
      dplyr::slice(2)
    link <- rvest::html_node(., 'a') %>% rvest::html_attr('onclick')
    tb %>%
      dplyr::mutate(link = link) %>%
      tidyr::gather()
  }
# dados da condenacao
assunto <- h %>%
  rvest::html_node('#listaAssuntos') %>% {
    x <- .
    nm_assunto <- rvest::html_nodes(x, '.textoAssunto') %>% rvest::html_text() %>% paste(collapse = '\n')
    cod_assunto <- rvest::html_nodes(x, 'input') %>% rvest::html_attr('value') %>% paste(collapse = '\n')
    tibble::data_frame(key = c('nm_assunto', 'cod_assunto'),
                       value = c(nm_assunto, cod_assunto))
  }
tipo_pena <- h %>%
  rvest::html_node(xpath = '//input[@type="radio" and @checked="checked"]') %>%
  rvest::html_attr('value')
tipo_pena <- ifelse(tipo_pena == 'J',
                    'Tr\032nsito em julgado', '\032rg\032o colegiado')


tab_condenacao <- h %>%
    rvest::html_nodes(xpath = '//table[@width="700px" and @align="center"]//tr[not(@style="display: none;")]') %>% {
      x <- .
      i <- x %>% rvest::html_text() %>%
        stringr::str_detect("INFORMA(.)?(.)?ES SOBRE A CONDENA(.)?(.)?O") %>%
        which()
      x[(1+i):length(x)]
    } %>%
    lapply(function(x) {
      x %>%
        rvest::html_nodes('td') %>%
        rvest::html_text() %>%
        stringr::str_replace_all("[[:space:]]+|:", " ") %>%
        stringr::str_trim() %>%
        matrix(ncol = 2) %>%
        data.frame(stringsAsFactors = FALSE) %>%
        tibble::as_data_frame() %>%
        setNames(c('key', 'value'))
    }) %>%
    dplyr::bind_rows() %>%
    dplyr::mutate_all(funs(str_trim(.))) %>%
    dplyr::filter(key != '', key != 'Tipo Julgamento') %>%
    dplyr::add_row(key = 'tipo_pena', value = tipo_pena) %>%
    dplyr::bind_rows(assunto)

  dplyr::bind_rows(tab_processo, tab_pessoa, tab_condenacao)
}

