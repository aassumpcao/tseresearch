#!/bin/bash
# this is an example of an sbatch script to run  tensorflow interactively
#  using singularity to run the tensorflow image on a nogpu environment.
# 1. you will be dropped into an interactive shell with the tensorflow
#    environment.
# 2. change reserved resources as needed for your job.
#
# define number of threads
unset OMP_NUM_THREADS

# Set SIMG path
SIMG_PATH=/nas/longleaf/apps/tensorflow_nogpu_py3/1.9.0/simg

# Set SIMG name
SIMG_NAME=tensorflow1.9.0-py3-nogpu-ubuntu18.04.simg

# GPU with Singularity
srun --partition=general --nodes=1 --mem=256g --ntasks=4 --time=5:00:00 --pty singularity shell --nv -B /pine -B /proj $SIMG_PATH/$SIMG_NAME
