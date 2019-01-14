import os

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
    tse(file).parse_related_docs()

files

# test
tse(file).parse_summary()
tse(file).parse_updates()
tse(file).parse_details()
tse(file).parse_related_docs()

"""method to wrangle case decisions"""
### initial objects for parser
# isolate updates and further tables
self = tse(files[1])
tables = self.tables[2:]

# define regex to find table title
regex3 = re.compile('despach|senten|decis', re.IGNORECASE)
regex4 = re.compile(r'\n', re.IGNORECASE)

# find the position of tables with decisions
decisions = [i for i in range(len(tables)) if \
             re.search(regex3, tables[i].td.get_text())]

# define empty lists for position, head, and body of decisions
shead = []
sbody = []

# for loop extracting the positions and the content of sentence heads
for i in decisions:
    # create empty list of head and body of decisions per table
    spos  = []
    tbody = []
    # define total number of rows per table
    rows  = tables[i].find_all('tr')
    prows = len(tables[i].find_all('tr'))
    # extract sentence head and position per table
    for tr, x in zip(rows, range(prows)):
        if tr['class'] == ['tdlimpoImpar']:
            spos.append(x) 
            shead.append(tr.text)
    # add last row in sequence
    spos.append(prows)
    # extract sentence body per head per table
    for y, z in zip(spos[:-1], range(len(spos[:-1]))):
        tbody.append([y + 1, spos[z + 1]])
        # subset sentences per head
        for t in tbody:
            decision = [rows[w].text for w in range(t[0], t[1])]
            decision = ''.join(decision[:])
        # bind decisions as the same length as head
        sbody.append(decision)


len(decision)

sbodyflat = [item for sublist in l for item in sublist]

for i in sbody:
    el = ''.join(sbody[i])


[item for i in sbody for item in i]

for i in sbody:
    test = ''.join(item for item in i)




len(shead)
len(sbody)
len(sbody[0])
len(sbody[1])
len(sbody[2])



for t in tbody:
    for w in range(t[0], t[1]):
        decision = rows[w].text


decision = [rows[w].text for w in range(d[0], d[1]) for d in pbody]
decision = [rows[y].text for y in range(z[0], z[1]) for z in pbody]



for y in [2, 3]:


rows[2].text
rows[3].text
rows[4].text

self = tse(files[8])

# isolate updates and further tables
tables = self.tables[2:]

# define regex to find table title
regex3 = re.compile('documen', re.IGNORECASE)
regex4 = re.compile(r'\n', re.IGNORECASE)

# find the position of tables with decisions
decisions = [i for i in range(len(tables)) if \
             re.search(regex3, tables[i].td.get_text())]

# define empty list of docs
docs = []

# for loop finding references to all docs
for tr in tables[decisions[0]].find_all('tr')[1:]:
    td = [td.text for td in tr.find_all('td')]
    docs.append(td)    

# build corrected dataset
docs = pd.DataFrame(docs[1:])
    
# remove weird characters
docs = docs.replace(self.regex0, ' ', regex = True)
docs = docs.replace(self.regex1, ' ', regex = True)
docs = docs.replace(self.regex2, ' ', regex = True)
docs = docs.replace(' +', ' ', regex = True)

# assign column names
docs.columns = ['reference', 'type']

# return outcome
return pd.DataFrame(docs)
