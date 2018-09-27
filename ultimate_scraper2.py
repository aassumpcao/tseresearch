# tse decision number scraper
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
import numpy as np
import os
import pandas as pd
import time
import re
# import pdfkit
# import json
import codecs

from html_table_parser import parse_html_table

################################################################################
# initial options
# set working dir
os.chdir('/Users/aassumpcao/OneDrive - University of North Carolina ' +
  'at Chapel Hill/Documents/Research/2018 TSE')

# define chrome options
CHROME_PATH      ='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
CHROMEDRIVER_PATH='/usr/local/bin/chromedriver'
WINDOW_SIZE      ='1920,1080'

# # define printer settings using json to print page as pdf
# appState = {
#     "recentDestinations": [
#         {
#             "id": "Save as PDF",
#             "origin": "local"
#         }
#     ],
#     "selectedDestinationId": "Save as PDF",
#     "version": 2
# }
# prefs = {
#     'printing.print_preview_sticky_settings.appState': json.dumps(appState)
# }

# set options
chrome_options = Options()
# chrome_options.add_argument('--headless')
chrome_options.add_argument('--window-size=%s'  % WINDOW_SIZE)
# chrome_options.add_argument('--kiosk-printing')
# chrome_options.add_experimental_option('prefs', prefs)
chrome_options.binary_location = CHROME_PATH

# open invisible browser
browser = webdriver.Chrome(executable_path = CHROMEDRIVER_PATH,
                           chrome_options  = chrome_options)
# browser.quit()

# set implicit wait for page load
browser.implicitly_wait(60)

# search parameters
main     = 'http://inter03.tse.jus.br/sadpPush/ExibirDadosProcesso.do?nprot='
protNum  = '550892016'
court    = '&comboTribunal='
state    = 'ma'
xpath1   = '//*[contains(@value, "Andam")]'
xpath2   = '//*[contains(@value, "Despacho")]'
deciPath = '//*[contains(@)]'
viewPath = '//*[@value="Visualizar"]'
url = 'http://inter03.tse.jus.br/sadpPush/ExibirDadosProcesso.do?nprot=92232016&comboTribunal=ms'
url      = main + str(protNum) + court + state
browser.get(url)

tablepath = '//table'
print(tables)
print(table)

type(table)

decision  = EC.presence_of_element_located((By.XPATH, tablepath))
WebDriverWait(browser, 3).until(decision)
decision1 = browser.find_element_by_xpath(xpath1).click()
decision2 = browser.find_element_by_xpath(xpath2).click()
visualize = browser.find_element_by_xpath(viewPath).click()
tables    = browser.find_elements_by_xpath(tablepath)
table     = [tables[0].text]
table     = tables[1].text
table     = [tables[2].text]
htmltest  = browser.execute_script('return document.getElementsByTagName("html")[0].innerHTML')
open('file', 'w').write(str(table))
codecs.open('htmltest.txt', 'w', 'UTF-8').write(str(table))

################################################################################
# import scraper
from tse_case import tse_case
from tse_decision import tse_decision
tse_case(270000007695, 96032, 2016, browser)

tse_decision(550892016, 'ma', browser)

