### tse candidacy cases scraper
# this script fixes manual problems in earlier downloads
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import os
import pandas as pd
import re

# define function to clear screen of interactive session
clear = lambda: os.system('clear')

# load earlier candidate files
candidates = pd.read_csv('data/candidatesPending.csv')
candidates_full = pd.read_csv('data/candidates1.csv', dtype = str)

# find and load csv files (with errors)
casenumbers = pd.read_csv('data/casenumbers.csv')
casenumbers.shape

# drop duplicates
casenumbers = casenumbers.drop_duplicates('candidateID')
urls = casenumbers['url'].to_list()

### 1. download errors
# isolate cases which should be downloaded again
rx = re.compile(r'timeout|Crashed')
redownload = [i for i, url in enumerate(urls) if re.search(rx, url)]
redownload = casenumbers.loc[redownload, 'candidateID'].to_list()
redownload = candidates[candidates['candidateID'].isin(redownload)]

### 2. missing candidates
# isolate cases which should be tried again because I skipped them
alldownloads = casenumbers['candidateID'].to_list()
missing = candidates[~candidates['candidateID'].isin(alldownloads)]

# save them to disk and run scraper again
scrapeagain = pd.concat([redownload, missing], ignore_index = True)
scrapeagain.to_csv('data/casenumbers_scrapeagain.csv', index = False)

# load results
scrapedagain = pd.read_csv('data/casenumbers_scrapedagain.csv')
scrapedagain = scrapedagain.drop(scrapedagain.index[range(8, 13)])
scrapedmanually = pd.read_csv('data/casenumbers_scrapedmanually.csv')
scrapedagain = pd.concat([scrapedagain, scrapedmanually], ignore_index = True)

### 3. broken links
# isolate cases where the link is broken
rx = re.compile(r'stale|null|undefined')
brokenlinks = [i for i, url in enumerate(urls) if re.search(rx, url)]
brokenlinks = casenumbers.loc[brokenlinks, 'candidateID'].to_list()

# load csv with corrections
casenumbers_brokenlinks = pd.read_csv('data/casenumbers_brokenlinks.csv')

### 4. fix everything
# work with original dataset, drop problems, and merge solutions
rx = re.compile(r'timeout|Crashed|stale|null|undefined')
observations = casenumbers['url'].to_list()
drop = [i for i, case in enumerate(observations) if re.search(rx, case)]
casenumbers = casenumbers.drop(casenumbers.index[drop])
casenumbers = pd.concat(
    [casenumbers, scrapedagain, casenumbers_brokenlinks], ignore_index = True
)

# check problems and find last missing observations
old = candidates['candidateID'].to_list()
new = casenumbers['candidateID'].to_list()
missing = list(set(old) - set(new))

# save to file, scrape them again
missing = candidates[candidates['candidateID'].isin(missing)]
missing.to_csv('data/casenumbers_missing.csv', index = False)

# load solutions
fixedmissing = pd.read_csv('data/casenumbers_fixedmissing.csv')
casenumbers = casenumbers.drop_duplicates('candidateID')
casenumbers = pd.concat([casenumbers, fixedmissing], ignore_index = True)

# save to file
casenumbers.to_csv('data/casedecision_list.csv', index = False)
