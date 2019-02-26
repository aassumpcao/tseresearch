### tse electoral crime html parser
# developed by:
# andre assumpcao
# andre.assumpcao@gmail.com

# import standard libraries
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
file = random.sample(files, 1)

# loop over files, parse summary and bind
kwargs = {'transpose': True}

for i, file in enumerate(files):
    tse.parser(file).parse_summary(**kwargs)
    print(i)



