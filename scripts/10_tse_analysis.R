### electoral crime and performance paper
# main analysis script
#   this script produces all tables, plots, and analyses in the electoral crime
#   and performance paper

# author: andre assumpcao
# by andre.assumpcao@gmail.com

# for testing purposes only!
rm(list = ls())

### data and library calls
# import libraries
library(AER)
library(lfe)
library(magrittr)
library(stargazer)
library(tidyverse)
library(xtable)

# load data
load('data/tseFinal.Rda')

### function definitions
# function to conduct t-tests across parameters in different regressions
t.test2 <- function(mean1, mean2, se1, se2) {
  # Args:
  #   mean1, mean2: means of each parameter
  #   se1, se2:     standard errors of each parameter

  # Returns:
  #   test statistics

  # Body:
  #   compute statistics and return results

  # function
  se <- se1 + se2
  df <- ((se1 + se2)^2) / ((se1)^2 / (9442 - 1) + (se2)^2 / (9442 - 1))
  t  <- (mean1 - mean2) / se
  result <- c(mean1 - mean2, se, t, 2 * pt(-abs(t), df))
  names(result) <- c('Difference in Means', 'Std. Error', 't-stat', 'p-value')

  # return call
  return(result)
}

# function to change names of instrumented variable in felm regression so that
# stargazer outputs everything in the same row
cbeta <- function(reg) {
  # Args:
  #   reg: regression object

  # Returns:
  #   matrix of robust standard errors

  # Body:
  #   compute standard errors in different ways if lm, ivreg or felm classes

  # function
  if (class(reg) == 'felm') {
    if (length(reg$coefficients) > 1) {
      row.names(reg$coefficients)[2] <- 'candidacy.invalid.ontrial'
      row.names(reg$beta)[2]         <- 'candidacy.invalid.ontrial'
      names(reg$rse)[2]              <- 'candidacy.invalid.ontrial'
    } else if (length(reg$coefficients) == 1) {
      row.names(reg$coefficients)[1] <- 'candidacy.invalid.ontrial'
      row.names(reg$beta)[1]         <- 'candidacy.invalid.ontrial'
      names(reg$rse)[1]              <- 'candidacy.invalid.ontrial'
    }
  }

  # return call
  return(reg)
}

# define function to calculate corrected SEs for OLS, IV, and FELM regressions
cse <- function(reg) {
  # Args:
  #   reg: regression object

  # Returns:
  #   matrix of robust standard errors

  # Body:
  #   compute standard errors in different ways if lm, ivreg or felm classes

  # function
  if (class(reg) == 'lm') {
    rob <- sqrt(diag(sandwich::vcovHC(reg, type = 'HC1')))
  } else if (class(reg) == 'felm') {
    if (length(reg$coefficients > 1)) {
      reg <- cbeta(reg)
      rob <- summary(reg, robust = TRUE)$coefficients[, 2]
    }

  } else if (class(reg) == 'ivreg') {
    rob <- ivpack::robust.se(reg)[, 2]
  } else {
    message('not implemented yet')
  }
  # # fix coefficient names
  # names(rob) %<>% str_replace(fixed('`candidacy.invalid.ontrial(fit)`'),
  #                             fixed('candidacy.invalid.ontrial'))
  # return matrix
  return(rob)
}

### define y's and x's used in analysis and their labels
# outcome labels
outcomes       <- c('outcome.elected', 'outcome.share', 'outcome.distance')
outcome.labels <- c('Probability of Election',
                    'Total Vote Share (in p.p.)',
                    'Vote Distance to Election Cutoff (in p.p.)')

# define instruments and their labels
instrument        <- 'candidacy.invalid.onappeal'
instrumented      <- 'candidacy.invalid.ontrial'
instrument.labels <- c('Convicted at Trial', 'Convicted on Appeal')

# define independent variables and their labels
covariates       <- c('candidate.age', 'candidate.male', 'candidate.education',
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

# define levels for education and marital status variables
labels1 <- c('Illiterate', 'Completed ES/MS', 'Incomplete ES/MS',
             'Can Read and Write', 'Completed HS', 'Incomplete HS',
             'Completed College', 'Incomplete College')
labels2 <- c('Married', 'Divorced', 'Legally Divorced', 'Single', 'Widowed')

# assign factors
tse.analysis$candidate.education %<>% factor(labels = labels1)
tse.analysis$candidate.maritalstatus %<>% factor(labels = labels2)

# remove variable indexes
rm(integers, factors, labels1, labels2)

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
  # out = 'tables/sumstats.tex',
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

### reversals table
# run tabulation of convictions
reversals <- tse.analysis %$%
  table(candidacy.invalid.ontrial, candidacy.invalid.onappeal)

# do the math for table
reversals[1, 2] / (reversals[1, 1] + reversals[1, 2])
reversals[2, 1] / (reversals[2, 2] + reversals[2, 1])

# remove useless objects
rm(reversals)

### test for heterogeneous judicial behavior between trial and appeals
# i am interested in knowing whether justices change change the factors
# affecting ruling when elections have passed.

# regression for factors affecting trial
tse.analysis %>%
  {felm(candidacy.invalid.ontrial ~ outcome.elected + candidate.age +
    candidate.male + candidate.maritalstatus + candidate.education +
    candidate.experience + candidacy.expenditures.actual | election.year +
    election.ID + party.coalition, data = .)} -> covariate.balance.instrumented

# regression for factors affecting appeals
tse.analysis %>%
  {felm(candidacy.invalid.onappeal ~ outcome.elected + candidate.age +
    candidate.male + candidate.maritalstatus + candidate.education +
    candidate.experience + candidacy.expenditures.actual | election.year +
    election.ID + party.coalition, data = .)} -> covariate.balance.instrument

# check point estimates and standard errors in each regression
covariate.balance.instrumented %>% {summary(.)$coefficients[, c(1, 2)]}
covariate.balance.instrument   %>% {summary(.)$coefficients[, c(1, 2)]}

# create table of judicial behavior
judicial.behavior <- tibble()

# loop over stats and create vector
for (i in 1:16){
  # create data vector
  vector <- t.test2(
    summary(covariate.balance.instrumented)$coefficients[i, 1],
    summary(covariate.balance.instrument)$coefficients[i, 1],
    summary(covariate.balance.instrumented)$coefficients[i, 2],
    summary(covariate.balance.instrument)$coefficients[i, 2]
  )
  # bind to data
  judicial.behavior <- bind_rows(judicial.behavior, vector)
}

# format variable names to include in table
var.names <- summary(covariate.balance.instrument)$coefficients %>%
  {dimnames(.)[[1]]} %>%
  str_remove_all('candida(cy|te)\\.|education|maritalstatus|\\.actual')
var.names[c(2, 3)] %<>% str_to_sentence()
var.names[c(1, 15, 16)] <- c('Elected to Office', covariate.labels[c(5, 6)])

# format judicial behavior dataset
judicial.behavior %>%
  mutate(Variable = var.names) %>%
  select(Variable, everything()) %>%
  mutate_at(vars(2:4), ~sprintf(., fmt = '%.3f')) %>%
  slice(1:3, 14:16, 4:13) %>%
  xtable(label = 'tab:heterogeneous_sentencing', digits = 3) %>%
  print.xtable(floating = FALSE, hline.after = c(-1, -1, 0, 16, 16),
               include.rownames = FALSE)

# remove useless objects
rm(list = objects(pattern = 'balance|var\\.names|judicial\\.behavior|vector'))

### first-stage tests
# produce graphs testing the first-stage strength
tse.analysis %>%
  {lm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal, data = .)} -> fs1

tse.analysis %>%
  {felm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .,
    exactDOF = TRUE)} -> fs2

tse.analysis %>%
  {felm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education|election.year + election.ID +
    party.coalition, data = ., exactDOF = TRUE)} -> fs3

# extract point estimates and s.e.'s for graph and tables
point.estimates1 <- c(summary(fs1)$coefficients[2, 1], cse(fs1)[2])
point.estimates2 <- c(summary(fs2)$coefficients[2, 1], cse(fs2)[2])
point.estimates3 <- c(summary(fs3)$coefficients[1, 1], cse(fs3)[1])

# extract f-stat for graphs and tables
f.stat1 <- summary(fs1)$fstatistic[1]
f.stat2 <- summary(fs2)$fstat
f.stat3 <- summary(fs3)$P.fstat['F']

# build vectors with point estimates and 10%, 5%, and 1% CIs around estimates
fs.estimate1 <- point.estimates1 %>%
  {c(.[1], .[1] - qnorm(.1) * .[2], .[1] + qnorm(.1) * .[2],
     .[1] - qnorm(.05) * .[2], .[1] + qnorm(.05) * .[2],
     .[1] - qnorm(.01) * .[2], .[1] + qnorm(.01) * .[2])} %>%
  unname() %>%
  round(3)
fs.estimate2 <- point.estimates2 %>%
  {c(.[1], .[1] - qnorm(.1) * .[2], .[1] + qnorm(.1) * .[2],
     .[1] - qnorm(.05) * .[2], .[1] + qnorm(.05) * .[2],
     .[1] - qnorm(.01) * .[2], .[1] + qnorm(.01) * .[2])} %>%
  unname() %>%
  round(3)
fs.estimate3 <- point.estimates3 %>%
  {c(.[1], .[1] - qnorm(.1) * .[2], .[1] + qnorm(.1) * .[2],
     .[1] - qnorm(.05) * .[2], .[1] + qnorm(.05) * .[2],
     .[1] - qnorm(.01) * .[2], .[1] + qnorm(.01) * .[2])} %>%
  unname() %>%
  round(3)

# build dataset
models <- rep(c('model1', 'model2', 'model3'), 3)
ci_bound <- rep(c('90% CI', '95% CI', '99% CI'), each = 3)
estimate <- rep(c(fs.estimate1[1], fs.estimate2[1], fs.estimate3[1]), 3)
ci_upper <- c(fs.estimate1[2], fs.estimate2[2], fs.estimate3[2],
              fs.estimate1[4], fs.estimate2[4], fs.estimate3[4],
              fs.estimate1[6], fs.estimate2[6], fs.estimate3[6])
ci_lower <- c(fs.estimate1[3], fs.estimate2[3], fs.estimate3[3],
              fs.estimate1[5], fs.estimate2[5], fs.estimate3[5],
              fs.estimate1[7], fs.estimate2[7], fs.estimate3[7])
fs.estimates <- tibble(models, ci_bound, estimate, ci_upper, ci_lower)

# define x-axis labels for ggplot
labels <- c(f.stat1, f.stat2, f.stat3) %>%
  round(1) %>%
  format(big.mark = ',') %>%
  trimws() %>%
  {paste0('(F-stat = ', ., ')')} %>%
  {paste(c('No Covariates', 'Individual Covariates',
           'Individual Covariates \n and Fixed-Effects'), ., sep = '\n')}

# build plot
ggplot(fs.estimates, aes(y = estimate, x = models, group = ci_bound)) +
  geom_point(size = 4) +
  geom_text(aes(label = estimate), nudge_x = .15, family = 'LM Roman 10') +
  geom_errorbar(aes(ymax = ci_upper, ymin = ci_lower, color = ci_bound),
    width = .25, position = position_nudge(x = 0, y = 0)) +
  scale_color_manual(values = c('grey74', 'yellow4', 'grey10'),
    name = 'Confidence Intervals') +
  scale_x_discrete(labels = labels) +
  labs(y = 'Instrument Point Estimates', x = element_blank()) +
  ylim(min = .65, max = .8) +
  theme_bw() +
  theme(axis.title = element_text(size = 10), legend.position = 'top',
        axis.text.x = element_text(size = 10, lineheight = 1.1),
        text = element_text(family = 'LM Roman 10'),
        panel.grid.major = element_line(color = 'snow3', linetype = 'dashed'),
        panel.grid.minor = element_line(color = 'snow3', linetype = 'dashed')
  )

# # save plot
# ggsave('firststage.png', device = 'png', path = 'plots', dpi = 300)

# remove unnecessary objects
rm(list = objects(pattern = 'f\\.stat|point\\.estimate|names|models|ci'))

# produce tables showing first-stage strength
stargazer(

  # first-stage regressions
  list(fs1, fs2, fs3),

  # table cosmetics
  type = 'text',
  title = 'First-Stage Regressions of Convictions at Trial and on Appeal',
  style = 'default',
  # out = 'tables/firststage.tex',
  out.header = FALSE,
  covariate.labels = instrument.labels[2],
  dep.var.caption = paste0('Outcome: ', instrument.labels[1]),
  dep.var.labels.include = FALSE,
  align = TRUE,
  se = list(cse(fs1), cse(fs2), cse(fs3)),
  column.sep.width = '4pt',
  digit.separate = 3,
  digits = 3,
  digits.extra = 0,
  font.size = 'scriptsize',
  header = FALSE,
  initial.zero = FALSE,
  model.names = FALSE,
  keep = c('invalid'),
  label = 'tab:firststage',
  no.space = FALSE,
  omit = c('constant', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)

### hausman tests of instrument strength
# produce graphs testing the first-stage strength
tse.analysis %>%
  {ivreg(outcome.elected ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv1

tse.analysis %>%
  {ivreg(outcome.share ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv2

tse.analysis %>%
  {ivreg(outcome.distance ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv3

filter(tse.analysis, office.ID == 13) %>%
  {ivreg(outcome.distance ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv4

filter(tse.analysis, office.ID == 11) %>%
  {ivreg(outcome.distance ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv5

# create hausman dataset
hausman <- objects(pattern = 'iv') %>%
           lapply(get) %>%
           lapply(summary, diagnostics = TRUE) %>%
           lapply(function(x){x$diagnostics[2, c(3, 4)]}) %>%
           unlist()

# print table
tibble(
  Outcome = str_remove_all(outcome.labels, '\\((.)*\\)') %>% trimws() %>%
    c('City Councilor', 'Mayor'),
  `Hausman Statistic` = hausman[seq(1, 10, 2)] %>% sprintf(fmt = '%.2f'),
  `p-value` = hausman[seq(2, 10, 2)] %>% sprintf(fmt = '%.3f')
) %>%
xtable(
  label  = 'tab:hausman',
  align  = c('r', 'l', 'D{.}{.}{-2}', 'D{.}{.}{-3}'),
  digits = c(0, 0, 2, -3)
) %>%
print.xtable(
  floating = FALSE,
  hline.after = c(-1, -1, 0, 5, 5),
  include.rownames = FALSE
)

### ols results
# create regression objects using the three outcomes and two samples
tse.analysis %>%
  {lm(outcome.elected ~ candidacy.invalid.ontrial, data = .)} -> ols1

tse.analysis %>%
  {lm(outcome.elected ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)} -> ols2

tse.analysis %>%
  {felm(outcome.elected ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.year +
    election.ID + party.coalition, data = ., exactDOF = TRUE)} -> ols3

tse.analysis %>%
  {lm(outcome.share ~ candidacy.invalid.ontrial, data = .)} -> ols4

tse.analysis %>%
  {lm(outcome.share ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)} -> ols5

tse.analysis %>%
  {felm(outcome.share ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.year +
    election.ID + party.coalition, data = ., exactDOF = TRUE)} -> ols6

filter(tse.analysis, office.ID == 13) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial, data = .)} -> ols7

filter(tse.analysis, office.ID == 13) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)} -> ols8

filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ candidacy.invalid.ontrial ~ candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.year +
    election.ID + party.coalition, data = ., exactDOF = TRUE)} -> ols9

filter(tse.analysis, office.ID == 11) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial, data = .)} -> ols10

filter(tse.analysis, office.ID == 11) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)} -> ols11

filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ candidacy.invalid.ontrial ~ candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.year +
    election.ID + party.coalition, data = ., exactDOF = TRUE)} -> ols12

### instrumental variables results
# create regression objects using the three outcomes and two samples
# create regressions using outcome.elected and outcome.share as y
tse.analysis %>%
  {felm(outcome.elected ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)} -> ss1

tse.analysis %>%
  {felm(outcome.elected ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal + candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss2

tse.analysis %>%
  {felm(outcome.elected ~ 1 | election.year + election.ID + party.coalition |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss3

tse.analysis %>%
  {felm(outcome.share ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)} -> ss4

tse.analysis %>%
  {felm(outcome.share ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal + candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss5

tse.analysis %>%
  {felm(outcome.share ~ 1 | election.year + election.ID + party.coalition |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss6

filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)} -> ss7

filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal + candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss8

filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ 1 | election.year + election.ID + party.coalition |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss9

filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)} -> ss10

filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal + candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss11

filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ 1 | election.year + election.ID + party.coalition |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education), data = .,
    exactDOF = TRUE)} -> ss12

# produce tables with outcome one
stargazer(

  # first-stage regressions
  list(ols1, ols2, ols3, cbeta(ss1), cbeta(ss2), cbeta(ss3)),

  # table cosmetics
  type = 'text',
  title = 'The Effect of Electoral Crimes on the Probability of Election',
  style = 'default',
  # out = 'tables/secondstageoutcome1.tex',
  out.header = FALSE,
  column.labels = rep(c('OLS', 'IV'), each = 3),
  column.separate = rep(1, 6),
  covariate.labels = instrument.labels[1],
  dep.var.caption = paste0('Outcome: ', outcome.labels[1]),
  dep.var.labels.include = FALSE,
  align = TRUE,
  se = list(cse(ols1), cse(ols2), cse(ols3), cse(ss1), cse(ss2), cse(ss3)),
  p.auto = TRUE,
  column.sep.width = '4pt',
  digit.separate = 3,
  digits = 3,
  digits.extra = 0,
  font.size = 'scriptsize',
  header = FALSE,
  initial.zero = FALSE,
  model.names = FALSE,
  keep = c('invalid'),
  label = 'tab:secondstageoutcome1',
  no.space = FALSE,
  omit = c('constant', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)

# produce tables with outcome two
stargazer(

  # first-stage regressions
  list(ols4, ols5, ols6, cbeta(ss4), cbeta(ss5), cbeta(ss6)),

  # table cosmetics
  type = 'text',
  title = 'The Effect of Electoral Crimes on the Total Vote Share',
  style = 'default',
  # out = 'tables/secondstageoutcome2.tex',
  out.header = FALSE,
  column.labels = rep(c('OLS', 'IV'), each = 3),
  column.separate = rep(1, 6),
  covariate.labels = instrument.labels[2],
  dep.var.caption = paste0('Outcome: ', outcome.labels[2]),
  dep.var.labels.include = FALSE,
  align = TRUE,
  se = list(cse(ols4), cse(ols5), cse(ols6), cse(ss4), cse(ss5), cse(ss6)),
  p.auto = TRUE,
  column.sep.width = '4pt',
  digit.separate = 3,
  digits = 3,
  digits.extra = 0,
  font.size = 'scriptsize',
  header = FALSE,
  initial.zero = FALSE,
  model.names = FALSE,
  keep = c('invalid'),
  label = 'tab:secondstageoutcome2',
  no.space = FALSE,
  omit = c('constant', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)

# produce tables with outcome three for city councilor and mayor sample
stargazer(

  # first-stage regressions
  list(ols9, cbeta(ss9), ols12, cbeta(ss12)),

  # table cosmetics
  type = 'text',
  title = paste('The Effect of Electoral Crimes on the Vote Distance to',
                'Election Cutoff', sep = ' '),
  style = 'default',
  # out = 'tables/secondstageoutcome2.tex',
  out.header = FALSE,
  column.labels = rep(c('OLS', 'IV'), each = 3),
  column.separate = rep(1, 6),
  covariate.labels = instrument.labels[2],
  dep.var.caption = paste0('Outcome: ', outcome.labels[3]),
  dep.var.labels.include = FALSE,
  align = TRUE,
  se = list(cse(ols9), cse(ols12), cse(ss9), cse(ss12)),
  p.auto = TRUE,
  column.sep.width = '4pt',
  digit.separate = 3,
  digits = 3,
  digits.extra = 0,
  font.size = 'scriptsize',
  header = FALSE,
  initial.zero = FALSE,
  model.names = FALSE,
  keep = c('invalid'),
  label = 'tab:secondstageoutcome2',
  no.space = FALSE,
  omit = c('constant', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)
