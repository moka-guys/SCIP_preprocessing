#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# make output folders
mkdir -p ~/out ./genome ~/out/all_outputs ~/out/hbb_mpileup ~/out/sced_mpileup ~/out/hbb_mpileup_155bp ~/out/sced_mpileup_155bp

# make directory for reference genome and unpackage the reference genome
dx cat "$ref_genome" | tar zxvf - -C genome

echo ${bam_file_prefix} # also works - umi filename
describer=$(echo ${bam_file_prefix}) #${describer}
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

echo ${bam_file_path[0]}
echo ${bam_file_path[1]}

# filter bam to reads with insert size of 155bp or less
samtools view -h ${bam_file_path} | \
awk 'substr($0,1,1)=="@" || ($9>=0 && $9<=155) || ($9<=0 && $9>=-155)' | \
samtools view -b > ${describer}_155bp.bam

# perform mpileup
samtools mpileup -l ${hbb_bed_file_path} ${bam_file_path} -o ~/out/hbb_mpileup/con_${describer}_HBB.M3.mpileup 

samtools mpileup -l ${sced_bed_file_path} ${bam_file_path} -o ~/out/sced_mpileup/con_${describer}_SCED.M3.mpileup

samtools mpileup -l ${hbb_bed_file_path} ${describer}_155bp.bam -o ~/out/hbb_mpileup_155bp/con_${describer}_155bp_HBB.M3.mpileup 

samtools mpileup -l ${sced_bed_file_path} ${describer}_155bp.bam -o ~/out/sced_mpileup_155bp/con_${describer}_155bp_SCED.M3.mpileup

# upload outputs
dx-upload-all-outputs --parallel