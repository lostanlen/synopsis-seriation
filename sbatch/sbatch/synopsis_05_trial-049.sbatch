#!/bin/bash

#BATCH --job-name=synopsis_05_trial-049
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=96:00:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/synopsis_05_trial-049_%j.out

module purge
module load matlab/2018b

# The argument is the name of the recording unit.
matlab -nosplash -nodesktop -nodisplay -r "trial_id = 49; addpath(genpath('~/scattering.m')); run('../../synopsis05_seriation_v2.m');"