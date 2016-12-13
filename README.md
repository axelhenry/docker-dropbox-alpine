## Run the container

docker run -ti -d -P -v /path/to/dropbox/config/on/host:/home/dbox/.dropbox -v /path/to/dropbox/data/on/host:/home/dbox/Dropbox -e DBOX_UID=1000 -e DBOX_GID=100 --name=mydropbox axelhenry/docker-dropbox-alpine


## Check dropbox' status

docker exec -t -i mydropbox su - dbox -c 'dropbox-cli status' -s /bin/sh
