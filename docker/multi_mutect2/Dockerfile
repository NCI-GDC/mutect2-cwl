FROM ubuntu:16.04

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev openjdk-8-jre-headless

ADD multi_mutect2.py /bin/
ADD GenomeAnalysisTK.jar /bin/

ENV multi_mutect2 v1.2
