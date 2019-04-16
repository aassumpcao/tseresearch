library(magrittr)
library(tidyverse)

load('train.Rda')
load('tseTrain.Rda')

train %<>% mutate(y = factor(tseTrain$broad.rejection))

# model running time:
system.time(
adaBoostModel <- adabag::boosting(y ~ ., data = train)
)

# prediction running time:
system.time(
adaPreds <- adabag::predict.boosting(adaBoostModel, newdata = train)
)

# save models and predictions to file
saveRDS(adaBoostModel, '051adaBoostModel.Rds')
saveRDS(adaBoostPreds, '051adaBoostPreds.Rds')