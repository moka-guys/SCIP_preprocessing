#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# make output folders
mkdir -p ~/out ./genome ~/out/sam_file

# make directory for reference genome and unpackage the reference genome
dx cat "$ref_genome" | tar zxvf - -C genome

echo ${forward_consensus_prefix} # also works - umi filename
describer=$(echo ${forward_consensus_prefix}) #${describer}
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

# align consensus reads
bwa mem -M -t 8 genome/genome.fa ${forward_consensus_path} ${reverse_consensus_path} > ~/out/sam_file/con_${describer}.M3.sam
#bwa mem -M -t 8 genome/genome.fa ${forward_consensus_path} ${reverse_consensus_path} > ~/out/sam_file/con_${describer}.M3.bam

# could output straight to bam and then sort here

#BWA-MEM FASTQ Read Mapper v1.3 - fastqs as inputs, bam bai outputs sorted

# upload outputs
dx-upload-all-outputs --parallel