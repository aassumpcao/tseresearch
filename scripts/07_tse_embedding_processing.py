### electoral crime and performance paper
# judicial decisions script
#  this script transforms the words in sentences into document term
#  matrices with tf-idfs and counts
# andre assumpcao
# andre.assumpcao@gmail.com

# import statements
from sklearn.feature_extraction.text import TfidfVectorizer
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import codecs, os, re
import numpy as np, scipy.sparse as sparse
import pandas as pd
import io

# define function to load the data
def load_tse():
    kwargs = {'index_col': False, 'encoding': 'utf-8'}
    df = pd.read_csv('data/tsePredictions.csv', **kwargs)
    df['classID'] = df['class'].factorize()[0]
    df = df.sort_values('classID').reset_index(drop=True)
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
        'num_words': 100000
    }

# load pretrained vectors
def load_vectors(fname):
    f = io.open(fname, 'r', encoding='utf-8', newline='\n', errors='ignore')
    data = {}
    for line in f.readlines()[1:]:
        tokens = line.rstrip().split(' ')
        data[tokens[0]] = np.asarray(tokens[1:], 'float')
    f.close()
    return data

# define functions to fit word initializers on judicial sentences
def vectorize_sentences(sentences, tfidf, tokenizer):
    tfidf_features = tfidf.fit_transform(sentences).toarray()
    token_features = tokenizer.texts_to_sequences(sentences)
    return (tfidf_features, token_features)

# define main function
def main():

    # load dataset and get indexes for classification sample
    tse = load_tse()
    split = len(tse[tse['classID'] == -1])

    # save kwargs for each vectorization function
    kwargs1, kwargs2 = create_kwargs()

    # initialize the vectorizers (tf-idf for six classification algos
    #  and counts for deep neural networks)
    tfidf, tokenizer = TfidfVectorizer(**kwargs1), Tokenizer(**kwargs2)

    # fit sentences on text
    tokenizer.fit_on_texts(tse.sbody)

    # create tf-idf vector, create vector, print dimensions
    tfidf_features, token_features = \
        vectorize_sentences(tse.sbody, tfidf, tokenizer)

    # define count of unique words (tokens) in sentences
    word_index = tokenizer.word_index

    # create tokenizer vector
    print('rows, features: {}'.format(tfidf_features.shape))
    print('rows, features: ({}, {})'.format(len(tse), len(word_index)))

    # pad sequences such that vectors have 0s where no word is found
    token_features = pad_sequences(token_features)

    # load onto python the embedding vectors (300 dimensions)
    embeddings_index = load_vectors('data/cc.pt.300.vec')

    # create embedding matrix (300 dimensions)
    embedding_matrix = np.zeros((len(word_index) + 1, 300))
    for word, i in word_index.items():
        try:
            embedding_vector = embeddings_index[word]
            embedding_matrix[i] = embedding_vector
        except:
            pass

    # split cross-validation and prediction samples
    tfidf_features_cv = tfidf_features[split:]
    token_features_cv = token_features[split:]
    tfidf_features_pr = tfidf_features[:split]
    token_features_pr = token_features[:split]

    # convert to sparse matrix
    sparse_matrix_tfidf_cv = sparse.csc_matrix(tfidf_features_cv)
    sparse_matrix_token_cv = sparse.csc_matrix(token_features_cv)
    sparse_matrix_tfidf_pr = sparse.csc_matrix(tfidf_features_pr)
    sparse_matrix_token_pr = sparse.csc_matrix(token_features_pr)
    embedding_matrix = sparse.csc_matrix(embedding_matrix)

    # save to disk
    sparse.save_npz('data/features_tfidf_cv.npz', sparse_matrix_tfidf_cv)
    sparse.save_npz('data/features_token_cv.npz', sparse_matrix_token_cv)
    sparse.save_npz('data/features_tfidf_pr.npz', sparse_matrix_tfidf_pr)
    sparse.save_npz('data/features_token_pr.npz', sparse_matrix_token_pr)
    sparse.save_npz('data/embedding_matrix.npz', embedding_matrix)

# define main program block
if __name__ == '__main__':
    main()
