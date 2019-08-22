### tse electoral crime html parser
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import glob
import pandas as pd
import re
import random
import os

# import third-party libraries
import tse

# define clear function
clear = lambda: os.system('clear')

# load list of files to parse
regex = re.compile('(?<=run/)[^a-z]+[0-9]+(?=\\.html)')
files = glob.glob('./html-first-run/*.html')
files = list(filter(regex.search, files))

# create list of scraperIDs passed to data frames
scraperID = [{'scraperID': [re.search(regex, file).group()]} for file in files]

### parse summary
# parse summary and include each file's scraperID in the dictionary
summary = [tse.parser(file).parse_summary() for file in files]
for i, case in enumerate(summary): case.update(scraperID[i])

# build dataset
summary = pd.concat([pd.DataFrame.from_dict(case) for case in summary])
summary = summary.reset_index(drop = True)

# save dataset
summary.to_csv('.data/tseSummary.csv', index = False, sep = '#')

### parse updates
# parse updates and include each file's scraperID in the dictionary
updates = [tse.parser(file).parse_updates() for file in files]

# create an equalizer list that will repeat scraperID so that all rows
# in the updates data frame have a scraperID number
equalizer = [len(case['zone']) for case in updates]

# update the scraperID object with the new length from above
scraperID = [{'scraperID': politician['scraperID'] * equalizer[i]} \
             for i, politician in enumerate(scraperID)]

# build dictionary including each file's scraperID
for i, case in enumerate(updates): case.update(scraperID[i])

# build dataset
updates = pd.concat([pd.DataFrame.from_dict(case) for case in updates])
updates = updates.reset_index(drop = True)

# save dataset
updates.to_csv('./data/tseUpdates.csv', index = False, sep = '#')

### parse details
# parse table details
details = [tse.parser(file).parse_details() for file in files]

# create an equalizer list that will repeat scraperID so that all rows
# in the details data frame have a scraperID number
equalizer = [len(case['shead']) for case in details]

# update the scraperID object with the new length from above
scraperID = [{'scraperID': politician['scraperID'] * equalizer[i]} \
             for i, politician in enumerate(scraperID)]

# build dictionary including each file's scraperID
for i, case in enumerate(details): case.update(scraperID[i])

# build dataset
sentences = pd.concat([pd.DataFrame.from_dict(case) for case in details])
sentences = sentences.reset_index(drop = True)

# save dataset
sentences.to_csv('./data/tseSentences.csv', index = False, sep = '#')



