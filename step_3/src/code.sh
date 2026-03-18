#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --parallel

# make output folders
mkdir -p ~/out ~/out/bam_file

echo ${bam_file_prefix} # also works - umi filename
describer=$(echo ${bam_file_prefix}) #${describer}
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

# Calculate 60% of available RAM for Java heap (safe buffer)
AVAILABLE_RAM_GB=$(free -g | awk '/^Mem:/{print int($2 * 0.6)}')
JAVA_THREADS=$(( $(nproc) / 4 ))
[ ${JAVA_THREADS} -lt 2 ] && JAVA_THREADS=2

# Set JVM options variably dependent on instance type and resource available
JAVA_OPTS="-Xmx${AVAILABLE_RAM_GB}g -XX:+UseParallelGC -XX:ParallelGCThreads=${JAVA_THREADS} -XX:+UseAdaptiveSizePolicy -Djava.io.tmpdir=/home/dnanexus "

# run fgbio UMI processing
java ${JAVA_OPTS} -jar ${fgbio_jar_path} --compression 1 AnnotateBamWithUmis \
  -i ${bam_file_path} -f ${umi_sequence_path} -o /dev/stdout | \
java ${JAVA_OPTS} -jar ${fgbio_jar_path} --compression 1 SortBam \
  -i /dev/stdin -o /dev/stdout -s queryname | \
java ${JAVA_OPTS} -jar ${fgbio_jar_path} --compression 1 SetMateInformation \
  -i /dev/stdin -o /dev/stdout | \
java ${JAVA_OPTS} -jar ${fgbio_jar_path} --compression 1 GroupReadsByUmi \
  -i /dev/stdin -f ~/out/${describer}_family_size_histogram.txt -s adjacency -o /dev/stdout | \
java ${JAVA_OPTS} -jar ${fgbio_jar_path} --compression 5 CallMolecularConsensusReads \
  -i /dev/stdin -o ~/out/bam_file/fgcon_${describer}.M3.bam -M 3

# upload outputs
dx-upload-all-outputs --parallel
