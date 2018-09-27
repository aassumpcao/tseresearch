
library(MCMCpack)

load("SchoolAidLongleaf.Rdata")

MCMCposterior <- MCMCordfactanal(~ councillor_performance2 +
  councillor_performance3 + councillor_performance4,
  lambda.constraints = list(councillor_performance2 = list(2, "+"),
  councillor_performance3 = list(2, "+"),
  councillor_performance4 = list(2, "+")),
  factors = 1, store.scores = TRUE, data = SchoolAidLongleaf)

saveRDS(MCMCposterior, file = "MCMCposterior_20000_1.rds")

