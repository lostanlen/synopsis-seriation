#!/bin/bash

#BATCH --job-name=synopsis_03_trial-064
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:05:00
#SBATCH --mem=4GB
#SBATCH --output=../slurm/synopsis_03_trial-064_%j.out

module purge

# The argument is the name of the recording unit.
matlab ../../synopsis03_seriation.m 64matlab -nosplash -nodesktop -nodisplay -r "trial_id = '64'; addpath(genpath('~/scattering.m')); run('../synopsis03_seriation.m');"