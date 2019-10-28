### electoral crime and performance paper
# judicial decisions script
#  this script uses the trained models to predict sentence categories. i
#  use the textual info in the sentences to determine the (class)
#  allegations against  individual candidates running for office.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
from sklearn.svm import LinearSVC
from sklearn.externals import joblib
import pickle, csv
import pandas as pd
import scipy.sparse as sparse

# define function to load the data
def load_tse():
    kwargs = {'index_col': False, 'encoding': 'utf-8'}
    df = pd.read_csv('data/tsePredictions.csv', **kwargs)
    df['classID'] = df['class'].factorize()[0]
    df = df.sort_values('classID').reset_index(drop = True)
    return df

# define function to save candidateIDs
def save_candidateID(df):
    split = len(df[df['classID'] == -1])
    return (
        df.loc[split:, 'candidateID'].reset_index(drop = True),
        df.loc[:(split-1), 'candidateID'].reset_index(drop = True)
    )

# define function to split validation and classification samples
def split_labels_tse(df):
    split = len(df[df['classID'] == -1])
    return (
        df.loc[split:, 'classID'].reset_index(drop = True),
        df.loc[:(split-1), 'classID'].reset_index(drop = True)
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

    # load features for validation and classification
    labels_cv, labels_pr = split_labels_tse(tse)

    # save candidateIDs
    id_cv, id_pr = save_candidateID(tse)

    # load features for validation and classification
    features_cv, features_pr = load_features()

    # load linear SVC model
    model = joblib.load('data/LinearSVC.pkl')

    # predict classes
    y_pred = model.predict(features_pr)

    # check dimensions of all prediction files
    len(labels_pr) == len(id_pr) == len(features_pr) == len(y_pred)

    # create new datasets with observed and predicted classes
    tseObserved = pd.DataFrame({'class': labels_cv, 'candidateID': id_cv})
    tsePredicted = pd.DataFrame({'class': y_pred, 'candidateID': id_pr})

    # create new dataset with the class probability from dnn model
    tseClasses = pd.concat([tseObserved, tsePredicted], ignore_index = True)

    # save to file
    kwargs = {'index': False, 'quoting': csv.QUOTE_ALL}
    tseClasses.to_csv('data/tseClasses.csv', **kwargs)

# define main program block
if __name__ == '__main__':
    main()
