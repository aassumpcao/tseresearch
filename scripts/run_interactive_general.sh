#!/bin/bash
# run on general partition
srun --ntasks=48 --cpus-per-task=1 --mem=64G --time=4:00:00 --partition=general --pty singularity shell
