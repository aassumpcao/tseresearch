#!/bin/bash

#SBATCH -p bigmem
#SBATCH --qos bigmem_access
#SBATCH -N 1
#SBATCH --mem=1000g
#SBATCH -n 6
#SBATCH -t 7-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python 99_tse_sentence_classification.py
