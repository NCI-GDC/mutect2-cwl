#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=XX_THREAD_COUNT_XX
#SBATCH --ntasks=1
#SBATCH --mem=18000
#SBATCH --workdir="/mnt/SCRATCH/"

refdir="XX_REFDIR_XX"
block="XX_BLOCKSIZE_XX"
thread_count="XX_THREAD_COUNT_XX"
contEst="XX_CONTEST_XX"

normal="XX_NORMAL_XX"
tumor="XX_TUMOR_XX"
normal_id="XX_NORMAL_ID_XX"
tumor_id="XX_TUMOR_ID_XX"
case_id="XX_CASE_ID_XX"

s3dir="XX_S3DIR_XX"

repository="git@github.com:NCI-GDC/mutect-cwl.git"

wkdir=`sudo mktemp -d -t mutect.XXXXXXXXXX -p /mnt/SCRATCH/` \
&& sudo chown ubuntu:ubuntu $wkdir \
&& cd $wkdir \
&& sudo git clone -b feat/slurm $repository \
&& sudo chown ubuntu:ubuntu mutect-cwl \
&& /home/ubuntu/.virtualenvs/p2/bin/python mutect-cwl/slurm/run_cwl.py \
--refdir $refdir \
--block $block \
--thread_count $thread_count \
--normal $normal \
--normal_id $normal_id \
--tumor $tumor \
--tumor_id $tumor_id \
--case_id $case_id \
--basedir $wkdir \
--s3dir $s3dir \
--cwl $wkdir/mutect-cwl/workflows/mutect-wxs-workflow.cwl.yaml

sudo rm -rf $wkdir
