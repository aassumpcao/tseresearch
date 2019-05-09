### electoral crime and performance paper
# main analysis script
#   this script produces all tables, plots, and analyses in the electoral crime
#   and performance paper

# author: andre assumpcao
# by andre.assumpcao@gmail.com

### data and library calls
# import libraries
library(lfe)
library(magrittr)
library(stargazer)
library(tidyverse)
library(xtable)

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
  names(result) <- c('Difference in Means', 'Std. Error', 't-stat', 'p-value')

  # return call
  return(result)
}

### define y's and x's used in analysis and their labels
# outcome labels
outcomes       <- c('outcome.elected', 'outcome.distance', 'outcome.share')
outcome.labels <- c('Probability of Election',
                    'Vote Distance to Election Cutoff (in p.p.)',
                    'Total Vote Share (in p.p.)')

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

### reversals table
# run tabulation of convictions
reversals <- tse.analysis %$%
  table(candidacy.invalid.ontrial, candidacy.invalid.onappeal)

# do the math for table
reversals[1, 2] / (reversals[1, 1] + reversals[1, 2])
reversals[2, 1] / (reversals[2, 2] + reversals[2, 1])

### test for heterogeneous judicial behavior between trial and appeals
# i am interested in knowing whether justices change change the factors
# affecting ruling when elections have passed.

# regression for factors affecting trial
tse.analysis %>%
  {felm(candidacy.invalid.ontrial ~ candidate.age + candidate.male +
    candidate.maritalstatus + candidate.education + candidate.experience +
    candidacy.expenditures.actual | election.year + election.ID +
    party.coalition, data = .)} -> covariate.balance.instrumented

# regression for factors affecting appeals
tse.analysis %>%
  {felm(candidacy.invalid.onappeal ~ candidate.age + candidate.male +
    candidate.maritalstatus + candidate.education + candidate.experience +
    candidacy.expenditures.actual | election.year + election.ID +
    party.coalition, data = .)} -> covariate.balance.instrument

# check point estimates and standard errors in each regression
covariate.balance.instrumented %>% {summary(.)$coefficients[, c(1, 2)]}
covariate.balance.instrument   %>% {summary(.)$coefficients[, c(1, 2)]}

# create table of judicial behavior
judicial.behavior <- tibble()

# loop over stats and create vector
for (i in 1:15){
  # create datavector
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
var.names[c(1, 2)] %<>% str_to_sentence()
var.names[c(14, 15)] <- covariate.labels[c(5, 6)]

# format judicial behavior dataset
judicial.behavior %>%
  mutate(Variable = var.names) %>%
  select(Variable, everything()) %>%
  mutate_at(vars(2:4), ~sprintf(., fmt = '%.3f')) %>%
  slice(1:2, 14:15, 3:13) %>%
  xtable(label = 'tab:heterogeneous_sentencing', digits = 3) %>%
  print.xtable(floating = FALSE, hline.after = c(-1, -1, 0, 14, 15, 15),
               include.rownames = FALSE)

### first-stage tests
# produce tables testing the first-stage strength
tse.analysis %>%
  {lm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal, data = .)} %>%
  summary() -> fs1

tse.analysis %>%
  {felm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = ., exactDOF = T)} %>%
  summary() -> fs2

tse.analysis %>%
  {felm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education|election.year + election.ID +
    party.coalition, data = ., exactDOF = TRUE)} %>%
  summary() -> fs3

# extract point estimates and s.e.'s for graph and tables
point.estimates1 <- fs1$coefficients[2, c(1, 2)]
point.estimates2 <- fs2$coefficients[2, c(1, 2)]
point.estimates3 <- fs3$coefficients[1, c(1, 2)]

# extract f-stat for graphs and tables
f.stat1 <- fs1$fstatistic[1]
f.stat2 <- fs2$fstat
f.stat3 <- fs3$P.fstat['F']

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
models       <- rep(c('model1', 'model2', 'model3'), 3)
ci_bound     <- rep(c('90% CI', '95% CI', '99% CI'), each = 3)
estimate     <- rep(c(fs.estimate1[1], fs.estimate2[1], fs.estimate3[1]), 3)
ci_upper     <- c(fs.estimate1[2], fs.estimate2[2], fs.estimate3[2],
                  fs.estimate1[4], fs.estimate2[4], fs.estimate3[4],
                  fs.estimate1[6], fs.estimate2[6], fs.estimate3[6])
ci_lower     <- c(fs.estimate1[3], fs.estimate2[3], fs.estimate3[3],
                  fs.estimate1[5], fs.estimate2[5], fs.estimate3[5],
                  fs.estimate1[7], fs.estimate2[7], fs.estimate3[7])
fs.estimates <- tibble(models, ci_bound, estimate, ci_upper, ci_lower)

# define x labels for ggplot
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
  scale_color_manual(values = paste0('grey', c(74, 49, 10)),
    name = 'Confidence Intervals') +
  scale_x_discrete(labels = labels) +
  labs(y = 'Instrument Point Estimates', x = element_blank()) +
  theme_bw() +
  theme(axis.title = element_text(size = 10), legend.position = 'top',
        axis.text.x = element_text(size = 10, lineheight = 1.1),
        text = element_text(family = 'LM Roman 10'),
        panel.grid.major = element_line(color = 'snow3', linetype = 'dashed'),
        panel.grid.minor = element_line(color = 'snow3', linetype = 'dashed'))

# save plot
ggsave('fsestimates.png', device = 'png', path = 'plots', dpi = 300)

# remove unnecessary objects
rm(list = objects(pattern = 'fs|f\\.stat|point\\.estimate|names'))
