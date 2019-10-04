### electoral crime and performance paper
# judicial decisions script
#   this script formats the text used for training the machine learning
#   algorithms on python.
# author: andre assumpcao
# by andre.assumpcao@gmail.com

# import libraries
import pandas as pd

# define function to load sentence files
def load_sentences(fname1, fname2):
    df1 = pd.read_csv(fname1, index = False, dtype = str)
    df2 = pd.read_csv(fname2, index = False, dtype = str)
    return df1, df2

def main():
    pass




# define main program block
if __name__ == '__main__':
    main()
