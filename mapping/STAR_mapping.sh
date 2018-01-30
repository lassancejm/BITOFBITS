#------------------------------------------------------------------------------------------
# variables
#-------------------------------------------------------------------------------------------
#!/bin/bash
usage() { echo " 
Script to perform splice-mapping with STAR and prepare for output for expression calculation with RSEM/mmseq, assembly with Cufflinks or variant calling with GATK

Currently, reads are expected to be paired-end, in fastq.gz format and filtered using Trimgalore.sh
 
Usage: $0 [-n] [-b] [-o] [--mode]      
       -n : number of launches
       -b |--STARidx= : path to STAR genome indexes (built using genome and annotation)
       -o |--output=: output directory
       --mode : output mode
        options: --mode=rsem : create output compatible with RSEM (Encode3 pipeline; transcriptome format with no indel, no soft-clipped bases;default)
                 --mode=gatk : create output compatible with GATK (SamMappedUniq reassigned to  60; bam file sorted by coordinate)
                 --mode=cuff : create output compatible with Cufflinks (only canonical splice sites)   
"
1>&2;exit 1;}


options=$(getopt -o n:b:o:h -l STARidx:,output:,mode:,help -- "$@")

# Check to see if the getopts command failed
if [ $? -ne 0 ];
then
   echo "Failed to parse arguments"
   exit 1
fi


eval set -- "$options"

MODE=rsem

while true; do
    case "$1" in 
	-n) numLaunches=$2;shift 2 ;; 

	-b | --STARidx) STARidx=$2;shift 2;;
	-o | --output) output=$2;shift 2;;
        --mode) MODE=$2
	[[ ! $MODE =~ rsem|gatk|cuff ]] && {
	    echo "Incorrect output mode provided"
	    exit 1
	    }
	    shift 2
	    ;;
	-h | --help) usage;exit 1;;
	--)shift;break;;
	*) echo "Incorrect options provided"; usage;; 
    esac
done

if [ -z "$numLaunches" ]
then
    echo " Missing # of launches; type --help if unsure about the options"
    exit
fi
if [ -z "$STARidx" ] || [ -z "$output" ]
then
    echo " Missing necessary arguments; type --help if unsure about the options"
    exit
fi
 



directory=`pwd`
jobname="STARMapping"
for i in `seq 1 1 $numLaunches`
do

#------------------------------------------------------------------------------------------
#Prepare runs: get files to put in batch, etc.
#-------------------------------------------------------------------------------------------
cd $directory
cd data

file1=$(ls *1.f*q.gz | head -1)
file2=$(ls *2.f*q.gz | head -1)
prefix=`echo $file1 | awk -F "." '{print $1}' `
#prefix=`echo $file1 | awk -F "_" '{print $1,$2,$3,$4,$5,$7}' OFS="_" `  
echo prefix is $prefix
mv $file1 ../started
mv $file2 ../started

cd ..

echo -n "Launching ${jobname}_${prefix}..."

cd run
 (
#------------------------------------------------------------------------------------------
#Cluster features 
#-------------------------------------------------------------------------------------------
echo "#!/bin/sh"
echo "#SBATCH -n 1"
echo "#SBATCH --cpus-per-task=16"
echo "#SBATCH -N 1" 
echo "#SBATCH -t 300 #Runtime in minutes"
echo "#SBATCH -e mapping_${prefix}.e" 
echo "#SBATCH -o mapping_${prefix}.o" 
echo "#SBATCH -p general,holyhoekstra,shared #Partition to submit to" 
echo "#SBATCH --mem=50000 #Memory per node in MB"
echo "#uncomment next line if you want to load module from RC"
echo "#source new-modules.sh; module load STAR"
echo "echo -n \"Starting job on \""
echo "date"
echo "mkdir /scratch/STAR_${prefix}_${i}/" 
echo "scratchFolder=\"/scratch/STAR_${prefix}_${i}/\""

#-------------------------------------------------------------------------------------------
#Copy Files into scratchFolder
#-------------------------------------------------------------------------------------------
echo "cd $directory"
echo "cp started/${file1} \$scratchFolder"
echo "cp started/${file2} \$scratchFolder"
echo "cd \$scratchFolder"
echo "echo \" files copied; ready to launch!\""


#-------------------------------------------------------------------------------------------
# Launch
#------------------------------------------------------------------------------------------- 
echo "mkdir ${output}_${prefix}"

#parameters based on rsem pipeline, which uses encode3 params (with a few exception)
if [ $MODE == "rsem" ]; then
    echo "STAR --runMode alignReads --runThreadN ${SLURM_CPUS_PER_TASK} --genomeDir ${STARidx} --readFilesIn ${file1} ${file2} --readFilesCommand zcat --outFileNamePrefix ${output}_${prefix} --twopassMode Basic --outFilterType BySJout --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 -sjdbScore 1 --genomeLoad NoSharedMemory --outSAMattributes All --outSAMtype BAM Unsorted --quantMode TranscriptomeSAM --quantTranscriptomeBan IndelSoftclipSingleend --outSAMattrRGline ID:${prefix} PL:ILLUMINA LB:${prefix} SM:${prefix} PU:barcode"

#for gatk, important to have unique mapped read flag to 60
elif [ $MODE == "gatk" ]; then 
    echo "STAR --runMode alignReads --runThreadN ${SLURM_CPUS_PER_TASK} --genomeDir ${STARidx} --readFilesIn ${file1} ${file2} --readFilesCommand zcat --outFileNamePrefix ${output}_${prefix} --twopassMode Basic --outFilterType BySJout --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 -sjdbScore 1 --genomeLoad NoSharedMemory --outSAMattributes All --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:${prefix} PL:ILLUMINA LB:${prefix} SM:${prefix} PU:barcode --outSAMmapqUnique 60"
elif [ $MODE == "cuff" ]; then
    echo "STAR --runMode alignReads --runThreadN ${SLURM_CPUS_PER_TASK} --genomeDir ${STARidx} --readFilesIn ${file1} ${file2} --readFilesCommand zcat --outFileNamePrefix ${output}_${prefix} --twopassMode Basic --outFilterType BySJout --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 -sjdbScore 1 --genomeLoad NoSharedMemory --outSAMattributes Standard --outSAMtype BAM Unsorted SortedByCoordinate --outSAMattrRGline ID:${prefix} PL:ILLUMINA LB:${prefix} SM:${prefix} PU:barcode --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --alignEndsType EndToEnd"
fi;

echo "echo \" mapping command executed\""
echo "echo \" copying results back\""
#-------------------------------------------------------------------------------------------
# copy results back
#-------------------------------------------------------------------------------------------
echo "mkdir -p $directory/$output"
echo "rm ${prefix}*R?_*.f*q.gz"  
echo "cp -r ${output}_${prefix}* $directory/$output"
#-------------------------------------------------------------------------------------------
# remove files
#-------------------------------------------------------------------------------------------  
#echo "cd $directory"
echo "rm -r -f \$scratchFolder" 
##echo "cd $directory"
echo "echo -n \"End of job on \""
echo "date"
) > submit_mapping_STAR_${prefix}.sh 
 
chmod +x submit_mapping_STAR_${prefix}.sh
sbatch < submit_mapping_STAR_${prefix}.sh;
#-----------------
cd ..
done
