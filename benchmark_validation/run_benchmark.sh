#!/bin/bash

set -e

# ============================================================
# HCC1395/HCC1395BL Somatic Variant Benchmark
# SEQC2 truth set
# NimbleGen Exome v3 + SEQC2 high-confidence regions
# ============================================================

# Input files
OWN_VCF="mutect2_output/tumor_normal_filtered.vcf.gz"
SNV_TRUTH="truth/hcc1395_snv_truth.vcf.gz"
INDEL_TRUTH="truth/hcc1395_indel_truth.vcf.gz"
TARGET_BED="targets/NimbleGenExome_v3_GRCh38_primary_chr.bed"
TARGET_BED_NOCHR="targets/NimbleGenExome_v3_GRCh38_primary_nochr.bed"
HC_BED="truth/High-Confidence_Regions_v1.2.bed"
REFERENCE="reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

# Output directories
mkdir -p benchmark_validation/tmp

echo "=== Preparing benchmark regions ==="

bedtools intersect \
    -a "$TARGET_BED" \
    -b "$HC_BED" \
    > benchmark_validation/tmp/NimbleGenExome_v3_SEQC2_HC.bed

echo "=== Converting own VCF chromosome names to chr format ==="

bcftools annotate \
    --rename-chrs <(
        awk '{print $1"\tchr"$1}' "$TARGET_BED_NOCHR" | sort -u
    ) \
    "$OWN_VCF" \
    -Oz \
    -o benchmark_validation/tmp/own_chr.vcf.gz

bcftools index -f benchmark_validation/tmp/own_chr.vcf.gz

echo "=== Restricting own calls to benchmark regions ==="

bcftools view -R \
    benchmark_validation/tmp/NimbleGenExome_v3_SEQC2_HC.bed \
    benchmark_validation/tmp/own_chr.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/own_WES_HC.vcf.gz

bcftools index -f benchmark_validation/tmp/own_WES_HC.vcf.gz

echo "=== Separating PASS SNVs and indels ==="

bcftools view -f PASS -v snps \
    benchmark_validation/tmp/own_WES_HC.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/own_SNVs_PASS.vcf.gz

bcftools index -f benchmark_validation/tmp/own_SNVs_PASS.vcf.gz

bcftools view -f PASS -v indels \
    benchmark_validation/tmp/own_WES_HC.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/own_indels_PASS_chr.vcf.gz

bcftools index -f benchmark_validation/tmp/own_indels_PASS_chr.vcf.gz

echo "=== Preparing indels for normalization ==="

bcftools annotate \
    --rename-chrs <(
        awk '{print "chr"$1"\t"$1}' "$TARGET_BED_NOCHR" | sort -u
    ) \
    benchmark_validation/tmp/own_indels_PASS_chr.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/own_indels_PASS_nochr.vcf.gz

bcftools index -f benchmark_validation/tmp/own_indels_PASS_nochr.vcf.gz

bcftools norm \
    -f "$REFERENCE" \
    -m -any \
    benchmark_validation/tmp/own_indels_PASS_nochr.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/own_indels_PASS_norm.vcf.gz

bcftools index -f benchmark_validation/tmp/own_indels_PASS_norm.vcf.gz

echo "=== Restricting truth sets to benchmark regions ==="

bcftools view -R \
    benchmark_validation/tmp/NimbleGenExome_v3_SEQC2_HC.bed \
    "$SNV_TRUTH" \
    -Oz \
    -o benchmark_validation/tmp/SNV_truth_WES_HC.vcf.gz

bcftools index -f benchmark_validation/tmp/SNV_truth_WES_HC.vcf.gz

bcftools view -R \
    benchmark_validation/tmp/NimbleGenExome_v3_SEQC2_HC.bed \
    "$INDEL_TRUTH" \
    -Oz \
    -o benchmark_validation/tmp/indel_truth_WES_HC_chr.vcf.gz

bcftools index -f benchmark_validation/tmp/indel_truth_WES_HC_chr.vcf.gz

echo "=== Preparing truth indels for normalization ==="

bcftools annotate \
    --rename-chrs <(
        awk '{print "chr"$1"\t"$1}' "$TARGET_BED_NOCHR" | sort -u
    ) \
    benchmark_validation/tmp/indel_truth_WES_HC_chr.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/indel_truth_WES_HC_nochr.vcf.gz

bcftools index -f benchmark_validation/tmp/indel_truth_WES_HC_nochr.vcf.gz

bcftools norm \
    -f "$REFERENCE" \
    -m -any \
    benchmark_validation/tmp/indel_truth_WES_HC_nochr.vcf.gz \
    -Oz \
    -o benchmark_validation/tmp/indel_truth_WES_HC_norm.vcf.gz

bcftools index -f benchmark_validation/tmp/indel_truth_WES_HC_norm.vcf.gz

echo "=== Benchmarking SNVs ==="

rm -rf benchmark_validation/tmp/isec_SNVs

bcftools isec \
    -p benchmark_validation/tmp/isec_SNVs \
    benchmark_validation/tmp/own_SNVs_PASS.vcf.gz \
    benchmark_validation/tmp/SNV_truth_WES_HC.vcf.gz

SNV_FP=$(bcftools view -H benchmark_validation/tmp/isec_SNVs/0000.vcf | wc -l)
SNV_FN=$(bcftools view -H benchmark_validation/tmp/isec_SNVs/0001.vcf | wc -l)
SNV_TP=$(bcftools view -H benchmark_validation/tmp/isec_SNVs/0002.vcf | wc -l)

echo "SNV TP=$SNV_TP FP=$SNV_FP FN=$SNV_FN"

echo "=== Benchmarking indels ==="

rm -rf benchmark_validation/tmp/isec_indels

bcftools isec \
    -p benchmark_validation/tmp/isec_indels \
    benchmark_validation/tmp/own_indels_PASS_norm.vcf.gz \
    benchmark_validation/tmp/indel_truth_WES_HC_norm.vcf.gz

INDEL_FP=$(bcftools view -H benchmark_validation/tmp/isec_indels/0000.vcf | wc -l)
INDEL_FN=$(bcftools view -H benchmark_validation/tmp/isec_indels/0001.vcf | wc -l)
INDEL_TP=$(bcftools view -H benchmark_validation/tmp/isec_indels/0002.vcf | wc -l)

echo "INDEL TP=$INDEL_TP FP=$INDEL_FP FN=$INDEL_FN"

echo "=== Calculating metrics ==="

python3 - <<PY

results = [
    ("SNV", $SNV_TP, $SNV_FP, $SNV_FN),
    ("INDEL", $INDEL_TP, $INDEL_FP, $INDEL_FN),
]

with open("benchmark_validation/benchmark_validation_results.tsv", "w") as f:

    f.write(
        "variant_type\tTP\tFP\tFN\tprecision\trecall\tF1\n"
    )

    for variant, tp, fp, fn in results:

        precision = tp / (tp + fp) if (tp + fp) else 0
        recall = tp / (tp + fn) if (tp + fn) else 0

        f1 = (
            2 * precision * recall / (precision + recall)
            if (precision + recall)
            else 0
        )

        f.write(
            f"{variant}\t{tp}\t{fp}\t{fn}\t"
            f"{precision*100:.2f}\t"
            f"{recall*100:.2f}\t"
            f"{f1*100:.2f}\n"
        )

print("Benchmark results written to:")
print("benchmark_validation/benchmark_validation_results.tsv")

PY

echo "=== Benchmark complete ==="