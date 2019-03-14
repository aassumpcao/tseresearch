### tse electoral crime html check
# this scripts checks the html files downloaded in two stages. i check
#   the pre-defense data against the post-defense data after updating
#   the tse module
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import glob
import os
import pandas as pd
import re
import shutil

# define clear function
clear = lambda: os.system('clear')

# copy files to 'html-first-run' folder so as to keep backup copies
older = glob.glob('./html-zero/**/*.html', recursive = True)
os.mkdir('./html-first-run')

# run loop moving files
for file in older: shutil.copy(file, './html-first-run')

# import list of downloaded files and their names
older = glob.glob('./html-first-run/*.html', recursive = True)
newer = glob.glob('./html-second-run/*.html', recursive = True)
cases = pd.read_csv('caseNumbers.csv', index_col = False).reset_index()
numbs = cases.drop('index', 1)
csvs  = glob.glob('./html-second-run/*.csv')

### wrangle old files first
# subset pandas dataset using years for which I have downloaded cases
cases = cases[(cases['electionYear'] == 2012)|(cases['electionYear'] == 2016)]

# recreate list of older cases downloaded
protnum = re.compile('(?<=nprot=)(.)+(?=&)')
urls = cases[['protNum', 'candidateID', 'scraperID']]

# create new column of filenames
urls['files'] = [re.search(protnum, prot).group() for prot in urls['protNum']]
urls['files'] = urls['files'] + '-' + urls['candidateID'].astype(str)
urls = urls.reset_index(drop = True)

# create dataset of file names
stripfile = re.compile('(\\./html-first-run/prot)|(\\.html)')
files = [(file, re.sub(stripfile, '', file)) for file in older]
files = pd.DataFrame(files)
files.columns = ['path', 'files']

# join scraperID onto filename dataset (by first defining args for join)
kwargs = {'how': 'left', 'on': 'files', 'validate': 'many_to_many'}
changes = files.merge(urls, **kwargs)
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
# define regex to exclude error files and filter down to valid files
regex = re.compile('(?<=run/)[^a-z]+[0-9]+(?=\\.html)')
older = glob.glob('./html-first-run/*.html')
older = list(filter(regex.search, older))

# transform old file list to data frame so as to compare to new files
older = pd.DataFrame(older)
scraperID = [re.search(regex, file).group() for file in older[0]]
older['scraperID'] = scraperID

# transform new file list to data frame so as to compare to old files
newer = pd.DataFrame(newer)
scraperID = [re.search(regex, file).group() for file in newer[0]]
newer['scraperID'] = scraperID

# check missing files in old files directory
set(newer['scraperID']) - set(older['scraperID'])

# join and create move data frame so as to pull the missing files in new
# directory and send them to old directory
kwargs = {'how': 'left', 'on': 'scraperID'}
move = newer.merge(older, **kwargs)
move = move[move['0_y'].isnull()]['0_x'].tolist()

# loop over new files list and send to old directory
for file in move: shutil.copy(file, './html-first-run')

### wrangle list of download status
# create args vector containing criteria to load each csv file
kwargs = {'index_col': False, 'usecols': [1, 2]}

# load all datasets and drop successful downloads
downloads = pd.concat([pd.read_csv(csv, **kwargs) for csv in csvs])
downloads = downloads.reset_index(drop = True).drop('index', 1)
downloads.columns = ['scraperID', 'status']

### check against caseNumbers data frame produced by R
# join download status
kwargs = {'how': 'left', 'on': 'scraperID'}
status = numbs.merge(downloads, **kwargs)
status = status[status['status'] != 'Download successful']
status.reset_index(drop = True).to_csv('./data/missingCandidates.csv')
