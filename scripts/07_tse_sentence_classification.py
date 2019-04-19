### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse website.
#   we use the textual information in the sentences to determine the allegations
#   against individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
from io                              import StringIO
from sklearn.ensemble                import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model            import LogisticRegression
from sklearn.manifold                import TSNE
from sklearn.model_selection         import cross_val_score
from sklearn.naive_bayes             import MultinomialNB
from sklearn.model_selection         import train_test_split
from sklearn.metrics                 import confusion_matrix
from sklearn.svm                     import SVC
import imblearn
import codecs
import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import re
import seaborn as sns

# define clear function
clear = lambda: os.system('clear')

# load dataset
tse = pd.read_csv('data/tse.csv', dtype = 'str')
