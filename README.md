# GDC GATK3 MuTect2 CWL
![Version badge](https://img.shields.io/badge/GATK3.6-nightly--2016--02--25--gf39d340-<COLOR>.svg)

The GATK3 MuTect2 pipeline employs a "Panel of Normals" to identify additional germline mutations. This panel is generated using TCGA blood normal genomes from thousands of individuals that were curated and confidently assessed to be cancer-free. This method allows for a higher level of confidence to be assigned to somatic variants that were called by the MuTect2 pipeline.

Original MuTect2: https://gatkforums.broadinstitute.org/gatk/discussion/9183/how-to-call-somatic-snvs-and-indels-using-mutect2

## Docker

All the docker images are built from `Dockerfile`s at https://github.com/NCI-GDC/mutect2-tool.

## CWL

https://www.commonwl.org/

The CWL are tested under multiple `cwltools` environments. The most tested one is:
* cwltool 1.0.20180306163216


## For external users
The repository has only been tested on GDC data and in the particular environment GDC is running in. Some of the reference data required for the workflow production are hosted in [GDC reference files](https://gdc.cancer.gov/about-data/data-harmonization-and-generation/gdc-reference-files "GDC reference files"). For any questions related to GDC data, please contact the GDC Help Desk at support@nci-gdc.datacommons.io.

There is a production-ready GDC CWL workflow at https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow, which uses this repo as a git submodule.

Please notice that you may want to change the docker image host of `dockerPull:` for each CWL.

To use CWL directly from this repo, we recommend to run
* `tools/mutect2_pon.cwl` on the normal BAM file from the "panel of normal".
* `tools/mutect2_somatic_variant.cwl` for GATK3 MuTect2 tumor/normal pair variant calling or `tools/multi_mutect2_svc.cwl` if you prefer parallelization on docker level.

To run CWL:

```
>>>>>>>>>>MuTect2 PON<<<<<<<<<<
cwltool tools/mutect2_pon.cwl -h
/home/ubuntu/.virtualenvs/p2/bin/cwltool 1.0.20180306163216
Resolved 'tools/mutect2_pon.cwl' to 'file:///mnt/SCRATCH/githubs/submodules/t/mutect2-cwl/tools/mutect2_pon.cwl'
usage: tools/mutect2_pon.cwl [-h] --cont CONT --cosmic COSMIC --dbsnp DBSNP
                             --duscb --java_heap JAVA_HEAP --normal_bam
                             NORMAL_BAM --output_name OUTPUT_NAME --ref REF
                             --region REGION
                             [job_order]

positional arguments:
  job_order             Job input json file

optional arguments:
  -h, --help            show this help message and exit
  --cont CONT           Contamination estimation score.
  --cosmic COSMIC       Cosmic reference file path.
  --dbsnp DBSNP         dbSNP reference file path.
  --duscb               Whether to use soft clipped bases, default is False.
  --java_heap JAVA_HEAP
                        Java heap memory.
  --normal_bam NORMAL_BAM
                        Normal bam file.
  --output_name OUTPUT_NAME
                        Output file name.
  --ref REF             Reference fasta file.
  --region REGION       Region used for scattering.



>>>>>>>>>>MuTect2 tumor/normal pair variant calling<<<<<<<<<<
cwltool tools/mutect2_somatic_variant.cwl -h
/home/ubuntu/.virtualenvs/p2/bin/cwltool 1.0.20180306163216
Resolved 'tools/mutect2_somatic_variant.cwl' to 'file:///mnt/SCRATCH/githubs/submodules/t/mutect2-cwl/tools/mutect2_somatic_variant.cwl'
usage: tools/mutect2_somatic_variant.cwl [-h] [--cont CONT] --cosmic COSMIC
                                         --dbsnp DBSNP --duscb
                                         [--java_heap JAVA_HEAP] --normal_bam
                                         NORMAL_BAM --pon PON --ref REF
                                         --region REGION --tumor_bam TUMOR_BAM
                                         [job_order]

positional arguments:
  job_order             Job input json file

optional arguments:
  -h, --help            show this help message and exit
  --cont CONT           Contamination estimation score.
  --cosmic COSMIC       Cosmic reference file path.
  --dbsnp DBSNP         dbSNP reference file path.
  --duscb               Whether to use soft clipped bases, default is False.
  --java_heap JAVA_HEAP
                        Java heap memory.
  --normal_bam NORMAL_BAM
                        Normal bam file.
  --pon PON             Panel of normal reference file path.
  --ref REF             Reference fasta file.
  --region REGION       Region used for scattering.
  --tumor_bam TUMOR_BAM
                        Tumor bam file.
```

## For GDC users

See https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow.
