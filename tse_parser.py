# tse decision parser
# developed by:
# Andre Assumpcao
# andre.assumpcao@gmail.com

# import statements
import codecs
import glob
import pandas as pd
import re
from   bs4    import BeautifulSoup

# define class
class tse_parser:

    #2 parse summary info table:
    def parse_summary(self, file):
        # regex compile for splitting rows
        regex1 = re.compile('\n|\t')
        regex2 = re.compile('  ')
        # call BeautifulSoup to read string as html
        soup = BeautifulSoup(file, 'lxml')
        # find all tables in document
        tables = soup.find_all('table')
        # isolate summary table
        table = tables[0]
        # find all rows in table
        rows = table.find_all('tr')
        # find case, municipality, and protocol information from table
        processo  = [td.text for td in rows[0].find_all('td')]
        municipio = [td.text for td in rows[1].find_all('td')]
        protocolo = [td.text for td in rows[2].find_all('td')]
        # split title and information
        processo  = [processo[0],  ''.join(processo[1:])]
        municipio = [municipio[0], ''.join(municipio[1:])]
        protocolo = [protocolo[0], ''.join(protocolo[1:])]
        # find more complex elements
        #1 find plaintiffs using regex
        regex3 = re.compile('(requere|impugnan|recorren|litis)', re.IGNORECASE)
        # create list of plaintiff information
        plaintiffs = ['plaintiffs']
        # for each row in the summary table:
        for row in rows:
            # find rows that match the plaintiff regex
            if row.find_all(text = regex3) != []:
                # extract all columns and join them into one observation
                plaintiff = [td.text for td in row.find_all('td')]
                plaintiff = ''.join(plaintiff[1:])
                # append to plaintiff list
                plaintiffs.append(plaintiff)
        # format list
        plaintiffs = [plaintiffs[0], ';'.join(plaintiffs[1:])]
                

    # parse html function
    def parse_html(self, file):
        # call BeautifulSoup to read string as html
        soup = BeautifulSoup(file, 'lxml')
        # define table counter
        counter = 0
        # parse each table into tuple
        for table in soup.find_all('table'):
            counter += 1
            return [(counter, self.parse_html_table(table))]

    # parse each table in html file
    def parse_html_table(self, table):
        # define initial table size (0x0)
        ncols = 0
        nrows = 0
        colnames = []
        # find number of columns per row
        for row in table.find_all('tr'):
            # determine the number of columns per row
            columns = row.find_all('td')
            # if table is not empty
            if len(columns) > 0:
                # increment the total number of rows for each iteration
                nrows += 1
                # if this is the first iteration
                if ncols == 0:
                    # Set the number of columns for our table
                    ncols = len(columns)

            # Handle column names if we find them
            th_tags = row.find_all('th')
            if len(th_tags) > 0 and len(colnames) == 0:
                for th in th_tags:
                    colnames.append(th.get_text())

        # Safeguard on Column Titles
        if len(colnames) > 0 and len(colnames) != ncols:
            raise Exception("Column titles do not match the number of columns")

        columns = colnames if len(colnames) > 0 else range(0,ncols)
        df = pd.DataFrame(columns = columns,
                          index= range(0,nrows))
        row_marker = 0
        for row in table.find_all('tr'):
            column_marker = 0
            columns = row.find_all('td')
            for column in columns:
                df.iat[row_marker,column_marker] = column.get_text()
                column_marker += 1
            if len(columns) > 0:
                row_marker += 1

        # Convert to float if possible
        for col in df:
            try:
                df[col] = df[col].astype(float)
            except ValueError:
                pass

        return df
