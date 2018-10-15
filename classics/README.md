# Some commands of frequent use

* Compress vcf file:

`bgzip -c file.vcf > file.vcf.gz`

`tabix -p vcf file.vcf.gz`

note: tools distributed with samtools; access using `module load samtools`

* Compress sam file:

with samtools:
`samtools view -Shb file.sam > file.bam`

with Picard:
`java -jar picard.jar SortSam I=file.sam O=file.bam SORT_ORDER=unsorted` 

* determine size of a folder:

`du -sh directory-name`

* Compress file with gzip:

`gzip file-name` will create file-name.gz

* Uncompress gzipped file:

`gunzip file-name.gz` or `gzip -d file-name.gz`

* Compress folder:

`tar -czf archive-name.tar.gz name_of_directory_to_compress`

add 'v' to increase verbosity:

`tar -zcvf archive-name.tar.gz directory-name`

* To extract Tarball file:

`tar -xzvf file.tar.gz`

* changing permission of a folder

`chmod -R u+rw,g+rw,o-rwx folder`  : give read+writing permission to user and group levels; remove read-write-execute permission to the rest

* changing permission of a file

`chmod u+rw,g+rw,o-rwx file`

* check quota on Lustre filesystem

`lfs quota -hg hoekstra_lab /n/regal` 
`lfs quota -hg hoekstra_lab /n/holylfs`
