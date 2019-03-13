# structure
# class scraper:
#     case()
#     decision()

# class parser:
#     parse_summary()
#     parse_updates()
#     parse_details()
#     parse_related_cases()
#     parse_related_docs()
#     parse_all()

import codecs
import glob
import pandas as pd
import re
import os
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions        import TimeoutException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support.ui     import WebDriverWait
from selenium.webdriver.support        import expected_conditions as EC
import numpy as np
import time
import re
import random

# define chrome options
CHROME_PATH      ='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
CHROMEDRIVER_PATH='/usr/local/bin/chromedriver'
WINDOW_SIZE      ='1920,1080'

# set options
chrome_options = Options()
# chrome_options.add_argument('--headless')
# chrome_options.add_argument('--window-size=%s' % WINDOW_SIZE)
chrome_options.binary_location = CHROME_PATH

# open invisible browser
browser = webdriver.Chrome(executable_path = CHROMEDRIVER_PATH)

# browser = webdriver.Chrome(executable_path = CHROMEDRIVER_PATH,
#                            chrome_options  = chrome_options)

# set implicit wait for page load
browser.implicitly_wait(60)

page = []

################################################################################
### case()
page = 'http://divulgacandcontas.tse.jus.br/divulga/#/candidato/2016/2/70793/250000069963'
url = 'http://inter03.tse.jus.br/sadpPush/ExibirDadosProcesso.do?nprot=356152012&comboTribunal=ms'
url = 'http://inter03.tse.jus.br/sadpPush/ExibirDadosProcesso.do?nprot=2354642016&comboTribunal=sp'
file = './prot356152012.html'

main            = 'http://divulgacandcontas.tse.jus.br/divulga/#/candidato'
electionYear    = '2016'
electionID      = '2'
electoralUnitID = '70793'
candidateID     = '250000069963'

# case and protocol xpaths
casePath = '//*[contains(@data-ng-if, "numeroProcesso")]'
protPath = '//*[contains(@href, "nprot")]'

from tse import *

scraper(browser).case('2012', '1699', '91693', '120000006917')
scraper(browser, url).decision()
parser(file).parse_all()

parser(file).parse_details()

