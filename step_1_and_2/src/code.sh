#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# make output folders
mkdir -p ~/out ./genome ~/out/bam_file

# make directory for reference genome and unpackage the reference genome
dx cat "$ref_genome" | tar -xzf - -C genome  
	
echo ${umi_sequence_prefix} # also works - umi filename
describer=$(echo ${umi_sequence_prefix} | sed -e 's/_R2_001//') #${describer}
echo ${describer}	

sample=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${sample}

# Calculate 60% of available RAM for Java heap (safe buffer)
AVAILABLE_RAM_GB=$(free -g | awk '/^Mem:/{print int($2 * 0.6)}')
JAVA_THREADS=$(( $(nproc) / 4 ))
[ ${JAVA_THREADS} -lt 2 ] && JAVA_THREADS=2

# Set JVM options variably dependent on instance type and resource available
JAVA_OPTS="-Xmx${AVAILABLE_RAM_GB}g -XX:+UseParallelGC -XX:ParallelGCThreads=${JAVA_THREADS} -Djava.io.tmpdir=${TMPDIR:-/tmp}"

# step 1: align, step 2: compress and sort
bwa mem -M -t $(nproc) genome/genome.fa \
  ${fastq_forward_reads_r1_path} \
  ${fastq_reverse_reads_r3_path} | \
java ${JAVA_OPTS} -Djava.awt.headless=true -jar ${picard_jar_path} SortSam \ 
  I=/dev/stdin \
  O=~/out/bam_file/${describer}.bam \
  SORT_ORDER=coordinate \
  COMPRESSION_LEVEL=5 

# upload outputs
dx-upload-all-outputs --parallel


