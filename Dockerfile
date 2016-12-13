FROM frolvlad/alpine-glibc

MAINTAINER Axel Henry <axel.durandil@gmail.com>

ENV DBOX_UID 1000
ENV DBOX_GID 1000
ENV PATH /opt/dropbox:/scripts:$PATH
ENV S6_VERSION 1.18.1.5

USER root

#Download s6-overlay's files
ADD https://keybase.io/justcontainers/key.asc /tmp/key.asc
ADD https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz /tmp/s6.tar.gz
ADD https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz.sig /tmp/s6.sig

#Download dropbox's files
ADD https://www.dropbox.com/download?plat=lnx.x86_64 /tmp/dropbox-linux-x86_64.tar.gz
ADD https://www.dropbox.com/download?dl=packages/dropbox.py /usr/local/bin/dropbox-cli

#COPY repositories /etc/apk/repositories

RUN set -xe \
	&& apk --no-cache add python tar gnupg

#Verify s6-overlay' signature
RUN set -xe \
	&& cd /tmp \
	&& gpg --import /tmp/key.asc \
	&& gpg --verify /tmp/s6.sig /tmp/s6.tar.gz \
	&& tar xzf s6.tar.gz -C /

RUN set -xe \
	&& mkdir -p /opt/dropbox \
	&& tar xzfv /tmp/dropbox-linux-x86_64.tar.gz --strip 1 -C /opt/dropbox

#Delete /tmp folder
RUN set -xe \
	&& rm -rf /tmp /root/.gnupg

RUN set -xe \
	&& apk --no-cache del tar gnupg

WORKDIR /home/dbox

EXPOSE 17500

VOLUME ["/home/dbox/Dropbox", "/home/dbox/.dropbox"]

COPY dropbox-service-user-exec-sh.s6 /etc/services.d/dropbox@dbox/run
COPY fix-dropbox-cli.s6  /etc/fix-attrs.d/00-dropbox-cli
COPY create-user.s6 /etc/cont-init.d/01-create-user.sh
COPY create-user-folders.s6 /etc/cont-init.d/02-create-user-folders.sh
COPY bootstrap-user-sh.s6 /etc/cont-init.d/03-bootstrap-user.sh
COPY display-dropbox-version.s6 /etc/cont-init.d/04-display-dropbox-version.sh
#COPY fix-launch-dropbox.s6 /etc/fix-attrs.d/01-launch-dropbox

ENTRYPOINT ["/init"]
