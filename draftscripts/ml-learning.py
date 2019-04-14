### electoral crime and performance paper
#   this script implements machine learning algorithm to classify sentence type
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import statements
import pandas as pd
import os
import matplotlib.pyplot as plt
from io import StringIO

# import scikit-learn modules
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import LinearSVC

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
