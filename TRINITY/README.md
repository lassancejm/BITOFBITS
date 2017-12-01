## TrinityAssembly.sh:

Bash script to submit Trinity de novo transcriptome assembly. Submit two jobs to the grid: 1) prep the files that are not taking advantage of the grid but are memory hungry and 2)proceed with the step that can be run in parallel using HpcGridRunner.

```
Usage: ./TrinityAssembly.sh [-h] [-l][-r][-g][-m]
    -h      shows this help
    -l left reads
    -r right reads
    -g grid conf file
    -m long reads
    
What the script does: prepare a bash file with all the necessary arguments for sbatch submission to slurm Scheduler and  
submit the job to the grid. 
```

## TrinityAssembly_onestep.sh
Script to launch Trinity de novo assembly in one step. Benefit: a single job; Caveat: sitting on a lot of RAM, even when not needed (specially true with Slurm)

```
Usage: ./TrinityAssembly_onestep.sh [-h] [-l][-r][-g][-m][-s]
    -h      shows this help
    -l left reads
    -r right reads
    -s strand-specific data yes:1 (dUTP;RF) ; no:0 (default:no)
    -g grid conf file
    -m long reads
    
What the script does: prepare a bash file with all the necessary arguments for sbatch submission to slurm Scheduler
and submit the job to the grid. 
```
## grid_slurm.conf:
config file for HpcGridRunner using Slurm


