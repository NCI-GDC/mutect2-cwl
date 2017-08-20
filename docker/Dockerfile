FROM quay.io/jeremiahsavage/cdis_base

USER root
RUN apt-get update && apt-get install -y --force-yes \
    openjdk-8-jre-headless

USER ubuntu
ENV HOME /home/ubuntu

ENV mutect2-tool nightly-2016-02-25-gf39d340

ADD GenomeAnalysisTK.jar ${HOME}/tools/

WORKDIR ${HOME}
