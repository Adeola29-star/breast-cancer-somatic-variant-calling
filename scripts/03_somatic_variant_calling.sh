#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 3: Somatic variant calling
#
# Tool:
#   GATK Mutect2
#
# Samples:
#   SRR37849527 = TUMOR
#   SRR37849526 = NORMAL
#
# Reference:
#   GRCh38
#
# Input:
#   Duplicate-marked BAM files
#
# Output:
#   Unfiltered somatic VCF

REFERENCE="../reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
ALIGNMENTS="../alignments"
OUTPUT="../mutect2_output"
GATK="$HOME/gatk-4.6.2.0/gatk"

mkdir -p "$OUTPUT"

echo "Step 3: Somatic variant calling"

"$GATK" Mutect2 \
    -R "$REFERENCE" \
    -I "$ALIGNMENTS/SRR37849527_marked.bam" \
    -I "$ALIGNMENTS/SRR37849526_marked.bam" \
    -normal NORMAL \
    -O "$OUTPUT/tumor_normal_unfiltered.vcf.gz"

echo "Step 3 complete."
