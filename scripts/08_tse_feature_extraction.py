### electoral crime and performance paper
# judicial decisions script
#  this script wrangles the judicial decisions via deep neural networks
# andre assumpcao
# andre.assumpcao@gmail.com

# import helper libraries
import codecs, os, re
import numpy as np, scipy.sparse
import pandas as pd

# import tf and scikit-learn libraries
from sklearn.feature_extraction.text import TfidfVectorizer

# define clear function
clear = lambda: os.system('clear')

# load sentences and stopwords sets
tse = pd.read_csv('data/tsePredictions.csv', dtype = 'str')
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factors out of classes
tse['classID'] = tse['class'].factorize()[0]

# split data for testing script (not necessary for training model)
predicted = tse[tse['classID'] != -1].reset_index(drop = True)

### create tf-idf measures to inspect and transform data
# pass kwargs to tf-idf vectorizer to construct a measure of word
# importance
kwargs = {
    'sublinear_tf': True, 'min_df': 5, 'stop_words': stopwords,
    'encoding': 'utf-8', 'ngram_range': (1, 2), 'norm': 'l2'
}

# create tf-idf vector
tfidf = TfidfVectorizer(**kwargs)

# create features vector (words) and classes
features = tfidf.fit_transform(predicted.sbody).toarray()
labels = predicted['classID']
identifiers = predicted['candidateID']

# check dimensionality of data: 16,199 rows; 103,968 features
print('rows, features: {}'.format(features.shape))

# convert to sparse matrix
sparse_matrix = scipy.sparse.csc_matrix(features)
scipy.sparse.save_npz('data/sentenceFeatures.npz', sparse_matrix)
