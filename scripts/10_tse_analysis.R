### electoral crime and performance paper
# main analysis script
#   this script produces all tables, plots, and analyses in the electoral crime
#   and performance paper

# author: andre assumpcao
# by andre.assumpcao@gmail.com

### data and library calls
# import libraries
library(magrittr)
library(stargazer)
library(tidyverse)

# load data
load('data/tseFinal.Rda')

### define y's and x's used in analysis and their labels
# outcome labels
outcomes <- c('outcome.elected', 'outcome.distance', 'outcome.share')
outcome.labels <- c('Probability of Election',
  'Vote Distance to Election Cutoff (in p.p.)',
  'Total Vote Share (in p.p.)')

# define instruments and their labels
instrument <- 'candidacy.invalid.onappeal'
instrumented <- 'candidacy.invalid.ontrial'
instrument.labels <- c('Convicted at Trial', 'Convicted on Appeal')

# define independent variables and their labels
covariates <- c('candidate.age', 'candidate.male', 'candidate.education',
  'candidate.maritalstatus', 'candidate.experience',
  'candidacy.expenditures.actual')
covariate.labels <- c('Age', 'Male', 'Level of Education', 'Marital Status',
  'Political Experience', 'Campaign Expenditures (in R$)')

### define matrices of fixed effects
# party
party.fe    <- 'party.coalition'
party.label <- 'Political Coalition'

# municipal election
mun.fe      <- 'election.ID'
mun.label   <- 'Municipal Election'

# election year
time.fe     <- 'election.year'
time.label  <- 'Election Year'

# define variable types for analysis
integers <- c(6, 11, 17, 20, 26, 31:32, 36:43)
factors  <- c(2, 5, 9, 21, 23:24, 33:35)

# change variable types
tse.analysis %<>%
  mutate_at(vars(integers), as.integer) %>%
  mutate_at(vars(factors), as.factor)

### tables and analyses
# produce summary statistics table
stargazer(

  # summmary table
  as.data.frame(
    tse.analysis[, c(covariates, instrumented, instrument, outcomes)]
  ),

  # table cosmetics
  type = 'text',
  title = 'Descriptive Statistics',
  style = 'default',
  summary = TRUE,
  # out = './tables/sumstats.tex',
  out.header = FALSE,
  covariate.labels = c(covariate.labels[c(1:2, 5:6)],
                       instrument.labels,
                       outcome.labels),
  align = FALSE,
  digit.separate = 3,
  digits = 3,
  digits.extra = 2,
  font.size = 'scriptsize',
  header = FALSE,
  initial.zero = FALSE,
  model.names = FALSE,
  label = 'tab:sumstats',
  no.space = FALSE,
  table.placement = '!htbp',
  summary.logical = TRUE,
  summary.stat = c('n', 'mean', 'sd', 'min', 'max')
)

# reversals table
# run tabulation of convictions
reversals.table <- tse.analysis %$%
  table(candidacy.invalid.ontrial, candidacy.invalid.onappeal)

# do the math for table
percent1 <- reversals.table[1,2] / (reversals.table[1,1] + reversals.table[1,2])
percent2 <- reversals.table[2,1] / (reversals.table[2,2] + reversals.table[2,1])





