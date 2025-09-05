#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# make output folders
mkdir -p ~/out ./genome ~/out/bam_file

# make directory for reference genome and unpackage the reference genome
dx cat "$ref_genome" | tar zxvf - -C genome

echo ${sam_file_prefix} 
describer=$(echo ${sam_file_prefix}) 
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

# compress sam to bam and sort by coordinates
java -Djava.awt.headless=true -jar ${picard_jar_path} SortSam I=${sam_file_path} O=~/out/bam_file/${describer}.bam SORT_ORDER=coordinate

# upload outputs
dx-upload-all-outputs --parallel
