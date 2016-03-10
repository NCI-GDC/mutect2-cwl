import status_postgres
import argparse
import os


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description="MuTect2 Variant Calling")

    required = parser.add_argument_group("Required input parameters")
    required.add_argument("--config", default=None, help="path to config file", required=True)
    required.add_argument("--outdir", default="./", help="otuput directory for slurm scripts")
    required.add_argument("--refdir", default=None, help="path to ref dir on object store", required=True)
    required.add_argument("--block", default=None, help="parallel block size", required=True)
    required.add_argument("--thread_count", default=None, help="thread count", required=True)
    required.add_argument("--contEst", default="0.02", help="contamination estimation value", required=True)
    required.add_argument("--s3dir", default="s3://ceph_kh11_mutect2_variant", help="path to output files", required=True)
    args = parser.parse_args()

    if not os.path.isdir(args.outdir):
        raise Exception("Cannot find output directory: %s" %args.outdir)

    if not os.path.isfile(args.config):
        raise Exception("Cannot find config file: %s" %args.config)


    s = open(args.config, 'r').read()
    config = eval(s)

    DATABASE = {
        'drivername': 'postgres',
        'host' : 'pgreadwrite.osdc.io',
        'port' : '5432',
        'username': config['username'],
        'password' : config['password'],
        'database' : 'prod_bioinfo'
    }

    engine = status_postgres.db_connect(DATABASE)

    cases = status_postgres.get_case(engine, 'mutect2_vc_status')

    for case in cases:
        slurm = open(os.path.join(args.outdir, "mutect.%s.%s.sh" %(cases[case][1], cases[case][3])), "w")
        temp = open("template.sh", "r")
        for line in temp:
            if "XX_REFDIR_XX" in line:
                line = line.replace("XX_REFDIR_XX", args.refdir)

            if "XX_BLOCKSIZE_XX" in line:
                line = line.replace("XX_BLOCKSIZE_XX", str(args.block))

            if "XX_THREAD_COUNT_XX" in line:
                line = line.replace("XX_THREAD_COUNT_XX", str(args.thread_count))

            if "XX_CONTEST_XX" in line:
                line = line.replace("XX_CONTEST_XX", str(args.contEst))

            if "XX_S3DIR_XX" in line:
                line = line.replace("XX_S3DIR_XX", args.s3dir)

            if "XX_NORMAL_XX" in line:
                line = line.replace("XX_NORMAL_XX", cases[case][2])

            if "XX_NORMAL_ID_XX" in line:
                line = line.replace("XX_NORMAL_ID_XX", cases[case][1])

            if "XX_TUMOR_XX" in line:
                line = line.replace("XX_TUMOR_XX", cases[case][4])

            if "XX_TUMOR_ID_XX" in line:
                line = line.replace("XX_TUMOR_ID_XX", cases[case][3])

            if "XX_CASE_ID_XX" in line:
                line = line.replace("XX_CASE_ID_XX", cases[case][0])

            slurm.write(line)
        slurm.close()
        temp.close()
