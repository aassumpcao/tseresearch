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
# library(extrafont)
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
  result <- c(mean1, mean2, mean1 - mean2, se, t, 2 * pt(-abs(t), df))
  names(result) <- c('Trial', 'Appeals', 'Difference in beta', 'Std. Error',
                     't-stat', 'p-value')

  # return call
  return(result)
}

# function to change names of instrumented variable in felm regression so that
# stargazer outputs everything in the same row
cbeta <- function(reg, name = 'candidacy.invalid.ontrial') {
  # Args:
  #   reg: regression object

  # Returns:
  #   matrix of robust standard errors

  # Body:
  #   compute standard errors in different ways if lm, ivreg or felm classes

  # function
  # check where the coefficient with the wrong name is
  i <- which(str_detect(row.names(reg$coefficients), fixed('(fit)')))
  j <- which(str_detect(row.names(reg$beta), fixed('(fit)')))
  w <- which(str_detect(names(reg$rse), fixed('(fit)')))

  # assign
  if (class(reg) == 'felm') {
    if (!is.null(name)) {
      row.names(reg$coefficients)[i] <- name
      row.names(reg$beta)[j]         <- name
      names(reg$rse)[w]              <- name
    }
  }

  # return call
  return(reg)
}

# define function to calculate corrected SEs for OLS, IV, and FELM regressions
cse <- function(reg, fs = FALSE, ...) {
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
    if (fs == FALSE) {reg <- cbeta(reg, ...)}
    rob <- summary(reg, robust = TRUE)$coefficients[, 2]
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

# define independent variables labels
covariates       <- c('candidate.age', 'candidate.male',
                      'candidate.maritalstatus', 'candidate.education',
                      'candidate.experience', 'candidacy.expenditures.actual')
covariate.labels <- c('Age', 'Male', 'Level of Education', 'Marital Status',
                      'Political Experience', 'Campaign Expenditures (in R$)')

### define matrices of fixed effects
# municipality and time
mun.label   <- 'Municipal Election'
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

# revert expenditures to log (and preserve original dataset for candidate
# disengagement tests at the end)
candidate.disengagement.analysis <- tse.analysis
tse.analysis$candidacy.expenditures.actual %<>% {log(. + 1)}

### first-stage tests
# produce graphs testing the first-stage strength
fs01 <- lm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal, tse.analysis)
fs02 <- felm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal +
  candidate.age + candidate.male + candidate.experience +
  candidacy.expenditures.actual + candidate.maritalstatus +
  candidate.education, data = tse.analysis, exactDOF = TRUE)
fs03 <- felm(candidacy.invalid.ontrial ~ candidacy.invalid.onappeal +
  candidate.age + candidate.male + candidate.experience +
  candidacy.expenditures.actual + candidate.maritalstatus +
  candidate.education | election.ID + election.year + party.number,
  data = tse.analysis, exactDOF = TRUE)

# extract point estimates and s.e.'s for graph and tables
point.estimates1 <- c(summary(fs01)$coefficients[2, 1], cse(fs01, fs = TRUE)[2])
point.estimates2 <- c(summary(fs02)$coefficients[2, 1], cse(fs02, fs = TRUE)[2])
point.estimates3 <- c(summary(fs03)$coefficients[1, 1], cse(fs03, fs = TRUE)[1])

# extract f-stat for graphs and tables
f.stat1 <- summary(fs01)$fstatistic[1]
f.stat2 <- summary(fs02)$fstat
f.stat3 <- summary(fs03)$F.fstat[1]

# build vectors with point estimates and 10%, 5%, and 1% CIs around estimates
fs.estimate1 <- point.estimates1 %>%
  {c(.[1], .[1] - qnorm(.05) * .[2], .[1] + qnorm(.05) * .[2],
     .[1] - qnorm(.025) * .[2], .[1] + qnorm(.025) * .[2],
     .[1] - qnorm(.005) * .[2], .[1] + qnorm(.005) * .[2])} %>%
  unname() %>%
  round(3)
fs.estimate2 <- point.estimates2 %>%
  {c(.[1], .[1] - qnorm(.05) * .[2], .[1] + qnorm(.05) * .[2],
     .[1] - qnorm(.025) * .[2], .[1] + qnorm(.025) * .[2],
     .[1] - qnorm(.005) * .[2], .[1] + qnorm(.005) * .[2])} %>%
  unname() %>%
  round(3)
fs.estimate3 <- point.estimates3 %>%
  {c(.[1], .[1] - qnorm(.05) * .[2], .[1] + qnorm(.05) * .[2],
     .[1] - qnorm(.025) * .[2], .[1] + qnorm(.025) * .[2],
     .[1] - qnorm(.005) * .[2], .[1] + qnorm(.005) * .[2])} %>%
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
  geom_point(aes(color = ci_bound), position = position_dodge(width = .25),
    size = 3) +
  geom_text(aes(label = estimate), nudge_x = -.25, family = 'LM Roman 10',
    size = 4) +
  geom_errorbar(aes(ymax = ci_upper, ymin = ci_lower, color = ci_bound),
    width = .25, position = position_dodge(width = .25)) +
  scale_color_manual(values = c('grey74', 'yellow4', 'grey10'),
    name = 'Confidence Intervals:') +
  scale_x_discrete(labels = labels) +
  labs(y = 'Instrument Point Estimates', x = element_blank()) +
  ylim(min = .7, max = .8) +
  theme_bw() +
  theme(axis.title  = element_text(size = 10),
        axis.text.y = element_text(size = 10, lineheight = 1.1, face = 'bold'),
        axis.text.x = element_text(size = 10, lineheight = 1.1, face = 'bold'),
        text = element_text(family = 'LM Roman 10'),
        panel.border = element_rect(colour = 'black', size = 1),
        legend.text  = element_text(size = 10), legend.position = 'top',
        panel.grid.major = element_line(color = 'lightcyan4',
                                        linetype = 'dotted'),
        panel.grid.minor = element_line(color = 'lightcyan4',
                                        linetype = 'dotted')
  )

# # save plot
# library(extrafont)
# ggsave('firststage.pdf', device = cairo_pdf, path = 'plots', dpi = 100,
#        width = 7, height = 5)

# remove unnecessary objects
rm(list = objects(pattern = 'f\\.stat|point\\.estimate|names|models|ci'))

# produce tables showing first-stage strength
stargazer(

  # first-stage regressions
  list(fs01, fs02, fs03),

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
  se = list(cse(fs01, fs = TRUE), cse(fs02, fs = TRUE), cse(fs03, fs = TRUE)),
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
  label = 'tab:firststage',
  no.space = FALSE,
  omit = c('constant|education|maritalstatus', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)

### hausman tests of instrument strength
# produce graphs testing the first-stage strength
tse.analysis %>%
  {ivreg(outcome.elected ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv01
tse.analysis %>%
  {ivreg(outcome.share ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv02
tse.analysis %>%
  {ivreg(outcome.distance ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv03
filter(tse.analysis, office.ID == 13) %>%
  {ivreg(outcome.distance ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv04
filter(tse.analysis, office.ID == 11) %>%
  {ivreg(outcome.distance ~
    candidacy.invalid.ontrial | candidacy.invalid.onappeal, data = .)} -> iv05

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

# # remove unnecessary objects
# rm(iv01, iv02, iv03, iv04, iv05)

### ols results
# create regression objects using the three outcomes and two samples

# outcome 1: probability of election
ols01 <- lm(outcome.elected ~ candidacy.invalid.ontrial, data = tse.analysis)
ols02 <- lm(outcome.elected ~ candidacy.invalid.ontrial + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education, data = tse.analysis)
ols03 <- felm(outcome.elected ~ candidacy.invalid.ontrial + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education | election.ID + election.year +
  party.number, data = tse.analysis, exactDOF = TRUE)

# outcome 2: vote share
ols04 <- lm(outcome.share ~ candidacy.invalid.ontrial, data = tse.analysis)
ols05 <- lm(outcome.share ~ candidacy.invalid.ontrial + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education, data = tse.analysis)
ols06 <- felm(outcome.share ~ candidacy.invalid.ontrial + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education | election.ID + election.year +
  party.number, data = tse.analysis, exactDOF = TRUE)

# outcome 3: distance to election cutoff for city councilor candidates
ols07 <- filter(tse.analysis, office.ID == 13) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial, data = .)}
ols08 <- filter(tse.analysis, office.ID == 13) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)}
ols09 <- filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number, data = ., exactDOF = TRUE)}

# outcome 3: distance to election cutoff for mayor candidates
ols10 <- filter(tse.analysis, office.ID == 11) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial, data = .)}
ols11 <- filter(tse.analysis, office.ID == 11) %>%
  {lm(outcome.distance ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)}
ols12 <- filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ candidacy.invalid.ontrial + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number, data = ., exactDOF = TRUE)}

### instrumental variables results
# create regression objects using the three outcomes and two samples

# outcome 1: probability of election
ss01 <- tse.analysis %>%
  {felm(outcome.elected ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)}
ss02 <- tse.analysis %>%
  {felm(outcome.elected ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | 0 |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal), data = .,
    exactDOF = TRUE)}
ss03 <- tse.analysis %>%
  {felm(outcome.elected ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number | (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal),
    data = ., exactDOF = TRUE)}

# outcome 2: vote share
ss04 <- tse.analysis %>%
  {felm(outcome.share ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)}
ss05 <- tse.analysis %>%
  {felm(outcome.share ~ candidate.age + candidate.male + candidate.experience +
    candidacy.expenditures.actual + candidate.maritalstatus +
    candidate.education | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)}
ss06 <- tse.analysis %>%
  {felm(outcome.share ~ candidate.age + candidate.male + candidate.experience +
    candidacy.expenditures.actual + candidate.maritalstatus +
    candidate.education | election.ID + election.year + party.number |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal), data = .,
    exactDOF = TRUE)}

# outcome 3: distance to election cutoff for city councilor candidates
ss07 <- filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)}
ss08 <- filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | 0 |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal), data = .,
    exactDOF = TRUE)}
ss09 <- filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number | (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal),
    data = ., exactDOF = TRUE)}

# outcome 3: distance to election cutoff for mayor candidates
ss10 <- filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ 1 | 0 | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal), data = ., exactDOF = TRUE)}
ss11 <- filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | 0 |
    (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal), data = .,
    exactDOF = TRUE)}
ss12 <- filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number | (candidacy.invalid.ontrial ~ candidacy.invalid.onappeal),
    data = ., exactDOF = TRUE)}

# produce tables with outcome one
stargazer(

  # first-stage regressions
  list(ols01, ols02, ols03, cbeta(ss01), cbeta(ss02), cbeta(ss03)),

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
  se = list(cse(ols01), cse(ols02), cse(ols03),
            cse(ss01), cse(ss02), cse(ss03)),
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

# extract f-stat for graphs and tables
c('\textit{F}-stat ',
  summary(ols01)$fstatistic[1] %>% round(2),
  summary(ols02)$fstatistic[1] %>% round(2),
  summary(ols03)$F.fstat[1]    %>% round(2),
  summary(ss01)$F.fstat[1]     %>% round(2),
  summary(ss02)$F.fstat[1]     %>% round(2),
  summary(ss03)$F.fstat[1]     %>% round(2)
) %>%
paste0(collapse = ' & ') %>%
paste0(' \\')

# produce tables with outcome two
stargazer(

  # first-stage regressions
  list(ols04, ols05, ols06, cbeta(ss04), cbeta(ss05), cbeta(ss06)),

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
  se = list(cse(ols04), cse(ols05), cse(ols06),
            cse(ss04), cse(ss05), cse(ss06)),
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

# extract f-stat for graphs and tables
c('\textit{F}-stat ',
  summary(ols04)$fstatistic[1] %>% round(2),
  summary(ols05)$fstatistic[1] %>% round(2),
  summary(ols06)$F.fstat[1]    %>% round(2),
  summary(ss04)$F.fstat[1]     %>% round(2),
  summary(ss05)$F.fstat[1]     %>% round(2),
  summary(ss06)$F.fstat[1]     %>% round(2)
) %>%
paste0(collapse = ' & ') %>%
paste0(' \\')

# produce tables with outcome three for city councilor and mayor sample
stargazer(

  # first-stage regressions
  list(ols09, cbeta(ss09), ols12, cbeta(ss12)),

  # table cosmetics
  type = 'text',
  title = paste('The Effect of Electoral Crimes on the Vote Distance to',
                'Election Cutoff', sep = ' '),
  style = 'default',
  # out = 'tables/secondstageoutcome3.tex',
  out.header = FALSE,
  column.labels = rep(c('OLS', 'IV'), 2),
  column.separate = rep(1, 4),
  covariate.labels = instrument.labels[1],
  dep.var.caption = paste0('Outcome: ', outcome.labels[3]),
  dep.var.labels.include = FALSE,
  align = TRUE,
  se = list(cse(ols09), cse(ss09), cse(ols12), cse(ss12)),
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
  label = 'tab:secondstageoutcome3',
  no.space = FALSE,
  omit = c('constant', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)

# extract f-stat for graphs and tables
objects(pattern = 'ols|ss') %>%
{.[c(9, 12, 21, 24)]} %>%
lapply(get) %>%
lapply(function(x){summary(x)$F.fstat[1]}) %>%
unlist() %>%
round(2) %>%
paste0(collapse = ' & ') %>%
{paste0('\textit{F}-stat & ', .)} %>%
paste0(' \\')

### test for the correlation between instrument and other covariates
# here i want to know whether

### test for heterogeneous judicial behavior between trial and appeals
# i am interested in knowing whether justices change change the factors
# affecting ruling when elections have passed.

# regression for factors affecting trial
covariate.balance.instrumented <- felm(candidacy.invalid.ontrial ~
  outcome.elected + candidate.age + candidate.male + candidate.maritalstatus +
  candidate.education + candidate.experience + candidacy.expenditures.actual |
  party.number | 0 | election.ID + election.year, data = tse.analysis,
  exactDOF = TRUE, psdef = FALSE)

# regression for factors affecting appeals
covariate.balance.instrument <- felm(candidacy.invalid.onappeal ~
  outcome.elected + candidate.age + candidate.male + candidate.maritalstatus +
  candidate.education + candidate.experience + candidacy.expenditures.actual |
  party.number | 0 | election.ID + election.year, data = tse.analysis,
  exactDOF = TRUE, psdef = FALSE)

# check point estimates and standard errors in each regression
summary(covariate.balance.instrumented, robust = TRUE)$coefficients[, c(1, 2)]
summary(covariate.balance.instrument,   robust = TRUE)$coefficients[, c(1, 2)]

# create table of judicial behavior
judicial.behavior <- tibble()

# loop over stats and create vector
for (i in 1:16) {
  # create data vector
  vector <- t.test2(
    summary(covariate.balance.instrumented,
      robust = TRUE)$coefficients[i, 1],
    summary(covariate.balance.instrument,
      robust = TRUE)$coefficients[i, 1],
    summary(covariate.balance.instrumented,
      robust = TRUE)$coefficients[i, 2],
    summary(covariate.balance.instrument,
      robust = TRUE)$coefficients[i, 2]
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
  mutate(`Difference in beta` = Trial - Appeals) %>%
  mutate_at(vars(2:7), ~sprintf(., fmt = '%.3f')) %>%
  slice(1:3, 15:16, 4:14) %>%
  xtable(label = 'tab:heterogeneous_sentencing') %>%
  print.xtable(floating = FALSE, hline.after = c(-1, -1, 0, 16, 16),
    include.rownames = FALSE)

# remove useless objects
rm(list = objects(pattern = 'balance|var\\.names|judicial\\.behavior|vector'))

### test for the correlation between instrument and other covariates
# here i want to know whether the instrument might be significantly correlated
# with other covariates beyond the endogenous correlation between the
# instrumented variable and covariates. solution: run ols with instrument
# straight into second-stage

# outcome 1: probability of election
ols13 <- lm(outcome.elected ~ candidacy.invalid.onappeal, data = tse.analysis)
ols14 <- lm(outcome.elected ~ candidacy.invalid.onappeal + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education, data = tse.analysis)
ols15 <- felm(outcome.elected ~ candidacy.invalid.onappeal + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education | election.ID + election.year +
  party.number, data = tse.analysis, exactDOF = TRUE)

# outcome 2: vote share
ols16 <- lm(outcome.share ~ candidacy.invalid.onappeal, data = tse.analysis)
ols17 <- lm(outcome.share ~ candidacy.invalid.onappeal + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education, data = tse.analysis)
ols18 <- felm(outcome.share ~ candidacy.invalid.onappeal + candidate.age +
  candidate.male + candidate.experience + candidacy.expenditures.actual +
  candidate.maritalstatus + candidate.education | election.ID + election.year +
  party.number, data = tse.analysis, exactDOF = TRUE)

# outcome 3: distance to election cutoff for city councilor candidates
ols19 <- filter(tse.analysis, office.ID == 13) %>%
  {lm(outcome.distance ~ candidacy.invalid.onappeal, data = .)}
ols20 <- filter(tse.analysis, office.ID == 13) %>%
  {lm(outcome.distance ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)}
ols21 <- filter(tse.analysis, office.ID == 13) %>%
  {felm(outcome.distance ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number, data = ., exactDOF = TRUE)}

# outcome 3: distance to election cutoff for mayor candidates
ols22 <- filter(tse.analysis, office.ID == 11) %>%
  {lm(outcome.distance ~ candidacy.invalid.onappeal, data = .)}
ols23 <- filter(tse.analysis, office.ID == 11) %>%
  {lm(outcome.distance ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education, data = .)}
ols24 <- filter(tse.analysis, office.ID == 11) %>%
  {felm(outcome.distance ~ candidacy.invalid.onappeal + candidate.age +
    candidate.male + candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID + election.year+
    party.number, data = ., exactDOF = TRUE)}

# define list of models to extract betas and std errors
models <- objects(pattern = 'ols')

# recover betas
betas <- models %>%
  lapply(get) %>%
  lapply(summary) %>%
  lapply(function(x){x$coefficients[, 1]}) %>%
  unlist() %>%
  {.[str_detect(names(.), 'invalid')]}

# recover standard errors
stderr <- models %>%
  lapply(get) %>%
  lapply(cse) %>%
  unlist() %>%
  {.[str_detect(names(.), 'invalid')]}

# define vectors for dataset
depvar <- c('Probability of Election', 'Vote Share',
            'Vote Distance to Cutoff (City Councilor)',
            'Vote Distance to Cutoff (Mayor)')
models <- c('no.covariates', 'covariates', 'covariates.fe')
comparison <- rep(paste(rep(depvar, each = 3), models, sep = '.'), 2)
endogenous <- rep(c('Trial', 'Appeals'), each = 12)

# build dataset
tibble(outcomes = rep(rep(depvar, each = 3), 2), betas, models = rep(models,
  8), comparison, endogenous, stderr, ci_upper = betas + qnorm(0.005) *
  stderr, ci_lower = betas - qnorm(0.005) * stderr, group = paste0(models,
  endogenous)) %>%
mutate(outcomes = factor(outcomes, levels = unique(depvar)),
  models = factor(models, unique(models)), comparison = factor(comparison,
    levels = unique(unlist(comparison))), endogenous = factor(endogenous,
    levels = c("Trial", "Appeals"))) -> instrument.check

# build plot
ggplot(instrument.check, aes(y = betas, x = models, color = endogenous)) +
  geom_point(aes(color = endogenous), position = position_dodge(width = .25)) +
  geom_errorbar(aes(ymax = ci_upper, ymin = ci_lower, color = endogenous),
    width = .25, position = position_dodge(width = .25)) +
  scale_color_manual(values = c('grey56', 'grey10'), name = 'Coefficients:') +
  scale_x_discrete(
    labels = rep(c('No Covariates', 'Individual Covariates',
                   'Individual \n Covariates \n and Fixed Effects'), 4)) +
  labs(y = 'Point Estimates and 99% CIs', x = element_blank()) +
  facet_wrap(outcomes ~ ., scales = 'free_y') +
  theme_bw() +
  theme(axis.title  = element_text(size = 10),
        axis.text.y = element_text(size = 10, lineheight = 1.1, face = 'bold'),
        axis.text.x = element_text(size = 10, lineheight = 1.1, face = 'bold'),
        text = element_text(family = 'LM Roman 10'),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_line(color = 'lightcyan4',
                                        linetype = 'dotted'),
        panel.border = element_rect(colour = 'black', size = 1),
        legend.text  = element_text(size = 10), legend.position = 'top',
        strip.text.x = element_text(size = 10, face = 'bold')
  )

# # save plot
# library(extrafont)
# ggsave('instrumentcorrelation.pdf', device = cairo_pdf, path = 'plots',
#        dpi = 100, width = 10, height = 5)

# remove unnecessary objects
rm(depvar, models, comparison, endogenous, instrument.check, betas, stderr)

### test for voter disengagement
# there are two potential explanations for the effect here: (i) voters would be
# switching their choices when voting OR (ii) they would be disengaging from the
# political process altogether. this is what we test here.

# disengagement outcomes
voter.engagement <- c('Voter Turnout (percent)', 'Valid Votes (percent)',
                      'Invalid Votes (percent)')

# disengagement at the individual level
disengagement01 <- filter_at(tse.analysis, vars(37, 39, 41), ~!is.na(.)) %>%
  {felm(log(votes.turnout + 1) ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID +
    election.year + party.number | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal) | election.ID + election.year, data = .,
    exactDOF = TRUE, psdef = FALSE)}
disengagement02 <- filter_at(tse.analysis, vars(37, 39, 41), ~!is.na(.)) %>%
  {felm(log(votes.valid + 1) ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID +
    election.year + party.number | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal) | election.ID + election.year, data = .,
    exactDOF = TRUE, psdef = FALSE)}
disengagement03 <- filter_at(tse.analysis, vars(37, 39, 41), ~!is.na(.)) %>%
  {felm(log(votes.invalid + 1) ~ candidate.age + candidate.male +
    candidate.experience + candidacy.expenditures.actual +
    candidate.maritalstatus + candidate.education | election.ID +
    election.year + party.number | (candidacy.invalid.ontrial ~
    candidacy.invalid.onappeal) | election.ID + election.year, data = .,
    exactDOF = TRUE, psdef = FALSE)}

# aggregate dataset to party level
party.aggregation <- tse.analysis %>%
  group_by(election.ID, office.ID, election.year, party.number) %>%
  select(-matches('outcome|candidate')) %>%
  summarize(proportion.invalid.ontrial  = sum(candidacy.invalid.ontrial) /
    first(as.integer(office.vacancies)) * 100, proportion.invalid.onappeal =
    sum(candidacy.invalid.onappeal) / first(as.integer(office.vacancies)) * 100,
    votes.valid = first(votes.valid), votes.turnout = first(votes.turnout),
    votes.invalid = first(votes.invalid)
  ) %>%
  ungroup() %>%
  filter_at(vars(votes.turnout, votes.valid, votes.invalid), ~!is.na(.))

# disengagement at the party level
disengagement04 <- party.aggregation %>%
  {felm(log(votes.turnout + 1) ~ 1 | election.ID + election.year |
    (proportion.invalid.ontrial ~ proportion.invalid.onappeal) | election.ID +
    election.year, data = ., exactDOF = TRUE, psdef = FALSE)}
disengagement05 <- party.aggregation %>%
  {felm(log(votes.valid + 1) ~ 1 | election.ID + election.year |
    (proportion.invalid.ontrial ~ proportion.invalid.onappeal) | election.ID +
    election.year, data = ., exactDOF = TRUE, psdef = FALSE)}
disengagement06 <- party.aggregation %>%
  {felm(log(votes.invalid + 1) ~ 1 | election.ID + election.year |
    (proportion.invalid.ontrial ~ proportion.invalid.onappeal) | election.ID +
    election.year, data = ., exactDOF = TRUE, psdef = FALSE)}

# aggregate dataset to election level
election.aggregation <- tse.analysis %>%
  group_by(election.ID, office.ID, election.year) %>%
  select(-matches('outcome|candidate')) %>%
  summarize(proportion.invalid.ontrial  = sum(candidacy.invalid.ontrial) /
    first(as.integer(office.vacancies)) * 100, proportion.invalid.onappeal =
    sum(candidacy.invalid.onappeal) / first(as.integer(office.vacancies)) * 100,
    votes.valid = first(votes.valid), votes.turnout = first(votes.turnout),
    votes.invalid = first(votes.invalid)
  ) %>%
  ungroup() %>%
  filter_at(vars(votes.turnout, votes.valid, votes.invalid), ~!is.na(.))

# disengagement at the election level
disengagement07 <- election.aggregation %>%
  {felm(log(votes.turnout + 1) ~ 1 | election.ID + election.year |
    (proportion.invalid.ontrial ~ proportion.invalid.onappeal) | election.ID +
    election.year, data = ., exactDOF = TRUE, psdef = FALSE)}
disengagement08 <- election.aggregation %>%
  {felm(log(votes.valid + 1) ~ 1 | election.ID + election.year |
    (proportion.invalid.ontrial ~ proportion.invalid.onappeal) | election.ID +
    election.year, data = ., exactDOF = TRUE, psdef = FALSE)}
disengagement09 <- election.aggregation %>%
  {felm(log(votes.invalid + 1) ~ 1 | election.ID + election.year |
    (proportion.invalid.ontrial ~ proportion.invalid.onappeal) | election.ID +
    election.year, data = ., exactDOF = TRUE, psdef = FALSE)}

# build table
# produce tables with outcome one
stargazer(

  # first-stage regressions
  list(disengagement04, disengagement06, disengagement07, disengagement09),

  # table cosmetics
  type = 'text',
  title = 'The Effect of Electoral Crimes on Voter Engagement',
  style = 'default',
  # out = 'tables/voterbehavior.tex',
  out.header = FALSE,
  column.labels = c('Party-Level', 'Election-Level'),
  column.separate = rep(2, 2),
  covariate.labels = 'Share of Candidacies Invalid at Trial',
  dep.var.labels = rep(paste0('Outcome: ', voter.engagement[c(2, 3)]), 2),
  align = FALSE,
  apply.coef = function(x){x * 100},
  apply.se = function(x){x * 100},
  se = list(
    cse(disengagement04, name = NULL), cse(disengagement06, name = NULL),
    cse(disengagement07, name = NULL), cse(disengagement09, name = NULL)
  ),
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
  label = 'tab:voterbehavior',
  no.space = FALSE,
  omit = c('constant', 'party|electoral'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)

# extract f-stat for graphs and tables and assign latex format to it
objects(pattern = 'disengagement') %>%
{.[c(4, 6, 7, 9)]} %>%
lapply(get) %>%
lapply(function(x){summary(x)$F.fstat[1]}) %>%
unlist() %>%
round(1) %>%
paste0(collapse = ' & ') %>%
{paste0('\textit{F}-stat & ', .)} %>%
paste0(' \\')

# remove unnecessary objects
rm(party.aggregation, election.aggregation)

### test for candidate disengagement
# what i am testing here is whether candidates' strategies change conditional on
# the type of (favorable or unfavorable) ruling they see at either stage.
# ideally, what we want to show is that candidates keep the same strategy
# regardless of whether they see favorable rulings or not.

# tests: campaign expenditures by judicial ruling and across the entire review
# process using a non-parametric bootstrapped sample of expenditures.

# standardize candidate expenditures to offset outlier problems
candidate.disengagement.analysis %<>%
  mutate(candidacy.expenditures.actual = candidacy.expenditures.actual)

# test 1: campaign expenditures by judicial ruling
trial.expenditures <- candidate.disengagement.analysis %$%
  t.test(candidacy.expenditures.actual ~ candidacy.invalid.ontrial,
         conf.level = .99)
appeals.expenditures <- candidate.disengagement.analysis %$%
  t.test(candidacy.expenditures.actual ~ candidacy.invalid.onappeal,
         conf.level = .99)

# test 2: campaign expendtireus across judicial review process
review.expenditures <- candidate.disengagement.analysis %>%
  filter(candidacy.invalid.ontrial == 1) %$%
  t.test(candidacy.expenditures.actual ~ candidacy.invalid.onappeal)

# convert vectors to datasets
trial.expenditures   %<>% unlist() %>% {tibble(., names = names(unlist(.)))}
appeals.expenditures %<>% unlist() %>% {tibble(., names = names(unlist(.)))}
review.expenditures  %<>% unlist() %>% {tibble(., names = names(unlist(.)))}

# build dataset
bind_cols(trial.expenditures, appeals.expenditures, review.expenditures) %>%
select(1, 2, 3, 5) %>%
rename_all(~paste0('var', 1:4)) %>%
select(var2, var1, var3, var4) %>%
slice(-c(2, 4, 5, 8:11)) %>%
slice(3, 4, 1, 2) %>%
t() %>%
as_tibble(.name_repair = 'unique') %>%
rename_all(~c('Favorable', 'Unfavorable', 't-stat', 'p-value')) %>%
slice(-1) %>%
mutate_all(as.numeric) %>%
mutate_at(vars(3, 4), ~round(., digits = 3)) %>%
mutate(`Ruling Stage` = c('Trial', 'Appeals', 'Trial')) %>%
select(`Ruling Stage`, everything()) %>%
xtable(label = 'tab:candidatebehavior') %>%
print.xtable(floating = FALSE, hline.after = c(-1, -1, 0, 3, 3),
  include.rownames = FALSE)

# remove unnecessary objects
rm(candidate.disengagement.analysis, trial.expenditures, appeals.expenditures,
   review.expenditures)

### heterogeneous treatment effects
# these are the tests of differential effect conditional on conviction reason.
# here i am testing two hypotheses: (i) whether voters do punish politicians for
# type of electoral violation and (ii) whether strategy is beneficial from the
# when politicians are not caught.

# build new dataset containing only the politicians for which i can recover the
# type of electoral crime
hte.analysis <- filter(tse.analysis, !is.na(candidacy.ruling.class))

# relevel ruling categories to procedural or substantial rule breaking
hte.analysis$class <- hte.analysis$candidacy.ruling.class %>%
  {ifelse(.  != 'Requisito Faltante', 'Substantial', 'Procedural')} %>%
  factor() %>%
  {relevel(., ref = 'Procedural')}

# create one long ivreg regression formula for all problems
treat <- paste0(instrumented, ' * class + ')
instr <- paste0(instrument, ' * class + ')
exgos <- paste0(covariates, collapse = ' + ')
fe    <- ' + election.year + election.ID + party.number'
equations <- paste0(outcomes, ' ~ ', treat, exgos, fe, ' | ', instr, exgos, fe)

# run regressions (note: up to 5 minutes to execute)
# outcome 1: probability of election
hte01 <- ivreg(equations[1], data = hte.analysis)

# outcome 2: vote share
hte02 <- ivreg(equations[2], data = hte.analysis)

# outcome 3: distance to election cutoff for city councilor candidates
hte03 <- ivreg(equations[3], data = filter(hte.analysis, office.ID == 13))

# outcome 3: distance to election cutoff for mayor candidates
hte04 <- ivreg(equations[3], data = filter(hte.analysis, office.ID == 11))

# compute standard errors (note: up to 5 minutes to execute)
hte01.se <- cse(hte01)
hte02.se <- cse(hte02)
hte03.se <- cse(hte03)
hte04.se <- cse(hte04)

# produce table
stargazer(

  # first-stage regressions
  list(hte01, hte02, hte03, hte04),

  # table cosmetics
  type = 'latex',
  title = 'Heterogeneous Effect of Electoral Crime',
  style = 'default',
  # out = 'tables/hte.tex',
  out.header = FALSE,
  column.labels = c(rep('Full Sample', 2), 'City Councilor', 'Mayor'),
  column.separate = rep(1, 4),
  covariate.labels = c(instrument.labels[1], 'Substantial', 'Inter'),
  dep.var.caption = '',
  # dep.var.labels = paste0('Outcome: ', 1:4),
  dep.var.labels.include = FALSE,
  align = FALSE,
  se = list(hte01.se, hte02.se, hte03.se, hte04.se),
  p.auto = TRUE,
  column.sep.width = '4pt',
  digit.separate = 3,
  digits = 3,
  digits.extra = 0,
  font.size = 'scriptsize',
  header = FALSE,
  initial.zero = FALSE,
  model.names = FALSE,
  keep = 'invalid|class',
  label = 'tab:hte',
  no.space = FALSE,
  omit = c('education', 'party'),
  omit.labels = c('Individual Controls', 'Fixed-Effects'),
  omit.stat = c('ser', 'f', 'rsq'),
  omit.yes.no = c('Yes', '-'),
  table.placement = '!htbp'
)


