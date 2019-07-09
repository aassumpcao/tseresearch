### oab-sp presentation
# quick demonstration of tse module
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import codecs
import datetime
import importlib
import os
import pandas as pd
import re
import requests
from bs4 import BeautifulSoup
from selenium                          import webdriver
from selenium.common.exceptions        import NoSuchElementException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.common.exceptions        import TimeoutException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support        import expected_conditions
from selenium.webdriver.support.ui     import Select
from selenium.webdriver.support.ui     import WebDriverWait

# import third-party libraries
import tse

# define clear function
clear = lambda: os.system('clear')

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

### what i do
# define candidate page variable
page = 'http://divulgacandcontas.tse.jus.br/divulga/#/' + \
       'candidato/2016/2/70793/250000069963'

# visit page
browser.get(page)

# execute first method and extract page we want to scrape
url = tse.scraper(browser).case('2016', '2', '70793', '250000069963')

# save page
tse.scraper(browser).decision(url)

# parse summary table
tse.parser('decision.html').parse_summary()

# parse sentence
sentence = tse.parser('decision.html').parse_details()

# find sentence for registro de candidatura
sentence['sbody'][4]

### on the fly
# another interesting use
page = 'http://divulgacandcontas.tse.jus.br/divulga/#/' + \
       'candidato/2016/2/71072/250000011576'

# visit page
browser.get(page)
tse.scraper(browser).case('2016', '2', '71072', '250000011576')

# find government plan
govplan = '//*[contains(concat( " ", @class, " " ),' + \
          'concat( " ", "dvg-proposta", " " ))]'

# select link
browser.find_element_by_xpath(govplan)
browser.find_element_by_xpath(govplan).click()

# get pdf
browser.switch_to.window(browser.window_handles[1])
browser.current_url

# save pdf
pdf = requests.get(browser.current_url)
codecs.open('programa-de-governo.pdf', 'wb').write(pdf.content)
