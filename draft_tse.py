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

file = codecs.open(file, 'r', 'cp1252').read()

soup = BeautifulSoup(file, 'lxml')

tables = soup.find_all('table')

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
regex13 = re.compile('[^.]*:( )?')

# isolate summary table
table = tables[0]

# find all rows in table and extract their text
rows = [tr.text for tr in table.find_all('tr')]

# clean up text
rows = [re.sub(regex0, '', row) for row in rows]
rows = [re.sub(regex1, '', row) for row in rows]
rows = [re.sub(regex2, '', row) for row in rows]
rows = [re.sub(regex3,' ', row) for row in rows]

# slice javascript out of list
rows = rows[:-1]

# filter down each row to text that matters
case      = {'case'     : list(filter(regex4.search, rows))}
town      = {'town'     : list(filter(regex5.search, rows))}
prot      = {'prot'     : list(filter(regex6.search, rows))}
claimants = {'claimants': list(filter(regex7.search, rows))}
defendant = {'defendant': list(filter(regex8.search, rows))}
judge     = {'judge'    : list(filter(regex9.search, rows))}
subject   = {'subject'  : list(filter(regex10.search, rows))}
district  = {'district' : list(filter(regex11.search,rows))}
stage     = {'stage'    : list(filter(regex12.search, rows))}
empty = {'empty': []}

# join all information into single list
summary = [case, town, prot, claimants, defendant, judge, subject, \
           district, stage, empty]

# create dictionary
for info in summary[1:]: case.update(info)

# recreate summary
summary = case

# strip keys in dictionary values

for k, v in summary.items():
    summary[k] = [re.sub(regex13, '', i) for i in summary[k]]


