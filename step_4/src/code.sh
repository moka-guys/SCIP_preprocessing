#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# make output folders
mkdir -p ~/out ./genome ~/out/forward_consensus ~/out/reverse_consensus

# make directory for reference genome and unpackage the reference genome
dx cat "$ref_genome" | tar zxvf - -C genome

echo ${bam_file_prefix} # also works - umi filename
describer=$(echo ${bam_file_prefix}) #${describer}
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

# convert consensus to fastq

java -Djava.awt.headless=true -jar ${picard_jar_path} SamToFastq I=${bam_file_path} FASTQ=~/out/forward_consensus/con_R1_${describer}.M3.fastq SECOND_END_FASTQ=~/out/reverse_consensus/con_R2_${describer}.M3.fastq VALIDATION_STRINGENCY=LENIENT

# upload outputs
dx-upload-all-outputs --parallel