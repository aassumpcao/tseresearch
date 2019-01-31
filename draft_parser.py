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

# change directory
os.chdir('./html/2016')

# random sample from directory
files = random.sample(os.listdir('.'), 10)


for file in files:
    # tse(file).parse_summary()
    # tse(file).parse_updates()
    # tse(file).parse_details()
    # tse(file).parse_related_cases()
    tse(file).parse_related_docs()

file = files[3]

# test
tse(file).parse_summary()
tse(file).parse_updates()
tse(file).parse_details()
tse(file).parse_related_cases()
tse(file).parse_related_docs()

"""method to parse all tables into a single dataset"""
### call other parser functions
# tables we know exist
table1 = tse(self).parse_summary(transpose = True)
table2 = tse(self).parse_updates()

# insert column identifier for case information beginning
# in table 2
table2.insert(0, 'caseinfo', 'updates')

# tables we don't know if they exist
try:
    table3  = tse(self).parse_details()
    table3.insert(0, 'caseinfo', 'details')
    length3 = len(table3)
except:
    length3 = 0
try:
    table4  = tse(self).parse_related_cases()
    table4.insert(0, 'caseinfo', 'relatedcases')
    length4 = len(table4)
except:
    length4 = 0
try:
    table5  = tse(self).parse_related_docs()
    table5.insert(0, 'caseinfo', 'relateddocs')
    length5 = len(table5)
except:
    table5  = 0
