# electoral crime case decision scraper
# developed by:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
from selenium                          import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions        import TimeoutException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support.ui     import WebDriverWait
from selenium.webdriver.support        import expected_conditions as EC
import feather
import glob
import numpy as np
import os
import pandas as pd
import re
import time

# initial options
# set working dir
os.chdir('/Users/aassumpcao/OneDrive - University of North Carolina ' +
  'at Chapel Hill/Documents/Research/2020 Dissertation/2019 Electoral Crime')

# import scraper
from tse_decision import tse_decision2

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
browser.implicitly_wait(10)

# import test dataset with 1,000 individuals
cases = feather.read_dataframe('caseNumbers.feather')

# split dataset by election year
cases2004 = cases[cases['electionYear'] == '2004']
cases2008 = cases[cases['electionYear'] == '2008']
cases2012 = cases[cases['electionYear'] == '2012']
cases2016 = cases[cases['electionYear'] == '2016']

# create folder for html files
if not os.path.exists('./html'):
  os.mkdir('./html')

# change working directory
os.chdir('./html')

# candidates running in the 2004 election
for x in range(0, len(cases2004)):
  
  # define search
  decision = cases2004.iloc[x, 5]
  
  # run scraper for each candidate in the 2004 elections
  tse_decision2(decision, browser)

  # list files in directory, get the latest file, and create new name
  files   = glob.glob('./*')
  file    = max(files, key = os.path.getctime)
  newname = file[:-5] + '-' + cases2004.iloc[x, 3] + '.html'
  
  # assign new name
  os.rename(file, newname)
  
  # print information
  print('Iteration ' + str(x + 1) + ' / ' + str(len(cases2004)) + ' successful')

# candidates running in the 2008 election
for x in range(0, len(cases2008)):
  
  # define search
  decision = cases2008.iloc[x, 5]
  
  # run scraper for each candidate in the 2008 elections
  tse_decision2(decision, browser)
  
  # list files in directory, get the latest file, and create new name
  files   = glob.glob('./*')
  file    = max(files, key = os.path.getctime)
  newname = file[:-5] + '-' + cases2008.iloc[x, 3] + '.html'
  
  # assign new name
  os.rename(file, newname)
  
  # print information
  print('Iteration ' + str(x + 1) + ' / ' + str(len(cases2008)) + ' successful')

# candidates running in the 2012 election
for x in range(0, len(cases2012)):
  
  # define search
  decision = cases2012.iloc[x, 5]
  
  # run scraper for each candidate in the 2012 elections
  tse_decision2(decision, browser)
  
  # list files in directory, get the latest file, and create new name
  files   = glob.glob('./*')
  file    = max(files, key = os.path.getctime)
  newname = file[:-5] + '-' + cases2012.iloc[x, 3] + '.html'
  
  # assign new name
  os.rename(file, newname)
  
  # print information
  print('Iteration ' + str(x + 1) + ' / ' + str(len(cases2012)) + ' successful')

# candidates running in the 2016 election
for x in range(0, len(cases2016)):
  
  # define search
  decision = cases2016.iloc[x, 5]

  # run scraper for each candidate in the 2016 elections
  tse_decision2(decision, browser)
  
  # list files in directory, get the latest file, and create new name
  files   = glob.glob('./*')
  file    = max(files, key = os.path.getctime)
  newname = file[:-5] + '-' + cases2016.iloc[x, 3] + '.html'
  
  # assign new name
  os.rename(file, newname)
  
  # print information
  print('Iteration ' + str(x + 1) + ' / ' + str(len(cases2016)) + ' successful')

# quit browser
browser.quit()

# close python
exit()
