#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH --mem=256g
#SBATCH -n 24
#SBATCH -t 11-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/08_tse_feature_extraction.py
