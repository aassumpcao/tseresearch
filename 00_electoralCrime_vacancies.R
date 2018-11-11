# remove everything from environment
rm(list = objects())

# import statements
library(tidyverse)
library(magrittr)
library(pdftools)

################################################################################
# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[11])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:13]

################################################################################
# find vacancy files
files <- list.files('../2018 TSE Databank/', pattern = 'consulta_vagas')
paths <- paste0('../2018 TSE Databank/', files)

# unzip all files
lapply(paths, unzip, exdir = './vacancies')

# subset files and their paths by year
files2004 <- paste0('./vacancies/', list.files('./vacancies', pattern = '2004'))
files2008 <- paste0('./vacancies/', list.files('./vacancies', pattern = '2008'))
files2012 <- paste0('./vacancies/', list.files('./vacancies', pattern = '2012'))
files2016 <- paste0('./vacancies/', list.files('./vacancies', pattern = 'BRAS'))

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2004)) {
  path <- files2004[i]
  if (i == 1) {
    vacancies2004 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
    vacancies2004 <- rbind(vacancies2004, append)
  }
  if (i == length(files2004)) {rm(append, i, path)}
}

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2008)) {
  path <- files2008[i]
  if (i == 1) {
    vacancies2008 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
    vacancies2008 <- rbind(vacancies2008, append)
  }
  if (i == length(files2008)) {rm(append, i, path)}
}

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2012)) {
  path <- files2012[i]
  if (i == 1) {
    vacancies2012 <- read_delim(path, ";", escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ";", escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = "Latin1"), trim_ws = TRUE)
    vacancies2012 <- rbind(vacancies2012, append)
  }
  if (i == length(files2012)) {rm(append, i, path)}
}

# 2016 only requires one file
vacancies2016 <- read_delim(files2016, ";", escape_double = FALSE,
  col_names = TRUE, locale = locale(encoding = "Latin1"), trim_ws = TRUE)

# assign variable names
names(vacancies2004) <- codebook
names(vacancies2008) <- codebook
names(vacancies2012) <- codebook

# write to file
save(vacancies2004, file = 'vacancies2004.Rda')
save(vacancies2008, file = 'vacancies2008.Rda')
save(vacancies2012, file = 'vacancies2012.Rda')
save(vacancies2016, file = 'vacancies2016.Rda')

# quit
q('no')