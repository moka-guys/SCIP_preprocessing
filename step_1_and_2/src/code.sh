#!/bin/bash
set -e -x -o pipefail

# Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# Make output folders
mkdir -p ~/out ./genome ~/out/bam_file ~/out/bai_file

# Reference genome
dx cat "$ref_genome" | tar -xzf - -C genome  

echo ${umi_sequence_prefix}
describer=$(echo ${umi_sequence_prefix} | sed -e 's/_R2_001//')
echo ${describer}	

sample=$(echo ${describer} | grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${sample}

# Calculate 60% of available RAM for Java heap
AVAILABLE_RAM_GB=$(free -g | awk '/^Mem:/{print int($2 * 0.6)}')
JAVA_THREADS=$(( $(nproc) / 4 ))
[ ${JAVA_THREADS} -lt 2 ] && JAVA_THREADS=2
JAVA_OPTS="-Xmx${AVAILABLE_RAM_GB}g -XX:+UseParallelGC -XX:ParallelGCThreads=${JAVA_THREADS} -XX:+UseAdaptiveSizePolicy -Djava.io.tmpdir=/home/dnanexus"

# Step 1: BWA align to unsorted BAM
bwa mem -M -t $(nproc) genome/genome.fa \
  ${fastq_forward_reads_r1_path} \
  ${fastq_reverse_reads_r3_path} \
  > /home/dnanexus/${describer}.unsorted.bam

# Step 2: Picard sort (now has full RAM to itself)
java ${JAVA_OPTS} -Djava.awt.headless=true -jar ${picard_jar_path} SortSam \
  I=/home/dnanexus/${describer}.unsorted.bam \
  O=~/out/bam_file/${describer}.bam \
  SORT_ORDER=coordinate \
  COMPRESSION_LEVEL=5 \
  TMP_DIR=/home/dnanexus

# Clean up intermediate file to free disk space
rm /home/dnanexus/${describer}.unsorted.bam

# Index BAM
samtools index ~/out/bam_file/${describer}.bam ~/out/bai_file/${describer}.bam.bai

# Upload outputs
dx-upload-all-outputs --parallel