### tse electoral crime case decision scraper
# this script downloads the case decisions for all candidacy cases at
#   the tse electoral court for municipal elections since 2008. each
#   decision is downloaded as an html file and saved to disk
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import codecs
import glob
import importlib
import math
import numpy as np
import os
import pandas as pd
import re
import time
import datetime

# import third-party and local libraries
from selenium                          import webdriver
from selenium.common.exceptions        import NoSuchElementException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.common.exceptions        import TimeoutException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support        import expected_conditions as EC
from selenium.webdriver.support.ui     import WebDriverWait

# import third-party libraries
import importlib
import tse

# define chrome options
CHROME_PATH = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
WINDOW_SIZE = '1920,1080'
CHROMEDRIVER_PATH = '/usr/local/bin/chromedriver'

# set options
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--window-size=%s' % WINDOW_SIZE)
chrome_options.binary_location = CHROME_PATH

# open invisible browser
browser = webdriver.Chrome(CHROMEDRIVER_PATH, options = chrome_options)

# set implicit wait for page load
browser.implicitly_wait(15)

# import test dataset with 1,000 individuals
candidates = pd.read_csv('caseNumbers.csv').reset_index()
candidates['scraperID'] = candidates['scraperID'].astype(str)
limit = len(candidates)

# change working directory
os.chdir('./html-trialrun')

# load up scraper and prepare error catching list
scrape = tse.scraper(browser)
results = []

# run loop
for i in range(limit):
    # arguments for function
    arguments = {'url': candidates.loc[i, 'protNum'],
                 'filename': candidates.loc[i, 'scraperID']}
    # run scraper
    absorb = scrape.decision(**arguments)
    results.append((arguments['filename'], absorb))
    # print progress
    if (i + 1) % 1000 == 0:
        print(str(i+1) + ' / ' + str(limit), + ' ; ' + datetime.datetime.now())

# save scraper outcomes
pd.DataFrame(results).to_csv('./scraper_status.csv')

# quit browser
browser.quit()
