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

# import scikit-learn libraries
from imblearn.over_sampling          import SMOTE
from sklearn.feature_selection       import SelectKBest, chi2
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection         import cross_validate, train_test_split
from sklearn.naive_bayes             import MultinomialNB
from sklearn.metrics                 import accuracy_score, roc_auc_score

# parse command line arguments
op = OptionParser()
op.add_option('--chi2_select', action = 'store', type = 'int')
opts, args = op.parse_args()

# define clear function
clear = lambda: os.system('clear')

# load dataset
tse = pd.read_csv('data/tsePredictions.csv', dtype = 'str')

# rename class variable and create factors out of classes
tse['classID'] = tse['class'].factorize()[0]

# create holdout dataset
predictions = tse[['sbody', 'classID']]

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
if opts.chi2_select:
    chi_sqrd = SelectKBest(chi2, k = opts.chi2_select)
    features = chi_sqrd.fit_transform(features, labels)

# # 1. find out how to fit_transform when data don't have labels
# # 2.


# # split data for testing script (not necessary for training model)
# prediction, predicted = tse[tse['classID'] == -1], tse[tse['classID'] != -1]

# # reset indexes
# prediction.reset_index(drop = True, inplace = True)
# predicted.reset_index(drop = True, inplace = True)

# build model
naive_bayes = MultinomialNB()

# fit features onto classes
naive_bayes.fit(X_train, y_train)

# predict classes
y_pred = naive_bayes.predict(features_2012)
y_pred_proba = naive_bayes.predict_proba(features2012)

# naive_bayes: save predicted values and probabilities to file
np.savetxt('data/y_pred_proba.txt', y_pred_proba, '%f', ',')
np.savetxt('data/y_pred.txt', y_pred, '%d', ',')

# xgboost: load predicted values and probabilities onto python
y_pred_proba = np.loadtxt('data/y_pred_proba.txt', delimiter = ',')
y_pred = np.loadtxt('data/y_pred.txt')

# # create new datasets with observed and predicted classes
# tseObserved  = pd.DataFrame({
#     'rulingClass': labels[:split], 'scraperID': trainScraper
# })
# tsePredicted = pd.DataFrame({
#     'svmPred': y_pred_svm, 'xgPred': y_pred_xg, 'scraperID': testScraper
# })

# # join arrays
# arrays = [y_pred_proba_xg, y_pred_proba_svm]

# # create new dataset with the class probability from svm and xg algos
# tseClassProb = pd.concat([pd.DataFrame(array) for array in arrays], axis = 1)

# # rename dataset columns
# tseClassProb.columns = [
#     'xgClass0Prob', 'xgClass1Prob', 'xgClass2Prob', 'xgClass3Prob',
#     'svmClass0Prob', 'svmClass1Prob', 'svmClass2Prob', 'svmClass3Prob'
# ]

# # add scraperID column
# tseClassProb['scraperID'] = testScraper.reset_index(drop = True)

# # save to file
# saveargs = {'index': False, 'float_format': '%f'}
# tseObserved.to_csv('data/tseObserved.csv', **saveargs)
# tsePredicted.to_csv('data/tsePredicted.csv', **saveargs)
# tseClassProb.to_csv('data/tseClassProb.csv', **saveargs)
