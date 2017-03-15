#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=XX_THREAD_COUNT_XX
#SBATCH --ntasks=1
#SBATCH --workdir="/mnt/SCRATCH/"
#SBATCH --mem=XX_MEM_XX

refdir="XX_REFDIR_XX"
block="XX_BLOCKSIZE_XX"
thread_count="XX_THREAD_COUNT_XX"
host="XX_HOST_XX"

java_heap="XX_JAVAHEAP_XX"
contEst="XX_CONTEST_XX"


normal="XX_NORMAL_XX"
tumor="XX_TUMOR_XX"
normal_id="XX_NORMAL_ID_XX"
tumor_id="XX_TUMOR_ID_XX"
case_id="XX_CASE_ID_XX"

s3dir="XX_S3DIR_XX"
repository="git@github.com:NCI-GDC/mutect2-cwl.git"
wkdir=`sudo mktemp -d mutect2.XXXXXXXXXX -p /mnt/SCRATCH/`
sudo chown ubuntu:ubuntu $wkdir

cd $wkdir

function cleanup (){
    echo "cleanup tmp data";
    sudo rm -rf $wkdir;
}

sudo git clone $repository
sudo chown ubuntu:ubuntu -R mutect2-cwl

trap cleanup EXIT

/home/ubuntu/.virtualenvs/p2/bin/python mutect2-cwl/slurm/run_cwl.py \
--refdir $refdir \
--block $block \
--thread_count $thread_count \
--host $host \
--java_heap $java_heap \
--contEst $contEst \
--normal $normal \
--normal_id $normal_id \
--tumor $tumor \
--tumor_id $tumor_id \
--case_id $case_id \
--basedir $wkdir \
--s3dir $s3dir \
--index $wkdir/mutect2-cwl/tools/picard_buildbamindex.cwl.yaml \
--cwl $wkdir/mutect2-cwl/workflows/mutect2-vc-workflow.cwl.yaml
