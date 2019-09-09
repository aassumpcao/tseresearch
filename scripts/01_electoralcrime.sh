#!/bin/bash
#SBATCG -p general
#SBATCH --nodes=1
#SBATCH --mem=128g
#SBATCH --ntasks=8
#SBATCH -t 1-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/08_tse_feature_extraction.py
