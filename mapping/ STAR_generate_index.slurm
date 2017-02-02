#!/bin/bash 
#SBATCH -n 16
#SBATCH -N 1
#SBATCH -p holyhoekstra,general
#SBATCH -e STAR.e
#SBATCH -o STAR.o
#SBATCH --mail-type=END
#SBATCH --mail-type=BEGIN
#SBATCH -J STAR_idx
#SBATCH --mem=150000
#SBATCH --time=08:00:00
#$1 genome directory_STAR2.5.1b; $2: genome.fasta
mkdir -f ${1}_STAR2.5.1b
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir ${1}_STAR2.5.1b --genomeFastaFiles $2 --genomeChrBinNbits 18
