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
	
echo ${umi_sequence_prefix} # also works - umi filename
describer=$(echo ${umi_sequence_prefix} | sed -e 's/_R2_001//') #${describer}
echo ${describer}	

sample=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${sample}

# align trimmed reads to GRCh38
bwa mem -M -t 8 genome/genome.fa ${fastq_forward_reads_r1_path} ${fastq_reverse_reads_r3_path} > ~/out/sam_file/${describer}.sam

# upload outputs
dx-upload-all-outputs --parallel
