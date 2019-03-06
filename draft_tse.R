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


load('campaign.Rda')
