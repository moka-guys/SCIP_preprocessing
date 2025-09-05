#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --parallel

# make output folders
mkdir -p ~/out ~/out/trimmed_fastq_r1 ~/out/trimmed_fastq_r3 ~/out/trimmed_fastqs_unpaired

# instead of having source code as input - can do this with all the apps.
# download SCIP docker image 
# scip_docker_file_id=project-Gkvkbjj03P8qxxk16qb1yqqQ:file-GyqZ48003P8QB52q6xPx8fY3
# dx download ${scip_docker_file_id}

tar -xjf ${trimgalore_file_path}
cp bin/trim_galore /usr/local/bin

# trim adaptors from reads using trimgalore
trim_galore --paired --retain_unpaired ${fastq_forward_reads_r1_path} ${fastq_reverse_reads_r3_path} 

mv *val_1.fq.gz ~/out/trimmed_fastq_r1
mv *val_2.fq.gz ~/out/trimmed_fastq_r3

# upload outputs
dx-upload-all-outputs --parallel


