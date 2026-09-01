#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 6: Variant summary and biological interpretation
#
# Tools:
#   bcftools
#   Ensembl VEP filter_vep
#   Standard Unix command-line utilities
#
# Input:
#   Filtered and VEP-annotated somatic VCF
#
# Outputs:
#   - variant statistics
#   - functional consequence summary
#   - gene summary
#   - impact-specific VCF files
#   - high-impact gene list

INPUT="../mutect2_output/tumor_normal_annotated_pick.vep.vcf"
FILTERED="../mutect2_output/tumor_normal_filtered.vcf.gz"
OUTPUT="../mutect2_output"
VEP_FILTER="$HOME/ensembl-vep/filter_vep"

echo "Step 6: Variant summary and biological interpretation"

# Generate overall variant statistics
bcftools stats "$FILTERED" > "$OUTPUT/variant_stats.txt"

# Summarise functional consequences
grep -v "^#" "$INPUT" \
    | cut -f8 \
    | grep -o "CSQ=[^;]*" \
    | cut -d'=' -f2 \
    | cut -d'|' -f2 \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -20

# Summarise genes represented in the annotated variants
grep -v "^#" "$INPUT" \
    | cut -f8 \
    | grep -o "CSQ=[^;]*" \
    | cut -d'=' -f2 \
    | cut -d'|' -f4 \
    | grep -v "^$" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -30

# Separate variants by predicted functional impact
"$VEP_FILTER" \
    -i "$INPUT" \
    -o "$OUTPUT/high_impact.vcf" \
    --filter "IMPACT is HIGH" \
    --force_overwrite

"$VEP_FILTER" \
    -i "$INPUT" \
    -o "$OUTPUT/moderate_impact.vcf" \
    --filter "IMPACT is MODERATE" \
    --force_overwrite

"$VEP_FILTER" \
    -i "$INPUT" \
    -o "$OUTPUT/low_impact.vcf" \
    --filter "IMPACT is LOW" \
    --force_overwrite

"$VEP_FILTER" \
    -i "$INPUT" \
    -o "$OUTPUT/modifier_impact.vcf" \
    --filter "IMPACT is MODIFIER" \
    --force_overwrite

# Extract unique genes from the high-impact variant set
grep -v "^#" "$OUTPUT/high_impact.vcf" \
    | perl -ne 'if(/CSQ=([^;]+)/){ @a=split(/,/, $1); for(@a){ @f=split(/\|/); print "$f[3]\n" if $f[3] ne "" } }' \
    | sort -u \
    > "$OUTPUT/high_impact_genes.txt"

# Summarise high-impact genes
grep -v "^#" "$OUTPUT/high_impact.vcf" \
    | cut -f8 \
    | grep -o "CSQ=[^;]*" \
    | cut -d'=' -f2 \
    | cut -d'|' -f4 \
    | grep -v "^$" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -30

echo "Step 6 complete."
