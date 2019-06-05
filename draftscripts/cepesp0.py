### cepesp presentation
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import importlib
import codecs
import datetime
import os
import pandas as pd
import re
from bs4 import BeautifulSoup
from selenium                          import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions        import NoSuchElementException
from selenium.common.exceptions        import TimeoutException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support.ui     import Select
from selenium.webdriver.support.ui     import WebDriverWait
from selenium.webdriver.support        import expected_conditions

# import third-party libraries
import tse

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
browser = webdriver.Chrome(CHROMEDRIVER_PATH, options = chrome_options)

# set implicit wait for page load
browser.implicitly_wait(15)

# suppose you are interested in understanding how judicial rulings
# impact a candidate's electoral performance. voters might care about
# criminal history and punish candidates.

## 1. manual way
## 1. manual way using software
# candidate name and webpage
candidate = 'Delen'
page = 'http://divulgacandcontas.tse.jus.br/divulga/#/' + \
       'candidato/2016/2/70793/250000069963'

# visit page
browser.get(page)

# define where I want to go
prot = '//*[contains(@href, "nprot")][not(contains(@href, "undefined"))]'

# ask browser to find it
path = browser.find_element_by_xpath(prot)
path = path.get_attribute('href')

# visit new page
browser.get(path)

# xpath search patterns for decision method
xpath    = '//*[contains(@value, "Todos")]'
viewPath = '//*[@value="Visualizar"]'
errPath  = '//*[@color="RED"]'
java = 'return document.getElementsByTagName("html")[0].innerHTML'

# make selection
browser.find_element_by_xpath(xpath).click()
browser.find_element_by_xpath(viewPath).click()

# save page content
html = browser.execute_script(java)

# download file
codecs.open('decision.html', 'w', 'cp1252').write(html)

# open file
file = codecs.open('decision.html', 'r', 'cp1252').read()

# parse file
soup = BeautifulSoup(file, 'lxml')

# find all tables in document
tables = soup.find_all('table')

# select first table
table = tables[0]

# find all rows in table and extract their text
rows = [tr.text for tr in table.find_all('tr')]

# clean up cells
rows = [re.sub(r'\n|\t', '', row) for row in rows]
rows = [re.sub(r'\\n|\\t', '', row) for row in rows]
rows = [re.sub('\xa0', '', row) for row in rows]
rows = [re.sub(' +',' ', row) for row in rows]

# slice javascript out of list
rows = rows[:-1]

# find judge name
judge = list(filter(re.compile('JUIZ').search, rows))
judge[0][8:]

## 2. automated way
# find decision page
tse.scraper(browser).case('2016', '2', '70793', '250000069963')

# save page
tse.scraper(browser).decision(url)

# parse summary table
tse.parser('decision.html').parse_summary()

# parse sentence
sentence = tse.parser('decision.html').parse_details()

# find sentence for registro de candidatura
sentence['sbody'][4]

# use text for analysis, like I did
#   talk about machine learning algorithm used for identifying dismissal
#   reasons

## on the fly
# another interesting use
tse.scraper(browser).case('2016', '2', '71072', '250000011576')

# find government plan
govplan = '//*[contains(concat( " ", @class, " " ), concat( " ", "dvg-proposta", " " ))]'

# select link
browser.find_element_by_xpath(govplan)
browser.find_element_by_xpath(govplan).click()

# get pdf
browser.switch_to.window(browser.window_handles[1])
browser.current_url

# save pdf
import requests
pdf = requests.get(browser.current_url)
codecs.open('haddad.pdf', 'wb').write(pdf.content)
