# Docker
[![Docker Pulls](https://img.shields.io/docker/pulls/mashape/kong.svg)](https://hub.docker.com/r/axelhenry/docker-dropbox-alpine/)

[Dropbox](https://www.samba.org/) running under [s6 overlay](https://github.com/just-containers/s6-overlay) on [Alpine Linux](https://hub.docker.com/_/alpine/).

## Configuration

### Quickstart

````Shell
docker run -ti -d --restart=always --name=mydropbox axelhenry/docker-dropbox-alpine
````

### Dropbox data mounted to local folder on the host

````Shell
docker run -ti -d --restart=always -v /path/to/dropbox/config/on/host:/home/dbox/.dropbox -v /path/to/dropbox/data/on/host:/home/dbox/Dropbox --name=mydropbox axelhenry/docker-dropbox-alpine
````

### Run dropbox with custom user/group id

This fixes file permission errrors that might occur when mounting the Dropbox file folder (/dbox/Dropbox) from the host or a Docker container volume. You need to set DBOX_UID/DBOX_GID to the user id and group id of whoever owns these files on the host

````Shell
docker run -ti -d --restart=always -v /path/to/dropbox/config/on/host:/home/dbox/.dropbox -v /path/to/dropbox/data/on/host:/home/dbox/Dropbox -e DBOX_UID=1000 -e DBOX_GID=100 --name=mydropbox axelhenry/docker-dropbox-alpine
````
### Environment variables

````
DBOX_UID
Default: 1000
Run Dropbox with a custom user id (matching the owner of the mounted files)

DBOX_GID
Default: 1000
Run Dropbox with a custom group id (matching the group of the mounted files)
````

## Check dropbox' status

docker exec -t -i mydropbox su - dbox -c 'dropbox-cli status' -s /bin/sh

## Autoupdate

Running under s6-overlay, the dropbox daemon should autoupdate flawlessly... (not tested)

## Thanks
