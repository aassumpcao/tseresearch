python3.7
# import statements
import codecs
import glob
import math
import os
import pandas as pd
import re
import time
from bs4 import BeautifulSoup
from selenium                          import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions        import TimeoutException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support.ui     import WebDriverWait
from selenium.webdriver.support        import expected_conditions as EC

# import function
import tse
import feather
import importlib

# importlib if needed
importlib.reload(tse)

# define chrome options
CHROME_PATH = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
WINDOW_SIZE = '1920,1080'
CHROMEDRIVER_PATH = '/usr/local/bin/chromedriver'

# set options
chrome_options = Options()
# chrome_options.add_argument('--headless')
# chrome_options.add_argument('--window-size=%s' % WINDOW_SIZE)
chrome_options.binary_location = CHROME_PATH

# open invisible browser
browser = webdriver.Chrome(executable_path = CHROMEDRIVER_PATH,
                           options = chrome_options)

# set implicit wait for page load
browser.implicitly_wait(10)

# import test dataset with 1,000 individuals
candidates = pd.read_csv('candidatesPython.csv')

# test
i = 8765

# create dictionary for any random candidate
arguments = {'electionYear'   : candidates.loc[int(i), 'electionYear'],
             'electionID'     : candidates.loc[int(i), 'electionID'],
             'electoralUnitID': candidates.loc[int(i), 'electoralUnitID'],
             'candidateID'    : candidates.loc[int(i), 'candidateID']}

tse.scraper(browser).case(**arguments)
tse.scraper(browser).decision(url)

problemCases = feather.read_dataframe('problemCases.feather')
problemCases.to_csv('problemCases.csv', index = False)


# extract protocol number from url
num = re.search('(?<=nprot=)(.)*(?=&)', self.url).group(0)

 # replace weird characters by nothing
num = re.sub(r'\/|\.|\&|\%|\-', '', num)

ber = re.compile('[0-9]+(-)[0-9]+(?=\\.html)')
candclear  = re.compile('(?<=-)[0-9]+(?=\\.html)')
protclear  = re.compile(r'\/|\.|\&|\%|\-')

file = file[0]

tse.parser('./html-first-run/7615.html').parse_summary()

test = codecs.open(file, 'r', 'cp1252').read()

soup = BeautifulSoup(test, 'lxml')



regex0 = re.compile(r'\n|\t')
regex1 = re.compile(r'\\n|\\t')
regex2 = re.compile('\xa0')
regex3 = re.compile(' +')
regex4 = re.compile('^PROCESSO')
regex5 = re.compile('^MUNIC[IÍ]PIO')
regex6 = re.compile('^PROTOCOLO')
regex7 = re.compile('^(requere|impugnan|recorren|litis)', re.IGNORECASE)
regex8 = re.compile('^(requeri|impugnad|recorri|candid)', re.IGNORECASE)
regex9 = re.compile('^(ju[íi]z|relator)', re.IGNORECASE)
regex10 = re.compile('^assunt', re.IGNORECASE)
regex11 = re.compile('^localiz', re.IGNORECASE)
regex12 = re.compile('^fase', re.IGNORECASE)
regex13 = re.compile('(?<=:)(.)*')
regex14 = re.compile('^(?!.*Plenár)(Despach|Senten|Decis)')

tables = soup.find_all('table')

test = tse.parser(files[0])
test.xt

# isolate following tables
kwargs = {'class': 'titulo_tabela'}
xtable = [td.text for t in test.tables for td in t.find_all('td', **kwargs)]
xtable = {t: i for i, t in enumerate(xtable)}

# find table to parse
for k, v in xtable.items():
    if re.search(regex14, k):
        index = int(v)

# choose updates table to parse
table = tables[index]

# extract rows from table
kwarg = {'class': 'tdlimpoImpar'}
shead = [tr.text for tr in table.find_all('tr', **kwarg)]
kwarg = {'class': 'tdlimpoPar'}
sbody = [tr.text for tr in table.find_all('tr', **kwarg)]

# clean up headers
shead = [re.sub(regex0, '', i) for i in shead]
shead = [re.sub(regex1, '', i) for i in shead]
shead = [re.sub(regex2, '', i) for i in shead]
shead = [re.sub(regex3,' ', i) for i in shead]
shead = [i.strip() for i in shead]

# clean up body
sbody = [re.sub(regex0, '', i) for i in sbody]
sbody = [re.sub(regex1, '', i) for i in sbody]
sbody = [re.sub(regex2, '', i) for i in sbody]
sbody = [re.sub(regex3,' ', i) for i in sbody]
sbody = [i.strip() for i in sbody]

# assign updates to dictionary
if len(shead) == len(sbody):
    details = {'shead': shead, 'sbody': sbody}
else:
    sbody = [i + ' ' + j for i, j in zip(sbody[::2], sbody[1::2])]
    details = {'shead': shead, 'sbody': sbody}

# return dictionary of information
return details

# find the position of tables with decisions
decisions = [i for i in range(len(tables)) if \
             re.search(regex3, tables[i].td.get_text())]

# define empty lists for position, head, and body of decisions
shead = []
sbody = []

# for loop extracting the positions and the content of sentence head
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

# build database taking into account potential parsing failures
nrow = max(len(shead), len(sbody))

# define the number of observations
bindhead = ['Parsing Failure'] * (nrow - len(shead))
bindbody = ['Parsing Failure'] * (nrow - len(sbody))

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

# throw error if table is not available
except:
return 'There are no sentence details here.'
