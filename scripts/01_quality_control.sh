#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 1: Raw-read quality control and trimming
#
# Tools:
#   FastQC
#   fastp
#
# Samples:
#   SRR37849526 = NORMAL
#   SRR37849527 = TUMOR
#
# Input:
#   Paired-end FASTQ files in data/raw/
#
# Output:
#   FastQC reports
#   Trimmed FASTQ files
#   fastp HTML and JSON reports

RAW_DIR="../data/raw"
TRIMMED_DIR="../data/trimmed"

mkdir -p "$TRIMMED_DIR"

echo "Step 1: Raw-read quality control"

# Initial quality assessment
fastqc \
    "$RAW_DIR/SRR37849526_1.fastq" \
    "$RAW_DIR/SRR37849526_2.fastq" \
    "$RAW_DIR/SRR37849527_1.fastq" \
    "$RAW_DIR/SRR37849527_2.fastq"

# Adapter detection and read trimming
fastp \
    -i "$RAW_DIR/SRR37849527_1.fastq" \
    -I "$RAW_DIR/SRR37849527_2.fastq" \
    -o "$TRIMMED_DIR/SRR37849527_trimmed_1.fastq" \
    -O "$TRIMMED_DIR/SRR37849527_trimmed_2.fastq" \
    -h "$TRIMMED_DIR/SRR37849527_fastp.html" \
    -j "$TRIMMED_DIR/SRR37849527_fastp.json" \
    --detect_adapter_for_pe

fastp \
    -i "$RAW_DIR/SRR37849526_1.fastq" \
    -I "$RAW_DIR/SRR37849526_2.fastq" \
    -o "$TRIMMED_DIR/SRR37849526_trimmed_1.fastq" \
    -O "$TRIMMED_DIR/SRR37849526_trimmed_2.fastq" \
    -h "$TRIMMED_DIR/SRR37849526_fastp.html" \
    -j "$TRIMMED_DIR/SRR37849526_fastp.json" \
    --detect_adapter_for_pe

# Quality assessment after trimming
fastqc "$TRIMMED_DIR"/*.fastq

echo "Step 1 complete."
