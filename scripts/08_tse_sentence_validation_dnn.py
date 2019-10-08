### electoral crime and performance paper
# judicial decisions script
#  this script wrangles the judicial decisions via deep neural networks
# andre assumpcao
# andre.assumpcao@gmail.com

# import statements
from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from tensorflow import keras
from tensorflow.keras.initializers import Constant
import pandas as pd, numpy as np, scipy.sparse as sparse
import tensorflow as tf
import random

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
    features_cv = sparse.load_npz('data/features_token_cv.npz').toarray()
    features_pr = sparse.load_npz('data/features_token_pr.npz').toarray()
    return features_cv, features_pr

# define function to load embedding layer
def load_embedding_layer():
    embedding_matrix = sparse.load_npz('data/embedding_matrix.npz').toarray()
    return embedding_matrix

# define main function
def main():

    # load dataset and split labels for validation and classification
    tse = load_tse()
    labels_cv, labels_pr = split_labels_tse(tse)

    # load features for validation and classification
    features_cv, features_pr = load_features()

    # # split random
    # split = random.sample(range(0, len(labels_cv)), 1000)
    # features_cv, labels_cv = features_cv[split], labels_cv.iloc[split,]

    # split up features and labels so that we have two train and test sets
    X_train, X_test, y_train, y_test = train_test_split(
        features_cv, labels_cv, test_size = 0.20, random_state = 42
    )

    # load word embeddings for validation and classification
    embedding_matrix = load_embedding_layer()

    # input shape is the vocabulary (term) count
    vocab_size = len(embedding_matrix)

    # define parameters for embedding layer
    kwargs = {
        'input_dim': vocab_size, 'output_dim': 300, 'trainable': False,
        'embeddings_initializer': Constant(embedding_matrix)
    }

    # oversample train data so that classes are balanced training models
    sm = SMOTE()
    X_train, y_train = sm.fit_sample(X_train, y_train)

    # check shape
    print('rows, features: {}'.format(X_train.shape))

    # create layers and hidden units
    model = keras.Sequential([
        keras.layers.Embedding(**kwargs),
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
        x = X_train, y = y_train, batch_size = 2048, epochs = 100,
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

    # save model to disk
    model.save('data/dnn_model.h5')

# call main function
if __name__ == '__main__':
    main()
