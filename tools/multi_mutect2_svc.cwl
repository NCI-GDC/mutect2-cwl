class: CommandLineTool
cwlVersion: v1.0
id: multi_mutect2_svc
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/mutect2-tool:1.0.0-70.ccea14b
doc: |
  Multithreading on GATK3.6 MuTect2 function.

inputs:

  java_heap:
    type: string
    default: '3G'
    doc: Java heap memory.
    inputBinding:
      position: 2
      prefix: '--java-heap'

  ref:
    type: File
    doc: Reference fasta file.
    inputBinding:
      position: 8
      prefix: '--reference-path'
    secondaryFiles:
      - '.fai'
      - '^.dict'

  region:
    type: File
    doc: Region used for scattering.
    inputBinding:
      position: 9
      prefix: '--interval-bed-path'

  tumor_bam:
    type: File
    doc: Tumor bam file.
    inputBinding:
      position: 10
      prefix: '--tumor-bam'
    secondaryFiles:
      - '.bai'

  normal_bam:
    type: File
    doc: Normal bam file.
    inputBinding:
      position: 11
      prefix: '--normal-bam'
    secondaryFiles:
      - '.bai'

  thread_count:
    type: int
    inputBinding:
      position: 12
      prefix: '--thread-count'

  pon:
    type: File
    doc: Panel of normal reference file path.
    inputBinding:
      position: 13
      prefix: '--pon'
    secondaryFiles:
      - '.tbi'

  cosmic:
    type: File
    doc: Cosmic reference file path.
    inputBinding:
      position: 14
      prefix: '--cosmic'
    secondaryFiles:
      - '.tbi'

  dbsnp:
    type: File
    doc: dbSNP reference file path.
    inputBinding:
      position: 15
      prefix: '--dbsnp'
    secondaryFiles:
      - '.tbi'

  cont:
    type: float
    default: 0.02
    doc: Contamination estimation score.
    inputBinding:
      position: 16
      prefix: '--contest'

  duscb:
    type: boolean
    doc: Whether to use soft clipped bases, default is False.
    default: false
    inputBinding:
      position: 17
      prefix: '--not_clipped_bases'

  timeout:
    type: int?
    inputBinding:
      position: 99
      prefix: --timeout
outputs:
  MUTECT2_OUTPUT:
    type: File
    outputBinding:
      glob: 'multi_mutect2_merged.vcf'

baseCommand: ['mutect2_tool']
