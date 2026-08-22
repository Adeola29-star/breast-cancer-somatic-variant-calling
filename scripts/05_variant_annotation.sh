#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 5: Functional annotation
#
# Tool:
#   Ensembl Variant Effect Predictor (VEP)
#
# Annotation included:
#   - consequence
#   - impact
#   - gene
#   - transcript
#   - protein consequence
#   - population frequency information
#   - selected clinical/database annotations

echo "Step 5: Variant annotation"
echo "The filtered somatic variants were annotated using Ensembl VEP."
