### electoral crime and performance paper
# judicial decisions script
#  this script transforms the words in sentences into document term
#  matrices with tf-idfs and counts
# andre assumpcao
# andre.assumpcao@gmail.com

# import helper libraries
import codecs, os, re
import numpy as np, scipy.sparse
import pandas as pd

# import tf and scikit-learn libraries
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer

# define clear function
clear = lambda: os.system('clear')

# load sentences and stopwords sets
tse = pd.read_csv('data/tsePredictions.csv', dtype = str)
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factors out of classes
tse['classID'] = tse['class'].factorize()[0]

# split data for testing script (not necessary for training model)
predicted = tse[tse['classID'] != -1].reset_index(drop = True)

### create tf-idf measures to inspect and transform data
# pass kwargs to tf-idf vectorizer to construct a measure of word
# importance
kwargs_tfidf, kwargs_count = {
    'sublinear_tf': True, 'min_df': 5, 'stop_words': stopwords,
    'encoding': 'utf-8', 'ngram_range': (1, 2), 'norm': 'l2'
}, {
    'min_df': 5, 'stop_words': stopwords, 'encoding': 'utf-8',
    'ngram_range': (1, 2)
}

# create tf-idf vector, create vector, print dimensions
print('\ntfidf vectorizer initiated')
tfidf = TfidfVectorizer(**kwargs_tfidf)
tfidf_features = tfidf.fit_transform(predicted.sbody).toarray()
print('rows, features: {}'.format(tfidf_features.shape))

# create count vector, create vector, print dimensions
print('count vectorizer initiated')
count = CountVectorizer(**kwargs_count)
count_features = count.fit_transform(predicted.sbody).toarray()
print('rows, features: {}'.format(count_features.shape))

# convert to sparse matrix
sparse_matrix_tfidf = scipy.sparse.csc_matrix(tfidf_features)
sparse_matrix_count = scipy.sparse.csc_matrix(count_features)
scipy.sparse.save_npz('data/sentenceFeatures_tfidf.npz', sparse_matrix_tfidf)
scipy.sparse.save_npz('data/sentenceFeatures_count.npz', sparse_matrix_count)
