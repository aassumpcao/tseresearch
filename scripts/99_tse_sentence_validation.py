### electoral crime and performance paper
# judicial decisions script
#  this script wrangles the judicial decisions downloaded from the tse
#  website. we use the textual info in the sentences to determine the
#  (class) allegations against individual candidates running for office
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import standard libraries
import codecs, os, random
import numpy as np, pandas as pd

# import scikit-learn machine classification libraries
from imblearn.over_sampling          import SMOTE
from sklearn.ensemble                import AdaBoostClassifier
from sklearn.ensemble                import GradientBoostingClassifier
from sklearn.ensemble                import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model            import LogisticRegression
from sklearn.model_selection         import cross_validate, train_test_split
from sklearn.naive_bayes             import MultinomialNB
from sklearn.svm                     import SVC
from sklearn.metrics                 import accuracy_score, roc_auc_score

# define clear function
clear = lambda: os.system('clear')

# load dataset
tse = pd.read_csv('data/tsePredictions.csv', dtype = 'str')
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factors out of classes
tse['classID'] = tse['class'].factorize()[0]

# sort data for later split between classified an unclassified sets
tse = tse.sort_values('classID').reset_index(drop = True)
# split = len(tse[tse['classID'] == -1])

# split data for testing script (not necessary for training model)
prediction, predicted = tse[tse['classID'] == -1], tse[tse['classID'] != -1]

# # reduce dimensionality for testing model
# prediction, predicted = prediction[:5000], predicted.sample(5000)

# reset indexes
prediction.reset_index(drop = True, inplace = True)
predicted.reset_index(drop = True, inplace = True)

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

# # check dimensionality of data: 16,199 rows; 103,968 features
# '(rows, features): {}'.format(features.shape)

# # split data across classified and unclassified sets
# modelFeatures, predictFeatures = features[split:], features[:split]
# modelLabels, predictLabels     = labels[split:], labels[:split]
# modelScraper, predictScraper   = scraper[split:], scraper[:split]

# split up features and labels so that we have two train and teste sets
kwargs = {'test_size': 0.20, 'random_state': 42}
X_train, X_test, y_train, y_test = train_test_split(features, labels, **kwargs)

# oversample train data so that we have fairly balanced classes for
# training models
sm = SMOTE()
X_train, y_train = sm.fit_sample(X_train, y_train)

# check shape
'(rows, features): {}'.format(X_train.shape)

### train models
# 1. multinomial naive bayes classification (nb)
# 2. logistic regression (logit)
# 3. support vector machine (svm)
# 4. random forest
# 5. adaptive boosting
# 6. gradient boosting

# create list of models used. their parameters have already been tuned
models = [
    MultinomialNB(),
    LogisticRegression(solver = 'lbfgs', multi_class = 'auto', max_iter = 500),
    SVC(kernel = 'linear', verbose = True),
    RandomForestClassifier(n_estimators = 100, max_depth = 3, verbose = 1),
    AdaBoostClassifier(n_estimators = 100),
    GradientBoostingClassifier(learning_rate = 1, verbose = 1)
]

# create empty list to store model results
entries, holdout = [], []

# create list of cross validation arguments outside function
cvkwargs = {
    'X': X_train, 'y': y_train, 'n_jobs': -1, 'verbose': 2, 'cv': 5,
    'scoring': ['accuracy', 'roc_auc'], 'return_train_score': True
}

# run training validation for all models (> 10 hours of execution time)
for model in models:
    # extract model name from model attribute
    mname = model.__class__.__name__
    # compute accuracy scores across cross-validation exercise
    metrics = cross_validate(model, **cvkwargs)
    # add model name to dictionary of results
    metrics['model'] = [mname] * 5
    # append results to entries list
    entries += [metrics]
    # print progress
    print('Validation complete for model: ' + str(mname) + '.')
    # fit each model
    model.fit(X_train, y_train)
    # predict each class
    y_pred = model.predict(X_test)
    # compute accuracy score
    y = (mname, accuracy_score(y_pred, y_test), roc_auc_score(y_pred, y_test))
    # compute auc
    holdout += [y]
    # print progress
    print('Hold-out test complete for model: ' + str(mname) + '.')

# fill in the cross-validation dataset and save to file
validation_performance = pd.concat([pd.DataFrame(entry) for entry in entries])
validation_performance.to_csv('data/validation_performance.csv', index = False)

# print progress
print('Hold-out test complete.')

# create dataframe of hold-out performances
columns = ['model', 'holdout_accuracy', 'holdout_auc']
holdout_performance = pd.DataFrame(holdout, columns = columns)
holdout_performance.to_csv('data/holdout_performance.csv', index = False)
