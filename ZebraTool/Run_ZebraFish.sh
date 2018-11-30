#!/bin/bash - 
#SBATCH -N1  # nodes
#SBATCH -n1  # tasks (cores)
#SBATCH --output="matlab_ZebraFish_%j.out"
#SBATCH --job-name=matlab_zebrafish
#SBATCH --mem 10G
#SBATCH -p Lewis
#SBATCH -t 2-00:00

##Lewis

## Load the matlab module
module load matlab/matlab-R2018a

## Path to matlab script

MATLAB_SCRIPT="/home/nalshak/Codes/ZebraFish/ZebraTool_For_the_Cluster/GapeCounter_MU.m"

## Run matlab non-interactively
 matlab -r "run('${MATLAB_SCRIPT}');exit"