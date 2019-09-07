### tse electoral crime case decision scraper
# this script downloads the remaining sentences for all candidates who
#   were prevented from running to office in 2016
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
candidates = pd.read_csv('data/prevented2016.csv')
infile = [file[:-5] for file in os.listdir('html')]
candidates = candidates[~candidates['candidateID'].isin(infile)]
candidates = candidates.reset_index(drop = True)

# change directory to html files
os.chdir('html')

# load up scraper and prepare error catching list
scrape = tse.scraper(browser)
results = []

# transform dataset elements into list
urls = candidates['url'].to_list()
identifiers = candidates['candidateID'].to_list()
candidates = [(a, b) for a, b in zip(urls, identifiers)]

print('loop began')
# run loop
for i, candidate in enumerate(candidates):

    # run scraper
    absorb = scrape.decision(*candidate)
    results.append((candidate[1], absorb))

    # print progress
    if (i + 1) % 1000 == 0: print(str(i + 1) + ' / ' + str(len(candidates)))

# save scraper outcomes
pd.DataFrame(results).to_csv('../data/prevented2016_status.csv')

# quit browser
browser.quit()
