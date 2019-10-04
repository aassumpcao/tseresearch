### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse
#   website. we use the textual info in the sentences to determine the
#   (class) allegations against individual candidates running for office
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import standard libraries
import codecs, os, random
import numpy as np, pandas as pd
import argparse

# import scikit-learn libraries
from imblearn.over_sampling import SMOTE
from sklearn.feature_selection import SelectKBest, chi2
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB

# parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--chi2_select', action = 'store', type = int)
args = parser.parse_args()

# load dataset
tse = pd.read_csv('data/tsePredictions.csv', dtype = 'str')
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factors out of classes
tse['classID'] = tse['class'].factorize()[0]
tse = tse.sort_values('classID').reset_index(drop = True)
split = len(tse[tse['classID'] == -1])

# create holdout dataset
predictions = tse[['sbody', 'classID', 'candidateID']]

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
features = tfidf.fit_transform(predictions.sbody).toarray()
labels = predictions['classID']
identifiers = predictions['candidateID']

# change the number of features according to tests
if args.chi2_select:
    chi_sqrd = SelectKBest(chi2, k = args.chi2_select)
    features = chi_sqrd.fit_transform(features, labels)

# # 1. find out how to fit_transform when data don't have labels
# # 2.
# split up features and labels so that we have two train and teste sets
X_train, y_train, id_train = features[split:], labels[split:], identifiers[split:]
X_test, y_test, id_test = features[:split], labels[:split], identifiers[:split]

# oversample train data so that we have fairly balanced classes for
# training models
sm = SMOTE()
X_train, y_train = sm.fit_sample(X_train, y_train)

# build model
naive_bayes = MultinomialNB()

# fit features onto classes
naive_bayes.fit(X_train, y_train)

# predict classes
y_pred = naive_bayes.predict(X_test)
y_pred_proba = naive_bayes.predict_proba(X_test)

# naive_bayes: save predicted values and probabilities to file
np.savetxt('data/y_pred_proba.txt', y_pred_proba, '%f', ',')
np.savetxt('data/y_pred.txt', y_pred, '%d', ',')

# create new datasets with observed and predicted classes
tseObserved  = pd.DataFrame({
    'class': labels[split:], 'class_prob': [1] * len(labels[split:]),
    'candidateID': id_train
})
tsePredicted = pd.DataFrame({
    'class': y_pred, 'class_prob': [y[0] for y in y_pred_proba],
    'candidateID': id_test
})

# create new dataset with the class probability from svm and xg algos
tseClasses = pd.concat([tseObserved, tsePredicted], ignore_index = True)

# save to file
saveargs = {'index': False, 'float_format': '%f'}
tseClasses.to_csv('data/tseClasses.csv', **saveargs)
