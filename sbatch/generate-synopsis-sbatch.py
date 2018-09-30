import os
import sys

# Define constants.
n_trials = 100


# Loop over recording units.
for trial_id in range(n_trials):
    script_path_with_args = " ".join(
        ["../../synopsis03_seriation.m", str(trial_id)]);
    job_name = "-".join(["synopsis_03_trial", str(trial_id).zfill(3)])
    file_name = job_name + ".sbatch"
    file_path = os.path.join(sbatch_dir, file_name)
    with open(file_path, "w") as f:
        f.write("#!/bin/bash\n")
        f.write("\n")
        f.write("#BATCH --job-name=" + job_name + "\n")
        f.write("#SBATCH --nodes=1\n")
        f.write("#SBATCH --tasks-per-node=1\n")
        f.write("#SBATCH --cpus-per-task=1\n")
        f.write("#SBATCH --time=0:05:00\n")
        f.write("#SBATCH --mem=4GB\n")
        f.write("#SBATCH --output=" +\
            "../slurm/" + job_name + "_%j.out\n")
        f.write("\n")
        f.write("module purge\n")
        f.write("\n")
        f.write("# The argument is the name of the recording unit.\n")
        f.write("python " + script_path_with_args)


# Open shell file.
file_path = os.path.join(sbatch_dir, script_name[:3] + ".sh")
with open(file_path, "w") as f:
    # Print header
    f.write("# This shell script executes all Slurm jobs" +\
        "for solving the seriation problem.\n")
    f.write("\n")

    # Loop over recording units.
    for trial_id in range(n_trials):
        # Define job name.
        job_name = "-".join(["synopsis_03_trial", str(trial_id).zfill(3)])
        sbatch_str = "sbatch " + job_name + ".sbatch"
        # Write SBATCH command to shell file.
        f.write(sbatch_str + "\n")


# Grant permission to execute the shell file.
# https://stackoverflow.com/a/30463972
mode = os.stat(file_path).st_mode
mode |= (mode & 0o444) >> 2
os.chmod(file_path, mode)
