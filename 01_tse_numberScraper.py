### tse candidacy cases scraper
# this script downloads the case number for all candidacy cases at the
#   tse electoral court for municipal elections since 2008. each case id
#   is used for creating a list of people for whom I download case
#   decisions in another python script.
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import os, re, time, codecs
import pandas as pd

# import selenium libraries
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

# import third-party libraries
import tse
# import importlib
# importlib.reload(tse)

# define function to clear screen
# clear = lambda: os.system('clear')

# define chrome options
CHROME_PATH = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
CHROMEDRIVER_PATH = '/usr/local/bin/chromedriver'

# set options
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--window-size=1920,1080')
chrome_options.binary_location = CHROME_PATH

# open invisible browser
browser = webdriver.Chrome(CHROMEDRIVER_PATH, options = chrome_options)

# set implicit wait for page load
browser.implicitly_wait(30)

# import test dataset with 1,000 individuals
candidates = pd.read_csv('./data/candidatesPending.csv')
candidates['unit'] = candidates['unit'].astype(str).str.pad(5, 'left', '0')
candidates = candidates[2500:5000].reset_index(drop = True)
limit = len(candidates)

# create empty dataset
casenumbers = []

# run scraper for all individuals
for i in range(limit):

    # pull sequential numbers from table
    arguments = {
        'year'      : candidates.loc[int(i), 'year'],
        'election'  : candidates.loc[int(i), 'electionID'],
        'unit'      : candidates.loc[int(i), 'unit'],
        'candidate' : candidates.loc[int(i), 'candID']
    }

    # run scraper capturing browser crash error
    row = [tse.scraper(browser).case(**arguments)]

    # merge candidate scraper id
    row += [candidates.loc[int(i), 'candidateID']]

    # print warning every 10 iterations
    if (i + 1) % 100 == 0: print(str(i + 1) + ' / ' + str(limit))

    # bind to dataset
    casenumbers.append(row)

# quit browser
browser.quit()

# transform list into dataframe
casenumbers = pd.DataFrame(casenumbers)

# save to file
casenumbers.to_csv('./data/casenumbers5000.csv', index = False)
