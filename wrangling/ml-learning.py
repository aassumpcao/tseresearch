# notebook
# andre assumpcao

# import staments
import pandas as pd
import os
import matplotlib.pyplot as plt
from io import StringIO
from sklearn.feature_extraction.text import TfidfVectorizer

# load dataset
df = pd.read_csv('Consumer_complaints.csv', dtype = 'str')

# check how data looks like
df.head()

# define columns we will be working with
col = ['Product', 'Consumer complaint narrative']
df  = df[col]
df  = df[pd.notnull(df['Consumer complaint narrative'])]

# change column names
df.columns = ['Product', 'Consumer_complaint_narrative']

# transform y's into categorical variables
df['category_id'] = df['Product'].factorize()[0]

# clean up dataset
category_id_df = df[['Product', 'category_id']].drop_duplicates()
category_id_df = category_id_df.sort_values('category_id')
category_to_id = dict(category_id_df.values)
id_to_category = dict(category_id_df[['category_id', 'Product']].values)

# reset index
df = df.reset_index()

# plot the complaint balance
fig = plt.figure(figsize = (8, 6))
df.groupby('Product').Consumer_complaint_narrative.count().plot.bar(ylim = 0)
plt.show()

# let us find the tf-idf for each term in the dataset
tfidf = TfidfVectorizer(sublinear_tf = True, min_df = 10, norm = 'l2',
                        encoding = 'latin-1', ngram_range = (1, 2),
                        stop_words = 'english')

# create document-feature matrix
features = tfidf.fit_transform(df.Consumer_complaint_narrative).toarray()
labels = df.category_id
features.shape
