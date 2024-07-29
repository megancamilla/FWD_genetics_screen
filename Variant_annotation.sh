#!/bin/bash
BAM_FILES=("A_S68_B_1" "A_S68_B_2" "A_S68_B_3" "A_S68_B_4" "A_S71_A_1" "B_S14_A_1" "B_S14_B_1" "B_S14_C_1" "B_S23_A_1" "B_S23_B_1" "B_S23_C_1" "B_S27_A_2" "B_S27_B_1" "B_S27_C_1" "UV80_1" "UV80_2" "UV80_3" "UV80_4")
REFERENCE="/PATHTOYOURFILES/IPO323.fasta"
GFF="/PATHTOYOURFILES/Zymtr1_INRAE_GeneModels_genes_20230422.gff3"

##### STEP 1: Remove all ISOLATE and chr names from the fasta file. VEP only accepts numeric chromosome names
cat IPO323.fasta | grep ">"

bgzip -c "$REFERENCE" > genome.fa.gz

echo "If you see anthing other than chromosome numbers above you need to fix your fasta file as the VEP tool only accepts 1, 2, 3...as chromosome names"

##### STEP 2: Format your gff3 file to fit the VEP rules and expectations..

sed 's/three_prime_UTR/3_prime_UTR/g; s/five_prime_UTR/5_prime_UTR/g' "$GFF" | grep -v "#" | sort -k1,1 -k4,4n -k5,5n -t$'\t' | bgzip -c > data.gff.gz
tabix -p gff data.gff.gz

#### STEP 3: Format your vcf file to remove isolate name and chr
awk '{gsub(/IPO323_chr_/, ""); print}' all.filtered.vcf > allnumeric.filtered.vcf



#### STEP 4: Run VEP with your newly formated reference and gff file named according to the tool guidlines
BAM_FILES_STR=$(printf "%s," "${BAM_FILES[@]}")
BAM_FILES_STR=${BAM_FILES_STR%?}  # Remove the trailing comma

echo "$BAM_FILES_STR"

vep -i allnumeric.filtered.vcf --gff data.gff.gz --fasta genome.fa.gz --distance 500 --individual "${BAM_FILES_STR}" --force_overwrite
filter_vep -i variant_effect_output.txt -o filtered_variant_effect.txt -filter "IMPACT is not MODIFIER" --force_overwrite
