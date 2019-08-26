### tse electoral crime case decision scraper
# this script downloads the case decisions for all candidacy cases at
#  the tse electoral court for municipal elections since 2008. each
#  decision is downloaded as an html file and saved to disk
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
import os
import pandas as pd

# import third-party libraries
import tse

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
browser.implicitly_wait(10)

# import test dataset with 1,000 individuals
candidates = pd.read_csv('data/casedecision_list.csv')
# candidates = candidates[
#     candidates['candidateID'].str.contains('(2012|2016)_', regex = True)
# ]

# create directory for html files
try:
    os.mkdir('html')
except:
    pass

# change directory to html files
os.chdir('html')

# load up scraper and prepare error catching list
scrape = tse.scraper(browser)
results = []

# transform dataset elements into list
urls = candidates['url'].to_list()
identifiers = candidates['candidateID'].to_list()
candidates = [(a, b) for a, b in zip(urls, identifiers)]

# run loop
for i, candidate in enumerate(candidates):

    # arguments for function
    arguments = {'url': candidate[0], 'filename': candidate[1], 'wait': 2}

    # run scraper
    absorb = scrape.decision(**arguments)
    results.append((arguments['filename'], absorb))

    # print progress
    if (i + 1) % 1000 == 0: print(str(i + 1) + ' / ' + str(len(candidates)))

# save scraper outcomes
pd.DataFrame(results).to_csv('../data/casedecision_status.csv')

# quit browser
browser.quit()
