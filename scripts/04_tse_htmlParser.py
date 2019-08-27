### tse electoral crime html parser
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import os, sys, re, csv
import pandas as pd

# import third-party libraries
import tse

# define clear function
clear = lambda: os.system('clear')

# load list of files to parse, and create identifier for all files
files = os.listdir('html')
files = sorted(files)[1:]
files = ['html/' + file for file in files]

### parse summary
# define function to parse case summary
def case_summary(file):
    case = tse.parser(file).parse_summary()
    case.update({'candidateID': file[5:-5]})
    return case

# map over list of cases and extract summary information
summary = list(map(case_summary, files))

# build dataset
summaries = pd.concat([pd.DataFrame.from_dict(case) for case in summary])
summaries = summaries.reset_index(drop = True)

# save dataset
kwargs = {'index': False, 'sep': ',', 'quoting': csv.QUOTE_NONNUMERIC}
summaries.to_csv('data/tseSummaries.csv', **kwargs)

### parse updates
# define function to parse case updates
def case_updates(file):
    case = tse.parser(file).parse_updates()
    eq = len(case['zone'])
    case.update({'candidateID': [file[5:-5]] * eq})
    return case

# parse updates and include each file's scraperID in the dictionary
updates = list(map(case_updates, files[:10]))

# build dataset
updates = pd.concat([pd.DataFrame(up) for up in update], ignore_index = True)
updates = updates.reset_index(drop = True)

# save dataset
updates.to_csv('data/tseUpdates.csv', **kwargs)

### parse details
# define function to parse case updates
def case_details(file):
    case = tse.parser(file).parse_details()
    eq = len(case['shead'])
    case.update({'candidateID': [file[5:-5]] * eq})
    return case

# parse table details
sentences = list(map(case_details, files[:10]))

# build dataset
sentences = pd.concat([pd.DataFrame(sentence) for sentence in sentences])
sentences = sentences.reset_index(drop = True)

# save dataset
sentences.to_csv('data/tseSentences.csv', **kwargs)



