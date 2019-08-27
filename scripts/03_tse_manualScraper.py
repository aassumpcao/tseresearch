### tse candidacy cases scraper
# this script fixes manual problems in earlier downloads
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import os, sys, re
import pandas as pd

# import additional libraries
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from scripts import tse

# create function to clear screen
clear = lambda: os.system('clear')

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
browser.implicitly_wait(3)

# read in dataset of candidates
candidates = pd.read_csv('data/casedecision_list.csv')

# read html files which were downloaded in previous script
files = os.listdir('html')
files = sorted(files)[1:]
files = [file[:-5] for file in files]

# transform dataset elements into list
urls = candidates['url'].to_list()
identifiers = candidates['candidateID'].to_list()
candidates = [(a, b) for a, b in zip(urls, identifiers)]

# find missing downloads if not year == 2004 | year == 2008
missing = [c for c in candidates if c[1] not in files]
missing2012 = [m for m in missing if re.search(r'^2012_', m[1])]
missing2016 = [m for m in missing if re.search(r'^2016_', m[1])]

# print length of these missing decisions
len(missing2012), len(missing2016)

# initiate class and change working directory
scrape = tse.scraper(browser)
os.chdir('html')

# try to download these again
check2012 = [(m[1], scrape.decision(*m)) for m in missing2012]
check2016 = [(m[1], scrape.decision(*m)) for m in missing2016]

# close browser
browser.quit()
