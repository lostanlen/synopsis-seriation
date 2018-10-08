#!/bin/bash

#BATCH --job-name=synopsis_03_trial-163
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=36:00:00
#SBATCH --mem=8GB
#SBATCH --output=../slurm/synopsis_03_trial-163_%j.out

module purge
module load matlab/2018b

# The argument is the name of the recording unit.
matlab -nosplash -nodesktop -nodisplay -r "trial_id = 163; addpath(genpath('~/scattering.m')); run('../../synopsis03_seriation.m');"