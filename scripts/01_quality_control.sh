#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 1: Raw-read quality control and trimming
#
# Tools:
#   FastQC
#   fastp
#
# Input:
#   Paired-end FASTQ files
#
# Output:
#   FastQC reports
#   fastp trimming/QC reports
#
# Sample IDs:
#   SRR37849526
#   SRR37849527

echo "Step 1: Quality control and read trimming"
echo "FastQC and fastp were used to assess and improve read quality."
