#!/bin/bash
usage() { echo " 
Script to perform quality and adaptor trimming using Trimgalore.
Input: paired-end fastq.gz (quality score determined internally).

Usage: $0 [-n] [-f] [-a][-b]
       -n : number of launches
       -f : five prime clipping [default: 0]
       -a : adapter [default: AGATCGGAAGAGC]
       -b : second adapter [default: same as first adapter]
"
1>&2;exit 1;}

#------------------------------------------------------------------------------------------
# variables
#-------------------------------------------------------------------------------------------
options=':n:f:a:b:'
#n : numLaunches
clipping=0
adapter="AGATCGGAAGAGC"
a2="AGATCGGAAGAGC"
while getopts $options option;
do 
    case $option in
	n)numLaunches=${OPTARG};;
	f)clipping=${OPTARG};;
	a)adapter=${OPTARG};;
	b)a2=${OPTARG};;
    esac
done

if [ -z "$numLaunches" ]
then
    echo " Missing # of launches"
    usage
    exit
fi

directory=`pwd`
jobname="Trimming"
for i in `seq 1 1 $numLaunches`
do

#------------------------------------------------------------------------------------------
#Prepare runs: get files to put in batch, etc.
#-------------------------------------------------------------------------------------------

cd $directory/data

file1=$(ls *1.fastq.gz | head -1)
file2=$(ls *2.fastq.gz | head -1)
prefix=`echo $file1 | awk -F "." '{print $1}' `
#prefix=`echo $file1 | awk -F "_" '{print $1,$2}' OFS="_" `  
echo prefix is $prefix

encoding=`less $file1 | head -n40 | awk '{if(NR%4==0) printf("%s",$0);}' |  od -A n -t u1 -v | awk 'BEGIN{min=100;max=0;}{for(i=1;i<=NF;i++) {if($i>max) max=$i; if($i<min) min=$i;}}END{if(max<=74 && min<59) print "Phred+33"; else if(max>73 && min>=64) print "Phred+64"; else if(min>=59 && min<64 && max>73) print "Solexa+64"; else print "Unknown score encoding!";}'`

echo quality score encoding: $encoding

mv $file1 ../started
mv $file2 ../started

if [[ $encoding == Unknown* ]]; then echo "Cannot determine quality encoding, exiting"; exit; elif [ $encoding == "Solexa+64" ]; then echo "Solexa+64 encoding, not supported"; exit; fi 

cd ..

echo -n "Launching ${jobname}_${prefix}..."

cd $directory/run
 (
#------------------------------------------------------------------------------------------
#Cluster features 
#-------------------------------------------------------------------------------------------
echo "#!/bin/sh"
echo "#SBATCH -n 1" 
echo "#SBATCH --time=05:00:00  #Runtime in minutes"
echo "#SBATCH -e trim_${prefix}.e" 
echo "#SBATCH -o trim_${prefix}.o" 
echo "#SBATCH -p serial_requeue,holyhoekstra #Partition to submit to" 
echo "#SBATCH --mem=10000 #Memory per node in MB"
echo "#SBATCH -J ${prefix}"

echo "echo -n \"Starting job on \""
echo "date"
echo "mkdir /scratch/lassance_${i}/" 
echo "scratchFolder=\"/scratch/lassance_${i}/\""

#-------------------------------------------------------------------------------------------
#Copy Files into scratchFolder
#-------------------------------------------------------------------------------------------
echo "cd $directory"
echo "cp $directory/started/${file1} \$scratchFolder"
echo "cp $directory/started/${file2} \$scratchFolder"
echo "cd \$scratchFolder"
echo "echo \" ready to launch!\""


#-------------------------------------------------------------------------------------------
# Launch
#------------------------------------------------------------------------------------------- 

if [ $encoding == "Phred+64" ]; then encoding="phred64"; elif [ $encoding == "Phred+33" ]; then encoding="phred33"; fi 

if [ $clipping != 0 ]; then echo "perl /n/home01/lassance/Software/trim_galore_modif --paired --trim1 --${encoding} --length 36 --quality 20 --stringency 1 -a ${adapter} -a2 $a2 --retain_unpaired --clip_R1 ${clipping} --clip_R2 ${clipping} ${file1} ${file2}"; else  echo "perl /n/home01/lassance/Software/trim_galore_modif --paired --trim1 --${encoding} --length 36 --quality 20 --stringency 1 -a ${adapter} -a2 $a2 --retain_unpaired ${file1} ${file2}"; fi  
 
#-------------------------------------------------------------------------------------------
# copy results back
#-------------------------------------------------------------------------------------------
echo "mkdir -p $directory/data_post_trimgalore"
echo "rm ${file1} ${file2}"  
echo "cp ${prefix}* $directory/data_post_trimgalore"
#-------------------------------------------------------------------------------------------
# remove files
#-------------------------------------------------------------------------------------------  
#echo "cd $directory"
echo "rm -r -f \$scratchFolder" 
echo "cd $directory"
echo "echo -n \"End of job on \""
echo "date"
) > submit_trimming_${prefix}.sh
chmod +x submit_trimming_${prefix}.sh
sbatch submit_trimming_${prefix}.sh;
#-----------------
cd ..
done
