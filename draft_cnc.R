library(magrittr)
library(tidyverse)
library(cnc)
library(rvest)
library(xml2)
library(lubridate)
library(abjutils)

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

# bind everything together
tidy_pags(d_pags)
tidy_processos(d_processos)
tidy_condenacoes(d_pessoas, d_pags, d_pessoas)
tidy_pessoas(d_pessoas_infos)

# tidy cnc for reference
load('tidy_cnc.Rda')

# new tidy_processos
tidy_processos <- function(cnc_processos) {
  cnc_processos_spr <- cnc_processos %>%
    mutate(key = tidy_nm(key)) %>%
    group_by(arq, key) %>%
    summarise(value = paste(value, collapse = '\n')) %>%
    ungroup() %>%
    spread(key, value)

  cnc_processos_tidy <- cnc_processos_spr %>%
    unite(secao, secao_judiciaria, subsecao, sep = '\n') %>%
    mutate(secao = if_else(secao == 'NA\nNA', NA_character_, secao)) %>%
    mutate(secao = if_else(is.na(secao), comarca, secao)) %>%
    mutate(`2_grau_justica_federal` = NA,
                  tribunal_superior = NA,
                  auditoria_militar = NA
    ) %>%
    select(1:4, `2_grau_justica_federal`, 5:13, tribunal_superior,
           auditoria_militar, everything()
    )

  cnc_processos_tidy %<>%
    mutate(instancia = if_else(
      !is.na(`1_grau_justica_estadual`) | !is.na(`1_grau_justica_federal`), '1 grau',
      if_else(
        !is.na(`2_grau_justica_estadual`) | !is.na(`2_grau_justica_federal`), '2 grau',
        if_else(!is.na(auditoria_militar), 'militar', 'superior'))
    )) %>%
    unite(tribunal, tribunal_de_justica_estadual:tribunal_superior) %>%
    mutate(tribunal = str_replace_all(tribunal, '_NA|NA_', ''),
           tribunal = if_else(tribunal == 'NA', NA_character_, tribunal)) %>%
    unite(vara_camara, starts_with('gabinete'),
          starts_with('varas'), auditoria_militar) %>%
    mutate(vara_camara = str_replace_all(vara_camara, '_NA|NA_', ''),
           vara_camara = if_else(vara_camara == 'NA', NA_character_, vara_camara)) %>%
    mutate(dt_propositura = dmy(data_da_propositura_da_acao),
           dt_cadastro = dmy_hms(data_da_informacao)) %>%
    mutate(id_processo = str_match(arq, "([0-9]+)\\.html$")[, 2]) %>%
    select(arq_processo = arq, id_processo, dt_cadastro,
           n_processo = num_do_processo,
           esfera_processo = esfera, tribunal, instancia, comarca_secao = secao,
           vara_camara, dt_propositura)

  cnc_processos_tidy
  }

# new tidy_condenacoes
tidy_condenacoes <- function(cnc_condenacoes, cnc_pags, cnc_processos) {
  loc <- readr::locale(decimal_mark = ',', grouping_mark = '.')
  re_pena <- sprintf('Anos%s([0-9]+)%sMeses%s([0-9]+)%sDias%s([0-9]+)',
                     '[[:space:]]+', '[[:space:]]+', '[[:space:]]+',
                     '[[:space:]]+', '[[:space:]]+', '[[:space:]]+')
  re_pena_de <- 'De[[:space:]]+([0-9]{2}/[0-9]{2}/[0-9]{4})'
  re_pena_ate <- 'At\u00e9[[:space:]]+([0-9]{2}/[0-9]{2}/[0-9]{4})'
  calcula_pena <- function(pena_txt) {
    conta <- function(x) {
      x <- as.numeric(x)
      x[1] * 365 + x[2] * 30 + x[3]
    }
    apply(str_match(pena_txt, re_pena)[, c(2:4)], 1, conta)
  }
  cnc_condenacoes_spr <- cnc_condenacoes %>%
    mutate(key = tidy_nm(key),
           key = if_else(key == 'link' & str_detect(value, 'recuperarDados'),
                         'link_pessoa',
                         if_else(key == 'link' & str_detect(value, 'visualizar_pr'),
                                 'link_processo', key
                         )
                 )
    ) %>%
    filter(!key %in% unique(tidy_nm(cnc_processos$key))) %>%
    group_by(arq, key) %>%
    summarise(value = paste(value, collapse = '\n')) %>%
    ungroup() %>%
    spread(key, value) %>%
    mutate_all(funs(suppressWarnings(janitor::convert_to_NA(., c('', 'NA'))))) %>%
    janitor::remove_empty('cols')

  aux_pags <- cnc_pags %>%
    tidy_pags() %>%
    select(arq_pag = arq, id_pag, id_condenacao, id_processo)

  cnc_condenacoes_tidy <- cnc_condenacoes_spr %>%
    mutate(id_pessoa = str_match(link_pessoa, "'([0-9]+)'")[, 2],
           id_condenacao = str_match(arq, "([0-9]+)\\.html$")[, 2]
    ) %>%
    mutate(data_da_decisao_do_orgao_colegiado = NA_character_,
           dt_decisao = NA_character_,
           dt_transito = NA_character_,
           dt_pena = if_else(is.na(dt_decisao), dt_transito, dt_decisao)
    ) %>%
    mutate(teve_inelegivel = NA_character_
    ) %>%
    mutate(teve_multa = if_else(str_detect(pagamento_de_multa, 'SIM'), 'sim',
                                pagamento_de_multa),
           vl_multa = if_else(str_detect(pagamento_de_multa, 'SIM'),
                              readr::parse_number(pagamento_de_multa, locale = loc),
                              NA_real_)
    ) %>%
    mutate(pena_privativa_de_liberdade = NA_character_,
           pena_txt = if_else(is.na(pena_privativa_de_liberdade),
                              pena_privativa_de_liberdade_aplicada,
                              pena_privativa_de_liberdade),
           teve_pena = if_else(str_detect(pena_txt, 'SIM'), 'sim', pena_txt),
           duracao_pena_regex = calcula_pena(pena_txt),
           de_pena = dmy(str_match(pena_txt, re_pena_de)[, 2]),
           ate_pena = dmy(str_match(pena_txt, re_pena_ate)[, 2]),
           duracao_pena = as.numeric(ate_pena-de_pena)
    ) %>%
    mutate(perda_bens = perda_de_bens_ou_valores_acrescidos_ilicitamente_ao_patrimonio,
           teve_perda_bens = if_else(str_detect(perda_bens, 'SIM'), 'sim', perda_bens),
           vl_perda_bens = if_else(str_detect(perda_bens, 'SIM'),
                                   readr::parse_number(perda_bens, locale = loc),
                                   NA_real_)
    ) %>%
    mutate(perda_de_emprego_cargo_funcao_publica = NA_character_,
           teve_perda_cargo = tolower(perda_de_emprego_cargo_funcao_publica)
    ) %>%
    mutate(proibicao_txt = proibicao_de_contratar_com_o_poder_publico_ou_receber_incentivos_fiscais_ou_crediticios_direta_ou_indiretamente_ainda_que_por_intermedio_de_pessoa_juridica_da_qual_seja_socio_majoritario,
           teve_proibicao = if_else(str_detect(proibicao_txt, 'SIM'), 'sim',
                                    proibicao_txt),
           duracao_proibicao_regex = calcula_pena(proibicao_txt),
           de_proibicao = dmy(str_match(proibicao_txt, re_pena_de)[, 2]),
           ate_proibicao = dmy(str_match(proibicao_txt, re_pena_ate)[, 2]),
           duracao_proibicao = as.numeric(ate_proibicao-de_proibicao)
    ) %>%
    mutate(ressarcimento = ressarcimento_integral_do_dano,
           teve_ressarcimento = if_else(str_detect(ressarcimento, 'SIM'), 'sim',
                                        ressarcimento),
           vl_ressarcimento = if_else(str_detect(ressarcimento, 'SIM'),
                                      readr::parse_number(ressarcimento, locale = loc),
                                      NA_real_)
    ) %>%
    mutate(suspensao_txt = suspensao_dos_direitos_politicos,
           teve_suspensao = if_else(str_detect(suspensao_txt, 'SIM'), 'sim',
                                    suspensao_txt),
           duracao_suspensao_regex = calcula_pena(suspensao_txt),
           de_suspensao = dmy(str_match(suspensao_txt, re_pena_de)[, 2]),
           ate_suspensao = dmy(str_match(suspensao_txt, re_pena_ate)[, 2]),
           duracao_suspensao = as.numeric(ate_suspensao-de_suspensao),
           comunicacao_tse = if_else(str_detect(suspensao_txt, 'Comunica.+SIM'),
                                     'sim', NA_character_)
    ) %>%
    separate(cod_assunto, paste('assunto_cod', 1:5, sep = '_'),
             sep = '\n', fill = 'right'
    ) %>%
    separate(nm_assunto, paste('assunto_nm', 1:5, sep = '_'),
             sep = '\n', fill = 'right'
    ) %>%
    inner_join(aux_pags, 'id_condenacao') %>%
    select(arq_pag, id_pag, arq,
           id_condenacao, id_processo, id_pessoa,
           # infos condenacao
           tipo_pena, dt_pena, starts_with('assunto'),
           # teve tal coisa?
           starts_with('teve_'),
           # qual o valor?
           starts_with('vl_'),
           # duracao, de, at\032
           starts_with('duracao_'), starts_with('de_'), starts_with('ate_')
    )
  cnc_condenacoes_tidy
}
