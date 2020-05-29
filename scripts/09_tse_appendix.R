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

# load google trends data
path <- 'data/google_trends.csv'
google_trends <- readLines(path)

# wrangle date to find web searches around each municipal election
data <- google_trends[4:length(google_trends)] %>%
  as_tibble() %>%
  separate(value, c('date', 'elections', 'clean_records'), ',') %>%
  mutate_at(vars(clean_records, elections), function(x){
    case_when(
      str_detect(x, '^[1-9]') ~ as.integer(x) + 1,
      str_detect(x, '^0|<1') ~ 1
    )}
  ) %>%
  mutate(
    date = lubridate::ymd(date, truncated = 2),
    year = str_sub(date, 1, 4), month = str_sub(date, 6, 7)
  )

# pivot
data %<>%
  pivot_longer(matches('elections|records'), 'type', values_to = 'trend')

# create month-year labels
scale <- arrange(data, year, month) %>%
         select(month, year) %>%
         distinct() %>%
         as.list() %$%
         month %>%
         as.integer() %>%
         {month.abb[.]}

# format axis labels and create scale for graph
label_axis <- function(labels) {
  fixedLabels <- c()
  for (l in 1:length(labels)) {
    fixedLabels[l] <- paste0(ifelse(l %% 2 == 0, '\n', ''), labels[l])
  }
  return(fixedLabels)
}

# scale <- label_axis(scale)
scale[seq(4,100,24)] <- paste0(scale[seq(4,100,24)], '\n', seq(2008,2016,2))
scale <- scale[seq(4,102,24)]
data %<>% arrange(year, month) %>% mutate(row = rep(1:102, each = 2))

# produce graph
p <- ggplot(data) +
  geom_vline(xintercept = c(4,52,100), linetype = 'dashed', color='skyblue2') +
  geom_vline(xintercept = c(28,76), linetype = 'dashed', color='coral1') +
  geom_line(aes(y = trend, x = row, color = type)) +
  scale_color_manual(
    values = c('grey17', 'grey74'), name = 'Search Term:',
    labels = c('Clean Records Act', 'Municipal Elections')
  ) +
  scale_x_continuous(
    breaks = seq(4,102,24), minor_breaks = NULL, expand = c(0,0), labels = scale
  ) +
  ylab('Web Searches Relative to Peak (=100)') +
  theme_bw() +
  theme(
    axis.title = element_text(size = 10),
    axis.title.y = element_text(margin = margin(r = 12)),
    axis.title.x = element_blank(),
    axis.text.y = element_text(size = 10, lineheight = 1.1, face = 'bold'),
    axis.text.x = element_text(size = 10, lineheight = 1.1, face = 'bold'),
    text = element_text(family = 'LM Roman 10'),
    panel.border = element_rect(color = 'black', size = 1),
    panel.grid = element_blank(),
    panel.grid.major.y = element_line(color = 'grey96'),
    legend.position = 'top', legend.text = element_text(size = 10)
  )

# save plot
ggsave(
  plot = p, 'google_searches.pdf', device = cairo_pdf, path = 'plots',
  dpi = 100, width = 7, height = 5
)

# read csv files
validation <- read_csv('data/validation_performance.csv')
holdout <- read_csv('data/holdout_performance.csv')
dnn <- read_csv('data/validation_performance_dnn.csv')

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

# plot learning curve and loss for dnn
dnn <- mutate(dnn, acc_color = '1', loss_color = '1')

# rename models
validation$model %<>%
  str_replace_all('([a-z])([A-Z])', '\\1 \\2') %>%
  str_remove(' Classifier') %>%
  str_replace_all('Ada Boost', 'Adaptive Boosting')

holdout$model %<>%
  str_replace_all('([a-z])([A-Z])', '\\1 \\2') %>%
  str_remove(' Classifier') %>%
  str_replace_all('Ada Boost', 'Adaptive Boosting')

# graph accuracy scores
p <- validation %>%
  ggplot() +
  # geom_point(
  #   data = mutate(holdout, source = 'hold-out', accuracy = holdout_accuracy),
  #   aes(x = fct_reorder(model, accuracy), y = accuracy, color = source),
  #   size = 2
  # ) +
  geom_boxplot(data = validation,
    aes(x = fct_reorder(model, accuracy), y = accuracy, color = source),
    outlier.shape = NA
  ) +
  geom_text(
    aes(y = .8, x = 1), label = '<.80', size = 4, family = 'LM Roman 10',
  ) +
  labs(y = 'Cross-Validation Accuracy') +
  scale_y_continuous(limits = c(.8, 1), breaks = seq(.8, 1, .025)) +
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
    panel.grid.minor.x = element_line(color = 'grey79', linetype = 'dashed'),
    legend.position = 'top'
  )

# save plot
ggsave(
  'validation-boxplots.pdf', device = cairo_pdf, path = 'plots', dpi = 100,
  width = 7, height = 5
)

# produce dnn plot
p <- dnn %>%
  ggplot() +
  geom_line(aes(x = epochs, y = accuracy, color = '1'), size = 1.5) +
  geom_line(aes(x = epochs, y = loss, color = '2'), size = 1.5) +
  labs(x = 'Epochs', y = 'Accuracy') +
  scale_y_continuous(limits = c(.1, 1), breaks = seq(.1, 1, .1)) +
  scale_x_continuous(limits = c(0, 150), breaks = seq(0, 150, 25)) +
  scale_color_manual(
    name = 'Performance Metrics:', breaks = c('1', '2'),
    labels = c('Accuracy', 'Loss'), values = c('1' = 'grey15', '2' = 'grey60')
  ) +
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    axis.title.x = element_text(margin = margin(t = 12)),
    axis.text.y = element_text(size = 10, lineheight = 1.1, face = 'bold'),
    axis.text.x = element_text(size = 10, lineheight = 1.1, face = 'bold'),
    text = element_text(family = 'LM Roman 10'),
    panel.border = element_rect(color = 'black', size = 1),
    panel.grid.major.y = element_line(color = 'grey79', linetype = 'dashed'),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_line(color = 'grey79', linetype = 'dashed'),
    panel.grid.minor.x = element_blank(),
    legend.position = 'top'
  )

# # save plot
# ggsave(
#   plot = p, 'validation-dnn.pdf', device = cairo_pdf, path = 'plots', dpi = 100,
#   width = 7, height = 5
# )

# graph area under the curve for all six models
validation %>%
  group_by(model) %>%
  summarize(accuracy = min(accuracy), auc = min(auc)) %>%
  arrange(desc(accuracy)) %>%
  xtable::xtable(digits = 3)

holdout %>%
  arrange(desc(holdout_accuracy)) %>%
  xtable::xtable(digits = 3)

dnn %>%
  summarize_all(mean) %>%
  xtable::xtable(digits = 3)
