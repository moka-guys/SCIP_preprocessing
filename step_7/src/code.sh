#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#Grab inputs
dx-download-all-inputs --except ref_genome --parallel

# make output folders
mkdir -p ~/out ./genome ~/out/all_outputs ~/out/hbb_mpileup ~/out/sced_mpileup

# make directory for reference genome and unpackage the reference genome
dx cat "$ref_genome" | tar zxvf - -C genome

echo ${bam_file_prefix} # also works - umi filename
describer=$(echo ${bam_file_prefix}) #${describer}
echo ${describer}	

describer=$(echo ${describer}| grep -o 'SCIP[0-9]*' | tail -n 1)
echo ${describer}

echo ${bam_file_path[0]}
echo ${bam_file_path[1]}

samtools mpileup -l ${hbb_bed_file_path} ${bam_file_path} -o ~/out/hbb_mpileup/con_${describer}_HBB.M3.mpileup 

samtools mpileup -l ${sced_bed_file_path} ${bam_file_path} -o ~/out/sced_mpileup/con_${describer}_SCED.M3.mpileup

#bcftools mpileup -f genome/genome.fa -R ${hbb_bed_file_path} ${bam_file_path} -o ~/out/all_outputs/con_${describer}_HBB.bcftools.M3.vcf

#bcftools mpileup -f genome/genome.fa -R ${hbb_bed_file_path} ${bam_file_path} 

# -A -Q 0 -q 0 -B -d 100000

# -A (Include anomalous/secondary alignments):

# Default: Excludes anomalous alignments.
# Secondary and anomalous reads are not included in the pileup by default.
# Effect with -A: Includes all alignments, including secondary and anomalous.
# -Q (Minimum base quality threshold):

# Default: 13.
# Bases with a Phred quality score below 13 are excluded.
# Effect with -Q 0: Includes all bases, regardless of quality.
# -q (Minimum mapping quality threshold):

# Default: 20.
# Reads with a mapping quality below 20 are excluded.
# Effect with -q 0: Includes all reads, regardless of mapping quality.
# -B (Disable BAQ adjustment):

# Default: Enabled.
# Base alignment quality (BAQ) is computed to correct for possible errors near indels.
# Effect with -B: Disables BAQ computation, leaving the raw qualities unchanged.
# -d (Maximum read depth per position):

# Default: 8000.
# Caps the number of reads considered at a single position to 8000.
# Effect with -d 100000: Allows up to 100,000 reads to be considered at each position.


# upload outputs
dx-upload-all-outputs --parallel