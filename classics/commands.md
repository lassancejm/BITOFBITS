# Here are some commands of frequent use

* Compress vcf file:

`bgzip -c file.vcf > file.vcf.gz`

`tabix -p vcf file.vcf.gz`

note: tools distributed with samtools; access using `module load samtools`

* determine size of a folder:

`du -sh directory-name`

* Compress folder:

`tar -czf archive-name.tar.gz name_of_directory_to_compress`

add 'v' to increase verbosity:

`tar -zcvf archive-name.tar.gz directory-name`

* To extract Tarball file:

`tar -xzvf file.tar.gz`

* changing permission of a folder

`chmod -R u+rw,g+rw,o-rwx folder`

* changing permission of a file

`chmod u+rw,g+rw,o-rwx file`
