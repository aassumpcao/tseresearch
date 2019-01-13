### tse classes and methods
# developed by:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
import codecs
import glob
import pandas as pd
import re
import os
from bs4 import BeautifulSoup

# define scraper class
class scraper:
    """series of methods to download TSE court documents

    """
    # define browser function
    browser = []

    def __init__(self, url):
        """load into class the url which will be downloaded"""
        self.url = url

    # scraper function when passing everything to scraper
    def tse_decision(self, browser):
        """method to download decision by url"""
        # xpath search patterns
        xpath    = '//*[contains(@value, "Todos")]'
        viewPath = '//*[@value="Visualizar"]'
        errPath  = '//*[text()="Problemas"]'
        
        # get case number
        num = re.search('(?<=nprot=)(.)*(?=&)', self.url).group(0)
        
        # replace weird characters by nothing
        num = re.sub(r'\/|\.|\&|\%|\-', '', num)

        # define browser object
        self.browser = browser
        
        # while loop to load page
        while True:
            try:
                # navigate to url
                self.browser.get(self.url)
                # check if elements are located
                decision = EC.presence_of_element_located((By.XPATH, viewPath))
                # wait up to 3s for last element to be located
                WebDriverWait(self.browser, 3).until(decision)
                # when element is found, click on 'andamento', 'despacho', and
                # 'view' so that the browser opens up the information we want
                decision  = self.browser.find_element_by_xpath(xpath).click()
                visualize = self.browser.find_element_by_xpath(viewPath).click()
                # save inner html to object
                jv = 'return document.getElementsByTagName("html")[0].innerHTML'
                html = self.browser.execute_script(jv)
                # create while loop for recheck
                counter = 1
                while len(html) == 0 | counter < 5:
                    time.sleep(.5)
                    html = self.browser.execute_script(jv)
                    counter += 1
                    break
                fail = 0
                break
            except StaleElementReferenceException as Exception:
                # if element is not in DOM, return to the top of the loop
                continue
            except TimeoutException as Exception:
                # if we spend too much time looking for elements, return to top
                #  of the loop
                error = EC.presence_of_element_located((By.XPATH, errPath))
                if error != '':
                    fail = 1
                    html = 'Nothing found'
                    print('Prot or case ' + str(num) + ' not found')
                    break
                continue

        # different names for files looked up via protocol or case number
        if fail == 1:
            file = './error' + str(num) + '.html'
        else:
            file = './prot' + str(num) + '.html'

        # save to file
        try:
            codecs.open(file, 'w', 'cp1252').write(html)
        except:
            codecs.open(file, 'w', 'utf-8').write(html)

# define parser class
class parser:
    """series of methods to wrangle TSE court documents

    attributes:
        file:   path to html containing the candidacy decision

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
    
    def __init__(self, file):
        """load into class the file which will be parsed"""
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
    def parse_summary(self):
        """method to wrangle summary information"""        
        ### initial objects for parser
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

        # return outcome
        return pd.DataFrame(summary)

    #2 parse case updates
    def parse_updates(self):
        """method to wrangle case updates information"""
        ### initial objects for parser
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
        """method to wrangle case decisions"""
        ### initial objects for parser
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

            # for loop extracting the positions and the content of sentence heads
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
            return 'There are no sentence details here'

    #4 parse related cases
    def parse_related_cases(self):
        return 'empty'

    #5 parse related documents
    def parse_related_docs(self):
        return 'empty'

    #6 return full table
    def parse_all(self):

        ### search for number of tables
        return 'empty'
