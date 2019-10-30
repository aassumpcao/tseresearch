### electoral crime and performance paper
# main analysis script
#   this script produces all tables, plots, and analyses in the electoral crime
#   and performance paper
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(magrittr)
library(tidyverse)
library(lfe)

# load data
load('data/tseFinal.Rda')

# function to simulate other correlation levels between trial and appeals
# rulings using the same judicial review data
simcorrel <- function(correl.shift = NULL, ...) {
  # Args:
  #   var: variable used to compute correlation
  #   ...: additional arguments passed to sample()

  # Returns:
  #   list with correlation coefficient, mean, and vector of simulated outcomes

  # Body:
  #   call to sample, correlation, mean, and store it to object

  # function
  # extract actual observed values from appeals distribution
  var <- tse.analysis$candidacy.invalid.onappeal
  nsample <- nrow(tse.analysis)

  # determine size of sampled observations
  if (is.null(correl.shift)) {samplesize <- nsample}
  else                       {samplesize <- ceiling(nsample * correl.shift)}

  # replace values in original variable
  if (samplesize < nsample) {

    # determine size of non-sampled observations
    sampled <- sample(nsample, samplesize, replace = FALSE)
    var[sampled] <- sample(c(1, 0), size = samplesize, replace = TRUE)

  } else {
    var %<>% sample(size = samplesize, ...)
  }

  # produce object
  object <- list(
    correlation = cor(tse.analysis$candidacy.invalid.ontrial, var),
    mean = mean(var),
    appeals.outcomes = var
  )

  # return call
  invisible(object)
}

### placebo test
# here I want to estimate an entire set of correlations between trial and
# appeals decisions to map when exactly would the IV parameter become the same
# as the OLS parameter

# convert appeals to numeric
tse.analysis <- tse.analysis %>%
  mutate_at(
    vars(candidacy.invalid.ontrial, candidacy.invalid.onappeal), as.integer
  )

# create vectors of independent coefficients, standard errors, and correlations
se <- c()
betas <- c()
fstat <- c()
ucorrel <- c()
ccorrel <- c()

# set seed to break process down into 2
set.seed(12345)

# execute for loop (~7 hours)
for (i in 1:100000) {

  # determine correlation deviation from main sample
  x <- runif(1, .001)

  # call to simulation and store to dataset
  y <- simcorrel(x)
  tse.analysis$appeals.simulation <- y$appeals.outcomes

  # run regressions
  regression <- tse.analysis %>%
    {felm(outcome.elected ~ candidate.age + candidate.male +
      candidate.experience + candidacy.expenditures.actual +
      candidate.maritalstatus + candidate.education | election.ID +
      election.year + party.number | (candidacy.invalid.ontrial ~
      appeals.simulation), data = ., exactDOF = TRUE)}

  # run regressions
  firststage <- tse.analysis %>%
    {felm(candidacy.invalid.ontrial ~ appeals.simulation + candidate.age +
      candidate.male + candidate.experience + candidacy.expenditures.actual +
      candidate.maritalstatus + candidate.education | election.ID +
      election.year + party.number, data = ., exactDOF = TRUE)}

  # catch exceptions
  tryCatch(
    expr = {
      # store results
      estimates <- summary(regression, robust = TRUE)$coefficients[16, c(1, 2)]
      ucorrel <- c(ucorrel, unname(y$correlation))
      ccorrel <- c(ccorrel, summary(firststage)$coefficients[1])
      betas <- c(betas, unname(estimates[1]))
      fstat <- c(fstat, summary(firststage)$fstat)
      se <- c(se, unname(estimates[2]))
    },
    error = function(e) {
      print('error in computing regression statistics, skipping iteration')
    }
  )

  # add checkpoint to save to file
  if (i %% 1000 == 0) {print(as.character(i))}
}

# create dataset
simulation <- tibble(ccorrel, ucorrel, betas, se, fstat)

# save to file
save(simulation, file = 'data/tseSimulation.Rda')

# remove everything for serial sourcing
rm(list = ls())
