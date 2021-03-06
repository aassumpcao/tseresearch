#!/bin/bash
#SBATCH --partition=bigmem
#SBATCH --qos=bigmem_access
#SBATCH --mem=200g
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH -t 4-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j.log

# clear number of threads
unset OMP_NUM_THREADS

# set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_nogpu_py3/1.9.0/simg

# set SIMG name
SIMG_NAME=tensorflow1.9.0-py3-nogpu-ubuntu18.04.simg

# set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv \
  -B /pine $SIMG_PATH/$SIMG_NAME bash \
  -c 'cd $DATA_PATH; python3.6 scripts/08_tse_sentence_validation_dnn.py'
