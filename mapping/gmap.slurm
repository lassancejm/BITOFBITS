#!/bin/bash
#SBATCH -n 8
#SBATCH -p general,holyhoekstra
#SBATCH -e gmap%A_%a.e
#SBATCH -o gmap%A_%a.o
#SBATCH -J gmap%A_%a
#SBATCH --mem=40000
#SBATCH --time=08:00:00
#SBATCH --array=0-99
#$1=path to gmap_db folder $2 db_name $3 input_file
#format=3: cDNA_match
gmap -D $1 -d $2 -B 5 --no-chimeras --nthreads=7 --npaths=1 --format=3 --part=${SLURM_ARRAY_TASK_ID}/100 --min-trimmed-coverage=0.90 --min-identity=0.90 $3 
