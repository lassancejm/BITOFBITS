#------------------------------------------------------------------------------------------
# variables
#-------------------------------------------------------------------------------------------
#!/bin/bash
usage() { echo " 

Tool to submit a de novo Transcriptome assembly using Trinity 

Usage: $0 [-h] [-l][-r][-g][-m][-s]
    -h      shows this help
    -l left reads
    -r right reads
    -s strand-specific data yes:1 (dUTP;RF) ; no:0 (default:no)
    -g grid conf file
    -m long reads"

1>&2;exit 1;}


options=':l:r:g:m:s:'
strand=0
while getopts $options option; 
do 
    case $option in
	l) left=${OPTARG};;
	r) right=${OPTARG};;
	s) strand=${OPTARG};;
	g) grid=${OPTARG};;
        m) long=${OPTARG};;
	h) usage; exit;;
        \?) echo "Unknown option: -${OPTARG}" >&2; usage; exit 1;;
        :) echo "Option: -${OPTARG} requires an argument" >&2;exit 1;; 
    esac
done

shift $(($OPTIND-1))

if [ -z "$left" ]|| [ -z "$right" ]
then
     echo "Necessary arguments were not passed"
     usage
     exit
elif [ ! -z "$long" ]
then 
    echo "Long reads provided"
fi

directory=`pwd`

numfilesPerBatch="1" 
numLaunches="1"
jobname="TrinityAssembly"
for i in `seq 1 1 $numLaunches`
do

#------------------------------------------------------------------------------------------
#Prepare runs: get files to put in batch, etc.
#-------------------------------------------------------------------------------------------

cd $directory

file1=$left
file2=$right
gridconf=$grid
prefix=`echo $file1 | awk -F "." '{print $1}' `
echo prefix is $prefix

echo -n "Launching ${jobname}_${prefix}..."
mkdir -p run
cd $directory/run
 (
#------------------------------------------------------------------------------------------
#Cluster features 
#-------------------------------------------------------------------------------------------
echo "#!/bin/sh"
echo "#SBATCH -N 1"
echo "#SBATCH -n 1 #Number of tasks"
echo "#SBATCH -c 32 #nb of cpus" 
echo "#SBATCH -t 4-00:00:00  #Runtime"
echo "#SBATCH -e Trinity_${prefix}.e" 
echo "#SBATCH -o Trinity_${prefix}.o" 
echo "#SBATCH -J Trin${prefix}"
echo "#SBATCH -p general,unrestricted,holyhoekstra #Partition to submit to" 
echo "#SBATCH --mem=320000 #Memory per task in MB"

echo "echo -n \"Starting job on \""
echo "date"
echo "cd $directory"

#-------------------------------------------------------------------------------------------
# Launch
#-------------------------------------------------------------------------------------------  
if [ $strand == 0 ] && [ -z "$long" ];then echo "/n/home01/lassance/Software/trinityrnaseq-2.0.6/Trinity --seqType fq --max_memory 320G --left ${file1} --right ${file2} --CPU 32 --output Trinity_${prefix} --full_cleanup --grid_conf ${gridconf} --grid_node_max_memory 5G"; elif [ $strand == 0 ] && [ ! -z "$long" ]; then echo "/n/home01/lassance/Software/trinityrnaseq-2.0.6/Trinity --seqType fq --max_memory 320G --left ${file1} --right ${file2} --long_reads ${long} --CPU 32 --output Trinity_${prefix} --full_cleanup --grid_conf ${gridconf} --grid_node_max_memory 5G"; elif [ $strand == 1 ] && [ -z "$long" ]; then echo "/n/home01/lassance/Software/trinityrnaseq-2.0.6/Trinity --seqType fq --max_memory 320G --left ${file1} --right ${file2} --CPU 32 --output Trinity_${prefix} --SS_lib_type RF --full_cleanup --grid_conf ${gridconf} --grid_node_max_memory 5G"; elif [ $strand == 1 ] && [ ! -z "$long" ]; then echo "/n/home01/lassance/Software/trinityrnaseq-2.0.6/Trinity --seqType fq --max_memory 320G --left ${file1} --right ${file2} --SS_lib_type RF --long_reads ${long} --CPU 32 --output Trinity_${prefix} --full_cleanup --grid_conf ${gridconf} --grid_node_max_memory 5G"; fi


echo "find Trinity_${prefix}/ -name \"*allProbPaths.fasta\" -exec cat {} + > Trinity_${prefix}/Trinity_${prefix}.fasta"

echo "echo -n \"End of job on \""
echo "date"
) >submit_assembly_${prefix}.sh
chmod +x submit_assembly_${prefix}.sh
sbatch submit_assembly_${prefix}.sh

done
