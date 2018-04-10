#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/multi_mutect2:1.0

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
    type: File[]
    outputBinding:
      glob: '*.mt2.vcf.gz'
    secondaryFiles:
      - '.tbi'

baseCommand: ['python', '/bin/multi_mutect2.py']
