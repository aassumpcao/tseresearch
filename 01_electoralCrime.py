# electoral crime case number scraper
# developed by:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions        import TimeoutException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support.ui     import WebDriverWait
from selenium.webdriver.support        import expected_conditions as EC
import feather
import numpy as np
import pandas as pd
import time
import re
import os

# initial options
# set working dir
os.chdir('/Users/aassumpcao/OneDrive - University of North Carolina ' +
  'at Chapel Hill/Documents/Research/2018 TSE')

# import scraper
from tse_case import tse_case

# define chrome options
CHROME_PATH      ='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
CHROMEDRIVER_PATH='/usr/local/bin/chromedriver'
WINDOW_SIZE      ='1920,1080'

# set options
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--window-size=%s' % WINDOW_SIZE)
chrome_options.binary_location = CHROME_PATH

# open invisible browser
browser = webdriver.Chrome(executable_path = CHROMEDRIVER_PATH,
                           chrome_options  = chrome_options)

# set implicit wait for page load
browser.implicitly_wait(60)

# import test dataset with 1,000 individuals
candidates = feather.read_dataframe('candidates.feather')

# run scraper for one random individual
tse_case(candidates.loc[1, 'electionYear'], candidates.loc[1, 'electionID'],
         candidates.loc[1, 'electoralUnitID'], candidates.loc[1, 'candidateID'], 
         browser)

# run scraper for 1,000 individuals pulled from random sample of candidates
# create empty dataset to bind results
candidateCases = [['electionYear', 'electionID', 'electoralUnitID', 
                   'candidateID', 'caseNum', 'protNum']]

# run scraper for all individuals
for x in range(0, len(candidates)):
    # pull sequential numbers from table
    electionYear    = candidates.loc[x, 'electionYear']
    electionID      = candidates.loc[x, 'electionID']
    electoralUnitID = candidates.loc[x, 'electoralUnitID']
    candidateID     = candidates.loc[x, 'candidateID']
    # run scraper capturing browser crash error
    try:
        row = tse_case(electionYear, electionID, electoralUnitID, candidateID,
                       browser)
    except:
        browser.quit()
        browser = webdriver.Chrome(executable_path = CHROMEDRIVER_PATH,
                                   chrome_options  = chrome_options)
        # set implicit wait for page load
        browser.implicitly_wait(60)
        # run scraper
        row = tse_case(electionYear, electionID, electoralUnitID, candidateID,
                       browser)
    # print information
    print('Iteration ' + str(x + 1) + ' of ' + str(len(candidates)) + 
          ' successful')
    # bind to dataset
    candidateCases.append(row)

# quit browser
browser.quit()

# wrangle data
# transform list into dataframe
candidateCases = pd.DataFrame(candidateCases)

# save to file
feather.write_dataframe(candidateCases, 'invalidCases.feather')

# close python
exit()
