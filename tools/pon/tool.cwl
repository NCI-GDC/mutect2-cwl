#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - $import: ../envvar-global.cwl
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/mutect2-tool:nightly-2016-02-25-gf39d340

inputs:

  - id: java_heap
    type: string
    inputBinding:
      position: 2
      prefix: '-Xmx'
      separate: false

  - id: ref
    type: File
    inputBinding:
      position: 8
      prefix: -R
    secondaryFiles:
      - '.fai'
      - '^.dict'

  - id: region
    type: string
    inputBinding:
      position: 9
      prefix: '-L'

  - id: normal_bam
    type: File
    inputBinding:
      position: 10
      prefix: '-I:tumor'
    secondaryFiles:
      - '^.bai'

  - id: cosmic
    type: File
    inputBinding:
      position: 11
      prefix: '--cosmic'
    secondaryFiles:
      - '.tbi'

  - id: dbsnp
    type: File
    inputBinding:
      position: 12
      prefix: '--dbsnp'
    secondaryFiles:
      - '.tbi'

  - id: cont
    type: string
    inputBinding:
      position: 13
      prefix: '--contamination_fraction_to_filter'

  - id: output_name
    type: string
    inputBinding:
      position: 14
      prefix: '-o'

  - id: duscb
    type: boolean
    default: false
    inputBinding:
      position: 18
      prefix: '--dontUseSoftClippedBases'

outputs:
  - id: output_file
    type: File
    outputBinding:
      glob: $(inputs.output_name)
    secondaryFiles:
      - '.tbi'

baseCommand: ['java', '-d64']
arguments:
  - valueFrom: '-XX:+UseSerialGC'
    position: 3
  - valueFrom: '/home/ubuntu/tools/GenomeAnalysisTK.jar'
    prefix: '-jar'
    position: 4
  - valueFrom: 'MuTect2'
    prefix: '-T'
    position: 5
  - valueFrom: '1'
    prefix: '-nct'
    position: 6
  - valueFrom: '1'
    prefix: '-nt'
    position: 7
  - valueFrom: 'EMIT_VARIANTS_ONLY'
    prefix: '--output_mode'
    position: 15
  - valueFrom: '--disable_auto_index_creation_and_locking_when_reading_rods'
    position: 16
  - valueFrom: '--artifact_detection_mode'
    position: 17
