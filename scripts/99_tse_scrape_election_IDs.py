### download election ids from tse
# andre assumpcao
# andre.assumpcao@gmail.com

# import libraries
import re, os, sys
import pandas as pd

# import selenium libraries
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options

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

# define tse page
TSE = 'http://divulgacandcontas.tse.jus.br/divulga/#/'
menu = '//*[@data-placement="bottom"]'
suplementares = '//*[@class="fa fa-chevron-right"]'
eleições = ['//option[@label="{}"'.format(y) for y in range(2004, 2020, 4)]
estados = '//select[@id="selectEstado"]//option'
selecionar = '//*[@class="list-group-item ng-binding ng-scope"]'
confirmar = '//button[@class="sweet-confirm styled"]'

# create loop to scrape electoral identifiers
for eleição in eleições:
    pass

# visit page, and open off-cycle elections menu
browser.get(TSE)
browser.find_element_by_xpath(menu).click()
browser.find_elements_by_xpath(suplementares)[1].click()

# pick year and scrape codes
browser.find_element_by_xpath('//option[@label="2008"]').click()
states = browser.find_elements_by_xpath(estados)
states = [state.get_attribute('label') for state in states][2:]
for state in states:
    pass

browser.find_element_by_xpath('//option[@label="AM"]').click()
browser.find_element_by_xpath('//button').click()
browser.find_element_by_xpath(selecionar).click()
browser.find_element_by_xpath(confirmar).click()

# close browser
browser.quit()
