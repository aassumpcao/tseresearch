### electoral crime and performance paper
# judicial decisions script
#  this script transforms the words in sentences into document term
#  matrices with tf-idfs and counts
# andre assumpcao
# andre.assumpcao@gmail.com

# import statements
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
import codecs, os, re
import numpy as np, scipy.sparse as sparse
import pandas as pd

# define function to load the data
def load_tse():
    df = pd.read_csv('data/tsePredictions.csv', dtype = str)
    df['classID'] = df['class'].factorize()[0]
    df = df.sort_values('classID').reset_index(drop = True)
    return df

# define function to load stopwords
def load_stopwords():
    stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8')
    stopwords = stopwords.read().split('\n')[:-1]
    return stopwords

# define keyword arguments to initialize vectorizers:
def create_kwargs():
    return {
        'sublinear_tf': True, 'min_df': 5, 'stop_words': load_stopwords(),
        'encoding': 'utf-8', 'ngram_range': (1, 2), 'norm': 'l2'
    }, {
        'min_df': 5, 'stop_words': load_stopwords(), 'encoding': 'utf-8',
        'ngram_range': (1, 2)
    }

# define main program block
if __name__ == '__main__':

    # load dataset and get indexes for classification sample
    tse = load_tse()
    split = len(tse[tse['classID'] == -1])

    # save kwargs for each vectorization function
    kwargs1, kwargs2 = create_kwargs()

    # initialize the the vectorizers (tf-idf for six classification algos
    #  and counts for deep neural networks)
    tfidf, count = TfidfVectorizer(**kwargs1), CountVectorizer(**kwargs2)

    # create tf-idf vector, create vector, print dimensions
    print('\ntfidf transformation initiated')
    tfidf_features = tfidf.fit_transform(tse.sbody).toarray()
    print('rows, features: {}'.format(tfidf_features.shape))

    # create count vector, create vector, print dimensions
    print('\ncount transformation initiated')
    count_features = count.fit_transform(tse.sbody).toarray()
    print('rows, features: {}'.format(count_features.shape))

    # split cross-validation and prediction samples
    tfidf_features_cv = tfidf_features[split:]
    count_features_cv = count_features[split:]
    tfidf_features_pr = tfidf_features[:split]
    count_features_pr = count_features[:split]

    # convert to sparse matrix
    sparse_matrix_tfidf_cv = sparse.csc_matrix(tfidf_features_cv)
    sparse_matrix_count_cv = sparse.csc_matrix(count_features_cv)
    sparse_matrix_tfidf_pr = sparse.csc_matrix(tfidf_features_pr)
    sparse_matrix_count_pr = sparse.csc_matrix(count_features_pr)

    # save to disk
    sparse.save_npz('data/features_tfidf_cv.npz', sparse_matrix_tfidf_cv)
    sparse.save_npz('data/features_count_cv.npz', sparse_matrix_count_cv)
    sparse.save_npz('data/features_tfidf_pr.npz', sparse_matrix_tfidf_pr)
    sparse.save_npz('data/features_count_pr.npz', sparse_matrix_count_pr)




