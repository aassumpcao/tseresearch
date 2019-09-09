#!/bin/bash

#SBATCH -p bigmem
#SBATCH --qos bigmem_access
#SBATCH -N 1
#SBATCH --mem=1000g
#SBATCH -n 16
#SBATCH -t 7-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/10_tse_sentence_validation.py
