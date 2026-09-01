#!/usr/bin/env bash
set -euo pipefail

# Breast Cancer Somatic Variant Calling
# Step 2: Alignment and BAM processing
#
# Tools:
#   BWA-MEM
#   samtools
#   GATK MarkDuplicates
#
# Samples:
#   SRR37849526 = NORMAL
#   SRR37849527 = TUMOR
#
# Reference:
#   GRCh38
#
# Workflow:
#   1. Align paired-end reads to GRCh38
#   2. Sort alignments
#   3. Index sorted BAM files
#   4. Generate alignment QC statistics
#   5. Mark PCR/optical duplicates
#   6. Index duplicate-marked BAM files

TRIMMED_DIR="../data/trimmed"
REFERENCE="../reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
ALIGNMENTS="../alignments"
GATK="$HOME/gatk-4.6.2.0/gatk"

mkdir -p "$ALIGNMENTS"

echo "Step 2: Alignment and BAM processing"

# Align normal sample and sort BAM
bwa mem -t 4 \
    -R "@RG\tID:NORMAL\tSM:NORMAL\tPL:ILLUMINA" \
    "$REFERENCE" \
    "$TRIMMED_DIR/SRR37849526_trimmed_1.fastq" \
    "$TRIMMED_DIR/SRR37849526_trimmed_2.fastq" \
    | samtools sort -o "$ALIGNMENTS/SRR37849526_sorted.bam"

# Align tumour sample and sort BAM
bwa mem -t 4 \
    -R "@RG\tID:TUMOR\tSM:TUMOR\tPL:ILLUMINA" \
    "$REFERENCE" \
    "$TRIMMED_DIR/SRR37849527_trimmed_1.fastq" \
    "$TRIMMED_DIR/SRR37849527_trimmed_2.fastq" \
    | samtools sort -o "$ALIGNMENTS/SRR37849527_sorted.bam"

# Index sorted BAM files
samtools index "$ALIGNMENTS/SRR37849526_sorted.bam"
samtools index "$ALIGNMENTS/SRR37849527_sorted.bam"

# Generate alignment QC statistics
samtools flagstat \
    "$ALIGNMENTS/SRR37849526_sorted.bam" \
    > "$ALIGNMENTS/SRR37849526_flagstat.txt"

samtools flagstat \
    "$ALIGNMENTS/SRR37849527_sorted.bam" \
    > "$ALIGNMENTS/SRR37849527_flagstat.txt"

# Mark duplicates
"$GATK" MarkDuplicates \
    -I "$ALIGNMENTS/SRR37849527_sorted.bam" \
    -O "$ALIGNMENTS/SRR37849527_marked.bam" \
    -M "$ALIGNMENTS/SRR37849527_markduplicates_metrics.txt"

"$GATK" MarkDuplicates \
    -I "$ALIGNMENTS/SRR37849526_sorted.bam" \
    -O "$ALIGNMENTS/SRR37849526_marked.bam" \
    -M "$ALIGNMENTS/SRR37849526_markduplicates_metrics.txt"

# Index duplicate-marked BAM files
samtools index "$ALIGNMENTS/SRR37849526_marked.bam"
samtools index "$ALIGNMENTS/SRR37849527_marked.bam"

echo "Step 2 complete."
