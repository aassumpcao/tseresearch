### electoral crime paper
# section wrangling
#   this script wrangles electoral results data at the lowest-level possible
#   (the electoral section). the work here is necessary to recover vote counts
#   for politicians who are eventually convicted of crimes and for which there
#   are no results at higher aggregation levels.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)
library(pdftools)

# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[17])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:18]

### 2004 results wrangling
# find 2004 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2004_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2004 election files
lapply(paths, unzip, exdir = './2004section')

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
states <- list.files('./2004section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2004section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2004 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2004'
    sections2004 <- rbind(sections2004, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2004) <- codebook

# write to disk
save(sections2004, file = 'sections2004.Rda')

# remove files
unlink('./2004section', recursive = TRUE)

### 2006 results wrangling
# find 2006 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2006_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2004 election files
lapply(paths, unzip, exdir = './2006section')

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
states <- list.files('./2006section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2006section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2006 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2004'
    sections2006 <- rbind(sections2006, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2006) <- codebook

# write to disk
save(sections2006, file = 'data/sections2006.Rda')

# remove files
unlink('./2006section', recursive = TRUE)

### 2008 results wrangling
# find 2008 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2008_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2008 election files
lapply(paths, unzip, exdir = './2008section')

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
states <- list.files('./2008section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2008section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2008 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2008'
    sections2008 <- rbind(sections2008, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2008) <- codebook

# write to disk
save(sections2008, file = 'data/sections2008.Rda')

# remove files
unlink('./2008section', recursive = TRUE)

### 2010 results wrangling
# find 2010 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2010_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2010 election files
lapply(paths, unzip, exdir = './2010section')

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
states <- list.files('./2010section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2010section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2010 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2010'
    sections2010 <- rbind(sections2010, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2010) <- codebook

# write to disk
save(sections2010, file = 'data/sections2010.Rda')

# remove files
unlink('./2010section', recursive = TRUE)

# 2012 results wrangling
# unzip 2012 election files
unzip('../2018 TSE Databank/votacao_secao_2012.zip', exdir = './2012section')

# get file names
states <- list.files('./2012section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2012section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2012 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2012'
    sections2012 <- rbind(sections2012, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2012) <- codebook

# write to disk
save(sections2012, file = 'data/sections2012.Rda')

# remove files
unlink('./2012section', recursive = TRUE)

### 2014 results wrangling
# find 2014 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2014_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2014 election files
lapply(paths, unzip, exdir = './2014section')

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
states <- list.files('./2014section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2014section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2014 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2014'
    sections2014 <- rbind(sections2014, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2014) <- codebook

# write to disk
save(sections2014, file = 'data/sections2014.Rda')

# remove files
unlink('./2014section', recursive = TRUE)

# 2016 results wrangling
# find 2016 files
files <- list.files('../2018 TSE Databank/', pattern = 'votacao_secao_2016_')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2016 election files
lapply(paths, unzip, exdir = './2016section')

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
states <- list.files('./2016section', pattern = 'votacao')

# for loop to load and merge all .txt files
for (i in 1:length(states)) {
  # create path for reading files
  path <- paste0('./2016section/', states[i])
  # define actions by sequence of files
  if (i == 1) {
    # if looping over first .txt file, create dataset
    sections2016 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    # append to 'sections2016'
    sections2016 <- rbind(sections2016, append)
  }
  # print looping information
  print(paste0('Iteration ', i, ' of ', length(states)))
  # delete objects at the end of loop
  if (i == length(states)) {rm(append, path, i)}
}

# assign names
names(sections2016) <- codebook

# write to disk
save(sections2016, file = 'data/sections2016.Rda')

# remove files
unlink('./2016section', recursive = TRUE)

# bind all data
sections <- bind_rows(sections2004, sections2006, sections2008, sections2010,
                      sections2012, sections2014, sections2016)

# collapse results to individual voting counts
sections %<>%
  group_by(ANO_ELEICAO, SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes2 = sum(QTDE_VOTOS)) %>%
  arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes2)) %>%
  ungroup()

# save to file
save(sections, file = 'data/sections.Rda')

### voting information
# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[22])[5:34]

# fix names
codebook %<>% substr(0, 26) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]

# find files
files <- list.files('../2018 TSE Databank/', pattern = 'detalh(.)*(04|8|12|16)')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2004 election files
mapply(unzip, paths, MoreArgs = list(exdir = './detalhes'))

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
detalhes2004 <- list.files('./detalhes', pattern = '2004', full.names = TRUE)
detalhes2008 <- list.files('./detalhes', pattern = '2008', full.names = TRUE)
detalhes2012 <- list.files('./detalhes', pattern = '2012', full.names = TRUE)
detalhes2016 <- list.files('./detalhes', pattern = '2016', full.names = TRUE)

# build dataset
details2004 <- tibble()

# loop over election years and create datasets
for (i in detalhes2004) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2004 <- bind_rows(details2004, temp.ds)
}

# build dataset
details2008 <- tibble()

# loop over election years and create datasets
for (i in detalhes2008) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2008 <- bind_rows(details2008, temp.ds)
}

# build dataset
details2012 <- tibble()

# loop over election years and create datasets
for (i in detalhes2012) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2012 <- bind_rows(details2012, temp.ds)
}

# build dataset
details2016 <- tibble()

# loop over election years and create datasets
for (i in detalhes2016) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2016 <- bind_rows(details2016, temp.ds)
}

# remove files
unlink('./detalhes', recursive = TRUE)

# bind everything
turnout <- bind_rows(details2004, details2008, details2012, details2016)

# assign var names
names(turnout) <- codebook

# save to file
save(turnout, file = 'data/turnout.Rda')

# remove all for serial sourcing
rm(list = ls())
