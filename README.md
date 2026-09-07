# Breast Cancer Somatic Variant Calling

A reproducible tumour-normal somatic variant-calling workflow for identifying, filtering, annotating, prioritising, and evaluating genetic variants from paired tumour-normal whole-exome sequencing (WES) data.

> **Portfolio project:** Bioinformatics / Cancer Genomics
> **Sequencing:** Paired tumour–normal WES
> **Reference genome:** GRCh38
> **Variant caller:** GATK Mutect2
> **Annotation:** Ensembl Variant Effect Predictor (VEP)
> **Benchmark:** SEQC2 HCC1395 somatic truth set

---

## Problem

Somatic variant calling is a central task in cancer genomics, but identifying candidate variants is only one part of the analysis.

A tumour sample can contain sequencing artefacts, alignment errors, germline variants, and other technical signals that may appear as candidate somatic mutations. Therefore, a useful somatic variant workflow needs to go beyond simply generating a VCF.

The problem addressed in this project was:

> **Can a paired tumour-normal WES workflow identify and characterise somatic variants in the HCC1395 breast cancer model, and how well do the resulting calls agree with an established benchmark truth set?**

The project therefore combines two components:

1. **Somatic variant analysis** - from raw sequencing reads through variant calling, filtering, functional annotation, and biological interpretation.
2. **Benchmark validation** - evaluation of the final variant calls against the SEQC2 HCC1395 somatic truth set within genomic regions that were actually targeted by the WES assay and considered high-confidence by SEQC2.

This provides a more complete assessment of the workflow than reporting variant counts alone.

---

## Project objectives

The objectives of this analysis were to:

1. Perform quality control on paired-end tumour and normal sequencing reads.
2. Trim adapter sequences and low-quality bases.
3. Align sequencing reads to the GRCh38 reference genome.
4. Process aligned reads through sorting and duplicate marking.
5. Perform tumour–normal somatic variant calling using GATK Mutect2.
6. Filter candidate variants using GATK's somatic filtering framework.
7. Annotate filtered variants using Ensembl VEP.
8. Classify variants according to their predicted functional consequences.
9. Prioritise genes containing HIGH-impact variants.
10. Interpret selected cancer-relevant variants biologically.
11. Evaluate the called SNVs and indels against an established HCC1395 benchmark.
12. Calculate precision, recall, and F1-score.
13. Evaluate important limitations of the workflow and distinguish computational interpretation from clinical interpretation.

---

## Dataset

This project uses paired tumour–normal **whole-exome sequencing (WES)** data from the **HCC1395 breast cancer cell line** and its matched normal lymphoblastoid cell line **HCC1395BL**.

| Sample    | Role           | SRA accession |
| --------- | -------------- | ------------- |
| HCC1395   | Tumour         | `SRR37849527` |
| HCC1395BL | Matched normal | `SRR37849526` |

The data are part of **NCBI BioProject PRJNA1445230**, titled *Whole Exome Sequencing of HCC1395 Tumor and Matched Normal HCC1395BL with Bulk RNA-seq of HCC1395*.

The tumour experiment (`SRX32714295`) used:

* **NimbleGen Exome v3** enrichment
* Illumina HiSeq 2500 sequencing
* Whole-exome sequencing
* Hybrid selection
* Paired-end sequencing

The corresponding tumour run (`SRR37849527`) contains approximately 96.1 million paired-end spots and 19.2 Gbases of sequence data.

The analysis used paired tumour and normal FASTQ files and the **GRCh38 primary assembly** as the reference genome.

Raw FASTQ files, BAM files, and reference genome files are not stored in this repository because of their size. The repository instead contains the scripts, figures, tables, benchmark results, and documentation required to understand and reproduce the analytical workflow.

---

## Why WES matters for the benchmark

Because this project uses **whole-exome sequencing rather than whole-genome sequencing**, the sequencing experiment does not provide uniform coverage across the entire genome.

The tumour experiment used the **NimbleGen Exome v3 capture design**, which defines the genomic regions targeted for enrichment and sequencing.

For benchmarking, it would therefore be inappropriate to compare the WES-derived calls against every known HCC1395 variant across the entire genome.

Instead, the benchmark was restricted to:

```text
NimbleGen Exome v3 target regions
                │
                ▼
      SEQC2 high-confidence regions
                │
                ▼
      Benchmark evaluation regions
```

This means that the benchmark asks:

> **How well did the workflow recover benchmark variants in genomic regions that were both targeted by the WES assay and considered high-confidence by SEQC2?**

This provides a more appropriate comparison for the sequencing data used in this project.

---

## Analytical workflow

The primary somatic variant workflow was:

```text
Paired tumour/normal FASTQ
          │
          ▼
       FastQC
          │
          ▼
        fastp
          │
          ▼
   Post-trimming QC
          │
          ▼
      BWA-MEM
          │
          ▼
     Sorted BAM
          │
          ▼
   Duplicate marking
          │
          ▼
     GATK Mutect2
          │
          ▼
   Somatic candidates
          │
          ▼
 FilterMutectCalls
          │
          ▼
    Filtered VCF
          │
          ▼
         VEP
          │
          ▼
Functional annotation
          │
          ▼
 Impact classification
          │
          ▼
High-impact prioritisation
          │
          ▼
Biological interpretation
```

The validation layer was then added after variant calling and filtering:

```text
Filtered somatic calls
          │
          ├───────────────┐
          ▼               │
 Restrict to WES          │
 target regions           │
          │               │
          ▼               │
 Restrict to SEQC2       │
 high-confidence regions  │
          │               │
          ▼               │
 PASS SNVs / indels       │
          │               │
          ▼               │
 Normalisation check      │
          │               │
          └───────┬───────┘
                  ▼
        Compare with SEQC2
          truth variants
                  │
                  ▼
             TP / FP / FN
                  │
                  ▼
       Precision / Recall / F1
```

![Pipeline workflow](figures/pipeline_workflow.png)

---

## Data processing

The sequencing reads underwent:

* Initial quality control using **FastQC**
* Adapter and quality trimming using **fastp**
* Post-trimming quality assessment using **FastQC**
* Alignment to **GRCh38** using **BWA-MEM**
* BAM sorting and indexing using **SAMtools**
* Duplicate marking using **GATK MarkDuplicates**

The processed BAM files were then used as input for tumour–normal somatic variant calling.

---

## Tools and technologies

| Stage                | Tool                   | Purpose                                      |
| -------------------- | ---------------------- | -------------------------------------------- |
| Quality control      | FastQC                 | Assess raw and processed sequencing quality  |
| Read preprocessing   | fastp                  | Adapter trimming and quality filtering       |
| Alignment            | BWA-MEM                | Align reads to GRCh38                        |
| BAM processing       | SAMtools               | Sorting, indexing and alignment statistics   |
| Duplicate marking    | GATK MarkDuplicates    | Identify duplicate reads                     |
| Somatic calling      | GATK Mutect2           | Detect tumour-specific candidate variants    |
| Variant filtering    | GATK FilterMutectCalls | Filter low-confidence somatic calls          |
| Variant annotation   | Ensembl VEP            | Predict variant consequences                 |
| Variant statistics   | bcftools               | Manipulate and summarise VCF files           |
| Benchmark comparison | bcftools isec          | Compare called variants with truth variants  |
| Region intersection  | bedtools               | Define WES/high-confidence benchmark regions |
| Scripting            | Bash                   | Automate workflow steps                      |
| Visualisation        | Python/Matplotlib      | Generate figures                             |

---

## Somatic variant calling and filtering

Somatic variants were called from the paired HCC1395 tumour and HCC1395BL normal samples using **GATK Mutect2**.

The resulting candidate calls were processed using **GATK FilterMutectCalls** to remove calls that were less consistent with high-confidence somatic variation.

The final filtered VCF contained:

| Metric                            | Result |
| --------------------------------- | -----: |
| Samples                           |      2 |
| Variant records                   | 20,937 |
| SNPs                              | 15,097 |
| MNPs                              |    616 |
| Indels                            |  5,375 |
| Multiallelic sites                |  1,567 |
| SNP transition/transversion ratio |   1.20 |

These figures describe the full filtered callset. The subsequent benchmark used a more restricted subset because benchmarking was limited to WES target regions, SEQC2 high-confidence regions, and PASS variants.

Detailed statistics are available in [`results/variant_stats.txt`](results/variant_stats.txt).

---

# Benchmark validation

## Why benchmark the calls?

A variant caller can produce a large number of technically plausible calls, but variant counts alone do not demonstrate accuracy.

To evaluate the performance of the workflow, the HCC1395 calls were compared with the **SEQC2 HCC1395 somatic truth set**.

The benchmark included separate truth resources for:

* SNVs
* Indels
* SEQC2 high-confidence genomic regions

The comparison was deliberately restricted to the intersection between the **NimbleGen Exome v3 WES target regions** and the **SEQC2 high-confidence regions**.

---

## Building the benchmark region

The WES target regions were obtained for the **NimbleGen Exome v3** design.

These regions were intersected with the SEQC2 high-confidence regions:

```text
NimbleGen Exome v3
        ∩
SEQC2 high-confidence regions
        =
Benchmark evaluation region
```

This ensured that variants were evaluated only where:

1. The sequencing experiment was designed to capture the region.
2. The SEQC2 benchmark considered the region sufficiently reliable for truth-set evaluation.

---

## Preparing the called variants

Before comparison, the filtered somatic VCF was processed to make the two datasets comparable.

### 1. Chromosome naming harmonisation

The project VCF and benchmark resources used different chromosome naming conventions in some files.

For example:

```text
1
2
3
```

versus:

```text
chr1
chr2
chr3
```

The chromosome names were therefore harmonised before intersection and comparison.

### 2. WES and high-confidence region restriction

The project calls were restricted to the intersection of:

* NimbleGen Exome v3 target regions
* SEQC2 high-confidence regions

This produced the benchmark evaluation set.

### 3. PASS filtering

Only variants passing the somatic variant filtering criteria were used for the final benchmark.

SNVs and indels were evaluated separately because their calling characteristics and error profiles can differ.

### 4. Variant normalisation

The PASS indels were normalised using `bcftools norm` against the same GRCh38 reference used for the analysis.

The normalisation step produced no changes:

* 132 project PASS indels were unchanged.
* 87 benchmark truth indels were unchanged.

Therefore, normalisation did not alter the final indel benchmark results.

### 5. Variant comparison

The final project calls were compared with the corresponding SEQC2 truth variants using `bcftools isec`.

Exact allele matching was used for the comparison.

The resulting sets were interpreted as:

* **TP — True Positive:** called by the workflow and present in the benchmark truth set.
* **FP — False Positive:** called by the workflow but absent from the benchmark truth set.
* **FN — False Negative:** present in the benchmark truth set but not recovered by the workflow.

Precision, recall, and F1-score were then calculated.

---

# Benchmark results

The final benchmark produced the following results:

| Variant type |    TP |  FP |  FN |  Precision |     Recall |         F1 |
| ------------ | ----: | --: | --: | ---------: | ---------: | ---------: |
| **SNV**      | 1,166 | 307 | 613 | **79.16%** | **65.54%** | **71.71%** |
| **Indel**    |    62 |  70 |  25 | **46.97%** | **71.26%** | **56.62%** |

The complete benchmark output is available in [`benchmark_validation/benchmark_validation_results.tsv`](benchmark_validation/benchmark_validation_results.tsv).

The complete reproducible benchmark script is available in [`benchmark_validation/run_benchmark.sh`](benchmark_validation/run_benchmark.sh).

---

## Interpreting the benchmark

### SNVs

The workflow identified:

* **1,166 true-positive SNVs**
* **307 false-positive SNVs**
* **613 false-negative SNVs**

This produced:

* **Precision = 79.16%**
* **Recall = 65.54%**
* **F1 = 71.71%**

A precision of 79.16% means that, within the benchmark region, approximately 79% of the SNVs called by the workflow were also present in the SEQC2 truth set.

A recall of 65.54% means that the workflow recovered approximately 66% of the benchmark SNVs evaluated in the same region.

The F1-score of 71.71% represents the balance between these two measures.

Therefore, the SNV results show **moderately high precision with lower recall**: the workflow's PASS SNV calls were reasonably enriched for benchmark-supported variants, but a substantial proportion of benchmark SNVs were not recovered.

---

### Indels

The workflow identified:

* **62 true-positive indels**
* **70 false-positive indels**
* **25 false-negative indels**

This produced:

* **Precision = 46.97%**
* **Recall = 71.26%**
* **F1 = 56.62%**

The indel results show a different pattern from the SNVs.

The recall of 71.26% indicates that the workflow recovered a relatively large proportion of the benchmark indels evaluated.

However, the precision of 46.97% indicates that fewer than half of the PASS indel calls matched the benchmark truth set under the comparison criteria.

This illustrates an important practical characteristic of variant calling:

> **Higher sensitivity does not necessarily mean higher precision.**

Indels can be more difficult to call reliably because their detection and representation are more sensitive to alignment ambiguity, local sequence context, and variant representation.

---

## What the benchmark demonstrates

The benchmark does **not** show that the workflow is universally accurate for all breast cancer samples.

Instead, it provides an empirical evaluation of this particular workflow on the HCC1395/HCC1395BL dataset within the defined benchmark regions.

The results demonstrate that:

1. The workflow recovered a substantial number of benchmark-supported SNVs and indels.
2. SNVs showed higher precision than indels.
3. Indels showed higher recall than SNVs in this analysis.
4. The workflow did not recover every benchmark variant.
5. Some called variants did not match the benchmark truth set.
6. Variant-calling performance therefore depends on variant type and the characteristics of the sequencing data and analysis pipeline.

The benchmark should consequently be viewed as a **workflow validation exercise**, rather than a claim of clinical diagnostic accuracy.

---

# Functional consequence annotation

After variant calling and filtering, variants were annotated using **Ensembl Variant Effect Predictor (VEP)**.

VEP was used to determine predicted consequences of variants on genes and transcripts.

The analysis identified a broad range of consequences, including:

* Intron variants
* Non-coding transcript variants
* Non-coding transcript exon variants
* Missense variants
* UTR variants
* Synonymous variants
* Frameshift variants
* Inframe deletions
* Stop-gained variants
* Splice-region and splice-site variants

![Functional consequences](figures/functional_consequences.png)

Detailed counts are available in [`tables/functional_consequences.csv`](tables/functional_consequences.csv).

---

# Variant impact classification

VEP consequences were grouped according to predicted impact:

* **HIGH** — variants predicted to have major effects on gene function
* **MODERATE** — variants potentially affecting protein function
* **LOW** — variants with less severe predicted effects
* **MODIFIER** — variants with limited or uncertain predicted functional impact

![Impact distribution](figures/impact_distribution.png)

The corresponding summary table is available in [`tables/variant_impact_summary.csv`](tables/variant_impact_summary.csv).

Importantly, these impact categories are **computational predictions** and should not be interpreted as equivalent to clinical pathogenicity classifications.

---

# High-impact variant prioritisation

Rather than interpreting every detected variant individually, the analysis prioritised genes containing **HIGH-impact variants**.

The final high-impact gene list contained **169 genes**.

Examples included:

* **BRCA2**
* **KMT2C**
* **NF1**
* **MKI67**
* **KMT2B**
* **MUC4**
* **MUC16**
* **MUC6**
* **FLG**
* **HLA-DQA1**
* **HLA-DRB1**

The complete list is available in [`results/high_impact_genes.txt`](results/high_impact_genes.txt).

![Top high-impact genes](figures/top_high_impact_genes.png)

The gene-level summary is available in [`tables/high_impact_gene_summary.csv`](tables/high_impact_gene_summary.csv).

---

# Biological interpretation of selected variants

Three genes were selected for detailed interpretation because they contained particularly relevant HIGH-impact variants and have established biological roles in cancer.

## BRCA2

A HIGH-impact **stop-gained** variant was identified in **BRCA2**:

**c.4777G>T; p.Glu1593Ter**

A stop-gained variant introduces a premature termination codon into the coding sequence and is predicted to produce a truncated protein.

BRCA2 is involved in homologous recombination-mediated DNA repair. Disruption of BRCA2 function can contribute to impaired DNA repair and genomic instability.

The identification of this predicted protein-disrupting variant therefore provides a biologically plausible link between the variant profile of this sample and impaired DNA repair.

However, the computational identification of a HIGH-impact variant does **not independently establish clinical pathogenicity, functional loss, or treatment eligibility**.

---

## KMT2C

Two HIGH-impact variants were identified in **KMT2C**:

* **Frameshift:** p.Lys2797ArgfsTer26
* **Stop-gained:** p.Cys391Ter

KMT2C, also known as MLL3, encodes a chromatin-regulating histone methyltransferase involved in regulation of gene expression.

Frameshift and stop-gained variants can disrupt protein structure and function.

The presence of two independent HIGH-impact protein-disrupting variants therefore suggests that KMT2C may be substantially affected in this sample.

This remains a computationally derived biological interpretation rather than proof of functional loss.

---

## NF1

A HIGH-impact **splice donor** variant was identified in **NF1**:

**c.730+2T>G**

Splice donor variants can interfere with normal RNA processing and may result in abnormal transcripts.

NF1 encodes neurofibromin, a tumour suppressor that negatively regulates RAS signalling.

The identified splice donor variant is therefore biologically plausible as a variant that could disrupt normal NF1 function and influence RAS pathway regulation.

Again, experimental confirmation would be required to establish the actual effect of the variant on RNA splicing or protein function.

---

# Clinical relevance and interpretation boundaries

The selected variants demonstrate how somatic variant analysis can connect genomic findings with biological mechanisms.

In particular:

* **BRCA2** provides a potential link to DNA repair and homologous recombination.
* **KMT2C** provides a potential link to chromatin and epigenetic regulation.
* **NF1** provides a potential link to RAS signalling.

However, these findings should **not be interpreted as clinical diagnoses**.

This project is a computational bioinformatics analysis using public sequencing data and annotation resources.

Clinical interpretation would require additional evidence, potentially including:

* validated variant classification frameworks
* appropriate clinical databases and guidelines
* tumour purity and clonality assessment
* germline/somatic interpretation where relevant
* orthogonal confirmation where appropriate
* clinical context
* review by appropriately qualified clinical professionals

---

# Pathway analysis

Pathway-level interpretation was also explored using enrichment analysis.

Although some prioritised genes were associated with cancer-related pathways, the analysed gene set did **not produce statistically significant pathway enrichment after multiple-testing correction**.

Therefore, no pathway was presented as a statistically significant finding.

This distinction is important because the presence of a gene in a pathway does not demonstrate that the pathway is significantly enriched or activated in the tumour.

Pathway analysis was therefore treated as **supporting biological context rather than a primary statistical conclusion**.

---

# Limitations

Several limitations should be considered when interpreting this project.

## 1. Single tumour–normal pair

The analysis is based on one tumour-normal sample pair. The observed variant profile and benchmark performance should therefore not be generalised to breast cancer as a whole.

Performance may differ across samples with different tumour purity, sequencing depth, mutation burden, genomic complexity, or technical characteristics.

## 2. WES rather than WGS

The sequencing data are whole-exome data, meaning that the analysis does not evaluate the entire genome uniformly.

Consequently, both variant interpretation and benchmark performance are restricted largely to the regions captured by the WES assay.

## 3. Benchmark region restriction

The benchmark was intentionally restricted to the intersection of the **NimbleGen Exome v3 target regions** and **SEQC2 high-confidence regions**.

Therefore, the reported precision, recall, and F1-scores describe performance within these evaluated regions and should not be interpreted as genome-wide performance.

## 4. Benchmark truth is not absolute clinical truth

The SEQC2 truth set provides an established research benchmark for evaluating somatic variant-calling performance.

It should not be interpreted as an absolute representation of every true biological variant in the sample or as a substitute for clinical validation.

## 5. Variant-calling performance

Somatic variant detection is affected by:

* sequencing depth
* tumour purity
* variant allele fraction
* mapping quality
* local sequence complexity
* sequencing artefacts
* alignment parameters
* filtering thresholds

Different pipeline configurations could therefore produce different precision and recall values.

## 6. Indel representation and calling

Indels can be particularly sensitive to local sequence context and representation.

Although variant normalisation was explicitly checked in this project, normalisation did not change the observed indel calls. The relatively low indel precision therefore remains an important characteristic of this particular analysis rather than an issue that was resolved by normalisation.

## 7. Functional prediction

VEP impact categories are computational predictions.

A HIGH-impact annotation does not independently prove pathogenicity or demonstrate the biological effect of a variant in the tumour.

## 8. Complex genomic regions

Some genes in the HIGH-impact list, including HLA and mucin genes, occur in highly polymorphic, repetitive, or otherwise challenging genomic regions.

Variants in such regions can be more susceptible to mapping and alignment artefacts and would require additional scrutiny before being considered biologically meaningful.

## 9. Clinical interpretation

The project does not establish clinical diagnosis, prognosis, pathogenicity, or treatment eligibility.

The biological interpretations are hypothesis-generating and would require additional evidence and validation for clinical use.

---

# Getting the data

The raw sequencing data and reference genome are not included in this repository due to file size, but can be re-downloaded using the steps below.

## Download raw sequencing reads

Requires the [SRA Toolkit](https://github.com/ncbi/sra-tools).

```bash
prefetch SRR37849526 SRR37849527

fasterq-dump SRR37849526 --split-files -O data/raw/
fasterq-dump SRR37849527 --split-files -O data/raw/
```

## Download the reference genome

```bash
wget https://ftp.ensembl.org/pub/release-116/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz -P reference/

gunzip reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
```

The benchmark additionally requires the appropriate WES target and SEQC2 benchmark resources described in the benchmark validation section.

---

# Reproducibility

The main analytical stages are documented in the shell scripts:

```text
scripts/
├── 01_quality_control.sh
├── 02_alignment_and_bam_processing.sh
├── 03_somatic_variant_calling.sh
├── 04_variant_filtering.sh
├── 05_variant_annotation.sh
└── 06_variant_summary.sh
```

The benchmark validation is separately documented in:

```text
benchmark_validation/
├── benchmark_validation_results.tsv
└── run_benchmark.sh
```

The benchmark script automates:

1. Benchmark region construction
2. Chromosome-name harmonisation
3. WES/high-confidence region restriction
4. PASS variant selection
5. SNV/indel separation
6. Indel normalisation
7. Truth-set preparation
8. Variant comparison
9. TP/FP/FN calculation
10. Precision, recall, and F1 calculation

Processed summary outputs are provided in:

```text
results/
├── high_impact_genes.txt
└── variant_stats.txt
```

Summary tables are provided in:

```text
tables/
├── functional_consequences.csv
├── high_impact_gene_summary.csv
├── pipeline_tools.csv
├── variant_impact_summary.csv
└── variant_summary.csv
```

Figures generated from the analysis are provided in:

```text
figures/
├── functional_consequences.png
├── impact_distribution.png
├── pipeline_workflow.png
├── top_high_impact_genes.png
└── variant_types.png
```

Large raw and intermediate sequencing files are excluded from the repository using `.gitignore`.

---

# Repository structure

```text
breast-cancer-somatic-variant-calling/
│
├── benchmark_validation/
│   ├── benchmark_validation_results.tsv
│   └── run_benchmark.sh
│
├── figures/
│   ├── functional_consequences.png
│   ├── impact_distribution.png
│   ├── pipeline_workflow.png
│   ├── top_high_impact_genes.png
│   └── variant_types.png
│
├── results/
│   ├── high_impact_genes.txt
│   └── variant_stats.txt
│
├── scripts/
│   ├── 01_quality_control.sh
│   ├── 02_alignment_and_bam_processing.sh
│   ├── 03_somatic_variant_calling.sh
│   ├── 04_variant_filtering.sh
│   ├── 05_variant_annotation.sh
│   └── 06_variant_summary.sh
│
├── tables/
│   ├── functional_consequences.csv
│   ├── high_impact_gene_summary.csv
│   ├── pipeline_tools.csv
│   ├── variant_impact_summary.csv
│   └── variant_summary.csv
│
├── .gitignore
└── README.md
```

---

# Conclusion

This project demonstrates an end-to-end tumour–normal somatic variant analysis workflow using paired WES data from the HCC1395 breast cancer model.

The workflow progressed from raw sequencing quality control and preprocessing through alignment, BAM processing, somatic variant calling, filtering, functional annotation, variant prioritisation, and biological interpretation.

Importantly, the project also incorporated an independent benchmark validation layer. The HCC1395 calls were compared with the SEQC2 somatic truth set after restricting both datasets to the intersection of the **NimbleGen Exome v3 target regions** and **SEQC2 high-confidence regions**.

The benchmark produced:

* **SNV precision: 79.16%**
* **SNV recall: 65.54%**
* **SNV F1: 71.71%**
* **Indel precision: 46.97%**
* **Indel recall: 71.26%**
* **Indel F1: 56.62%**

The results show that the workflow recovered a substantial proportion of benchmark-supported variants, while also demonstrating differences between SNV and indel performance.

The downstream analysis identified **169 genes containing HIGH-impact variants** and highlighted **BRCA2, KMT2C, and NF1** for biological interpretation.

Overall, the project demonstrates an important principle in cancer bioinformatics:

> **Variant calling is not the end of the analysis. Confidence in genomic findings requires appropriate filtering, annotation, validation, benchmarking, biological interpretation, and explicit consideration of limitations.**

This project is intended as a **bioinformatics portfolio/research analysis** and not as a clinical diagnostic or treatment tool.

---

# Skills demonstrated

* Tumour–normal somatic variant calling
* Whole-exome sequencing (WES) analysis
* NGS quality control
* FASTQ preprocessing
* Read alignment
* BAM processing
* Duplicate marking
* GATK Mutect2
* GATK somatic variant filtering
* VEP functional annotation
* bcftools
* bedtools
* Variant benchmarking
* TP/FP/FN analysis
* Precision, recall, and F1-score
* Variant normalisation
* Variant prioritisation
* Cancer genomics
* Functional consequence analysis
* Biological interpretation
* Bash scripting
* Python/Matplotlib
* Reproducible bioinformatics workflows
* Critical evaluation of analytical limitations

---

**Note:** This is a portfolio/research project. The results are not intended for clinical diagnosis, prognosis, or treatment decisions.
