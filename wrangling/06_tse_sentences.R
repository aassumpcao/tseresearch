### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse website.
#   we use the textual information in the sentences to determine the allegations
#   against individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

### import statements
# import packages
library(tidytext)
library(tidyverse)
library(magrittr)

# load datasets
load('data/tseSummary.Rda')
load('data/tseUpdates.Rda')
load('data/tseSentences.Rda')
load('data/electoralCrimes.Rda')

# load reasons for rejection
narrow.reasons <- readRDS('rejections.Rds') %>% str_remove_all('\\.$')

### wrangle sentences
# create new order of severity of electoral crimes
neworder <- c(5, 3, 1, 4, 6, 7, 8, 2)
narrow.reasons <- narrow.reasons[neworder]

# convert reasons to regex versions
narrow.reasons.regex <- narrow.reasons %>%
  str_replace_all('\\(', '\\\\(') %>%
  str_replace_all('\\.', '\\\\.') %>%
  str_replace_all('\\)', '\\\\)')

# create empty rejections vector
electoralCrimes$rejections <- NA_character_

# split training and testing data
tseTrain <- filter(electoralCrimes, !is.na(DS_MOTIVO_CASSACAO))
tseTest  <- filter(electoralCrimes,  is.na(DS_MOTIVO_CASSACAO))

# create narrow rejection reasons
for (i in seq(8, 1)) {
  tseTrain %<>% mutate(narrow.rejection = ifelse(str_detect(DS_MOTIVO_CASSACAO,
    narrow.reasons.regex[i]), narrow.reasons[i], rejections))
  if (i == 1) {rm(i)}
}

# create broad rejection reasons
tseTrain %<>% mutate(broad.rejection = narrow.rejection %>%
  {case_when(str_detect(., '64') ~ 'Ficha Limpa',
             str_detect(., '97') ~ 'Lei das Eleições',
             str_detect(., 'Ausência') ~ 'Requisito Faltante',
             str_detect(., 'Indeferimento') ~ 'Partido/Coligação')})

# join rejection reasons and their sentences
tseTrain <- tseSentences %>%
  mutate(scraperID = as.character(scraperID)) %>%
  inner_join(tseTrain, 'scraperID') %>%
  filter(!is.na(sbody) | nchar(sbody) > 2)

# drop first row (invalid) and filter empty sentences. next, clean text for
# later classification.
tseTrain %<>%
  mutate_at(vars(1:2), ~str_to_lower(.)) %>%
  mutate_at(vars(1:2), ~str_squish(.)) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '64(.)?90', '6490')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., '9(\\.)?504', '9504')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., ',|\\.', ' ')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'n º', 'nº')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'art( )?', 'art')) %>%
  mutate_at(vars(1:2), ~str_replace_all(., 'lei eleitoral', 'leieleitoral')) %>%
  mutate_at(vars(1:2), ~str_remove_all(., '_|-|\\(|\\)'))

# create list of stopwords
stopwords <- c(stopwords::stopwords('portuguese'), 'é', 'art', 'nº', '2016',
               'lei', '2012', 'i', 'g', 'fls', 'tse', 'ata', 'n', 'ser')

### tidy data for text classification
# produce tf-idf scores
tfidfSentences <- tseTrain %>%
  mutate(line = row_number()) %>%
  tidytext::unnest_tokens(word, sbody) %>%
  anti_join(tibble(word = stopwords)) %>%
  count(scraperID, word, sort = TRUE) %>%
  tidytext::bind_tf_idf(word, scraperID, n)

### run spectral clustering algorithms (k-means)
# run spectral clustering topic model
spectralModel <- stm::stm(dfmSentences, K = 4, init.type = 'Spectral',
                          verbose = TRUE)

# save to disk to avoid running this again
saveRDS(spectralModel, 'data/spectralModel.Rds')

# print results
summary(spectralModel)

# tidy results
spectralBeta <- tidytext::tidy(spectralModel)

# build beta matrix and plot it (which is the matrix tying words to topics == 8
# candidacy rejections in this case)
spectralBeta %>%
  group_by(topic) %>%
  top_n(10) %>%
  ungroup() %>%
  ggplot(aes(y = beta, x = term, fill = as.factor(topic))) +
    geom_col(alpha = .8, show.legend = FALSE) +
    facet_wrap(~topic, scales = 'free_y') +
    drlib::scale_x_reordered() +
    coord_flip()

# save beta matrix clustering plot
ggsave('plots/spectralBeta.png')

# build gamma matrix
spectralGamma <- tidytext::tidy(spectralModel, matrix = 'gamma',
                                document_names = rownames(dfmSentences))

# plot gamma matrix (which matches sentences to candidacy rejection reasons)
ggplot(spectralGamma, aes(x = gamma, fill = as.factor(topic))) +
  geom_histogram(alpha = .8, show.legend = FALSE, binwidth = .1) +
  facet_wrap(~topic, ncol = 3) +
  drlib::scale_x_reordered() +
  labs(title = 'Sentence Probability by Conviction Type',
       subtitle = '(null)',
       y = 'Number of sentences', x = expression(gamma))

# save gamma matrix probability plot
ggsave('plots/spectralGamma.png')

### lda algorithm
# run lda clustering model
ldaModel <- stm::stm(dfmSentences, K = 8, init.type = 'LDA', verbose = FALSE)

# save to disk to avoid running this again
saveRDS(ldaModel, 'data/ldaModel.Rds')

# print results
summary(ldaModel)

# tidy results
ldaBeta <- tidytext::tidy(ldaModel)

# build beta matrix and plot it (which is the matrix tying words to topics == 8
# candidacy rejections in this case)
ldaBeta %>%
  group_by(topic) %>%
  top_n(10) %>%
  ungroup() %>%
  ggplot(aes(y = beta, x = term, fill = as.factor(topic))) +
    geom_col(alpha = .8, show.legend = FALSE) +
    drlib::scale_x_reordered() +
    facet_wrap(~topic, scales = 'free_y') +
    coord_flip()

# save beta matrix clustering plot
ggsave('plots/ldaBeta.png')

# build gamma matrix
ldaGamma <- tidytext::tidy(ldaModel, matrix = 'gamma',
                           document_names = rownames(dfmSentences))

# plot gamma matrix (which matches sentences to candidacy rejection reasons)
ggplot(ldaGamma, aes(x = gamma, fill = as.factor(topic))) +
  geom_histogram(alpha = .8, show.legend = FALSE, binwidth = .1) +
  facet_wrap(~topic, ncol = 3) +
  drlib::scale_x_reordered() +
  labs(title = 'Sentence Probability by Conviction Type',
       subtitle = '(null)',
       y = 'Number of sentences', x = expression(gamma))

# save gamma matrix probability plot
ggsave('plots/ldaGamma.png')
