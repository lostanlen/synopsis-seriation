#!/bin/bash

#BATCH --job-name=synopsis_04_trial-034
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=96:00:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/synopsis_04_trial-034_%j.out

module purge
module load matlab/2018b

# The argument is the name of the recording unit.
matlab -nosplash -nodesktop -nodisplay -r "trial_id = 34; addpath(genpath('~/scattering.m')); run('../../synopsis04_seriation.m');"