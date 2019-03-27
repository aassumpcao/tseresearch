### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse website.
#   we use the textual information in the sentences to determine the allegations
#   against individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidyverse)
library(magrittr)
# library(tidytext)
# library(stm)
library(quanteda)

# load datasets
load('data/tseSummary.Rda')
load('data/tseUpdates.Rda')
load('data/tseSentences.Rda')
load('data/electoralCrimes.Rda')

# load reasons for rejection
rejections <- readRDS('rejections.Rds')

### wrangle sentences
# create new order of severity of crimes
neworder <- c(5, 3, 1, 4, 6, 7, 8, 2)
rejections <-  rejections[neworder]

# transform rejections variable using 2016 data. it takes priority over judicial
# decisions because it is explicitly reported by tse
for (rejection in seq(1:8)) {
  electoralCrimes %<>%
    mutate(rejections = ifelse(match(DS_MOTIVO_CASSACAO, rejections[rejection]),
                               rejections[rejection],
                               NA_character_))
}

# create list of regex patterns to match each reason for rejection
regexs <- c('(?i)ficha(.){1,4}limpa', '(?i)compra(s)?(.){1,4}voto(s)?',
            '(?i)abuso(.){1,4}poder(.){1,4}(econ[oô]mico)?',
            '(?i)conduta(.){1,4}vedada[o]',
            '(?i)(gasto|despesa)?(.){1,4}(il[íi]cit[ao]|ilegal|proibid[oa])',
            '(?i)indeferi(.){1,7}(partid|coliga)')

# find reasons for candidacy rejection in judicial decisions
for (regex in c(1:5, 7)) {
  tseSentences %>%
    group_by(scraperID) %>%
    mutate(rejections2 = ifelse(str_detect(sbody, regexs[regex]),
                               rejections[regex],
                               NA_character_))
}

# drop first row (invalid) and filter empty sentences. next, clean text for
# later classification.
tseSentences %<>% slice(-1) %>% filter(nchar(sbody) > 2)
tseSentences %<>%
  mutate_all(~str_to_lower(.)) %>%
  mutate_all(~str_replace_all(., ',|\\.', ' ')) %>%
  mutate_all(~str_remove_all(., '_|-'))

# create list of stopwords
stopwords <- c(stopwords::stopwords('portuguese'), 'é', 'art', 'nº', '2016',
               'lei', '2012', 'i', 'g', 'fls', 'tse', 'ata', 'n')

# # tidy dataset for text classification
# tidySentences <- tseSentences %>%
#   mutate(line = row_number()) %>%
#   tidytext::unnest_tokens(word, sbody) %>%
#   anti_join(tibble(word = stopwords))

### run spectral clustering algorithms (k-means)
# create document-feature (word) matrix
dfmSentences <- tseSentences %>%
  mutate(line = row_number()) %>%
  tidytext::unnest_tokens(word, sbody) %>%
  anti_join(tibble(word = stopwords)) %>%
  count(scraperID, word, sort = TRUE) %>%
  tidytext::cast_dfm(scraperID, word, n)

# run spectral clustering topic model
topicModel <- stm::stm(dfmSentences, K = 8, init.type = 'Spectral')

# print results
summary(topicModel)

# tidy results
beta.results <- tidytext::tidy(topicModel)

# build beta matrix (which is the matrix tying words to topics == 8 candidacy
# rejections in this case)
beta.results %>%
  group_by(topic) %>%
  top_n(10) %>%
  ungroup() %>%
  ggplot(aes(y = beta, x = term, fill = as.factor(topic))) +
    geom_col(alpha = .8, show.legend = FALSE) +
    facet_wrap(~topic, scales = 'free_y') +
    coord_flip()

# save beta matrix clustering plot
ggsave('plots/betaClusteringPlot.png')

# build gamma matrix
gamma.results <- tidytext::tidy(topicModel, matrix = 'gamma',
                                document_names = row_names(dfmSentences))

