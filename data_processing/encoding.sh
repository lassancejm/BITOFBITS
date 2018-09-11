#!/bin/bash
#usage: ./encoding.sh input_filename
input=$1
file1=$(ls $input | head -1)
#file1=$(ls *1.fastq.gz | head -1)
prefix=`echo $file1 | awk -F "." '{print $1}' `
echo prefix is $prefix

encoding=`less $file1 | head -n80 | awk '{if(NR%4==0) printf("%s",$0);}' |  od -A n -t u1 -v | awk 'BEGIN{min=100;max=0;}{for(i=1;i<=NF;i++) {if($i>max) max=$i; if($i<min) min=$i;}}END{if(max<=74 && min<59) print "Phred+33"; else if(max>73 && min>=64) print "Phred+64"; else if(min>=59 && min<64 && max>73) print "Solexa+64"; else print "Unknown score encoding!";}'`

echo quality score encoding: $encoding

if [[ $encoding == Unknown* ]]; then echo "Cannot determine quality encoding, exiting"; exit; elif [ $encoding == "Solexa+64" ]; then echo "Solexa+64 encoding, not supported"; exit; fi
