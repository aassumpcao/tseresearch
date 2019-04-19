### electoral crime and performance paper
#   this script practices text classification algorithms
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
import codecs
import glob
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import re
import os
from io import StringIO
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.manifold import TSNE

# define clear function
clear = lambda: os.system('clear')

# list all files which should be loaded
files = glob.glob('bbc/*/*.txt', recursive = True)
rgex1 = re.compile('(?<=bbc/).*(?=/[0-9]{3,4}.txt)')
rgex2 = re.compile('[0-9]{3,4}.txt')

# load all article information as list
articles = [codecs.open(file, 'r', 'cp1252').read() for file in files]
classes  = [re.search(rgex1, file)[0] for file in files]
filename = [re.search(rgex2, file)[0] for file in files]

# create dataset
df = pd.DataFrame({'classes': classes, 'filename': filename,
                   'content': articles})

# create classes
df['classes_id'] = df['classes'].factorize()[0]

# create new variables and dictionaries
classes_id_df = df[['classes', 'classes_id']].drop_duplicates()
classes_id_df = classes_id_df.sort_values('classes_id').reset_index(drop =True)
classes_to_id = dict(classes_id_df.values)
id_to_classes = dict(classes_id_df[['classes_id', 'classes']].values)

# check dataset
df.sample(5, random_state = 0)

### create tf-idf measures to inspect data
# pass kwargs to tf-idf vectorizer to construct a measure of word
# importance
kwargs = {'sublinear_tf': True, 'min_df': 5, 'stop_words': 'english',
          'encoding': 'cp1252', 'ngram_range': (1, 2), 'norm': 'l2'}

# create tf-idf vector
tfidf = TfidfVectorizer(**kwargs)

# create features vector (words) and classes
features = tfidf.fit_transform(df.content).toarray()
labels = df.classes_id

# check dimensionality of data:
# each of our 2225 documents is now represented by 14415 features,
# representing the tf-idf score for different unigrams and bigrams.
features.shape

# reduce dimensionality of features to produce 2D graph of the tf-idf
# vector for the various classes
# define sample size
SAMPLE_SIZE = int(len(features) * 0.3)

# set seed so that we can easily recover the same results in later
# interactions
np.random.seed(0)

# indices of randomly sampled rows
indices = np.random.choice(range(len(features)), size = SAMPLE_SIZE,
                           replace = False)

# project features using t-sne technique
projected_features = TSNE(n_components = 2, random_state = 0)
projected_features = projected_features.fit_transform(features[indices])

# define graphical parameters
colors = ['pink', 'green', 'midnightblue', 'orange', 'darkgrey']

# produce plot elements
for classes, classes_id in sorted(classes_to_id.items()):
    points = projected_features[(labels[indices] == classes_id).values]
    plt.scatter(points[:, 0], points[:, 1], s = 30, c = colors[classes_id],
                label = classes)

# print graph
plt.title('tf-idf feature vector for each article, projected on 2 dimensions.',
          fontdict = dict(fontsize = 15))

# include legend and display to screen
plt.legend()
plt.show()

### train and test models
#
