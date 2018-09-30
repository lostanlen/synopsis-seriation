#!/bin/bash

#BATCH --job-name=synopsis_03_trial-021
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:05:00
#SBATCH --mem=4GB
#SBATCH --output=../slurm/synopsis_03_trial-021_%j.out

module purge

# The argument is the name of the recording unit.
matlab ../../synopsis03_seriation.m 21matlab -nosplash -nodesktop -nodisplay -r "trial_id = '21'; addpath(genpath('~/scattering.m')); run('../synopsis03_seriation.m');"