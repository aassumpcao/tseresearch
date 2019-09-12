#!/bin/bash
#SBATCG -p general
#SBATCH --nodes=1
#SBATCH --mem=256g
#SBATCH --ntasks=12
#SBATCH -t 1-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/08_tse_feature_extraction.py
