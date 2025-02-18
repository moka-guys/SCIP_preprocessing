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

echo ${bam_file_prefix} # also works - umi filename
describer=$(echo ${bam_file_prefix}) #${describer}
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

# fgbio UMI processing
java -Xmx16g -XX:+AggressiveHeap -jar ${fgbio_jar_path}  SetMateInformation -i ${bam_file_path} -o ~/out/bam_file/setmate_${describer}.bam

# upload outputs
dx-upload-all-outputs --parallel