soup = BeautifulSoup(file, 'lxml')

# find all tables in document
tables = soup.find_all('table')

# isolate summary table
table = tables[0]

# find all rows in table
rows = table.find_all('tr')

# find case, municipality, and protocol information from table
case = [td.text for td in rows[0].find_all('td')]
town = [td.text for td in rows[1].find_all('td')]
prot = [td.text for td in rows[2].find_all('td')]
# split title and information
case = ['case', ''.join(case[1:])]
town = ['town', ''.join(town[1:])]
prot = ['prot', ''.join(prot[1:])]

# find more complex elements

#1 find claimants using regex
regex3 = re.compile('(requere|impugnan|recorren|litis)', re.IGNORECASE)
# create list of claimant information
claimants = ['claimants']
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
claimants = [claimants[0], ';'.join(claimants[1:])]

#2 find plaintiffs using regex
regex4 = re.compile('(requeri|impugnad|recorri|candid)', re.IGNORECASE)
# create list of plaintiff information
plaintiffs = ['plaintiffs']
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
plaintiffs = [plaintiffs[0], ';'.join(plaintiffs[1:])]

#3 find judges using regex
regex5 = re.compile('(ju[íi]z|relator)', re.IGNORECASE)
# create list of judge information
judges = ['judges']
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
judges = [judges[0], ';'.join(judges[1:])]

a = [case, town, prot, claimants, plaintiffs, judges]


import os

os.chdir('.')

file = './html/2012/prot594532012-60000012429.html'

try:
    file = codecs.open(file, 'r', 'cp1252').read()
except:
    file = codecs.open(file, 'r', 'utf-8').read()


from tse_parser import TSEdata as tse

tse(file).parse_summary()
