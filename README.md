# TCGA_preprocessing

Pipeline to download and preprocess TCGA transcriptome data.

~~~
nextflow run TCGA_pipeline.nf -c TCGA_pipeline.config
~~~

Modify "cancer_type" field of TCGA_pipeline.config file if you want to get data of other cancer type.
Please refer to TCGA Study abbreviation (https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/tcga-study-abbreviations) for available cancer types.
