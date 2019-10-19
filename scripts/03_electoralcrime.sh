#!/bin/bash
#SBATCH --partition=bigmem
#SBATCH --qos=bigmem_access
#SBATCH --mem=2000g
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH -t 11-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j.log

python3.6 scripts/09_tse_sentence_validation_allother.py
