class: CommandLineTool
cwlVersion: v1.0
id: mutect2_tumor_only_calling
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: docker.osdc.io/ncigdc/gatk:3.7-6f065cd
  - class: ResourceRequirement
    coresMax: 1
doc: |
  GATK3.6 MuTect2 tumor only calling.

inputs:

  java_heap:
    type: string
    doc: Java heap memory.
    inputBinding:
      position: 2
      prefix: '-Xmx'
      separate: false

  ref:
    type: File
    doc: Reference fasta file.
    inputBinding:
      position: 8
      prefix: -R
    secondaryFiles:
      - '.fai'
      - '^.dict'

  region:
    type: string
    doc: Region used for scattering.
    inputBinding:
      position: 9
      prefix: '-L'

  tumor_bam:
    type: File
    doc: Tumor bam file.
    inputBinding:
      position: 10
      prefix: '-I:tumor'
    secondaryFiles:
      - '^.bai'

  pon:
    type: File
    doc: Panel of normal reference file path.
    inputBinding:
      position: 11
      prefix: '--normal_panel'
    secondaryFiles:
      - '.tbi'

  cosmic:
    type: File
    doc: Cosmic reference file path.
    inputBinding:
      position: 12
      prefix: '--cosmic'
    secondaryFiles:
      - '.tbi'

  dbsnp:
    type: File
    doc: dbSNP reference file path.
    inputBinding:
      position: 13
      prefix: '--dbsnp'
    secondaryFiles:
      - '.tbi'

  cont:
    type: string
    doc: Contamination estimation score.
    inputBinding:
      position: 14
      prefix: '--contamination_fraction_to_filter'

  output_name:
    type: string
    doc: Output file name.
    inputBinding:
      position: 15
      prefix: '-o'

  duscb:
    type: boolean
    doc: Whether to use soft clipped bases, default is False.
    default: false
    inputBinding:
      position: 18
      prefix: '--dontUseSoftClippedBases'

outputs:
  output_file:
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
    position: 17
  - valueFrom: '--disable_auto_index_creation_and_locking_when_reading_rods'
    position: 18
