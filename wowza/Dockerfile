FROM ubuntu:focal as builder

WORKDIR /root

RUN apt-get update \
    && apt-get install -y supervisor wget expect nano mlocate net-tools openjdk-11-jre

COPY supervisor /etc/supervisor

RUN wget -O envsubst https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-Linux-x86_64
RUN chmod +x envsubst && mv envsubst /usr/local/bin

RUN wget -O wowza-installer.run https://www.wowza.com/downloads/WowzaStreamingEngine-4-8-23+2/WowzaStreamingEngine-4.8.23+2-linux-x64-installer.run
COPY install.exp install.exp
COPY exitzero.sh exitzero.sh

RUN chmod +x install.exp wowza-installer.run exitzero.sh
RUN expect install.exp
RUN rm /usr/local/WowzaStreamingEngine/conf/Server.license

# Backups (for volumes)
RUN mkdir wowza-backup && cp -r /usr/local/WowzaStreamingEngine/conf /root/wowza-backup/conf

VOLUME /usr/local/WowzaStreamingEngine/conf
VOLUME /usr/local/WowzaStreamingEngine/applications
VOLUME /usr/local/WowzaStreamingEngine/content
VOLUME /usr/local/WowzaStreamingEngine/logs

COPY entrypoint.sh entrypoint.sh
COPY exitzero.sh exitzero.sh
COPY hosts /root/
COPY wms-server.jar /root/
COPY updateavailablejava_tag.class /root/
COPY updateavailable_tag.class /root/
RUN chmod +x entrypoint.sh
ENTRYPOINT /root/entrypoint.sh
