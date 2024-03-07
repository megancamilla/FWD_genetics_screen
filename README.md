# FWD_genetics_screen
Script that uses bedtools and awk for processing re-sequenced UV-mutagenised IPO323 strains

## To subdivide the reference genome into intervals and then count intervals where the coverage is less than 5x in individual BAM files
1. Change the path for the REFERENCE_GENOME variable to fit your reference.
2. Set the path for where the individual bam files are located under the variable BAM_PATH
3. Change the list of names for your individual bam files under the BAM_FILES variable (bam file name format should be ISOALTE.sorted.bam)
5. run coverage_calculator.sh in your terminal
6. Expected outputs
   * intervals_5kb.bed that contains the coordinates for each 5kb of your reference
   * coverage_isolate_5kb_intervals.txt that contains the average coverate for each 5kb window for each isolate in your BAM_FILES list
   * intervals_less_than_5x_isolate.txt that contains the intervals with less than 5x coverage for each isolate in your BAM_FILES list
   * merged_intervals_less_than_5x.txt, sorted_merged_intervals_less_than_5x.txt and unique_lessthan5kb_intervals.bed (intermediate files but can be useful to look at, unique_5kb_intervals.bed is the most important. This file contains a unique non-redundant list of all the intervals (i.e. in any isolate) where the coverage was less than 5x)
   * isolate_summary.txt, tab-delmited file that summarises if a 5kb interval contained 
   * summary_table.txt, final summary table of all 5kb intervals, with a 0 for genome regions that are present in the isolate and a 1 for genomic regions that are absent (are less than 5x coverage and therefore present in the less_than_5x_isolate.txt file)
   
