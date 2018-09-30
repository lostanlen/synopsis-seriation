#!/bin/bash

#BATCH --job-name=synopsis_03_trial-046
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:05:00
#SBATCH --mem=4GB
#SBATCH --output=../slurm/synopsis_03_trial-046_%j.out

module purge

# The argument is the name of the recording unit.
matlab ../../synopsis03_seriation.m 46matlab -nosplash -nodesktop -nodisplay -r "trial_id = '46'; addpath(genpath('~/scattering.m')); run('../synopsis03_seriation.m');"