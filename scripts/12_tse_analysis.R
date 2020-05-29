rm(list = ls())
library(grid)
library(gtable)
library(gridExtra)
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
  dpi = 100, width = 9, height = 5
)

