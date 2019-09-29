#!/bin/bash
#SBATCH -p bigmem
#SBATCH --qos bigmem_access
#SBATCH -N 1
#SBATCH --mem=1500g
#SBATCH -n 16
#SBATCH -t 11-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/08_tse_feature_extraction.py
