### electoral crime and performance paper
# this script creates the simulation for correlations between instrumented var
#  and instrument.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
library(magrittr)
library(tidyverse)
library(lfe)

# load data
load('data/tseFinal.Rda')

# function to simulate correlations between trial and appeals rulings using the
#  same judicial review data.
simulate_correlation <- function(prob_1, prob_0, appeals_vector = appeals) {
  appeals_simulated <- appeals
  simulation <- sample(c(1, 0), nsample, TRUE, c(prob_1, prob_0))
  appeals_simulated[trials_favorable] <- simulation
  return(appeals_simulated)
}

# convert appeals to numeric
tse.analysis$candidacy.invalid.ontrial  %<>% as.integer()
tse.analysis$candidacy.invalid.onappeal %<>% as.integer()

# extract appeals from the original dataset
trials  <- tse.analysis$candidacy.invalid.ontrial
appeals <- tse.analysis$candidacy.invalid.onappeal

# define positions from appeals vector that we want to make changes in
trials_favorable <- which(trials == 1)
nsample <- length(trials_favorable)

# create vector of probabilities for correlation coefficients
probability <- runif(10000, 0, 1)
complement  <- 1-probability

# set seed to break process down into 2
set.seed(12345)

# create loop to execute simulations
for (i in 1:10000) {

  # create vectors of coefficients, standard errors, and correlations on first
  # iteration
  if (i == 1){
    se <- c()
    betas <- c()
    fstat <- c()
    ucorrel <- c()
    ccorrel <- c()
  }

  # put probabilities into separate scalars
  x <- probability[i]
  y <- complement[i]

  # create new vector and store into dataset
  tse.analysis$appeals.simulation <- simulate_correlation(x, y)

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

  # store results
  estimates <- summary(regression, robust = TRUE)$coefficients[16, c(1, 2)]
  ucorrel <- c(ucorrel, cor(appeals, tse.analysis$appeals.simulation))
  ccorrel <- c(ccorrel, summary(firststage)$coefficients[1])
  betas <- c(betas, unname(estimates[1]))
  fstat <- c(fstat, summary(firststage)$fstat)
  se <- c(se, unname(estimates[2]))

  # print progress
  if (i %% 1000 == 0) {print(paste0(i, ' done.'))}

}

# create dataset
simulation <- tibble(ccorrel, ucorrel, betas, se, fstat)

# save to file
save(simulation, file = 'data/tseSimulation.Rda')

# remove everything for serial sourcing
rm(list = ls())

