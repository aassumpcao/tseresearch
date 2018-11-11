# import statements
library(tidyverse)
library(magrittr)
library(pdftools)

################################################################################
# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[17])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:18]

################################################################################
# 2004 results wrangling
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
    sections2004 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
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

# 2008 results wrangling
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
    sections2008 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
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
save(sections2008, file = 'sections2008.Rda')

# remove files
unlink('./2008section', recursive = TRUE)

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
    sections2012 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
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

# assign names
names(sections2012) <- codebook

# write to disk
save(sections2012, file = 'sections2012.Rda')

# remove files
unlink('./2012section', recursive = TRUE)

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
    sections2016 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    # if looping over any other file, load .txt and append
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
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
save(sections2016, file = 'sections2016.Rda')

# remove files
unlink('./2016section', recursive = TRUE)