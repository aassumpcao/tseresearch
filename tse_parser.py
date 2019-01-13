### tse decision parser
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

# define class
class tse:
    """series of methods to wrangle TSE court documents

    attributes:
        to be completed
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
        # isolate updates and further tables
        try:
            tables = self.tables[2:]

            # define regex to find table title
            regex3 = re.compile('despach|senten|decis', re.IGNORECASE)
            regex4 = re.compile(r'\n', re.IGNORECASE)

            # find the position of tables with decisions
            decisions = [i for i in range(len(tables)) if \
                         re.search(regex3, tables[i].td.get_text())]

            # define empty lists for head and body of decisions
            shead = []
            sbody = []

            # loop over all tables containing decisions
            for i in decisions:
                # extract headers and body for all decisions
                for tr in tables[i].find_all('tr'):
                    if tr['class'] == ['tdlimpoImpar']:
                        shead.append(tr.text)
                    if tr['class'] == ['tdlimpoPar']:
                        sbody.append(tr.text)

            # drop empty columns
            sbody = [i for i in sbody if re.search('.', i)]

            # build database
            if len(shead) == len(sbody):
                sentences = pd.DataFrame(list(zip(shead, sbody)))
            else:
                # fix problems if lists are of unequal length
                nrow = max(len(shead), len(sbody))
                
                # define the number of observations
                bindhead = ['Head Not Available'] * (nrow - len(shead))
                bindbody = ['Body Not Available'] * (nrow - len(sbody))
                
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
            return 'there is no sentence table here'

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
