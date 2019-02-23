### tse classes and methods
# developed by:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import codecs
import glob
import math
import numpy as np
import os
import pandas as pd
import re
import time

# import third-party libraries
from bs4 import BeautifulSoup
from selenium                          import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions        import NoSuchElementException
from selenium.common.exceptions        import TimeoutException
from selenium.common.exceptions        import StaleElementReferenceException
from selenium.webdriver.common.by      import By
from selenium.webdriver.common.keys    import Keys
from selenium.webdriver.support.ui     import Select
from selenium.webdriver.support.ui     import WebDriverWait
from selenium.webdriver.support        import expected_conditions as EC

# define scraper class
class scraper:

    """
        the scraper class contains methods used to download data from
        tse websites. it visits two pages: (i) any candidate's profile
        and (ii) the decision regarding their candidacy.

        attributes:
            browser:    placeholder for selenium browser call

        methods:
            case:       download case and protocol number
            decision:   use protocol number to download judicial decision
    """
    # define static arguments for all methods in the scraper class
    browser = []
    page = []
    main = 'http://divulgacandcontas.tse.jus.br/divulga/#/candidato'
    java = 'return document.getElementsByTagName("html")[0].innerHTML'

    # xpath search pattern for case method
    prot = '//*[contains(@href, "nprot")][not(contains(@href, "undefined"))]'

    # xpath search patterns for decision method
    xpath    = '//*[contains(@value, "Todos")]'
    viewPath = '//*[@value="Visualizar"]'
    errPath  = '//*[@color="RED"]'

    # init method share by all class instances
    def __init__(self, browser):
        """load into class the url which will be downloaded"""

        # store browser info
        self.browser = browser

    # case number scraper function
    def case(self, electionYear, electionID, electoralUnitID, candidateID,
             wait = 10):

        """ method to download case number by candidate information """

        # turn method arguments to strings
        args = locals()
        pageargs = [str(value) for key, value in args.items() if key != 'self']

        # concatenate everything and form page address
        self.page = '/'.join([self.main] + pageargs)

        # try information in DOM
        try:
            # navigate to candidate page
            self.browser.get(self.page)

            # check if protocol number is visible in webpage
            # caseVis = EC.presence_of_element_located((By.XPATH, casePath))
            protVis = EC.presence_of_element_located((By.XPATH, self.prot))

            # wait up to 60s for elements to be located
            # WebDriverWait(browser, 60).until(caseVis)
            WebDriverWait(self.browser, wait).until(protVis)

            # if protocol number has been found, download it
            # caseElem = browser.find_element_by_xpath(casePath)
            protElem = self.browser.find_element_by_xpath(self.prot)

            # extract text from caseNum and href from protNum
            # caseNum = caseElem.text
            protNum = protElem.get_attribute('href')

        # handle exception
        except StaleElementReferenceException as Exception:
            # caseNum = ['staleException']
            protNum = 'staleElementException'

        # handle exception
        except TimeoutException as Exception:
            # caseNum = ['timeoutException']
            protNum = 'timeoutException'

        # return case and protocol numbers as list
        return protNum

    # decision scraper function
    def decision(self, url = None, filename = 'decision'):

        """ method to download tse decisions by url """

        # skip out if url has not been provided
        if url == None: return 'URL not loaded'

        # store url for scraping decisions
        self.url = url

        # catch error
        try:
            # navigate to url
            self.browser.get(self.url)

            # check if elements are located
            dec = EC.presence_of_element_located((By.XPATH, self.viewPath))

            # wait up to 3s for last element to be located
            WebDriverWait(self.browser, 15).until(dec)

            # when element is found, click on 'andamento', 'despacho',
            # and 'view' so that the browser opens up the information we
            # want
            self.browser.find_element_by_xpath(self.xpath).click()
            self.browser.find_element_by_xpath(self.viewPath).click()

            # save inner html to object
            html = self.browser.execute_script(self.java)

            # define filename
            if filename == 'decision':
                file = 'decision.html'
            else:
                # provide name to file
                file = str(filename) + '.html'
            # save to file
            try:
                codecs.open(file, 'w', 'cp1252').write(html)
            except:
                codecs.open(file, 'w', 'utf-8').write(html)

            # print message
            return 'Download successful'

        except NoSuchElementException as Exception:
            e = EC.presence_of_element_located((By.XPATH, self.errPath))
            WebDriverWait(self.browser, 1).until(e)
            return 'Download failed: NoSuchElementException'

        except TimeoutException as Exception:
            return 'Download failed: timeoutException'

        except StaleElementReferenceException as Exception:
            return 'Download failed: staleElementException'

        except:
            return 'Download failed: reason unknown'

# define parser class
class parser:

    """
        series of methods to wrangle TSE court documents

        attributes:
            file:                path to judicial decision html file

        methods:
            parse_summary:       parse summary table
            parse_updates:       parse case updates
            parse_details:       parse sentence details
            parse_related_cases: parse references to other cases
            parse_related_docs:  parse references to other documents
            parse_all:           parse everything above
    """

    # define static variables used for parsing all tables
    soup   = []
    tables = []

    # define regex compile for substituting weird characters in all tables
    regex0 = re.compile(r'\n|\t')
    regex1 = re.compile(r'\\n|\\t')
    regex2 = re.compile(r'\\xa0')

    # init method shared by all class instances
    def __init__(self, file):

        """ load into class the file which will be parsed """

        # try cp1252 encoding first or utf-8 if loading fails
        try:
            self.file = codecs.open(file, 'r', 'cp1252').read()
        except:
            self.file = codecs.open(file, 'r', 'utf-8').read()

        # call BeautifulSoup to read string as html
        self.soup = BeautifulSoup(self.file, 'lxml')

        # find all tables in document
        self.tables = self.soup.find_all('table')

    #1 parse summary info table:
    def parse_summary(self, transpose = False):

        """ method to wrangle summary information """

        # initial objects for parser
        # isolate summary table
        table = self.tables[0]

        # find all rows in table
        rows = table.find_all('tr')

        ### find simple information
        # find case, municipality, and protocol information from table
        case = [td.text for td in rows[0].find_all('td')]
        town = [td.text for td in rows[1].find_all('td')]
        prot = [td.text for td in rows[2].find_all('td')]

        # split title and information
        case = ['case', ''.join(case[1:])]
        town = ['town', ''.join(town[1:])]
        prot = ['prot', ''.join(prot[1:])]

        ### find more complex elements
        #1 find claimants using regex
        regex3 = re.compile('(requere|impugnan|recorren|litis)', re.IGNORECASE)

        # create list of claimant information
        claimants = []

        # for each row in the summary table:
        for row in rows:
            # find rows that match the claimant regex
            if row.find_all(text = regex3) != []:
                # extract all columns and join them into one observation
                claimant = [td.text for td in row.find_all('td')]
                claimant = ''.join(claimant[1:])
                # append to claimant list
                claimants.append(claimant)

        # format list
        claimants = ['claimants', ';;'.join(claimants[1:]) \
                                  if len(claimants) > 1 else claimants[0]]

        #2 find plaintiffs using regex
        regex4 = re.compile('(requeri|impugnad|recorri|candid)', re.IGNORECASE)

        # create list of plaintiff information
        plaintiffs = []

        # for each row in the summary table:
        for row in rows:
            # find rows that match the plaintiff regex
            if row.find_all(text = regex4) != []:
                # extract all columns and join them into one observation
                plaintiff = [td.text for td in row.find_all('td')]
                plaintiff = ''.join(plaintiff[1:])
                # append to plaintiff list
                plaintiffs.append(plaintiff)

        # format list
        plaintiffs = ['plaintiffs', ';;'.join(plaintiffs[1:]) \
                                    if len(plaintiffs) > 1 else plaintiffs[0]]

        #3 find judges using regex
        regex5 = re.compile('(ju[íi]z|relator)', re.IGNORECASE)

        # create list of judge information
        judges = []

        # for each row in the summary table:
        for row in rows:
            # find rows that match the judge regex
            if row.find_all(text = regex5) != []:
                # extract all columns and join them into one observation
                judge = [td.text for td in row.find_all('td')]
                judge = ''.join(judge[1:])
                # append to judge list
                judges.append(judge)

        # format list
        judges = ['judges', ';;'.join(judges[1:]) \
                            if len(judges) > 1 else judges[0]]

        ### find last information
        # find case subject, location, and stage in table
        regex6 = re.compile('assunt',  re.IGNORECASE)
        regex7 = re.compile('localiz', re.IGNORECASE)
        regex8 = re.compile('fase',    re.IGNORECASE)

        # find subject, location, and stage information from table
        subj  = [row.text for row in rows if row.find_all(text = regex6) != []]
        loc   = [row.text for row in rows if row.find_all(text = regex7) != []]
        stage = [row.text for row in rows if row.find_all(text = regex8) != []]

        # split title and information
        subj  = ['subject',  re.sub('(.)*:', '', str(subj))]
        loc   = ['location', re.sub('(.)*:', '', str(loc))]
        stage = ['stage',    re.sub('(.)*:', '', str(stage))]

        # join all information into single dataset
        summary = [case, town, prot, claimants, plaintiffs, \
                   judges, subj, loc, stage]

        # transform into pandas dataframe
        summary = pd.DataFrame(summary)

        # remove weird characters
        summary = summary.replace(self.regex0, ' ', regex = True)
        summary = summary.replace(self.regex1, ' ', regex = True)
        summary = summary.replace(self.regex2, ' ', regex = True)
        summary = summary.replace(' +', ' ', regex = True)

        # assign column names
        summary.columns = ['variables', 'values']

        # return outcome if transpose is not provided as argument
        if transpose == False:
            return pd.DataFrame(summary)
        else:
            summary = summary.T
            summary.columns = summary.iloc[0]
            return pd.DataFrame(summary[1:])

    #2 parse case updates
    def parse_updates(self):

        """ method to wrangle case updates information """

        # initial objects for parser
        # isolate updates table
        table = self.tables[1]

        # define regex to find table title
        regex3 = re.compile('data', re.IGNORECASE)

        ### for loop to find table indexes
        # find all rows in table
        rows = table.find_all('tr')

        # define counter for finding the first row to parse
        i = -1

        # loop incrementing row index
        for row in rows:
            i += 1
            if row.find_all(text = regex3) != []:
                i += 1
                break

        ### for loop to extract table text and build dataset
        # defined case updates
        updates = []

        # build table
        for row in rows:
            # extract information in each line
            line = [td.text for td in row.find_all('td')]
            # append to empty object
            updates.append(line)

        # build database
        updates = updates[i:len(rows)]

        # transform into pandas dataframe
        updates = pd.DataFrame(updates)

        # remove weird characters
        updates = updates.replace(self.regex0, ' ', regex = True)
        updates = updates.replace(self.regex1, ' ', regex = True)
        updates = updates.replace(self.regex2, ' ', regex = True)
        updates = updates.replace(' +', ' ', regex = True)

        # assign column names
        updates.columns = ['zone', 'date', 'update']

        # return outcome
        return pd.DataFrame(updates)

    #3 parse judicial decisions
    def parse_details(self):

        """ method to wrangle case decisions """

        ### initial objects for parser
        # try catch error if table doesn't exist
        try:
            # isolate updates and further tables
            tables = self.tables[2:]

            # define regex to find table title
            regex3 = re.compile('despach|senten|decis', re.IGNORECASE)
            regex4 = re.compile(r'\n', re.IGNORECASE)

            # find the position of tables with decisions
            decisions = [i for i in range(len(tables)) if \
                         re.search(regex3, tables[i].td.get_text())]

            # define empty lists for position, head, and body of decisions
            shead = []
            sbody = []

            # for loop extracting the positions and the content of sentence head
            for i in decisions:
                # create empty list of head and body of decisions per table
                spos  = []
                tbody = []
                # define total number of rows per table
                rows  = tables[i].find_all('tr')
                prows = len(tables[i].find_all('tr'))
                # extract sentence head and position per table
                for tr, x in zip(rows, range(prows)):
                    if tr['class'] == ['tdlimpoImpar']:
                        spos.append(x)
                        shead.append(tr.text)
                # add last row in sequence
                spos.append(prows)
                # extract sentence body per head per table
                for y, z in zip(spos[:-1], range(len(spos[:-1]))):
                    tbody.append([y + 1, spos[z + 1]])
                    # subset sentences per head
                    for t in tbody:
                        decision = [rows[w].text for w in range(t[0], t[1])]
                        decision = ''.join(decision[:])
                    # bind decisions as the same length as head
                    sbody.append(decision)

            # build database taking into account potential parsing failures
            nrow = max(len(shead), len(sbody))

            # define the number of observations
            bindhead = ['Parsing Failure'] * (nrow - len(shead))
            bindbody = ['Parsing Failure'] * (nrow - len(sbody))

            # bind at the end of lists
            shead.extend(bindhead)
            sbody.extend(bindbody)

            # build corrected dataset
            sentences = pd.DataFrame(list(zip(shead, sbody)))

            # remove weird characters
            sentences = sentences.replace(self.regex0, ' ', regex = True)
            sentences = sentences.replace(self.regex1, ' ', regex = True)
            sentences = sentences.replace(self.regex2, ' ', regex = True)
            sentences = sentences.replace(' +', ' ', regex = True)

            # assign column names
            sentences.columns = ['head', 'body']

            # return outcome
            return pd.DataFrame(sentences)

        # throw error if table is not available
        except:
            return 'There are no sentence details here.'

    #4 parse related cases
    def parse_related_cases(self):

        """ method to wrangle case decisions """

        ### initial objects for parser
        # try catch error if table doesn't exist
        try:
            tables = self.tables[2:]

            # define regex to find table title
            regex3 = re.compile('apensad', re.IGNORECASE)
            regex4 = re.compile(r'\n', re.IGNORECASE)

            # find the position of tables with decisions
            decisions = [i for i in range(len(tables)) if \
                         re.search(regex3, tables[i].td.get_text())]

            # define empty list of docs
            relatedcases = []

            # for loop finding references to all related cases
            for tr in tables[decisions[0]].find_all('tr')[1:]:
                td  = [td.text for td in tr.find_all('td')]
                relatedcases.append(td)

            # find url just in case and subset the duplicates to unique values
            url = [a['href'] for a in tables[decisions[0]].find_all('a')]
            url = [x for x, y in zip(url, range(len(url))) if int(y) % 2 != 0]

            # append link at the end of the table
            for x, i in zip(range(len(relatedcases[1:])), range(len(url))):
                relatedcases[x + 1].append(url[i])

            # build corrected dataset
            relatedcases = pd.DataFrame(relatedcases[1:])

            # remove weird characters
            relatedcases = relatedcases.replace(self.regex0, ' ', regex = True)
            relatedcases = relatedcases.replace(self.regex1, ' ', regex = True)
            relatedcases = relatedcases.replace(self.regex2, ' ', regex = True)
            relatedcases = relatedcases.replace(' +', ' ', regex = True)

            # assign column names
            relatedcases.columns = ['casetype', 'casenumber', 'caseurl']

            # return outcome
            return pd.DataFrame(relatedcases)

        # throw error if table is not available
        except:
            return 'There are related cases here.'

    #5 parse related documents
    def parse_related_docs(self):

        """ method to parse related docs into a single dataset """

        ### initial objects for parser
        # try catch error if table doesn't exist
        try:
            # isolate updates and further tables
            tables = self.tables[2:]

            # define regex to find table title
            regex3 = re.compile('Documentos', re.IGNORECASE)
            regex4 = re.compile(r'\n', re.IGNORECASE)

            # find the position of tables with decisions
            decisions = [i for i in range(len(tables)) if \
                         re.search(regex3, tables[i].td.get_text())]

            # define empty list of docs
            docs = []

            # for loop finding references to all docs
            for tr in tables[decisions[0]].find_all('tr')[1:]:
                td = [td.text for td in tr.find_all('td')]
                docs.append(td)

            # build corrected dataset
            docs = pd.DataFrame(docs[1:])

            # remove weird characters
            docs = docs.replace(self.regex0, ' ', regex = True)
            docs = docs.replace(self.regex1, ' ', regex = True)
            docs = docs.replace(self.regex2, ' ', regex = True)
            docs = docs.replace(' +', ' ', regex = True)

            # assign column names
            docs.columns = ['reference', 'type']

            # return outcome
            return pd.DataFrame(docs)

        # throw error if table is not available
        except:
            return 'There are related docs here.'

    #6 return full table
    def parse_all(self):

        """ method to parse all tables into a single dataset """

        ### call other parser functions
        # parse tables we know exist
        table1 = self.parse_summary(transpose = True)
        table2 = self.parse_updates()

        # insert column for identifying case information (updates)
        table2.insert(0, 'caseinfo', 'updates')

        # parse tables we are not sure exist
        # try catch if tables don't exist
        # table three
        try:
            # parse case details table
            table3 = self.parse_details()

            # insert column for identifying case information (details)
            table3.insert(0, 'caseinfo', 'details')

            # bind onto previous tables
            table2 = pd.concat([table2, table3], \
                               axis = 0, ignore_index = True, sort = False)
        # skip error if table doesn't exist
        except:
            pass

        # table four
        try:
            # parse related cases table
            table4 = self.parse_related_cases()

            # insert column for identifying case information (related cases)
            table4.insert(0, 'caseinfo', 'relatedcases')

            # bind onto previous tables
            table2 = pd.concat([table2, table4], \
                               axis = 0, ignore_index = True, sort = False)
        # skip error if table doesn't exist
        except:
            pass

        # table five
        try:
            # parse related docs table
            table5 = self.parse_related_docs()

            # insert column for identifying case information (related docs)
            table5.insert(0, 'caseinfo', 'relateddocs')

            # bind onto previous tables
            table2 = pd.concat([table2, table5], \
                               axis = 0, ignore_index = True, sort = False)
        # skip error if table doesn't exist
        except:
            pass

        # create list of column names
        names = list(table1)
        names.extend(list(table2))

        # bind everything together
        table = pd.concat([table1]*len(table2), ignore_index = True)
        table = pd.concat([table, table2], axis = 1, ignore_index = True)

        # reassign column names
        table.columns = names

        # reorder table columns
        ordered = [names[9]]
        ordered.extend(names[0:8])
        ordered.extend(names[10:])

        # change order of columns
        table = table[ordered]

        # return outcome
        return table
