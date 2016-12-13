FROM frolvlad/alpine-glibc

MAINTAINER Axel Henry <axel.durandil@gmail.com>

ENV DBOX_UID 1000
ENV DBOX_GID 1000
ENV PATH /opt/dropbox:/scripts:$PATH
ENV S6_VERSION 1.18.1.5

USER root

COPY repositories /etc/apk/repositories

RUN set -xe \
	&& apk --no-cache add shadow ca-certificates python tar curl gnupg

#Download s6-overlay
RUN set -xe \
	&& curl -Lo /tmp/s6.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz \
	&& curl -Lo /tmp/s6.sig https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz.sig \
	&& curl -Lo /tmp/key.asc https://keybase.io/justcontainers/key.asc

#Verify s6-overlay' signature
RUN set -xe \
	&& cd /tmp \
	&& gpg --import /tmp/key.asc \
	&& gpg --verify /tmp/s6.sig /tmp/s6.tar.gz \
	&& tar xzf s6.tar.gz -C / \
	&& rm -rf /tmp /root/.gnupg

#Download dropbox
RUN set -xe \
	&& mkdir -p /opt/dropbox \
	&& curl -Lo dropbox-linux-x86_64.tar.gz https://www.dropbox.com/download?plat=lnx.x86_64 \
	&& tar xzfv dropbox-linux-x86_64.tar.gz --strip 1 -C /opt/dropbox \
	&& rm dropbox-linux-x86_64.tar.gz \	
	&& curl -Lo /usr/local/bin/dropbox-cli https://www.dropbox.com/download?dl=packages/dropbox.py
#	&& chmod +x /usr/local/bin/dropbox-cli \
#	&& echo "Installed Dropbox version:" $(cat /opt/dropbox/VERSION)

RUN set -xe \
        && apk --no-cache del tar curl gnupg

WORKDIR /home/dbox

EXPOSE 17500

VOLUME ["/home/dbox/Dropbox", "/home/dbox/.dropbox"]

#COPY launch-dropbox.sh /scripts/launch-dropbox.sh

COPY dropbox-service-user-exec-sh.s6 /etc/services.d/dropbox@dbox/run
COPY fix-dropbox-cli.s6  /etc/fix-attrs.d/00-dropbox-cli
COPY create-user.s6 /etc/cont-init.d/01-create-user.sh
COPY create-user-folders.s6 /etc/cont-init.d/02-create-user-folders.sh
COPY bootstrap-user-sh.s6 /etc/cont-init.d/03-bootstrap-user.sh
COPY display-dropbox-version.s6 /etc/cont-init.d/04-display-dropbox-version.sh
#COPY create-log-folders.s6 /etc/cont-init.d/10-create-log-folders.sh
#COPY fix-launch-dropbox.s6 /etc/fix-attrs.d/01-launch-dropbox

ENTRYPOINT ["/init"]
