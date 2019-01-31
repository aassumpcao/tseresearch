import os
os.getcwd()
os.chdir('.')

file = './html/2012/prot428622012-150000012522.html'

try:
    file = codecs.open(file, 'r', 'cp1252').read()
except:
    file = codecs.open(file, 'r', 'utf-8').read()


from tse_parser import tse

self = tse(file)
tse(file).parse_summary()



### initial objects for parser
# isolate summary table
table = self.tables[2]

# define regex to find table title
regex3 = re.compile('data', re.IGNORECASE)

### for loop to find table indexes
# find all rows in table
rows = table.find_all('tr')

# define counter for finding the first row to parse
i = -1

# loop incrementing row index
for row in rows:
    i += 1
    if row.find_all(text = regex3) != []:
        i += 1
        break

### for loop to extract table text and build dataset
# defined case updates
updates = []

# build table
for row in rows:
    # extract information in each line
    line = [td.text for td in row.find_all('td')]
    # append to empty object
    updates.append(line)

# build database
updates = updates[i:len(rows)]

# transform into pandas dataframe
updates = pd.DataFrame(updates)

# remove weird characters
updates = updates.replace(self.regex0, ' ', regex = True)
updates = updates.replace(self.regex1, ' ', regex = True)
updates = updates.replace(self.regex2, ' ', regex = True)
updates = updates.replace(' +', ' ', regex = True)

# return outcome
return pd.DataFrame(updates)

# page with 'redistribuição'
file = './html/2016/prot150312016-260000003691.html'

file = 'teste.html'

# test
tse(file).parse_summary()
tse(file).parse_updates()
tse(file).parse_details()

from tse_parser import parser as tse
import random
import codecs
import glob
import pandas as pd
import re
import os
from bs4 import BeautifulSoup

# change directory
os.chdir('./html/2016')

# random sample from directory
files = random.sample(os.listdir('.'), 100)

dir(tse)

for file in files[1:99]:
    # tse(file).parse_summary()
    # tse(file).parse_updates()
    # tse(file).parse_details()
    # tse(file).parse_related_cases()
    # tse(file).parse_related_docs()
    # tse(file).parse_all()





file = files[3]

# test
tse(file).parse_summary()
tse(file).parse_updates()
tse(file).parse_details()
tse(file).parse_related_cases()
tse(file).parse_related_docs()

"""method to parse all tables into a single dataset"""
### call other parser functions
# parse tables we know exist
table1 = tse(self).parse_summary(transpose = True)
table2 = tse(self).parse_updates()

# insert column for identifying case information (updates) 
table2.insert(0, 'caseinfo', 'updates')

# parse tables we are not sure exist
# try catch if tables don't exist
# table three
try:
    # parse case details table
    table3 = tse(self).parse_details()

    # insert column for identifying case information (details)
    table3.insert(0, 'caseinfo', 'details')

    # bind onto previous tables
    table2 = pd.concat([table2, table3], \
                       axis = 0, ignore_index = True, sort = False)

# throw error if table doesn't exist
except:
    pass

# table four
try:
    # parse related cases table
    table4 = tse(self).parse_related_cases()

    # insert column for identifying case information (related cases)
    table4.insert(0, 'caseinfo', 'relatedcases')

    # bind onto previous tables
    table2 = pd.concat([table2, table4], \
                       axis = 0, ignore_index = True, sort = False)

# throw error if table doesn't exist
except:
    pass

# table five
try:
    # parse related docs table
    table5 = tse(self).parse_related_docs()

    # insert column for identifying case information (related docs)
    table5.insert(0, 'caseinfo', 'relateddocs')

    # bind onto previous tables
    table2 = pd.concat([table2, table5], \
                       axis = 0, ignore_index = True, sort = False)

# throw error if table doesn't exist
except:
    pass

# create list of column names
names = list(table1)
names.extend(list(table2))

# bind everything together
table = pd.concat([table1]*len(table2), ignore_index = True)
table = pd.concat([table, table2], axis = 1, ignore_index = True)

# reassign column names
table.columns = names

# reorder table columns
ordered = [names[9]]
ordered.extend(names[0:8])
ordered.extend(names[10:])

# change order of columns
table = table[ordered]

# return outcome
return table
