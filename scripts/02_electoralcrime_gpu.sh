#!/bin/bash
#SBATCH --partition=volta-gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --mem=220g
#SBATCH -t 10-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j.log

# clear number of threads
unset OMP_NUM_THREADS

# module load
module load tensorflow_py3/2.0.0

# set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_py3/2.0.0/simg

# set SIMG name
SIMG_NAME=tensorflow2.0.0-py3-cuda10.0-ubuntu18.04.simg

# set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv \
  -B /pine $SIMG_PATH/$SIMG_NAME bash \
  -c 'cd $DATA_PATH; python3.6 scripts/08_tse_sentence_validation_dnn.py'
