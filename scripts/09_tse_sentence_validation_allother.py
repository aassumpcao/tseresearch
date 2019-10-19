### electoral crime and performance paper
# judicial decisions script
#  this script wrangles the judicial decisions downloaded from the tse
#  website. we use the textual info in the sentences to determine the
#  (class) allegations against individual candidates running for office
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
from imblearn.over_sampling import SMOTE
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.externals import joblib
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.feature_selection import SelectKBest, chi2
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, roc_auc_score
from sklearn.model_selection import cross_validate, train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import LinearSVC
import argparse
import codecs, os, random
import numpy as np, pandas as pd
import scipy.sparse as sparse

# define function to extract arguments from shell
def get_options():
    parser = argparse.ArgumentParser()
    parser.add_argument('--chi2', action = 'store', type = int)
    args = parser.parse_args()
    return args.chi2

# define function to load the data
def load_tse():
    kwargs = {'index_col': False, 'encoding': 'utf-8'}
    df = pd.read_csv('data/tsePredictions.csv', **kwargs)
    df['classID'] = df['class'].factorize()[0]
    df = df.sort_values('classID').reset_index(drop = True)
    return df

# define function to split validation and classification samples
def split_labels_tse(df):
    split = len(df[df['classID'] == -1])
    return (
        df.loc[split:, 'classID'].reset_index(drop = True),
        df.loc[:split, 'classID'].reset_index(drop = True)
    )

# define function to load features into python
def load_features():
    features_cv = sparse.load_npz('data/features_tfidf_cv.npz').toarray()
    features_pr = sparse.load_npz('data/features_tfidf_pr.npz').toarray()
    return features_cv, features_pr

# define main program block
def main():

    # load dataset and split labels for validation and classification
    tse = load_tse()
    labels_cv, labels_pr = split_labels_tse(tse)

    # load features for validation and classification
    features_cv, features_pr = load_features()

    # transform if feature selection is specified
    if get_options():
        chi_sqrd = SelectKBest(chi2, k = get_options())
        features_cv = chi_sqrd.fit_transform(features_cv, labels_cv)
        features_pr = chi_sqrd.transform(features_pr)

    # split up features and labels so that we have train and test sets
    kwargs = {'test_size': 0.20, 'random_state': 42}
    X_train, X_test, y_train, y_test = train_test_split(
        features_cv, labels_cv, **kwargs
    )
    # oversample train data so that classes are balanced training models
    sm = SMOTE()
    X_train, y_train = sm.fit_sample(X_train, y_train)

    # check shape
    print('rows, features: {}'.format(X_train.shape))

    # train models
    # 1. multinomial naive bayes classification (nb)
    # 2. logistic regression (logit)
    # 3. support vector machine (svm)
    # 4. random forest
    # 5. adaptive boosting
    # 6. gradient boosting

    # create list of models used. parameters have already been tuned
    models = [
        MultinomialNB(),
        LogisticRegression(
            solver = 'lbfgs', multi_class = 'auto', max_iter = 500
        ),
        LinearSVC(),
        RandomForestClassifier(n_estimators = 100, max_depth = 3),
        AdaBoostClassifier(n_estimators = 100),
        GradientBoostingClassifier(learning_rate = 1)
    ]

    # create empty list to store model results
    validation, holdouts = [], []

    # create list of cross validation arguments outside function
    kwargs = {
        'X': X_train, 'y': y_train, 'n_jobs': -1, 'verbose': 2, 'cv': 5,
        'scoring': ['accuracy', 'roc_auc'], 'return_train_score': True
    }

    # run training validation for all models (>4 days of execution time)
    for model in models:

        # extract model name from model attribute
        mname = model.__class__.__name__

        # compute accuracy scores across cross-validation exercise
        metrics = cross_validate(model, **kwargs)

        # add model name to dictionary of results
        metrics['model'] = [mname] * 5

        # append results to entries list
        validation += [metrics]

        # print progress
        print('Validation complete for model: ' + str(mname) + '.')

        # fit each model
        model.fit(X_train, y_train)

        # save model
        joblib.dump(model, 'data/' + str(mname) + '.pkl')

        # predict each class
        y_pred = model.predict(X_test)

        # compute accuracy score
        holdout = (
            mname,
            accuracy_score(y_pred, y_test),
            roc_auc_score(y_pred, y_test)
        )

        # compute auc
        holdouts += [holdout]

        # print progress
        print('Hold-out test complete for model: ' + str(mname) + '.')


    # fill in the cross-validation dataset and save to file
    val_performance = pd.concat([pd.DataFrame(val) for val in validation])
    val_performance.to_csv('data/validation_performance.csv', index = False)

    # create dataframe of hold-out performances
    columns = ['model', 'holdout_accuracy', 'holdout_auc']
    holdout_performance = pd.DataFrame(holdouts, columns = columns)
    holdout_performance.to_csv('data/holdout_performance.csv', index = False)

# call main function
if __name__ == '__main__':
    main()
