#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --qos=gpu_access
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --mem=32g
#SBATCH -t 2-
#SBATCH --mail-user=andre.assumpcao@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j.log

# clear number of threads
unset OMP_NUM_THREADS

# set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_py3/2.0.0/simg

# set SIMG name
SIMG_NAME=tensorflow2.0.0-py3-cuda10.0-ubuntu18.04.simg

# set data path
DATA_PATH=/pine/scr/a/a/aa2015/electoralcrime

# GPU with Singularity
singularity exec --nv -B /pine $SIMG_PATH/$SIMG_NAME bash -c "cd $DATA_PATH; R CMD BATCH --no-save scripts/10_tse_simulation.R 10_tse_simulation.Rout"
