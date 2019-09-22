### electoral crime and performance paper
# appendix analysis
#   this script contains the analysis included in the appendix, footnotes, and
#   everything else not included in the body of the final paper.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)

# read csv files
validation <- read_csv('data/validation_performance.csv')
holdout <- read_csv('data/holdout_performance.csv')
dnn <- read_csv('data/dnnClassification.csv')

# add simulation history and unnest values
validation$simulation <- as.character(rep(seq(1, 5), 6))
validation <-  bind_rows(
  select(validation, -train_accuracy, -train_roc_auc) %>%
  rename(accuracy = test_accuracy, auc = test_roc_auc) %>%
  mutate(source = 'test'),
  select(validation, -test_accuracy, -test_roc_auc) %>%
  rename(accuracy = train_accuracy, auc = train_roc_auc) %>%
  mutate(source = 'train'),
)

# rename models
validation$model %<>%
  str_replace_all('([a-z])([A-Z])', '\\1 \\2') %>%
  str_remove(' Classifier') %>%
  str_replace_all('Ada Boost', 'Adaptive Boosting') %>%
  str_replace_all('SVC', 'Linear SVM')

# graph accuracy scores
ggplot(validation) +
  geom_boxplot(
    aes(x = fct_reorder(model, accuracy), y = accuracy, color = source),
    outlier.shape = NA
  ) +
  labs(y = 'Cross-Validation Accuracy') +
  scale_color_manual(
    name = 'Validation Stage', breaks = c('test', 'train'),
    values = c('test' = 'grey15', 'train' = 'grey60'),
    labels = c('Test', 'Train')
  ) +
  coord_flip() +
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    axis.title.x = element_text(margin = margin(t = 12)),
    axis.text.y = element_text(size = 10, lineheight = 1.1, face = 'bold'),
    axis.text.x = element_text(size = 10, lineheight = 1.1, face = 'bold'),
    text = element_text(family = 'LM Roman 10'),
    panel.border = element_rect(color = 'black', size = 1),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = 'grey79', linetype = 'dashed'),
    legend.position = 'top'
  )

# # save plot
# ggsave(
#   'validation-boxplots.pdf', device = cairo_pdf, path = 'plots', dpi = 100,
#   width = 7, height = 5
# )

# graph area under the curve for all six models
validation %>%
  group_by(model) %>%
  summarize(accuracy = mean(accuracy), auc = mean(auc)) %>%
  arrange(desc(accuracy)) %>%
  xtable::xtable(digits = 3)

holdout %>%
  arrange(desc(holdout_accuracy)) %>%
  xtable::xtable(digits = 3)
