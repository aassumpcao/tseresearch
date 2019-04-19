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
tse = tse[tse.sbody.notnull()]
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factor
tse = tse.rename(columns = {'broad.rejection': 'class'})
tse['classID'] = tse['class'].factorize()[0]

# create new variables and dictionaries
class_id_tse = tse[['class', 'classID']].drop_duplicates()
class_id_tse = class_id_tse.sort_values('classID').reset_index(drop = True)
class_to_ids = dict(class_id_tse.values)
ids_to_class = dict(class_id_tse[['classID', 'class']].values)

### create tf-idf measures to inspect and transform data
# pass kwargs to tf-idf vectorizer to construct a measure of word
# importance
kwargs = {'sublinear_tf': True, 'min_df': 5, 'stop_words': stopwords,
          'encoding': 'utf-8', 'ngram_range': (1, 2), 'norm': 'l2'}

# create tf-idf vector
tfidf = TfidfVectorizer(**kwargs)

# create features vector (words) and classes
features = tfidf.fit_transform(tse.sbody).toarray()
labels = tse.classID

# check dimensionality of data: 16,199 rows; 103,968 features
features.shape
