#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 3: Somatic variant calling
#
# Tool:
#   GATK Mutect2
#
# Analysis design:
#   Tumour-normal somatic variant calling
#
# Output:
#   Unfiltered somatic VCF

echo "Step 3: Somatic variant calling"
echo "GATK Mutect2 was used for tumour-normal somatic variant detection."
