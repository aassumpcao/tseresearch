# test for treatment and control groups for third dissertation paper
# by andre.assumpcao@gmail.com

# import statements
library(tidyverse)
library(magrittr)
library(readxl)

# load datasets
load('ibge.dataset.Rda')
load('audit.dataset.Rda')
load('brasil.transparente.Rda')

# create abbreviation for IBGE states
fullname <- ibge.dataset %$% unique(UF) %>% sort()
partname <- c('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT',
              'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO',
              'RR', 'SC', 'SP', 'SE', 'TO')

# create dataset
states <- tibble(fullname, partname)

# merge state IDs onto ibge data
ibge.dataset %<>% left_join(states, by = c('UF' = 'fullname'))

# find IBGE id for audit dataset
ibge.munID <- audit.dataset %>%
  transmute(municipio = str_to_upper(Municipio), UF = UF) %>%
  left_join(ibge.dataset, by = c('UF' = 'partname', 'municipio' = 'NomeMunic'))

# find municipalities with missing ID
missing <- which(is.na(ibge.munID$Codmundv))
munic   <- ibge.munID[missing, 'municipio'] %$% unique(municipio)

# mun ids from manual search
municID <- c('3515004', '1600154', '1714203', '5105309', '2300150', '2412559',
             '5000609')

# create dataset
municipalities <- tibble(munic, municID)

# join missing municipality names and IDs
ibge.munID %<>%
  left_join(municipalities, by = c('municipio' = 'munic')) %>%
  transmute(
    ibgeID = ifelse(!is.na(Codmundv), Codmundv, municID),
    munName = municipio, stateID = UF)

# join onto audit dataset
audit.dataset <- bind_cols(audit.dataset, ibge.munID)

# run tabulation on municipalities and year
audit.treatment <- audit.dataset %>%
  group_by(munName) %>%
  summarize(ibgeID = first(ibgeID),
            state  = first(stateID),
            year   = first(Ano_Sorteio)
  )

foi.treatment <- brasil.transparente %>%
  mutate(year = substr(dt_inicio_avaliacao, 7, 10)) %>%
  group_by(municipio, rodada) %>%
  summarize(ibgeID = first(cod_ibge), state = first(uf), year = first(year)) %>%
  spread(rodada, year) %>%
  mutate(rodada1 = ifelse(is.na(`1`), 0, 1), rodada2 = ifelse(is.na(`2`), 0, 1),
         rodada3 = ifelse(is.na(`3`), 0, 1)
  ) %>%
  select(c(1:3, 7:9)) %>%
  mutate(ibgeID = as.character(ibgeID)) %>%
  ungroup()

# workable group
full_join(foi.treatment, audit.treatment, by = c('ibgeID' = 'ibgeID')) %>%
transmute(ibgeID = ibgeID, ebt2015 = rodada1, ebt2016 = rodada2,
          ebt2017 = rodada3, state = state.x, audit.year = year,
          audit = ifelse(is.na(year), 0, 1),
          ebt = ifelse(is.na(ebt2015) & is.na(ebt2016) & is.na(ebt2017), 0,
                       ifelse(any(ebt2015, ebt2016, ebt2017) > 0, 1, 0))
) %$%
table(audit, ebt)


