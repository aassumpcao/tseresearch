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

# define arguments for pandas methods
kwarg  = {'ignore_index': True}
kwargs = {'index': False, 'sep': ',', 'quoting': csv.QUOTE_NONNUMERIC}

### parse summary
# define function to parse case summary
def case_summary(file):
    case = tse.parser(file).parse_summary()
    case.update({'candidateID': file[5:-5]})
    return case

# map over list of cases and extract summary information
summary = list(map(case_summary, files))

# build dataset
summaries = pd.concat([pd.DataFrame.from_dict(s) for s in summary], **kwarg)
summaries = summaries.reset_index(drop = True)

# save dataset
summaries.to_csv('data/tseSummaries.csv', **kwargs)

### parse updates
# define function to parse case updates
def case_updates(file):
    case = tse.parser(file).parse_updates()
    equalizer = len(case['zone'])
    case.update({'candidateID': [file[5:-5]] * equalizer})
    return case

# parse updates and include each file's scraperID in the dictionary
updates = list(map(case_updates, files))

# build dataset
updates = pd.concat([pd.DataFrame(up) for up in updates], **kwarg)
updates = updates.reset_index(drop = True)

# save dataset
updates.to_csv('data/tseUpdates.csv', **kwargs)

### parse details
# define function to parse case updates
def case_details(file):
    case = tse.parser(file).parse_details()
    equalizer = len(case['shead'])
    case.update({'candidateID': [file[5:-5]] * equalizer})
    return case

# parse table details
sentences = list(map(case_details, files))

# build dataset
sentences = pd.concat([pd.DataFrame(s) for s in sentences], **kwarg)
sentences = sentences.reset_index(drop = True)

# save dataset
sentences.to_csv('data/tseSentences.csv', **kwargs)



