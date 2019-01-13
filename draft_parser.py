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

from tse_parser import tse
import random

# change directory
os.chdir('../2012')

# random sample from directory
files = random.sample(os.listdir('.'), 10)

# same files
files = ['prot205692016-20000001925.html',  'prot959002016-50000021622.html',
         'prot835602016-90000016804.html',  'prot496812016-210000002719.html',
         'prot191542016-40000008197.html',  'prot556392016-150000010680.html',
         'prot534542016-150000008918.html', 'prot1157992016-160000024722.html', 
         'prot1153492016-160000024400.html','prot592092016-170000011317.html']

for file in files:
    # tse(file).parse_summary()
    # tse(file).parse_updates()
    tse(file).parse_details()

# test
tse(file).parse_summary()
tse(file).parse_updates()
tse(file).parse_details()

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
