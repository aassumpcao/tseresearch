import codecs
import glob
import pandas as pd
import re
from   bs4    import BeautifulSoup

# parse file
def parse_summary(file):
        
    ### initial objects for parser
    # regex compile for splitting rows
    regex1 = re.compile('\n|\t', re.MULTILINE)
    regex2 = re.compile('  ')
    # call BeautifulSoup to read string as html
    soup = BeautifulSoup(file, 'lxml')
    # find all tables in document
    tables = soup.find_all('table')
    # isolate summary table
    table = tables[0]
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
    
    # return outcome
    return pd.DataFrame(summary)
