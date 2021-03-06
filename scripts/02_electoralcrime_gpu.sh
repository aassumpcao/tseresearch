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

# set path
export PATH=/nas/longleaf/apps/python/3.6.6/bin:/nas/longleaf/apps/r/3.6.0/bin:/nas/longleaf/apps/r/3.6.0/openmpi/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/nas/longleaf/home/aa2015/.local/bin:/nas/longleaf/home/aa2015/bin

# set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_py3/2.0.0/simg

# set SIMG name
SIMG_NAME=tensorflow2.0.0-py3-cuda10.0-ubuntu18.04.simg

# set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv -B /pine $SIMG_PATH/$SIMG_NAME bash -c "cd $DATA_PATH; python scripts/08_tse_sentence_validation_dnn.py"
