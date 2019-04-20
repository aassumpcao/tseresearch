### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse
#   website. we use the textual info in the sentences to determine the
#   (class) allegations against individual candidates running for office
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
from imblearn.over_sampling          import SMOTE
from io                              import StringIO
from sklearn.ensemble                import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model            import LogisticRegression
#from sklearn.manifold                import TSNE
from sklearn.model_selection         import cross_val_score
from sklearn.naive_bayes             import MultinomialNB
from sklearn.model_selection         import train_test_split
from sklearn.metrics                 import confusion_matrix
from sklearn.svm                     import SVC
import codecs
import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import re
# import seaborn as sns

# define clear function
clear = lambda: os.system('clear')

# load dataset
tse = pd.read_csv('data/tse.csv', dtype = 'str')
tse = tse[tse.sbody.notnull()]
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factors out of classes
tse = tse.rename(columns = {'broad.rejection': 'class'})
tse['classID'] = tse['class'].factorize()[0]

# create new variables and dictionaries
class_id_tse = tse[['class', 'classID']].drop_duplicates()
class_id_tse = class_id_tse.sort_values('classID').reset_index(drop = True)
class_to_ids = dict(class_id_tse.values)
ids_to_class = dict(class_id_tse[['classID', 'class']].values)

# sort data by class so that we can manually split dataset later
tse = tse.sort_values('classID', ascending = False).reset_index(drop = True)
split = len(tse[tse['classID'] != -1]) - 1

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

# split up features and labels so that we have two datasets: one in
# which we know sentence class and one in which we don't know sentence
# class
trainfeatures = features[:split]
testfeatures = features[split:]
trainlabels = labels[:split]
testlabels = labels[split:]

# oversample train data so that we have fairly balanced classes for
# training models
sm = SMOTE()
trainfeatures, trainlabels = sm.fit_sample(trainfeatures, trainlabels)

### train and test models
# 1. multinomial naive bayes classification (nb)
# 2. logistic regression (logit)
# 3. support vector machine (svm)
# 4. random forest
# 5. adaptive boosting
# 6. gradient boosting

# create list of models used. their parameters have been tuned already
models = [
    MultinomialNB(alpha = 1),
    LogisticRegression(random_state = 0, solver = 'lbfgs',
                       multi_class = 'auto'),
    SVC(kernel = 'linear', C = 5),
    RandomForestClassifier(n_estimators = 100, max_depth = 3,
                           random_state = 0)
    # adaptive boosting
    # gradient boosting
]

# set the number of cross-validation folds
CV = 5

# create a dataset of the different models at each fold
cv_df = pd.DataFrame(index = range(CV * len(models)))

# create empty list to store model results
entries = []
