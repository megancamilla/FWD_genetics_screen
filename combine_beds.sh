#!/bin/bash
BAM_FILES=("A_S68_B_1" "A_S68_B_2" "A_S68_B_3" "A_S68_B_4" "A_S71_A_1" "B_S14_A_1" "B_S14_B_1" "B_S14_C_1" "B_S23_A_1" "B_S23_B_1" "B_S23_C_1" "B_S27_A_2" "B_S27_B_1" "B_S27_C_1" "UV80_1" "UV80_2" "UV80_3" "UV80_4")

unique_bed_file="unique_5kb_intervals.bed"
isolate_bed_file="intervals_less_than_5x_UV80_4.bed"
output_file="ISOLATE_summary.txt"

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