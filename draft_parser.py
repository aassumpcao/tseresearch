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


"""method to wrangle case decisions"""
### initial objects for parser
# isolate updates and further tables
try:
    tables = self.tables[2:]

    # define regex to find table title
    regex3 = re.compile('despach|senten|decis', re.IGNORECASE)
    regex4 = re.compile(r'\n', re.IGNORECASE)

    # find the position of tables with decisions
    decisions = [i for i in range(len(tables)) if \
                 re.search(regex3, tables[i].td.get_text())]

    # define empty lists for head and body of decisions
    shead = []
    sbody = []

    # loop over all tables containing decisions
    for i in decisions:
        # extract headers and body for all decisions
        for tr in tables[i].find_all('tr'):
            if tr['class'] == ['tdlimpoImpar']:
                shead.append(tr.text)
            if tr['class'] == ['tdlimpoPar']:
                sbody.append(tr.text)

    # drop empty columns
    sbody = [i for i in sbody if re.search('.', i)]

    # build database
    if len(shead) == len(sbody):
        sentences = pd.DataFrame(list(zip(shead, sbody)))
    else:
        # fix problems if lists are of unequal length
        nrow = max(len(shead), len(sbody))
        
        # define the number of observations
        bindhead = ['Head Not Available'] * (nrow - len(shead))
        bindbody = ['Body Not Available'] * (nrow - len(sbody))
        
        # bind at the end of lists
        shead.extend(bindhead)
        sbody.extend(bindbody)
        
        # build corrected dataset
        sentences = pd.DataFrame(list(zip(shead, sbody)))

    # remove weird characters
    sentences = sentences.replace(self.regex0, ' ', regex = True)
    sentences = sentences.replace(self.regex1, ' ', regex = True)
    sentences = sentences.replace(self.regex2, ' ', regex = True)
    sentences = sentences.replace(' +', ' ', regex = True)

    # assign column names
    sentences.columns = ['head', 'body']

    # return outcome
    return pd.DataFrame(sentences)

except:
    return 'there is no sentence table here'


# page with 'redistribuição'
file = './html/2016/prot150312016-260000003691.html'

file = 'teste.html'
 
# test
tse(file).parse_summary()
tse(file).parse_updates()
tse(file).parse_details()
