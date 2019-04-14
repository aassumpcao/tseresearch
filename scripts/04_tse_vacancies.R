### electoral crime paper
# vacancies wrangling
#   this script wrangles municipal vacancies data for each mayor and city council
#   race in sample years (2004, 2008, 2012, 2016). this data is used for creating
#   the outcomes in the final paper.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(here)
library(tidyverse)
library(magrittr)
library(pdftools)

# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[11])

# fix names
codebook %<>% substr(0, 17) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]
codebook <- codebook[4:13]

# find vacancy files
files <- list.files('../2018 TSE Databank/', pattern = 'consulta_vagas')
paths <- paste0('../2018 TSE Databank/', files)

# unzip all files
lapply(paths, unzip, exdir = './vacancies')

# subset files and their paths by year
files2004 <- list.files('./vacancies', pattern = '2004', full.names = TRUE)
files2006 <- list.files('./vacancies', pattern = '2006', full.names = TRUE)
files2008 <- list.files('./vacancies', pattern = '2008', full.names = TRUE)
files2010 <- list.files('./vacancies', pattern = '2010', full.names = TRUE)
files2012 <- list.files('./vacancies', pattern = '2012', full.names = TRUE)
files2014 <- list.files('./vacancies', pattern = '2014', full.names = TRUE)
files2016 <- list.files('./vacancies', pattern = '2016', full.names = TRUE)

# drop elements from two vectors
files2014 <- files2014[7]
files2016 <- files2016[6]

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2004)) {
  path <- files2004[i]
  if (i == 1) {
    vacancies2004 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    vacancies2004 <- rbind(vacancies2004, append)
  }
  if (i == length(files2004)) {rm(append, i, path)}
}

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2006)) {
  path <- files2006[i]
  if (i == 1) {
    vacancies2006 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    vacancies2006 <- rbind(vacancies2006, append)
  }
  if (i == length(files2006)) {rm(append, i, path)}
}

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2008)) {
  path <- files2008[i]
  if (i == 1) {
    vacancies2008 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    vacancies2008 <- rbind(vacancies2008, append)
  }
  if (i == length(files2008)) {rm(append, i, path)}
}

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2010)) {
  path <- files2010[i]
  if (i == 1) {
    vacancies2010 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    vacancies2010 <- rbind(vacancies2010, append)
  }
  if (i == length(files2010)) {rm(append, i, path)}
}

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2012)) {
  path <- files2012[i]
  if (i == 1) {
    vacancies2012 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    vacancies2012 <- rbind(vacancies2012, append)
  }
  if (i == length(files2012)) {rm(append, i, path)}
}

# 2014 only requires one file
vacancies2014 <- read_delim(files2014, ';', escape_double = FALSE,
  col_names = TRUE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)

# 2016 only requires one file
vacancies2016 <- read_delim(files2016, ';', escape_double = FALSE,
  col_names = TRUE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)

# convert electoral unit to string
vacancies2016 %<>% mutate(SG_UE = as.character(SG_UE))

# assign variable names
names(vacancies2004) <- codebook
names(vacancies2006) <- codebook
names(vacancies2008) <- codebook
names(vacancies2010) <- codebook
names(vacancies2012) <- codebook

# delete files on disk
unlink('./vacancies', recursive = TRUE)

# bind everything
vacancies <- bind_rows(vacancies2004, vacancies2006, vacancies2008,
                       vacancies2010, vacancies2012, vacancies2014,
                       vacancies2016)
# write to file
save(vacancies2004, file = 'data/vacancies2004.Rda')
save(vacancies2006, file = 'data/vacancies2006.Rda')
save(vacancies2008, file = 'data/vacancies2008.Rda')
save(vacancies2010, file = 'data/vacancies2010.Rda')
save(vacancies2012, file = 'data/vacancies2012.Rda')
save(vacancies2014, file = 'data/vacancies2014.Rda')
save(vacancies2016, file = 'data/vacancies2016.Rda')
save(vacancies, file = 'data/vacancies.Rda')

# remove all for serial sourcing
rm(list = ls())