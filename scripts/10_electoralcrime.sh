#!/bin/bash
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --mem=128g
#SBATCH -t 10-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j.log

# GPU with Singularity
R CMD BATCH --no-save scripts/10_tse_simulation.R 10_tse_simulation.Rout
