FROM python
MAINTAINER Lestat

RUN pip install you-get \
&& apt-get update \
&& apt-get install -y ffmpeg \
&& mkdir -p /data/download \
&& chmod -R 777 /data/download

WORKDIR /data/download