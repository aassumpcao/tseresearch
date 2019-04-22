### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse
#   website. we use the textual info in the sentences to determine the
#   (class) allegations against individual candidates running for office
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import standard libraries
import codecs
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import seaborn as sns

# import scikit-learn libraries
from imblearn.over_sampling          import SMOTE
from sklearn.ensemble                import AdaBoostClassifier
from sklearn.ensemble                import GradientBoostingClassifier
from sklearn.ensemble                import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model            import LogisticRegression
from sklearn.model_selection         import cross_validate, train_test_split
from sklearn.naive_bayes             import MultinomialNB
from sklearn.svm                     import SVC

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
labels   = tse.classID
candIDs  = tse.scraperID

# check dimensionality of data: 16,199 rows; 103,968 features
features.shape

# split up features and labels so that we have two datasets: one in
# which we know sentence class and one in which we don't know sentence
# class
trainFeatures = features[:split]
trainLabels   = labels[:split]
trainTse      = tse[:split]
testFeatures  = features[split:]
testLabels    = labels[split:]
testTse       = tse[split:]
testCandIDs   = candIDs[split:]

# oversample train data so that we have fairly balanced classes for
# training models
sm = SMOTE()
trainFeatures, trainLabels = sm.fit_sample(trainFeatures, trainLabels)

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

# set the number of cross-validation folds
CV = 5

# create empty list to store model results
entries = []

# create list of cross validation arguments outside of function
cvkwargs = {'X': trainFeatures, 'y': trainLabels, 'n_jobs': -1, 'verbose': 2,
            'scoring': {'acc': 'accuracy', 'f1micro': 'f1_micro'}, 'cv': CV,
            'return_train_score': True}

# run cross-validation for all models (> 10 hours of execution time)
for model in models:
    # extract model name from model attribute
    mname = model.__class__.__name__
    # compute accuracy scores across cross-validation exercise
    metrics = cross_validate(model, **cvkwargs)
    # add model name to dictionary of results
    metrics['model'] = [mname] * 5
    # append results to entries list
    entries.append(metrics)
    # print loop progress
    print(str(mname) + ' computation concluded.')

# fill in the cross-validation dataset and save to file
performance = pd.concat([pd.DataFrame(entry) for entry in entries])
performance.to_csv('data/modelPerformance.csv', index = False)

# # load dataset after running everything else on longleaf
# performance = pd.read_csv('data/modelPerformance.csv')

# 1. accuracy produce boxplots depicting model performance
sns.boxplot(x = 'model', y = 'train_acc', data = performance)
sns.stripplot(x = 'model', y = 'train_acc', data = performance,
              size = 8, jitter = True, edgecolor = 'gray', linewidth = 2)

# display plot
plt.show()
plt.savefig('analysis/cvTrainAccuracy.png')

# 2. f1_micro: produce boxplots depicting model performance
sns.boxplot(x = 'model', y = 'train_f1micro', data = performance)
sns.stripplot(x = 'model', y = 'train_f1micro', data = performance, size = 8,
              jitter = True, edgecolor = 'gray', linewidth = 2)

# display plot
plt.show()
plt.savefig('analysis/cvTrainAccuracy.png')

### test models
# here, we are implementing the preferred algorithm on the train data,
# which was held out during the training process.

# call best performing model: xgboost
model = GradientBoostingClassifier(learning_rate = 1, verbose = 1)

# produce train, test, and split elements to subset the dataset
train = train_test_split(trainFeatures, trainLabels, trainTse.index,
                         test_size = 0, shuffle = False)
test  = train_test_split(testFeatures, testLabels, testTse.index,
                         test_size = 1, shuffle = False)

# subset train data
x_train, y_train, indices_train = train[:-1:2]

# fit features to classes in train dataset
model.fit(x_train, y_train)

# subset test data
x_test, y_test, indices_test = test[:-1:2]

# predict y's and their probabilities using x's in test data
y_pred_proba = model.predict_proba(x_test)
y_pred = model.predict(x_test)

# save predicted values and probabilities to file
np.savetxt('data/y_pred_proba.txt', y_pred_proba, '%f', ',')
np.savetxt('data/y_pred.txt', y_pred, '%d', ',')

# load predicted values and probabilities onto python
y_pred_proba = np.loadtxt('data/y_pred_proba.txt', ',')
y_pred = np.loadtxt('data/y_pred.txt', ',')

