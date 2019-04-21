#!/bin/bash

#SBATCH -p general
#SBATCH -N 20
#SBATCH --mem=128g
#SBATCH -n 24
#SBATCH -t 2-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/07_tse_sentence_classification.py
