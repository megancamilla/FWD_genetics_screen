#!/bin/bash

BAM_FILES=("A_S68_B_1" "A_S68_B_2" "A_S68_B_3" "A_S68_B_4" "A_S71_A_1" "B_S14_A_1" "B_S14_B_1" "B_S14_C_1" "B_S23_A_1" "B_S23_B_1" "B_S23_C_1" "B_S27_A_2" "B_S27_B_1" "B_S27_C_1" "UV80_1" "UV80_2" "UV80_3" "UV80_4")

# Merge intervals from all files into a single file
cat intervals_less_than_5x_*.bed > merged_intervals_less_than_5x.bed

# Sort the merged file
sort -k1,1 -k2,2n merged_intervals_less_than_5x.bed > sorted_merged_intervals_less_than_5x.bed

# Use awk to generate a unique list of 5kb intervals
awk '!seen[$1,$2,$3]++' sorted_merged_intervals_less_than_5x.bed > unique_5kb_intervals.bed


# The common unique_bed_file for all isolates
unique_bed_file="unique_5kb_intervals.bed"

# Loop through each isolate
for isolate in "${BAM_FILES[@]}"; do
    isolate_bed_file="intervals_less_than_5x_${isolate}.bed"
    output_file="${isolate}_summary.txt"

    # Create a temporary file to store the presence information
    tmp_file=$(mktemp)

    # Loop through intervals in unique_5kb_intervals.bed
    while read -r chrom start stop _; do
        # Check if the interval exists in intervals_less_than_5x_ISOATE.bed
        found=$(awk -v chrom="$chrom" -v start="$start" -v stop="$stop" '$1 == chrom && $2 == start && $3 == stop { found = 1; exit } END { if (found) print 1; else print 0 }' "$isolate_bed_file")
        echo "$chrom $start $stop $found" >> "$tmp_file"
    done < "$unique_bed_file"

    # Sort the temporary file and add the header
    echo -e "Chrom\tStart\tStop\tPresence" > "$output_file"
    sort -k1,1 -k2,2n "$tmp_file" >> "$output_file"

    # Clean up temporary file
    rm "$tmp_file"

    echo "Summary for $isolate is generated in $output_file"
done


# Combine the first three columns from each individual summary file
paste -d $'\t' <(awk '{print $1, $2, $3}' A_S68_B_1_summary.txt) > combined_summary.txt

# Combine the fourth column (Presence) from each individual summary file
for isolate in "${BAM_FILES[@]}"; do
    paste -d $'\t' combined_summary.txt <(awk '{print $4}' "${isolate}_summary.txt") > temp_combined.txt
    mv temp_combined.txt combined_summary.txt
done

# Remove the header from the combined summary file
tail -n +2 combined_summary.txt > temp_combined.txt
mv temp_combined.txt combined_summary.txt

# Add the header with isolate names to the combined summary file
echo -e "Chrom\tStart\tStop\t${BAM_FILES[*]}" | cat - combined_summary.txt > temp_combined.txt
mv temp_combined.txt combined_summary.txt

echo "Combined summary file 'combined_summary.txt' generated."