### electoral crime and performance paper
# judicial decisions script
#  this script wrangles the judicial decisions via deep neural networks
# andre assumpcao
# andre.assumpcao@gmail.com

# import tf and scikit-learn libraries
from imblearn.over_sampling import SMOTE
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from tensorflow import keras
import tensorflow as tf

# import helper libraries
import codecs, os, re, random
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# define clear function
clear = lambda: os.system('clear')

# load sentences and stopwords sets
tse = pd.read_csv('data/tsePredictions.csv', dtype = 'str')
stopwords = codecs.open('data/stopwords.txt', 'r', 'utf-8').read().split('\n')
stopwords = stopwords[:-1]

# rename class variable and create factors out of classes
tse['classID'] = tse['class'].factorize()[0]

# create new variables and dictionaries
class_id_tse = tse[['class', 'classID']].drop_duplicates()
class_id_tse = class_id_tse.sort_values('classID').reset_index(drop = True)
class_to_ids = dict(class_id_tse.values)
ids_to_class = dict(class_id_tse[['classID', 'class']].values)

# sort data for later split between classified an unclassified sets
tse = tse.sort_values('classID').reset_index(drop = True)
# split = len(tse[tse['classID'] == -1])

# split data for testing script (not necessary for training model)
prediction, predicted = tse[tse['classID'] == -1], tse[tse['classID'] != -1]

# reduce dimensionality for testing model
prediction, predicted = prediction[:1000], predicted.sample(1000)

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

# check dimensionality of data: 16,199 rows; 103,968 features
'rows, features: {}'.format(features.shape)

# # split data across classified and unclassified sets
# modelFeatures, predictFeatures = features[split:], features[:split]
# modelLabels, predictLabels     = labels[split:], labels[:split]
# modelScraper, predictScraper   = scraper[split:], scraper[:split]

# split up features and labels so that we have two train and teste sets
tts = {'test_size': 0.20, 'random_state': 42}
X_train, X_test, y_train, y_test = train_test_split(features, labels, **tts)

# oversample train data so that we have fairly balanced classes for
# training models
sm = SMOTE()
X_train, y_train = sm.fit_sample(X_train, y_train)

# check shape
'rows, features: {}'.format(X_train.shape)

### build model
# define the network layers, which are built out of the inputs fed to the
# model

# input shape is the vocabulary count used for the movie reviews:
# (10,000 words)
vocab_size = X_train.shape[1]

# create layers and hidden units
model = keras.Sequential([
    keras.layers.Embedding(vocab_size, 16),
    keras.layers.GlobalAveragePooling1D(),
    keras.layers.Dense(16, activation = tf.nn.relu),  # hidden units
    keras.layers.Dense(1, activation = tf.nn.sigmoid) # labels (0 or 1)
])

# check model specifications
model.summary()

# compile metadata: definition of loss function, optimizer, and metrics
# to evaluate results
model.compile(
    loss = 'binary_crossentropy',
    optimizer = 'adam',
    metrics = ['accuracy']
)

# fit model
history = model.fit(
    x = X_train,
    y = y_train,
    batch_size = 512,
    epochs = 40,
    validation_data = (X_test, y_test)
)

# evaluate model
results = model.evaluate(X_test, y_test)
'Test Loss: {}, Test Accuracy: {}'.format(results[0], results[1])

# create graph
history_dict = history.history
history_dict.keys()

# total epochs
epochs = range(1, len(history_dict['accuracy']) + 1)

# build plot
plt.plot(epochs, history_dict['loss'], 'bo', label = 'Training loss')
plt.plot(epochs, history_dict['val_loss'], 'b', label = 'Validation loss')

# define graphical parameters
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend(), plt.show()

# clear figure
plt.clf()

# build plot
plt.plot(epochs, history_dict['accuracy'], 'bo', label = 'Training acc')
plt.plot(epochs, history_dict['val_accuracy'], 'b', label = 'Validation acc')

# define graphical parameters
plt.title('Training and validation accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend(), plt.show()
