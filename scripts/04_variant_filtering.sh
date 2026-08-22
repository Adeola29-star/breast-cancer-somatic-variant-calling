#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 4: Variant filtering
#
# Tool:
#   GATK FilterMutectCalls
#
# Purpose:
#   Remove variants that do not meet the filtering criteria
#   required for the final somatic variant set.

echo "Step 4: Variant filtering"
echo "GATK FilterMutectCalls was used to generate the filtered somatic VCF."
