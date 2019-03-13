# remove everything from environment
rm(list = ls())

# install.packages('randomizr')
library(randomizr)  # randomizr package for complete random assignment

# create initial data
possible.ns          <- seq(from = 3105, to = 5705, by = 100)
power.atleastone     <- rep(NA, length(possible.ns))
power.bothtreatments <- rep(NA, length(possible.ns))
power.fullranking    <- rep(NA, length(possible.ns))
alpha <- 0.1  #(one-tailed test at .05 level)
sims  <- 100

# outer loop to vary the number of subjects ####
for (j in 1:length(possible.ns)) {
  N <- possible.ns[j]
  p.T1vsC  <- rep(NA, sims)
  p.T2vsC  <- rep(NA, sims)
  p.T2vsT1 <- rep(NA, sims)
  c.T1vsC  <- rep(NA, sims)
  c.T2vsC  <- rep(NA, sims)
  c.T2vsT1 <- rep(NA, sims)

  # inner loop to conduct experiments 'sims' times over for
  # for each N
  for (i in 1:sims) {
    Y0    <- rnorm(n = N, mean = 60, sd = 20)
    tau_1 <- 2.5
    tau_2 <- 5.0
    Y1    <- Y0 + tau_1
    Y2    <- Y0 + tau_2
    Z.sim <- complete_ra(N = N, num_arms = 3)
    Y.sim <- Y0 * (Z.sim == "T3") + Y1 * (Z.sim == "T1") + Y2 * (Z.sim == "T2")
    frame.sim <- data.frame(Y.sim, Z.sim)
    fit.T1vsC.sim  <- lm(Y.sim ~ Z.sim == "T1", data = subset(frame.sim,
      Z.sim != "T2"))
    fit.T2vsC.sim  <- lm(Y.sim ~ Z.sim == "T2", data = subset(frame.sim,
      Z.sim != "T1"))
    fit.T2vsT1.sim <- lm(Y.sim ~ Z.sim == "T2", data = subset(frame.sim,
      Z.sim != "T3"))

    # need to capture coefficients and pvalues (one-tailed tests,
    # so signs are important)
    c.T1vsC[i]  <- summary(fit.T1vsC.sim)$coefficients[2, 1]
    c.T2vsC[i]  <- summary(fit.T2vsC.sim)$coefficients[2, 1]
    c.T2vsT1[i] <- summary(fit.T2vsT1.sim)$coefficients[2, 1]
    p.T1vsC[i]  <- summary(fit.T1vsC.sim)$coefficients[2, 4]
    p.T2vsC[i]  <- summary(fit.T2vsC.sim)$coefficients[2, 4]
    p.T2vsT1[i] <- summary(fit.T2vsT1.sim)$coefficients[2, 4]
  }
  power.atleastone[j] <- mean(c.T1vsC > 0 & c.T2vsC > 0 & (p.T1vsC <
    alpha/2 | p.T2vsC < alpha/2))
  power.bothtreatments[j] <- mean(c.T1vsC > 0 & c.T2vsC > 0 &
    p.T1vsC < alpha/2 & p.T2vsC < alpha/2)
  power.fullranking[j] <- mean(c.T1vsC > 0 & c.T2vsC > 0 &
    c.T2vsT1 > 0 & p.T1vsC < alpha/2 & p.T2vsT1 < alpha/2)
  print(j)
}

plot(possible.ns,   power.atleastone,     ylim = c(0, 1))
points(possible.ns, power.bothtreatments, col = "red")
points(possible.ns, power.fullranking,    col = "blue")