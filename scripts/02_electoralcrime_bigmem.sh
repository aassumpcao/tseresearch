#!/bin/bash
# this is an example of an sbatch script to run a tensorflow script
#  using singularity to run on the unc's gpu partition.

#SBATCH -p bigmem
#SBATCH --qos bigmem_access
#SBATCH -N 1
#SBATCH --mem=1000g
#SBATCH -n 16
#SBATCH -t 11-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL

# clear number of threads
unset OMP_NUM_THREADS

# set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_nogpu_py3/1.9.0/simg

# set SIMG name
SIMG_NAME=tensorflow1.9.0-py3-nogpu-ubuntu18.04.simg

# set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv -B /pine -B /proj $SIMG_PATH/$SIMG_NAME bash -c "cd $DATA_PATH; python scripts/08_tse_sentence_validation_dnn.py"
