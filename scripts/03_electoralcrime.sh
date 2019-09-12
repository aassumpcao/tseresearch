#!/bin/bash

#SBATCH -p bigmem
#SBATCH --qos bigmem_access
#SBATCH -N 1
#SBATCH --mem=2000g
#SBATCH -n 16
#SBATCH -t 10-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/10_tse_sentence_validation.py
