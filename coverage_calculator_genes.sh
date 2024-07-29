#!/bin/bash

#This script is written by Megan C. McDonald

# Acknowledgement:
# This script was generated with the assistance of OpenAI's ChatGPT.
# ChatGPT is an AI language model that helped in writing and refining the code.
# For more information about ChatGPT, visit https://www.openai.com/chatgpt


# Replace these with your actual file names and paths
REFERENCE_GENOME="/PATHTOYOURFILES/GATK4_Zymoseptoria/IPO323_reference/IPO323.fasta.fai"
GFF_FILE="/PATHTOYOURFILES/GATK4_Zymoseptoria/IPO323_reference/Zymtr1_INRAE_GeneModels_genesonly.gff3"
BAM_PATH="/PATHTOYOURFILES/GATK4_Zymoseptoria/02_mapped/"
BAM_FILES=("A_S68_B_1" "A_S68_B_2" "A_S68_B_3" "A_S68_B_4" "A_S71_A_1" "B_S14_A_1" "B_S14_B_1" "B_S14_C_1" "B_S23_A_1" "B_S23_B_1" "B_S23_C_1" "B_S27_A_2" "B_S27_B_1" "B_S27_C_1" "UV80_1" "UV80_2" "UV80_3" "UV80_4") # List all 10 .bam files here

############### PART 1: Use bedtools to calculate the coverage per isolate #########################################################
# Step 1: Loop through each .bam file, input is the $GFF_FILE showing the coordinates of each gene in the $REFERENCE_GENOME
# If your $REFERENCE_GENOME fasta file does not have an index, you can do this with samtools faidx tool.

for bam_file in "${BAM_FILES[@]}"; do
    # Step 2: Calculate coverage in 5kb intervals for each gene in $GFF_FILE
    # NOTE: BAM_FILES should have the following naming convention NAME.sorted.bam
    bedtools coverage -a "$GFF_FILE" -b "$BAM_PATH""$bam_file".sorted.bam -mean > "coverage_${bam_file%.bam}_INRAE_genes.txt"
    
    # Step 3: Extract all genes with less than 5x coverage
    awk '$10 < 5' "coverage_${bam_file%.bam}_INRAE_genes.txt" > "INRAEgenes_less_than_5x_${bam_file%.bam}.txt"
    
done


###############  PART 2A: Combine the different bedfiles into one and remove duplicate genes (genes with <5x coverage in more than one isolate) ###############################################

# Merge genes with less than 5x coverage into a single file
cat INRAEgenes_less_than_5x_*.txt > merged_INRAEgenes_less_than_5x.txt

# Sort the merged file by gene name
sort -k1,1 -k2,2n merged_INRAEgenes_less_than_5x.txt > sorted_merged_INRAEgenes_less_than_5x.txt

# Use awk to generate a unique list of genes with less than 5x coverage
awk '!seen[$1,$4,$5]++' sorted_merged_INRAEgenes_less_than_5x.txt > unique_INRAE_genes.bed


# The common unique_bed_file showing all genes with less than 5x coverage in one or more isolates
unique_bed_file="unique_INRAE_genes.bed"





###############  PART 3: Look through individual files and indicate if genomic region is present (0, reference) or absent (1, alternate) in less_than_5x_isolates.bed ###############################################

# Loop through each isolate
for isolate in "${BAM_FILES[@]}"; do
    isolate_bed_file="INRAEgenes_less_than_5x_${isolate}.txt"
    output_file="${isolate}_summary.txt"

    # Create a temporary file to store the presence information
    tmp_file=$(mktemp)

    # Loop through list of genes in unique_INRAE_genes.bed
    while read -r chrom start stop gene ; do
    	# Genes that are present in the genome will be given a 0 (reference) and genes that are absent will be given a 1 (absent/alternate). 
    	# This search is counter-intuitive because we search through a list of genes with <5x coverage.
    	# so Genes present in the less than 5x isolate.bed file are ABSENT from the genome.  
    	found=$(awk -v chrom="$chrom" -v start="$start" -v stop="$stop" -v gene="$gene" '$1 == chrom && $4 == start && $5 == stop && $9 == gene { found = 1; exit } END { if (found) print 1; else print 0 }' "$isolate_bed_file")
    echo -e "$chrom\t$start\t$stop\t$gene\t$found" >> "$tmp_file"
	done < <(cut -f 1,4,5,9 "$unique_bed_file")


    # Sort the temporary file and add the header
    echo -e "Chrom\tStart\tStop\tGene\tPresence" > "$output_file"
    sort -k1,1 -k2,2n "$tmp_file" >> "$output_file"

    # Clean up temporary file
    rm "$tmp_file"

    echo "Summary for $isolate is generated in $output_file"
done

###############  PART 4: Combine the individual_summary.txt files into one giant file ###############################################


# Combine the first three columns from each individual summary file
awk 'BEGIN {OFS="\t"; print "Chrom\tStart\tStop\tGene"} {print $1, $4, $5, $9}' unique_INRAE_genes.bed > combined_summary.txt

# Combine the fourth column ("Presence") from each individual summary file
for isolate in "${BAM_FILES[@]}"; do
    paste -d $'\t' combined_summary.txt <(awk '{print $5}' "${isolate}_summary.txt") > temp_combined.txt
    mv temp_combined.txt combined_summary.txt
done

# Remove the header from the combined summary file
tail -n +2 combined_summary.txt > temp_combined.txt
mv temp_combined.txt combined_summary.txt

# Add the header with isolate names to the combined summary file
header=$(printf "\t%s" "${BAM_FILES[@]}")
header="Chrom\tStart\tStop\tGene${header}"
echo -e "$header" | cat - combined_summary.txt > temp_combined.txt
mv temp_combined.txt combined_summary.txt

echo "Combined summary file 'combined_summary.txt' generated."

