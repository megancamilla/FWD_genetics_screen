# FWD_genetics_screen
A set of scripts that uses bedtools and awk for processing re-sequenced UV-mutagenised IPO323 strains

# Script genome_coverage_calculator.sh
## To subdivide the reference genome into intervals and then count intervals where the coverage is less than 5x in individual BAM files
1. Change the path for the REFERENCE_GENOME variable to fit your reference.
2. Set the path for where the individual bam files are located under the variable BAM_PATH
3. Change the list of names for your individual bam files under the BAM_FILES variable (bam file name format should be ISOALTE.sorted.bam)
4. run genome_coverage_calculator.sh in your terminal
5. Expected outputs
   * intervals_5kb.bed that contains the coordinates for each 5kb of your reference
   * coverage_isolate_5kb_intervals.txt that contains the average coverate for each 5kb window for each isolate in your BAM_FILES list
   * intervals_less_than_5x_isolate.txt that contains the intervals with less than 5x coverage for each isolate in your BAM_FILES list
   * merged_intervals_less_than_5x.txt, sorted_merged_intervals_less_than_5x.txt and unique_lessthan5x_intervals.bed (intermediate files but can be useful to look at, unique_lessthan5x_intervals.bed is the most important. This file contains a unique non-redundant list of all the intervals (i.e. in any isolate) where the coverage was less than 5x)
   * isolate_summary.txt, tab-delmited file that summarises if one of the unique_lessthan5x_intervals.bed is present in their individual less_than_5x_intervals.txt file.
   * summary_table.txt, final summary table of all lessthan5x intervals, with a 0 for genome regions that are present in the isolate (i.e. not less than 5x) and a 1 for genomic regions that are absent (i.e. are less than 5x coverage and therefore present in the less_than_5x_isolate.txt file). The 0 and 1 notation is meant to mimic a VCF file format where 0 is equvalent to the reference allele and a 1 indicates a difference from the reference.
  
# Script coverage_calculator_genes.sh
## To find individual genes where the coverage is less than 5x in individual BAM files
1. Change the path for the REFERENCE_GENOME variable to fit your reference. This should be and indexed fasta file, so of the format REFERENCEISOLATE.fasta.fai
2. Change the path for the GFF_FILE which should be the gff3 file showing the location of all genes for your REFERENCE.fasta
3. Set the path for where the individual bam files are located under the variable BAM_PATH
4. Change the list of names for your individual bam files under the BAM_FILES variable (bam file name format should be ISOALTE.sorted.bam)
5. run coverage_calculator_genes.sh in your terminal
6. Expected outputs
   * coverage_ISOLATENAME_INRAE_genes.txt, which is the average coverage for every gene in your gff file. You should get one file for each name in your BAM_FILES variable specified at the top of the script
   * INRAEgenes_less_than_5x_ISOLATE.txt, which is the list of genes with less than 5x coverage in that isolate. Note the INRAE name is specific to the annotation version for IPO323 used for this publication.
   * merged_INRAEgenes_less_than_5x.txt, sorted_merged_INRAEgenes_less_than_5x.txt and unique_INRAE_genes.bed (intermediate files but can be useful to look at, unique_INRAE_genes.bed is the most important. This file contains a unique non-redundant list of all the intervals (i.e. in any isolate) where the coverage for a gene was less than 5x)
   * isolate_summary.txt, tab-delmited file that summarises if one of the unique_INRAE_genes.bed is present in their individual INRAEgenes_less_than_5x_ISOLATE.txt file.
   * combined_summary.txt, final summary table of all genes with less than 5x coverage, with a 0 for genes that are present in the isolate (i.e. not less than 5x) and a 1 for genes that are absent (i.e. are less than 5x coverage and therefore present in the less_than_5x_isolate.txt file). The 0 and 1 notation is meant to mimic a VCF file format where 0 is equvalent to the reference allele and a 1 indicates a difference from the reference.
   
# R Notebook to import and combine the annotated VCF file and the final output combined_summary.txt from the coverage_calculator_genes.sh

