#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 4: Variant filtering
#
# Tool:
#   GATK FilterMutectCalls
#
# Reference:
#   GRCh38
#
# Input:
#   Unfiltered somatic VCF produced by Mutect2
#
# Output:
#   Filtered somatic VCF

REFERENCE="../reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
OUTPUT="../mutect2_output"
GATK="$HOME/gatk-4.6.2.0/gatk"

echo "Step 4: Variant filtering"

"$GATK" FilterMutectCalls \
    -R "$REFERENCE" \
    -V "$OUTPUT/tumor_normal_unfiltered.vcf.gz" \
    -O "$OUTPUT/tumor_normal_filtered.vcf.gz"

echo "Step 4 complete."
