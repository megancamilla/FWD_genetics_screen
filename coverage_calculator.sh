#!/bin/bash

# Replace these with your actual file names and paths
REFERENCE_GENOME="/Users/mcdonamc/GIT/GATK4_Zymoseptoria/IPO323_reference/IPO323.fasta.fai"
BAM_PATH="/Users/mcdonamc/GIT/GATK4_Zymoseptoria/02_mapped/"
BAM_FILES=("A_S68_B_1" "A_S68_B_2" "A_S68_B_3" "A_S68_B_4" "B_S14_A_1" "B_S14_B_1" "B_S14_C_1" "B_S23_A_1" "B_S23_B_1" "B_S23_C_1" "B_S27_A_2" "B_S27_B_1" "B_S27_C_1" "UV80_1" "UV80_2" "UV80_3" "UV80_4") # List all 10 .bam files here

# Step 1: Prepare the .bed file for 5kb intervals
bedtools makewindows -g "$REFERENCE_GENOME" -w 5000 > intervals_5kb.bed

# Loop through each .bam file
for bam_file in "${BAM_FILES[@]}"; do
    # Step 2: Calculate coverage in 5kb intervals
    bedtools coverage -a intervals_5kb.bed -b "$BAM_PATH""$bam_file".sorted.bam -mean > "coverage_${bam_file%.bam}_5kb_intervals.txt"
    
    # Step 3: Extract intervals with less than 5x coverage
    awk '$4 < 5' "coverage_${bam_file%.bam}_5kb_intervals.txt" > "intervals_less_than_5x_${bam_file%.bam}.txt"
done


# Merge intervals from all 10 files into a single file
cat intervals_less_than_5x_*.txt > merged_intervals_less_than_5x.txt

# Sort the merged file
sort -k1,1 -k2,2n merged_intervals_less_than_5x.txt > sorted_merged_intervals_less_than_5x.txt

# Use awk to generate a unique list of 5kb intervals
awk '!seen[$1,$2,$3]++' sorted_merged_intervals_less_than_5x.txt > unique_5kb_intervals.bed

# Create a header for the summary table
echo -e "Chromosome\tStart\tStop\t$(echo "${BAM_FILES[@]}" | tr ' ' '\t')" > summary_table.txt

# Populate the summary table with presence/absence information (0 for absent, 1 for present)
awk 'BEGIN {OFS="\t"} {print $1, $2, $3, 0}' sorted_merged_intervals_less_than_5x.txt > temp_summary.txt

while read -r chrom start stop; do
    while read -r file; do
        if grep -q "$chrom\s$start\s$stop" "intervals_less_than_5x_${file}.txt"; then
            awk -v chr="$chrom" -v st="$start" -v sp="$stop" -v f="$file" 'BEGIN {OFS="\t"} $1 == chr && $2 == st && $3 == sp {print f}' sorted_merged_intervals_less_than_5x.txt >> temp_summary.txt
        fi
    done < <(echo "${BAM_FILES[@]}")
done < common_intervals.bed

# Combine the common intervals and presence/absence information into the final summary table
sort -k1,1 -k2,2n temp_summary.txt | uniq | awk 'BEGIN {OFS="\t"} {if (NR > 1) {$4 = 1} print}' >> summary_table.txt

