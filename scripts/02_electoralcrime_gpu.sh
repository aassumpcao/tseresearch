#!/bin/bash
# this is an example of an sbatch script to run a tensorflow script
#  using singularity to run on the unc's gpu partition.

#SBATCH -p volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH -N 1
#SBATCH --mem=64g
#SBATCH -n 4
#SBATCH -t 11-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

# clear number of threads
unset OMP_NUM_THREADS

# set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_py3/2.0.0/simg

# set SIMG name
SIMG_NAME=tensorflow2.0.0-py3-cuda10.0-ubuntu18.04.simg

# set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv -B /pine -B /proj $SIMG_PATH/$SIMG_NAME bash -c "cd $DATA_PATH; python scripts/09_tse_dnn_validation.py --chi2=30000"
