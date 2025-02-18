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

# fgbio UMI processing
java -Xmx16g -XX:+AggressiveHeap -jar ${fgbio_jar_path} AnnotateBamWithUmis -i ${bam_file_path} -f ${umi_sequence_path} -o ~/out/bam_file/fgtag_${describer}.bam

ls ~/out/bam_file

# upload outputs
dx-upload-all-outputs --parallel