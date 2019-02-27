### tse electoral crime html parser
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
import codecs
import glob
import numpy as np
import os
import pandas as pd
import re
import shutil
import multiprocessing as mp
import importlib
import random

# import third-party libraries
import tse
importlib.reload(tse)

# define clear function
clear = lambda: os.system('clear')

# load list of files to parse
regex = re.compile('(?<=run/)[^a-z]+[0-9]+(?=\\.html)')
files = glob.glob('./html-first-run/*.html')
files = list(filter(regex.search, files))

# try random file
files = random.sample(files, 20)

# loop over files, parse summary and bind
for i, file in enumerate(files):
    pd.DataFrame.from_dict(tse.parser(file).parse_details()).T

tse.parser(files[18]).parse_details()

files[6]




