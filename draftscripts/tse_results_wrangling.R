################################################################################
# TSE results data
# Author:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# Remove everything from environment
rm(list = objects())

# Import statements
library(rvest)
library(magrittr)
library(tidyverse)
library(pdftools)

################################################################################
# download results data
years <- c('votacao_candidato_munzona_2000.zip',
           'votacao_candidato_munzona_2004.zip',
           'votacao_candidato_munzona_2008.zip',
           'votacao_candidato_munzona_2012.zip',
           'votacao_candidato_munzona_2016.zip')

# Url to look for files
url <- 'http://agencia.tse.jus.br/estatistica/sead/odsele/votacao_candidato_munzona/'

# Download candidate files
lapply(url, paste0, years) %>%
flatten_chr() %>%
download.file(destfile = '.')

# Unzip all files
lapply(paste0('./', years), unzip, exdir = './votacao')

# Merge files
results.2012 <- list.files('./votacao', pattern = '2000|2004|2008|2012')
results.2016 <- list.files('./votacao', pattern = '2016')

# loop and merge before 2010
for(i in 1:length(results.2012)) {

  # create path for reading files
  path <- paste0('./votacao/', results.2012[i])

  # define actions by sequence of files
  if (i == 1) {
    # if looping over first txt file, we want the creation of the dataset
    results <- read_delim(path,";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)

  } else {
    # if looping over any other file, we should read in the dataset first
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)

    # and then append to 'results'
    results <- rbind(results, append)
  }

  # print looping information
  print(paste0('Iteration ', i, ' of ', length(results.2012)))

  # delete objects at the end of loop
  if (i == length(results.2012)) {
    # rename last object
    results.2010 <- results

    # delete everything else
    rm(path, i, results, append)
  }
}

# loop and merge files for 2012
for (i in 1:length(results.2016)) {

  # create path for reading files
  path <- paste0('./votacao/', results.2016[i])

  # define actions by sequence of files
  if (i == 1) {
    # if looping over first txt file, we want the creation of the dataset
    results <- read_delim(path,";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)

  } else {
    # if looping over any other file, we should read in the dataset first
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)

    # and then append to 'results'
    results <- rbind(results, append)
  }

  # print looping information
  print(paste0('Iteration ', i, ' of ', length(results.2016)))

  # delete objects at the end of loop
  if (i == length(results.2016)) {
    # rename last object
    results.2016 <- results

    # delete everything else
    rm(path, i, results, append)
  }
}

################################################################################
# wrangle data
unlink('./votacao', recursive = TRUE)

# read codebook pdf and select just the relevant pages where we find variable
# names
codebook <- pdf_text('./LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- codebook[12:14]

# column names up to 2012
results.2010.columns <- c(codebook[[1]][c(7:13, 17:22, 24:27, 30, 33:39)],
                          codebook[[2]][c(2:5)])

# correct problems
results.2010.columns %<>%
  substr(., 1, 22) %>%
  str_remove_all(., '\\(\\*\\)') %>%
  str_squish() %>%
  str_trim()

# column names after 2012
results.2016.columns <- c(codebook[[2]][c(9:15, 19:24, 26:29, 32, 35:41)],
                          codebook[[3]][c(2:5, 7)])

# correct problems
results.2016.columns[1:25] %<>%
  substr(., 1, 22) %>%
  str_remove_all(., '\\(\\*\\)') %>%
  str_squish() %>%
  str_trim()

results.2016.columns[26:30] %<>%
  substr(1, 19) %>%
  str_squish() %>%
  str_trim()

# assign names to datasets
names(results.2010) <- results.2010.columns
names(results.2016) <- results.2016.columns

# bind all datasets
results.data <- bind_rows(results.2010, results.2016)

# filter by year
results2000 <- filter(results.data, ANO_ELEICAO == 2000)
results2004 <- filter(results.data, ANO_ELEICAO == 2004)
results2008 <- filter(results.data, ANO_ELEICAO == 2008)
results2012 <- filter(results.data, ANO_ELEICAO == 2012)
results2016 <- filter(results.data, ANO_ELEICAO == 2016)

# save by year
save(results2000, file = './results2000.Rda')
save(results2004, file = './results2004.Rda')
save(results2008, file = './results2008.Rda')
save(results2012, file = './results2012.Rda')
save(results2016, file = './results2016.Rda')

# save total
save(results.data, file = './resultsData.Rda')