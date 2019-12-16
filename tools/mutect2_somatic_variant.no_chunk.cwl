class: CommandLineTool
cwlVersion: v1.0
id: mutect2_somatic_variant.no_chunk
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk3:nightly-2016-02-25-gf39d340
  - class: ResourceRequirement
    coresMax: 1
doc: |
  GATK3.6 MuTect2. The `region` flag is optional and it works as `-L` in `MuTect2`.
  This tool is used in downstream CWL `no_chunk` workflow.

inputs:

  java_heap:
    type: string
    default: '3G'
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
    type: File?
    doc: Region used for scattering.
    inputBinding:
      prefix: -L
      position: 9

  tumor_bam:
    type: File
    doc: Tumor bam file.
    inputBinding:
      position: 10
      prefix: '-I:tumor'
    secondaryFiles:
      - '.bai'

  normal_bam:
    type: File
    doc: Normal bam file.
    inputBinding:
      position: 11
      prefix: '-I:normal'
    secondaryFiles:
      - '.bai'

  pon:
    type: File
    doc: Panel of normal reference file path.
    inputBinding:
      position: 12
      prefix: '--normal_panel'
    secondaryFiles:
      - '.tbi'

  cosmic:
    type: File
    doc: Cosmic reference file path.
    inputBinding:
      position: 13
      prefix: '--cosmic'
    secondaryFiles:
      - '.tbi'

  dbsnp:
    type: File
    doc: dbSNP reference file path.
    inputBinding:
      position: 14
      prefix: '--dbsnp'
    secondaryFiles:
      - '.tbi'

  cont:
    type: float
    default: 0.02
    doc: Contamination estimation score.
    inputBinding:
      position: 15
      prefix: '--contamination_fraction_to_filter'

  duscb:
    type: boolean
    doc: Whether to use soft clipped bases, default is False.
    default: false
    inputBinding:
      position: 19
      prefix: '--dontUseSoftClippedBases'

outputs:
  MUTECT2_OUTPUT:
    type: File
    outputBinding:
      glob: 'chunk.mutect2.vcf.gz'
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
  - valueFrom: $('chunk.mutect2.vcf.gz')
    prefix: '-o'
    position: 16
  - valueFrom: 'EMIT_VARIANTS_ONLY'
    prefix: '--output_mode'
    position: 17
  - valueFrom: '--disable_auto_index_creation_and_locking_when_reading_rods'
    position: 18
