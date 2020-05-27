class: CommandLineTool
cwlVersion: v1.0
id: multi_mutect2_svc
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/multi_mutect2:424752c607339af373928b3b8400514827a90eba
doc: |
  Multithreading on GATK3.6 MuTect2 function.

inputs:

  java_heap:
    type: string
    default: '3G'
    doc: Java heap memory.
    inputBinding:
      position: 2
      prefix: '-j'

  ref:
    type: File
    doc: Reference fasta file.
    inputBinding:
      position: 8
      prefix: '-f'
    secondaryFiles:
      - '.fai'
      - '^.dict'

  region:
    type: File
    doc: Region used for scattering.
    inputBinding:
      position: 9
      prefix: '-r'

  tumor_bam:
    type: File
    doc: Tumor bam file.
    inputBinding:
      position: 10
      prefix: '-t'
    secondaryFiles:
      - '.bai'

  normal_bam:
    type: File
    doc: Normal bam file.
    inputBinding:
      position: 11
      prefix: '-n'
    secondaryFiles:
      - '.bai'

  thread_count:
    type: int
    inputBinding:
      position: 12
      prefix: -c

  pon:
    type: File
    doc: Panel of normal reference file path.
    inputBinding:
      position: 13
      prefix: '-p'
    secondaryFiles:
      - '.tbi'

  cosmic:
    type: File
    doc: Cosmic reference file path.
    inputBinding:
      position: 14
      prefix: '-s'
    secondaryFiles:
      - '.tbi'

  dbsnp:
    type: File
    doc: dbSNP reference file path.
    inputBinding:
      position: 15
      prefix: '-d'
    secondaryFiles:
      - '.tbi'

  cont:
    type: float
    default: 0.02
    doc: Contamination estimation score.
    inputBinding:
      position: 16
      prefix: '-e'

  duscb:
    type: boolean
    doc: Whether to use soft clipped bases, default is False.
    default: false
    inputBinding:
      position: 17
      prefix: '-m'

outputs:
  MUTECT2_OUTPUT:
    type: File
    outputBinding:
      glob: 'multi_mutect2_merged.vcf'

baseCommand: ['python3.7', '/opt/multi_mutect2_p3.py']
