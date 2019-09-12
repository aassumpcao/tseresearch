#!/bin/bash
#SBATCG -p general
#SBATCH --nodes=1
#SBATCH --mem=128g
#SBATCH --ntasks=12
#SBATCH -t 7-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

python3.6 scripts/10_tse_sentence_validation6.py
