### tse electoral crime html check
# this scripts checks the html files downloaded in two stages. i check
#   the pre-defense data against the post-defense data after updating
#   the tse module
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import glob
import numpy as np
import os
import pandas as pd
import re

# define clear function
clear = lambda: os.system('clear')

# import list of downloaded files and their names
older = glob.glob('./html-first-run/*.html', recursive = True)
newer = glob.glob('./html-second-run/*.html', recursive = True)
cases = pd.read_csv('caseNumbers.csv', index_col = False).reset_index()

### wrangle old files first
# subset pandas dataset using years for which I have downloaded cases
cases = cases[(cases['electionYear'] == 2012)|(cases['electionYear'] == 2016)]

# recreate list of older cases downloaded
protnum = re.compile('(?<=nprot=)(.)+(?=&)')
urls = cases[['protNum', 'candidateID', 'scraperID']]

# create new column of filenames
urls['files'] = [re.search(protnum, prot).group() for prot in urls['protNum']]
urls['files'] = urls['files'] + '-' + urls['candidateID'].astype(str)
urls = urls.reset_index()

# create dataset of file names
stripfile = re.compile('(\\./html-first-run/)|(prot|error)|(\\.html)')
files = [(file, re.sub(stripfile, '', file)) for file in older]
files = pd.DataFrame(files)
files.columns = ['path', 'files']

# join scraperID onto filename dataset (by first defining args for join)
args = {'how': 'left', 'on': 'files', 'validate': 'many_to_many'}
changes = files.merge(urls, **args)
changes = changes.drop(changes.columns[1:5].values.tolist(), 1)

# filter only non-missing rows
changes = changes[changes['scraperID'].notnull()]
changes['scraperID'] = changes['scraperID'].astype(int).astype(str)
changes['scraperID'] = './html-first-run/' + changes['scraperID'] + '.html'

# rename files in directory
for src, dst in zip(changes['path'], changes['scraperID']):
    try:
        os.rename(src, dst)
    except:
        pass

### wrangle new files next


