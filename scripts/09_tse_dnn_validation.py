### electoral crime and performance paper
# judicial decisions script
#  this script wrangles the judicial decisions via deep neural networks
# andre assumpcao
# andre.assumpcao@gmail.com

# import statements
from imblearn.over_sampling import SMOTE
from sklearn.feature_selection import SelectKBest, chi2
from sklearn.model_selection import train_test_split
from tensorflow import keras
import argparse
import codecs, os, re, random
import pandas as pd, numpy as np, scipy.sparse as sparse
import tensorflow as tf

# define function to extract arguments from shell
def get_options():
    parser = argparse.ArgumentParser()
    parser.add_argument('--chi2', action = 'store', type = int)
    args = parser.parse_args()
    return args.chi2

# define function to load the data
def load_tse():
    df = pd.read_csv('data/tsePredictions.csv', dtype = str)
    df['classID'] = df['class'].factorize()[0]
    df = df.sort_values('classID').reset_index(drop = True)
    return df

# define function to split validation and classification samples
def split_labels_tse(df):
    split = len(df[df['classID'] == -1])
    return df.loc[split:, 'classID'], df.loc[:split, 'classID']

# define function to load features into python
def load_features(tfidf = True):
    if not tfidf:
        features_cv = sparse.load_npz('data/features_count_cv.npz').toarray()
        features_pr = sparse.load_npz('data/features_count_pr.npz').toarray()
    return features_cv, features_pr

# define main program block
if __name__ == '__main__':

    # load dataset and split labels for validation and classification
    tse = load_tse()
    labels_cv, labels_pr = split_labels_tse(tse)

    # load features for validation and classification
    features_cv, features_pr = load_features(tfidf = False)

    # transform if feature selection is specified
    if get_options():
        chi_sqrd = SelectKBest(chi2, k = get_options())
        features_cv = chi_sqrd.fit_transform(features_cv, labels_cv)
        features_pr = chi_sqrd.transform(features_pr)

    # split up features and labels so that we have two train and test sets
    kwargs = {'test_size': 0.20, 'random_state': 42}
    X_train, X_test, y_train, y_test = train_test_split(
        features_cv, labels_cv, **kwargs
    )

    # oversample train data so that classes are balanced training models
    sm = SMOTE()
    X_train, y_train = sm.fit_sample(X_train, y_train)

    # check shape
    print('rows, features: {}'.format(X_train.shape))

    # input shape is the vocabulary (term) count
    vocab_size = X_train.shape[1]

    # create layers and hidden units
    model = keras.Sequential([
        keras.layers.Embedding(vocab_size, 50),
        keras.layers.GlobalMaxPooling1D(),
        keras.layers.Dense(100, activation = tf.nn.relu),
        keras.layers.Dense(50, activation = tf.nn.relu),
        keras.layers.Dense(1, activation = tf.nn.sigmoid)
    ])

    # check model specifications
    model.summary()

    # compile metadata: definition of loss function, optimizer, and
    #  metrics to evaluate results
    model.compile(
        loss = 'binary_crossentropy',
        optimizer = 'adam',
        metrics = ['accuracy']
    )

    # fit model
    history = model.fit(
        x = X_train, y = y_train, batch_size = 32, epochs = 50,
        validation_data = (X_test, y_test)
    )

    # create graph
    history_dict = history.history

    # total epochs
    try:
        epochs = range(1, len(history_dict['accuracy']) + 1)
    except:
        epochs = range(1, len(history_dict['acc']) + 1)

    # save results to disk
    history_dict['epochs'] = epochs
    history_dict = pd.DataFrame(history_dict)
    history_dict.to_csv('data/validation_performance_dnn.csv', index = False)
