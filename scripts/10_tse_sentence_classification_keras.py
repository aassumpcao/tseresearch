### electoral crime and performance paper
# judicial decisions script
#   this script wrangles the judicial decisions downloaded from the tse
#   website. we use the textual info in the sentences to determine the
#   (class) allegations against individual candidates running for office
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
from tensorflow import keras
from tensorflow.nn import relu, sigmoid
from tensorflow.keras.initializers import Constant
import pandas as pd, numpy as np, scipy.sparse as sparse

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
        df.loc[split:, 'candidateID'].to_list(),
        df.loc[:split, 'candidateID'].to_list()
    )

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

    # save candidateIDs
    id_train, id_test = save_candidateID(tse)

    # load features for validation and classification
    features_cv, features_pr = load_features()

    # load word embeddings for validation and classification
    embedding_matrix = load_embedding_layer()

    # input shape is the vocabulary (term) count
    vocab_size = len(embedding_matrix)

    # define parameters for embedding layer
    kwargs = {
        'input_dim': vocab_size, 'output_dim': 300, 'trainable': False,
        'embeddings_initializer': Constant(embedding_matrix)
    }

    # check shape
    print('rows, features: {}'.format(features_pr.shape))

    ####################################################################
    ## load model
    ####################################################################

    # # create layers and hidden units
    # model = keras.Sequential([
    #     keras.layers.Embedding(**kwargs),
    #     keras.layers.GlobalMaxPooling1D(),
    #     keras.layers.Dense(100, activation = relu),
    #     keras.layers.Dense(50, activation = relu),
    #     keras.layers.Dense(1, activation = sigmoid)
    # ])

    # # check model specifications
    # model.summary()

    # # compile metadata: definition of loss function, optimizer, and
    # #  metrics to evaluate results
    # model.compile(
    #     loss = 'binary_crossentropy',
    #     optimizer = 'adam',
    #     metrics = ['accuracy']
    # )

    # # fit model
    # history = model.fit(
    #     x = X_train, y = y_train, batch_size = 256, epochs = 100,
    #     validation_data = (X_test, y_test)
    # )

    ####################################################################
    ## fit model
    ####################################################################

    # predict classes
    y_pred = dnn.predict(features_pr)
    y_pred_proba = dnn.predict_proba(features_pr)

    # naive_bayes: save predicted values and probabilities to file
    np.savetxt('data/y_pred_proba.txt', y_pred_proba, '%f', ',')
    np.savetxt('data/y_pred.txt', y_pred, '%d', ',')

    # create new datasets with observed and predicted classes
    tseObserved = pd.DataFrame({
        'class': labels_cv, 'class_prob': [1] * len(labels_cv),
        'candidateID': id_train
    })
    tsePredicted = pd.DataFrame({
        'class': labels_pr, 'class_prob': [y[0] for y in y_pred_proba],
        'candidateID': id_test
    })

    # create new dataset with the class probability from dnn model
    tseClasses = pd.concat([tseObserved, tsePredicted], ignore_index = True)

    # save to file
    saveargs = {'index': False, 'float_format': '%f'}
    tseClasses.to_csv('data/tseClasses.csv', **saveargs)

# call main function
if __name__ == '__main__':
    main()
