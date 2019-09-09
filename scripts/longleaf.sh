#!/bin/bash
# # create directory if necessary
# mkdir data

# # transfer files to longleaf
# # (not necessary after first attempt)
# scp data/tsePredictions.csv aa2015@longleaf.unc.edu:/pine/scr/a/a/aa2015/electoralcrime/data
# sleep 2
# 1Baby@234
# scp data/stopwords.txt aa2015@longleaf.unc.edu:/pine/scr/a/a/aa2015/electoralcrime/data
# sleep 2
# 1Baby@234

scp scripts/electoralcrime.sh aa2015@longleaf.unc.edu:/pine/scr/a/a/aa2015/electoralcrime
sleep 2
1Baby@234

# necessary after first changes
scp scripts/99_tse_sentence_validation.py aa2015@longleaf.unc.edu:/pine/scr/a/a/aa2015/electoralcrime/scripts
sleep 2
1Baby@234

# necessary after first changes
scp scripts/requirements.txt aa2015@longleaf.unc.edu:/pine/scr/a/a/aa2015/
sleep 2
1Baby@234

# login information
ssh -X aa2015@longleaf.unc.edu
1Baby@234

# change working directory
cd /pine/scr/a/a/aa2015/electoralcrime
cd /nas/longleaf/home/aa2015
cat requirements.txt | xargs -n 1 pip install

# check if all is correct
cat electoralcrime.sh
cat scripts/99_tse_sentence_classification.py

# job commands
sbatch electoralcrime.sh
sleep 5
squeue -u aa2015

# check errors
ls -l
cat slurm-32989053.out
