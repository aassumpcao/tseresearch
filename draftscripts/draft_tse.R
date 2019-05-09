# import statement
library(magrittr)
library(tidyverse)

# load database
load('candidates.2016.Rda')
load('sentencingData.Rda')
load('results2016.Rda')
load('candidacyDecisions.Rda')

# wrangling
names(candidates.2010)
candidates.2010 %>%
  filter(CODIGO_CARGO == 11) %$%
  table(DES_SITUACAO_CANDIDATURA)

load('results2008.Rda')
load('candidates.2010.Rda')

testSP <- candidates.2010 %>%
  filter(CODIGO_CARGO == 11) %>%
  filter(ANO_ELEICAO == 2008) %>%
  filter(SIGLA_UF == 'SP') %>%
  filter(DES_SITUACAO_CANDIDATURA == 'INDEFERIDO COM RECURSO')

candidates.2016 %>%
  filter(DES_SITUACAO_CANDIDATURA == 'INDEFERIDO COM RECURSO') %>%
  filter(CODIGO_CARGO == 11) %$%
  table(DESC_SIT_TOT_TURNO)

TEST <- results2016 %>%
  filter(DESC_SIT_CAND_SUPERIOR == 'APTO') %>%
  filter(DESC_SIT_CANDIDATO == 'DEFERIDO COM RECURSO') %>%
  filter(TOTAL_VOTOS == 0)


names(TEST)

TEST2 <- left_join(TEST, candidates.2016, by = c('SQ_CANDIDATO' = 'SEQUENCIAL_CANDIDATO'))

View(TEST2)

sectionSP %>%
  filter(X9 == 'GUARULHOS') %>%
  filter(X14 == 31022) %>%
  select(X15) %>%
  unlist() %>%
  sum()

analysis %$% table(candidate.education)


View(test)
rm(sectionAM, test, test2, testSP)
names(results2016)
View(testAM)

# testing votes per electoral section
unzip('./votacao_secao_2016_SP.zip', exdir = './section')

sectionSP <- read_delim('../2018 TSE Databank/votacao_secao_2016_SP/votacao_secao_2016_SP.txt', ';',
  escape_double = FALSE, col_names = FALSE, trim_ws = TRUE,
  locale = locale(encoding = 'Latin1'))

# checking whether votes are reported
resultsTest <- results2016 %>%
  filter(CODIGO_CARGO == 11) %>%
  filter(DESC_SIT_CANDIDATO == 'INDEFERIDO COM RECURSO') %>%
  filter(TOTAL_VOTOS == 0) %>%
  filter(SIGLA_UF == 'SP')

results <- resultsSection %>%
  filter(X12 == 11) %>%
  filter(X9 == 'AGUDOS') %>%
  filter(X10 == 7) %>%
  filter(X14 == 15)

results2016 %>%
  filter(CODIGO_CARGO == 11) %>%
  filter(NOME_MUNICIPIO == 'AGUDOS') %$%
  filter(NUMERO_ZONA == 7)

names


2251+337+179+157+13+5+5+3
names(results2016)

as.character(unlist(sentencingData[sort.list(sentencingData$stage), 'stage']))


as.character(sentencingData[596,])


candidates.2016 %<>% mutate(SEQUENCIAL_CANDIDATO = as.character(SEQUENCIAL_CANDIDATO))
results2016 %<>% mutate(SQ_CANDIDATO = as.character(SQ_CANDIDATO))

data <- left_join(candidacyDecisions, candidates.2016, by = c('candidateID' = 'SEQUENCIAL_CANDIDATO'))
data <- left_join(data, results2016, by = c('candidateID' = 'SQ_CANDIDATO'))

data %<>% filter(DES_SITUACAO_CANDIDATURA != 'DEFERIDO')

data %<>% left_join(sentencingData, by = c('protNum' = 'protNum'))


View(data)

lapply(data[51:61, 'sentence'], as.character)

names(results2016)

data %$% table(DES_SITUACAO_CANDIDATURA)


which(str_detect(unlist(results.data$NOME_CANDIDATO), 'RAMENZONI'))

which(str_detect(unlist(results2016$NOME_CANDIDATO), 'RUBENS ROBERTO ROSA'))

View(candidates.2016[212031,])
View(results2016[327857,])

library(feather)


candidates.2010 %$% names()
candidates.2010 %$% table(ANO_ELEICAO)
str(candidates.2010 %$%
  table(DES_SITUACAO_CANDIDATURA))
rm(list)



list <- una(unique(candidates.2010[, 'DES_SITUACAO_CANDIDATURA']))

unname(list)

str(list[1])


candidates.2010 %>%
  filter(DES_SITUACAO_CANDIDATURA == 'IMPUGNAÇÃO DE CANDIDATURA') %>%
  View()


candidates.2010 %>% names()
candidates.2012 %>% names()
candidates.2016 %>% names()


candidates.2010 %>%
  filter(ANO_ELEICAO == 2004)

elections %$% table(match)

candidates.pending %>% names()

path <- paste0('/Users/aassumpcao/OneDrive - University of North Carolina',
               ' at Chapel Hill/Documents/Research/2018 TSE/tse_case.py',
               collapse = '')
import_from_path('tse_case', path = path)

system2('pwd')
system('python 01_electoralCrime.py')


case.numbers %>%
  filter(str_detect(caseNum, 'Inform')) %>%
  select(electoralUnitID, candidateID) %>%
  left_join(mutate(candidates.pending,
                   SEQUENCIAL_CANDIDATO = as.character(SEQUENCIAL_CANDIDATO)),
            by = c('electoralUnitID' = 'SIGLA_UE',
                   'candidateID' = 'SEQUENCIAL_CANDIDATO')) %>%
  filter(CODIGO_CARGO != 12) %>%
  arrange(as.numeric(electoralUnitID), as.numeric(candidateID)) %>%
  View()


load('case.numbers.Rda')
load('candidates.pending.Rda')

case.numbers %>% names()
candidates.pending %>% names()

candidates.pending %>%
  mutate_all(as.character) %>%
  left_join(case.numbers, by = c('ANO_ELEICAO' = 'electionYear',
                                 'SIGLA_UE' = 'electoralUnitID',
                                 'SEQUENCIAL_CANDIDATO' = 'candidateID'))


results2004 %>% names()
results2008 %>% names()
results2012 %>% names()
results2016 %>% names()

results2004 %>% filter(CODIGO_CARGO == 11) %$% unique(DESC_SIT_CAND_TOT)
results2008 %>% filter(CODIGO_CARGO == 11) %$% unique(DESC_SIT_CAND_TOT)
results2012 %>% filter(CODIGO_CARGO == 11) %$% unique(DESC_SIT_CAND_TOT)
results2016 %>% filter(CODIGO_CARGO == 11) %$% unique(DESC_SIT_CAND_TOT)

sections2004 %>% names()

load('vacancies2004.Rda')
load('vacancies2008.Rda')
load('vacancies2012.Rda')
load('vacancies2016.Rda')

vacancies2004 %$% table(CODIGO_CARGO)
vacancies2008 %$% table(CODIGO_CARGO)
vacancies2012 %$% table(CODIGO_CARGO)
vacancies2016 %$% table(CD_CARGO)

vacancies2004 %>% names()
candidates %>% names()
candidates2004 %$% table(QTDE_VAGAS)

vacancies2016 %>% filter(SG_UF == 'AM') %>% View()

View(vacancies2004)

candidates2004 %>% filter(is.na(QTDE_VAGAS))
candidates2008 %>% filter(is.na(QTDE_VAGAS))
candidates2012 %>% filter(is.na(QTDE_VAGAS))
candidates2016 %>% filter(is.na(QT_VAGAS))

sections2016 %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, CODIGO_CARGO, NUM_TURNO) %>%
  arrange(SIGLA_UE, CODIGO_CARGO, NUM_TURNO, desc(votes)) %>% View()

total2016 %>% filter(SIGLA_UE == '00019')

sections2004 %>% names()

20772/11

vacancies2016 %>% filter(SG_UE == 19) %>% select(3:7, CD_CARGO, QT_VAGAS)

# # join with office vacancies so that we know how many spots were available in
# # each race
# candidates2004 <- candidates %>%
#   filter(ANO_ELEICAO == 2004) %>%
#   left_join(vacancies2004, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
#   select(-c(54:60))
# candidates2008 <- candidates %>%
#   filter(ANO_ELEICAO == 2008) %>%
#   left_join(vacancies2008, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
#   select(-c(54:60))
# candidates2012 <- candidates %>%
#   filter(ANO_ELEICAO == 2012) %>%
#   left_join(vacancies2012, by = c('SIGLA_UE', 'CODIGO_CARGO')) %>%
#   select(-c(54:60))
# candidates2016 <- candidates %>%
#   filter(ANO_ELEICAO == 2016) %>%
#   mutate(SIGLA_UE = as.integer(SIGLA_UE)) %>%
#   left_join(vacancies2016,
#             by = c('SIGLA_UE' = 'SG_UE', 'CODIGO_CARGO' = 'CD_CARGO')
#   ) %>%
#   select(-c(54:65))


sections2004
candidates
elections2004 %>% names()
elections2008 %>% names()
elections2012 %>% names()
elections2016 %>% names()

analysis %>% names()

left_join(
  mutate(sections2004, rank = order(votes, decreasing = TRUE)),
  elections2004,
  by = c('SIGLA_UE', 'NUM_TURNO', 'CODIGO_CARGO')
) %>%
group_by(SIGLA_UE, NUM_TURNO, CODIGO_CARGO) %>%
filter(QTDE_VAGAS == rank)

analysis %$% table(is.na(candidate.dob), election.year)

analysis %$% table(candidate.gender.ID)


analysis %$% table(candidate.experience)

analysis %$% table(candidate.education, election.year)

analysis %$% table(candidate.maritalstatus)

2913/9469
5924/9469

22/3379
1009/5059
analysis %>% str()
analysis %>% names()
analysis %$% table(election.stage)

analysis %$% table(candidate.maritalstatus)

analysis %$% table(candidate.education)

analysis %$% table(candidacy.invalid.ontrial, candidacy.invalid.onappeal)
3379+22+1009+5059

summary(analysis$candidacy.expenditures)

analysis %>%
  select(candidate.education, candidate.maritalstatus) %>%
  {model.matrix(~ candidate.education, data = .)} %>%
  as.tibble() %$% table(`(Intercept)`)
  select(
    intercept              = `(Intercept)`,
    read.write             = `candidate.educationLÊ E ESCREVE`,
    elementary.notfinished = `candidate.educationFUNDAMENTAL INCOMPLETO`,
    elementary.finished    = `candidate.educationFUNDAMENTAL COMPLETO`,
    highschool.notfinished = `candidate.educationMÉDIO COMPLETO`,
    highschool.finished    = `candidate.educationMÉDIO INCOMPLETO`,
    college.notfinished    = `candidate.educationSUPERIOR COMPLETO`,
    college.finished       = `candidate.educationSUPERIOR INCOMPLETO`,
    separated              = `candidate.maritalstatusDIVORCIADO(A)`,
    divorced               = `candidate.maritalstatusSEPARADO(A) JUDICIALMENTE`,
    single                 = `candidate.maritalstatusSOLTEIRO(A)`,
    widow.er               = `candidate.maritalstatusVIÚVO(A)`
)

analysis %>%
  select(candidate.education) %>%
  spread(key = candidate.education, value = 1)



campaign2004 <- readr::read_delim('DespesaCandidato2004.txt', ';',
                                  escape_double = FALSE,
                                  trim_ws = TRUE,
                                  locale = locale(encoding = 'Latin1'))

# files
files <- list.files('../2018 TSE Databank/prestacao_contas_2010',
                    full.names = TRUE, recursive = TRUE)

dataset <- tibble()

for (i in files) {
  data <- read_delim(i, delim = ';', escape_double = FALSE, trim_ws = TRUE,
                     locale = locale(encoding = 'Latin1'))
  data %<>% mutate_all(as.character)
  dataset <- bind_rows(dataset, data)
}

save(campaign2010, file = 'campaign2010.Rda')

# reformat campaign expenditure and convert to numeric format
campaign %<>%
  group_by(ANO_ELEICAO, SG_UE, NM_CANDIDATO) %>%
  mutate(TOTAL_DESPESA = sum(VR_DESPESA)) %>%
  filter(row_number() == 1) %>%
  ungroup()

library(magrittr)
library(tidyverse)

load('campaign.Rda')

# bind all data
sections <- bind_rows(sections2004, sections2006, sections2008, sections2010,
                      sections2012, sections2014, sections2016)

# collapse results to individual voting counts
sections %<>%
  group_by(ANO_ELEICAO, SIGLA_UE, NUM_TURNO, CODIGO_CARGO, NUM_VOTAVEL) %>%
  summarize(votes2 = sum(QTDE_VOTOS)) %>%
  arrange(SIGLA_UE, NUM_TURNO, CODIGO_CARGO, desc(votes2)) %>%
  ungroup()

save(sections, file = 'sections.Rda')

case.numbers

localCandidates %$% table(appeals)

files <- list.files('../2018 TSE Databank', 'to_munzona_20(06|10|14)')
files <- paste0('../2018 TSE Databank/', files)

lapply(files, unzip, exdir = './results')

files2006 <- paste0('results/', list.files('results/', pattern = '2006'))
files2010 <- paste0('results/', list.files('results/', pattern = '2010'))
files2014 <- paste0('results/', list.files('results/', pattern = '2014'))

files2006 <- files2006[1:27]
files2010 <- files2010[c(1:5, 7:28)]
files2014 <- files2014[-6]


# loop over vacancy files for each year and create dataset
for (i in 1:length(files2006)) {
  path <- files2006[i]
  if (i == 1) {
    results2006 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    results2006 <- rbind(results2006, append)
  }
  if (i == length(files2006)) {rm(append, i, path)}
}

results2006 %<>% mutate_all(as.character)

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2010)) {
  path <- files2010[i]
  if (i == 1) {
    results2010 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    results2010 <- rbind(results2010, append)
  }
  if (i == length(files2010)) {rm(append, i, path)}
}

results2010 %<>% mutate_all(as.character)

# loop over vacancy files for each year and create dataset
for (i in 1:length(files2014)) {
  path <- files2014[i]
  if (i == 1) {
    results2014 <- read_delim(path, ';', escape_double = FALSE,
      col_names = FALSE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = FALSE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    results2014 <- rbind(results2014, append)
  }
  if (i == length(files2014)) {rm(append, i, path)}
}

library(pdftools)

codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[12:13])
codebook <- codebook[7:44]


codebook <- unlist(codebook[16])
codebook <- codebook[6:29]
codebook <- str_extract(codebook, '^(.)*(  )')
codebook <- str_replace_all(codebook, ' +', ' ')
codebook <- codebook[which(codebook != ' ')]
codebook %<>% trimws()
codebook <- str_replace_all(codebook, ' |(\\(\\*\\))', '')



names(results2006) <- codebook
names(results2010) <- codebook
names(results2014) <- codebook

save(results2006, file = 'results2006.Rda')
save(results2010, file = 'results2010.Rda')
save(results2014, file = 'results2014.Rda')

load('results2006.Rda')
load('results2010.Rda')
load('results2014.Rda')
load('sections2006.Rda')
load('sections2010.Rda')
load('sections2014.Rda')
load('candidates.2006.Rda')
load('candidates.2010.Rda')
load('candidates.2014.Rda')

candidates.pending %$% table(DES_SITUACAO_CANDIDATURA, COD_SITUACAO_CANDIDATURA)

files <- list.files('../2018 TSE Databank/', 'cassacao', full.names = TRUE)

lapply(files, unzip, exdir = './cassacao')

datasets <- list.files('cassacao', '2014', full.names = TRUE)[-6]
?read_csv


# loop over vacancy files for each year and create dataset
for (i in 1:length(datasets)) {
  path <- datasets[i]
  if (i == 1) {
    prevented2014 <- read_delim(path, ';', escape_double = FALSE,
      col_names = TRUE, locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
  } else {
    append <- read_delim(path, ';', escape_double = FALSE, col_names = TRUE,
      locale = locale(encoding = 'Latin1'), trim_ws = TRUE)
    prevented2014 <- rbind(prevented2016, append)
  }
  if (i == length(datasets)) {rm(append, i, path)}
}

prevented2016 %<>% mutate_all(as.character)
save(prevented2016, file = 'prevented2016.Rda')

library(tidytext)
library(stm)
library(quanteda)

# drop first row and filter empty sentences
tseSentences %<>% slice(-1) %>% filter(nchar(sbody) > 2)
tseSentences %>%
  mutate_all(~str_to_lower(.)) %>%
  mutate_all(~str_replace_all(., ',', ' ')) %>%
  mutate_all(~str_remove_all(., '_|-'))

# create list of stopwords
stopwords <- c(stopwords::stopwords('portuguese'), 'é', 'art', 'nº', '2016',
               'lei', )

# tidying dataset
tidySentences <- tseSentences %>%
  mutate(line = row_number()) %>%
  unnest_tokens(word, sbody) %>%
  anti_join(tibble(word = stopwords))

# create document-feature (word) matrix
dfmSentences <- tidySentences %>%
  count(scraperID, word, sort = TRUE) %>%
  cast_dfm(scraperID, word, n)

# run structural topic model
topicModel <- stm(dfmSentences, K = 8, init.type = 'Spectral')

# print results
summary(topicModel)

# tidy results
beta.results <- tidy(topicModel)

# define relevant election years and criteria for join function across datasets
years <- seq(2004, 2016, 4)
joinkey <- c('SIGLA_UE', 'CODIGO_CARGO', 'ANO_ELEICAO')

# edit vacancies dataset before joining onto sections
vacancies %<>%
  mutate(
    SIGLA_UE     = ifelse(ANO_ELEICAO == 2016, str_pad(SG_UE, 5, pad = '0'),
                          SIGLA_UE),
    CODIGO_CARGO = ifelse(ANO_ELEICAO == 2016, CD_CARGO, CODIGO_CARGO),
    QTDE_VAGAS   = ifelse(ANO_ELEICAO == 2016, QT_VAGAS, QTDE_VAGAS)
  )

# create elections dataset
vacancies %>%
  {left_join(filter(sections, ANO_ELEICAO %in% years), ., joinkey)} %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, ANO_ELEICAO, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  ) -> elections

elections



sections %>%
  left_join(filter(vacancies, ANO_ELEICAO %in% years), joinkey.1) %>%
  select(-QT_VAGAS.x) %>%
  # mutate(SIGLA_UE = as.integer(SIGLA_UE)) %>%
  left_join(filter(vacancies, ANO_ELEICAO == 2016), joinkey.2) %>%
  mutate(QTDE_VAGAS = ifelse(ANO_ELEICAO == 2016, QT_VAGAS, QTDE_VAGAS)) %>%
  filter(!(NUM_VOTAVEL %in% c(95, 96, 97))) %>%
  group_by(SIGLA_UE, ANO_ELEICAO, CODIGO_CARGO, NUM_TURNO, QTDE_VAGAS) %>%
  summarize(total_votes = sum(votes2)) %>%
  mutate(votes1 = case_when(CODIGO_CARGO == 11 ~ floor(total_votes / 2),
    CODIGO_CARGO == 13 ~ floor(total_votes / QTDE_VAGAS))
  )

# test campaign data
library(tidyverse)
library(magrittr)
load('data/campaign.Rda')

# select variables in final dataset that will be used to match campaign spending
campaign.match <- tse.analysis %>% select(1, 4:6, 15)

# define joinkey
joinkey <- c('ANO_ELEICAO' = 'election.year', 'SG_UE' = 'election.ID',
             'NR_CANDIDATO' = 'candidate.number')

# filter observations down to municipal elections
campaign %>%
  filter(ANO_ELEICAO %in% seq(2004, 2016, 4) & DS_CARGO != 'Vice-prefeito') %>%
  mutate(CD_CARGO = ifelse(DS_CARGO == 'Vereador', 13, 11)) %>%
  inner_join(campaign.match, joinkey) %>%
  group_by(scraper.ID) %>%
  summarize(x = sum(TOTAL_DESPESA)) %>%
  {left_join(tse.analysis, ., 'scraper.ID')} %>%
  select(1:30, x, 31:36) %>%
  group_by(election.ID) %>%
  mutate(x = ifelse(is.na(x), mean(x, na.rm = TRUE), x)) %>%
  group_by(office.ID) %>%
  mutate(x = ifelse(is.na(x), mean(x, na.rm = TRUE), x)) %>%
  ungroup() %>%
  rename(candidacy.expenditures.actual = x) ->
  tse.analysis

######## detalhes

# extract column names from accompanying .pdf file
codebook <- pdf_text('LEIAME.pdf')
codebook <- strsplit(codebook, '\n')
codebook <- unlist(codebook[22])[5:34]

# fix names
codebook %<>% substr(0, 26) %>% {sub('\\(\\*\\)', '', .)} %>% trimws()
codebook <- codebook[which(codebook != '')]

# find files
files <- list.files('../2018 TSE Databank/', pattern = 'detalh(.)*(04|8|12|16)')
paths <- paste0('../2018 TSE Databank/', files)

# unzip 2004 election files
mapply(unzip, paths, MoreArgs = list(exdir = './detalhes'))

# wait for all files to be unzipped
Sys.sleep(15)

# get file names
detalhes2004 <- list.files('./detalhes', pattern = '2004', full.names = TRUE)
detalhes2008 <- list.files('./detalhes', pattern = '2008', full.names = TRUE)
detalhes2012 <- list.files('./detalhes', pattern = '2012', full.names = TRUE)
detalhes2016 <- list.files('./detalhes', pattern = '2016', full.names = TRUE)

# build dataset
details2004 <- tibble()

# loop over election years and create datasets
for (i in detalhes2004) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2004 <- bind_rows(details2004, temp.ds)
}

# build dataset
details2008 <- tibble()

# loop over election years and create datasets
for (i in detalhes2008) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2008 <- bind_rows(details2008, temp.ds)
}

# build dataset
details2012 <- tibble()

# loop over election years and create datasets
for (i in detalhes2012) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2012 <- bind_rows(details2012, temp.ds)
}

# build dataset
details2016 <- tibble()

# loop over election years and create datasets
for (i in detalhes2016) {
  # read each txt file
  temp.ds <- read_delim(i, ';', escape_double = FALSE, col_names = FALSE,
    col_type = cols(.default = 'c'), locale = locale(encoding = 'Latin1'),
    trim_ws = TRUE)
  # bind to empty dtaset
  details2016 <- bind_rows(details2016, temp.ds)
}

# remove files
unlink('./detalhes', recursive = TRUE)

# bind everything
turnout <- bind_rows(details2004, details2008, details2012, details2016)

# assign var names
names(turnout) <- codebook

# save to file
save(turnout, file = 'data/turnout.Rda')

turnout %>% View()

# covariate balance test
covariates.balance <- c(instrumented, covariates)

# create empty vector
stats <- c()

# loop over and run regressions for each covariate to test balance across groups
for (index in seq(2, length(covariates.balance))) {

  # extract indexes of variables which should remain as covariates
  indexes <- c(1, setdiff(seq(2, length(covariates.balance)), c(index)))

  # glue them together
  covariates.matrix <- paste(covariates.balance[indexes], collapse = ' + ')

  # glue them to index variable, which should be the outcome of the regression
  formula <- paste(covariates.balance[index], covariates.matrix, sep = ' ~ ')

  # convert to formula
  formula <- as.formula(formula)

  # run regression and output results
  mutate_at(tse.analysis, vars(23:24), as.integer) %>%
    {c(stats, summary(lm(formula, data = .))$coefficients[2, ])} ->
    stats
}

tse.analysis %$% table(outcome.elected, candidacy.invalid.ontrial)
tse.analysis %$% table(outcome.elected, candidacy.invalid.onappeal)
a <- t.test(candidacy.invalid.ontrial ~ outcome.elected, data = tse.analysis, var.equal = FALSE)
b <- t.test(candidacy.invalid.onappeal ~ outcome.elected, data = tse.analysis, var.equal = FALSE)


a %>% str()


t.test2(a$estimate[2], b$estimate[2],
        (a$estimate[2] - a$estimate[1]) / a$statistic,
        (b$estimate[2] - b$estimate[1])/ b$statistic)


(a$estimate[1] - a$estimate[2]) / 23.082

mean0 <- tse.analysis[tse.analysis$candidacy.invalid.ontrial == 0, 'outcome.elected'] %>% unlist() %>% mean(na.rm = TRUE)
mean1 <- tse.analysis[tse.analysis$candidacy.invalid.ontrial == 1, 'outcome.elected'] %>% unlist() %>% mean(na.rm = TRUE)
n0 <- tse.analysis[tse.analysis$candidacy.invalid.ontrial == 0, 'outcome.elected'] %>% filter(!is.na(outcome.elected)) %>% nrow()
n1 <- tse.analysis[tse.analysis$candidacy.invalid.ontrial == 1, 'outcome.elected'] %>% filter(!is.na(outcome.elected)) %>% nrow()

var0 <- tse.analysis[tse.analysis$candidacy.invalid.ontrial == 0, 'outcome.elected'] %>% unlist() %>% var(na.rm = TRUE)
var1 <- tse.analysis[tse.analysis$candidacy.invalid.ontrial == 1, 'outcome.elected'] %>% unlist() %>% var(na.rm = TRUE)

t.trial <- (mean0 - mean1) / ((var0/n0 + var1/n1)^(1/2))

mean0 <- tse.analysis[tse.analysis$candidacy.invalid.onappeal == 0, 'outcome.elected'] %>% unlist() %>% mean(na.rm = TRUE)
mean1 <- tse.analysis[tse.analysis$candidacy.invalid.onappeal == 1, 'outcome.elected'] %>% unlist() %>% mean(na.rm = TRUE)
n0 <- tse.analysis[tse.analysis$candidacy.invalid.onappeal == 0, 'outcome.elected'] %>% filter(!is.na(outcome.elected)) %>% nrow()
n1 <- tse.analysis[tse.analysis$candidacy.invalid.onappeal == 1, 'outcome.elected'] %>% filter(!is.na(outcome.elected)) %>% nrow()

var0 <- tse.analysis[tse.analysis$candidacy.invalid.onappeal == 0, 'outcome.elected'] %>% unlist() %>% var(na.rm = TRUE)
var1 <- tse.analysis[tse.analysis$candidacy.invalid.onappeal == 1, 'outcome.elected'] %>% unlist() %>% var(na.rm = TRUE)

t.appeal <- (mean0 - mean1) / ((var0/n0 + var1/n1)^(1/2))
