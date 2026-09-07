#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 5: Functional variant annotation
#
# Tool:
#   Ensembl Variant Effect Predictor (VEP)
#
# Reference:
#   GRCh38
#
# Input:
#   Filtered somatic VCF
#
# Annotation:
#   - consequence
#   - impact
#   - gene symbol
#   - canonical transcript
#   - HGVS
#   - variant class
#   - additional VEP annotations
#
# VEP cache:
#   Ensembl release 116, GRCh38

VEP="$HOME/ensembl-vep/vep"
REFERENCE="../reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
CACHE="$HOME/.vep"
INPUT="../mutect2_output/tumor_normal_filtered.vcf.gz"
OUTPUT="../mutect2_output/tumor_normal_annotated_pick.vep.vcf"

echo "Step 5: Variant annotation"

"$VEP" \
    --cache \
    --offline \
    --dir_cache "$CACHE" \
    --assembly GRCh38 \
    --species homo_sapiens \
    --fasta "$REFERENCE" \
    --vcf \
    --symbol \
    --canonical \
    --hgvs \
    --variant_class \
    --everything \
    --pick \
    --pick_order canonical,appris,tsl,biotype,rank \
    -i "$INPUT" \
    -o "$OUTPUT" \
    --force_overwrite

echo "Step 5 complete."
