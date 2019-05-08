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

### function definitions
# function to conduct t-tests across parameters in different regressions
t.test2 <- function(mean1, mean2, se1, se2){
  # Args:
  #   mean1, mean2: means of each parameter
  #   se1, se2:     standard errors of each parameter

  # Returns:
  #   test statistics

  # Body:
  #   compute statistics and return results
  se <- se1 + se2
  df <- ((se1 + se2)^2) / ((se1)^2 / (9470-1) + (se2)^2 / (9470-1))
  t  <- (mean1 - mean2) / se
  result <- c(mean1 - mean2, se, t, 2 * pt(-abs(t), df))
  names(result) <- c('Mean Difference', 'Std. Error', 't value', 'Pr(>|t|)')

  # return call
  return(result)
}

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

# remove variable indexes
rm(integers, factors)

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
reversals <- tse.analysis %$%
  table(candidacy.invalid.ontrial, candidacy.invalid.onappeal)

# do the math for table
reversals[1, 2] / (reversals[1, 1] + reversals[1, 2])
reversals[2, 1] / (reversals[2, 2] + reversals[2, 1])

# test for heterogeneous judicial behavior between trial and appeals: i am
# interested in knowing whether justices change change the factors affecting
# ruling when elections have passed.

# regression for factors affecting trial
tse.analysis %>%
  {lfe::felm(candidacy.invalid.ontrial ~ candidate.age + candidate.male +
    candidate.maritalstatus + candidate.education + candidate.experience +
    candidacy.expenditures.actual | election.year + election.ID +
    party.coalition, .)} -> covariate.balance.instrumented

# regression for factors affecting appeals
tse.analysis %>%
  {lfe::felm(candidacy.invalid.onappeal ~ candidate.age + candidate.male +
    candidate.maritalstatus + candidate.education + candidate.experience +
    candidacy.expenditures.actual | election.year + election.ID +
    party.coalition, .)} -> covariate.balance.instrument

# check point estimates and standard errors in each regression
covariate.balance.instrumented %>% {summary(.)$coefficients[, c(1, 2)]}
covariate.balance.instrument   %>% {summary(.)$coefficients[, c(1, 2)]}



for (i in 1:15){
  t.test2(
    summary(covariate.balance.instrumented)$coefficients[i, 1],
    summary(covariate.balance.instrument)$coefficients[i, 1],
    summary(covariate.balance.instrumented)$coefficients[i, 2],
    summary(covariate.balance.instrument)$coefficients[i, 2]
  )
}
