load('case.numbers.Rda')

case.numbers %>%
  filter(electionYear > 2008) %>%
  mutate(case_number = paste0(str_extract(protNum, '(?<=nprot=)(.)*(?=&)'),
                              str_extract(protNum, '(?<=comboTribunal=)(.)*'))
  ) %>%
  select(case_number) %>%
  unlist() %>%
  unname() %>%
  unique() %>%
  length()
