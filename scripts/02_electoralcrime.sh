#!/bin/bash
# this is an example of an sbatch script to run a tensorflow script
#  using singularity to run the tensorflow image.
#
# instructions:
# 1. set the data_path to the directory you want the job to run in.
# 2. on the singularity command line, replace ./test.py with your program
# 3. change reserved resources as needed for your job.

#SBATCG --partition=general
#SBATCH --nodes=1
#SBATCH --mem=256g
#SBATCH --ntasks=8
#SBATCH -t 7-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

# clear number of threads
unset OMP_NUM_THREADS

# Set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_nogpu_py3/1.9.0/simg

# Set SIMG name
SIMG_NAME=tensorflow1.9.0-py3-nogpu-ubuntu18.04.simg

# Set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv -B /pine -B /proj $SIMG_PATH/$SIMG_NAME bash -c "cd $DATA_PATH; python scripts/09_tse_dnn_validation.py"
