### electoral crime and performance paper
#   this script practices text classification algorithms
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
from io                              import StringIO
from sklearn.ensemble                import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model            import LogisticRegression
from sklearn.manifold                import TSNE
from sklearn.model_selection         import cross_val_score
from sklearn.naive_bayes             import MultinomialNB
from sklearn.model_selection         import train_test_split
from sklearn.metrics                 import confusion_matrix
from sklearn.svm                     import SVC
import imblearn
import codecs
import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import re
import seaborn as sns

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
# 1. multinomial naive bayes classification (nb)
# 2. logistic regression (logit)
#### 3. support vector machine (svm)
# 4. random forest

# create list of models used. their parameters have been tuned already
models = [
    MultinomialNB(),
    LogisticRegression(random_state = 0, solver = 'lbfgs',
                       multi_class = 'auto'),
    SVC(kernel = 'linear', C = 5),
    RandomForestClassifier(n_estimators = 200, max_depth = 3,
                           random_state = 0)
]

# set the number of cross-validation folds
CV = 5

# create a dataset of the different models at each fold
cv_df = pd.DataFrame(index = range(CV * len(models)))

# create empty list to store model results
entries = []

# loop over list of models and run tests
for model in models:
    # extract model name from model attribute
    model_name = model.__class__.__name__
    # compute accuracy scores across cross-validation exercise
    accuracies = cross_val_score(model, features, labels, scoring = 'accuracy',
                                 cv = CV)
    # append fold id and accuracy scores to entries list
    for fold_idx, accuracy in enumerate(accuracies):
        entries.append((model_name, fold_idx, accuracy))
    # fill in the cross-validation dataset
    cv_df = pd.DataFrame(entries,
                         columns = ['model_name', 'fold_idx', 'accuracy'])

# produce boxplots depicting model performance
sns.boxplot(x = 'model_name', y = 'accuracy', data = cv_df)
sns.stripplot(x = 'model_name', y = 'accuracy', data = cv_df,
              size = 8, jitter = True, edgecolor = 'gray', linewidth = 2)

# display plot
plt.show()

# display list of results
cv_df.groupby('model_name').accuracy.mean()

### interpreting models
# here, we want to make sure our models are not overfitting our samples.
# we want to run these processes more than once to guarantee this is not
# happening.

# here's one try using logistic regression
model = LogisticRegression(random_state = 0, solver = 'lbfgs',
                           multi_class = 'auto')

# produce train, test, and split elements to subset the dataset
split = train_test_split(features, labels, df.index, test_size = 0.33,
                         random_state = 0)

# assign elements of the split object to each of the objects below
X_train       = split[0]
X_test        = split[1]
y_train       = split[2]
y_test        = split[3]
indices_train = split[4]
indices_test  = split[5]

# fit features to classes in train dataset
model.fit(X_train, y_train)

# predict y probabilities using x's in test data
y_pred_proba = model.predict_proba(X_test)
y_pred = model.predict(X_test)

# create confusion matrix to check misclassification
conf_mat = confusion_matrix(y_test, y_pred)

# produce heatmat so that we can visualize what's going on with the
# classification algorithm
sns.heatmap(conf_mat, annot = True, fmt = 'd',
            xticklabels = classes_id_df.classes.values,
            yticklabels = classes_id_df.classes.values)

# include labels and show
plt.ylabel('Actual')
plt.xlabel('Predicted')
plt.show()
