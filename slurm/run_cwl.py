import argparse
import pipelineUtil
import uuid
import os
import postgres
import status_postgres
import setupLog
import logging
import tempfile
import time
import datetime
from elapsed_time import Time as Time

def update_postgres(exit, cwl_failure, vcf_upload_location, mutect_location, logger):
    """ update the status of job on postgres """

    loc = 'UNKNOWN'
    status = 'UNKNOWN'

    if exit == 0:

        loc = vcf_upload_location

        if not(cwl_failure):

            status = 'COMPLETED'
            logger.info("uploaded all files to object store. The path is: %s" %mutect_location)

        else:

            status = 'CWL_FAILED'
            logger.info("CWL failed but outputs were generated. The path is: %s" %mutect_location)

    else:

        loc = 'Not Applicable'

        if not(cwl_failure):

            status = 'UPLOAD_FAILURE'
            logger.info("Upload of files failed")

        else:
            status = 'FAILED'
            logger.info("CWL and upload both failed")

    return(status, loc)

def is_nat(x):
    '''
    Checks that a value is a natural number.
    '''
    if int(x) > 0:
        return int(x)
    raise argparse.ArgumentTypeError('%s must be positive, non-zero' % x)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Run mutect variant calling CWL")
    required = parser.add_argument_group("Required input parameters")
    required.add_argument("--refdir", help="path to reference dir on object store")
    required.add_argument("--block", type=is_nat, default=50000000, help="parallel block size")
    required.add_argument('--thread_count', type=is_nat, default=8, help='thread count')
    required.add_argument('--java_heap', default=None, help='java heap')
    required.add_argument('--contEst', default=None, help='Contamination Estimation')

    required.add_argument("--normal", default=None, help="path to normal bam file")
    required.add_argument("--tumor", default=None, help="path to tumor bam file")
    required.add_argument("--normal_id", default=None, help="UUID for normal BAM")
    required.add_argument("--tumor_id", default=None, help="UUID for tumor BAM")
    required.add_argument("--case_id", default=None, help="UUID for case")

    required.add_argument("--cwl", default=None, help="Path to CWL code")

    optional = parser.add_argument_group("Optional input parameters")
    optional.add_argument("--s3dir", default="s3://ceph_kh11_mutect2_variant", help="path to output files")
    optional.add_argument("--basedir", default="/mnt/SCRATCH/", help="Base directory for computations")

    args = parser.parse_args()

    if not os.path.isdir(args.basedir):
        raise Exception("Could not find path to base directory: %s" %args.basedir)

    #create directory structure
    casedir = tempfile.mkdtemp(prefix="mutect_%s_" %args.case_id, dir=args.basedir)
    workdir = tempfile.mkdtemp(prefix="workdir_", dir=casedir)
    inp = tempfile.mkdtemp(prefix="input_", dir=casedir)
    index = args.refdir

    #generate a random uuid
    vcf_uuid = uuid.uuid4()
    vcf_file = "%s.vcf" %(str(vcf_uuid))

    #setup logger
    log_file = os.path.join(workdir, "%s.mutect.cwl.log" %str(vcf_uuid))
    logger = setupLog.setup_logging(logging.INFO, str(vcf_uuid), log_file)

    #logging inputs
    logger.info("normal_bam_path: %s" %(args.normal))
    logger.info("normal_bam_id: %s" %(args.normal_id))
    logger.info("tumor_bam_path: %s" %(args.tumor))
    logger.info("tumor_bam_id: %s" %(args.tumor_id))
    logger.info("case_id: %s" %(args.case_id))
    logger.info("vcf_id: %s" %(str(vcf_uuid)))

    #Get datetime
    datetime_now = str(datetime.datetime.now())
    #Get CWL start time
    cwl_start = time.time()

    #download
    logger.info("getting refs")
    reference_fasta_path = os.path.join(index,"GRCh38.d1.vd1.fa")
    reference_fasta_fai = os.path.join(index,"GRCh38.d1.vd1.fa.fai")
    reference_fasta_dict = os.path.join(index,"GRCh38.d1.vd1.dict")
    pon_path = os.path.join(index, "MuTect2.PON.5210.vcf.gz")
    known_snp_vcf_path = os.path.join(index,"dbsnp_144.grch38.vcf")
    cosmic_path = os.path.join(index,"CosmicCombined.srt.vcf")
    postgres_config = os.path.join(index,"postgres_config")

    logger.info("getting normal bam")
    normal_path = os.path.dirname(args.normal)+'/'
    if normal_path.startswith("s3://ceph_"):
        pipelineUtil.download_from_cleversafe(logger, normal_path, inp, "ceph", "http://gdc-cephb-objstore.osdc.io/")
        bam_norm = os.path.join(inp, os.path.basename(args.normal))
    else:
        pipelineUtil.download_from_cleversafe(logger, normal_path, inp, "cleversafe", "http://gdc-accessors.osdc.io/")
        bam_norm = os.path.join(inp, os.path.basename(args.normal))

    logger.info("getting tumor bam")
    tumor_path = os.path.dirname(args.tumor)+'/'
    if tumor_path.startswith("s3://ceph_"):
        pipelineUtil.download_from_cleversafe(logger, tumor_path, inp, "ceph", "http://gdc-cephb-objstore.osdc.io/")
        bam_tumor = os.path.join(inp, os.path.basename(args.tumor))
    else:
        pipelineUtil.download_from_cleversafe(logger, tumor_path, inp, "cleversafe", "http://gdc-accessors.osdc.io/")
        bam_tumor = os.path.join(inp, os.path.basename(args.tumor))

    os.chdir(workdir)
    #run cwl command
    cmd = ['/home/ubuntu/.virtualenvs/p2/bin/cwl-runner',
            "--debug",
            "--tmpdir-prefix", inp,
            "--tmp-outdir-prefix", workdir,
            args.cwl,
            "--reference_fasta_path", reference_fasta_path,
            "--reference_fasta_fai", reference_fasta_fai,
            "--reference_fasta_dict", reference_fasta_dict,
            "--normal_bam_path", bam_norm,
            "--tumor_bam_path", bam_tumor,
            "--normal_id", args.normal_id,
            "--tumor_id", args.tumor_id,
            "--pon_path", pon_path,
            "--known_snp_vcf_path", known_snp_vcf_path,
            "--cosmic_path", cosmic_path,            
            "--contEst", str(args.contEst),
            "--Parallel_Block_Size", str(args.block),
            "--thread_count", str(args.thread_count),
            "--java_heap", str(args.java_heap),
            "--case_id", args.case_id,
            "--postgres_config", postgres_config,
            "--output_vcf", vcf_file
            ]

    cwl_exit = pipelineUtil.run_command(cmd, logger)

    cwl_failure = False
    if cwl_exit:
        cwl_failure = True

    #rename outputs
    orglog2 = os.path.join(workdir, "%s_gatk_mutect2.log" % args.case_id)
    if os.path.isfile(orglog2):
        os.rename(orglog2, os.path.join(workdir, "%s_tcga_mutect2_pon.log" % str(vcf_uuid)))
    orglog3 = os.path.join(workdir, "%s_picard_sortvcf.log" % args.case_id)
    if os.path.isfile(orglog3):
        os.rename(orglog3, os.path.join(workdir, "%s_picard_sortvcf.log" % str(vcf_uuid)))

    #upload results to s3

    mutect_location = os.path.join(args.s3dir, str(vcf_uuid))

    vcf_upload_location = os.path.join(mutect_location, vcf_file)

    exit = pipelineUtil.upload_to_cleversafe(logger, mutect_location, workdir, "ceph", "http://gdc-cephb-objstore.osdc.io/")

    cwl_end = time.time()
    cwl_elapsed = cwl_end - cwl_start

    #establish connection with database
    s = open(postgres_config, 'r').read()
    postgres_config = eval(s)

    DATABASE = {
        'drivername': 'postgres',
        'host' : 'pgreadwrite.osdc.io',
        'port' : '5432',
        'username': postgres_config['username'],
        'password' : postgres_config['password'],
        'database' : 'prod_bioinfo'
    }

    engine = postgres.db_connect(DATABASE)

    status, loc = update_postgres(exit, cwl_failure, vcf_upload_location, mutect_location, logger)

    met = Time(case_id = args.case_id,
               datetime_now = datetime_now,
               vcf_id = str(vcf_uuid),
               files = [args.normal_id, args.tumor_id],
               elapsed = cwl_elapsed,
               thread_count = str(args.thread_count),
               status = str(status))

    postgres.create_table(engine, met)
    postgres.add_metrics(engine, met)

    status_postgres.add_status(engine, args.case_id, str(vcf_uuid), [args.normal_id, args.tumor_id], status, loc, datetime_now, os.path.basename(pon_path))

    #remove work and input directories
    pipelineUtil.remove_dir(casedir)
