#!/bin/bash
set -exo pipefail

VAR=$1

sudo docker stop $(sudo docker ps -q) || true
sudo docker rm $(sudo docker ps -q -a) --force || true
sudo docker rmi $(sudo docker images -q) --force || true
cd ~
sudo docker load < app.tar
sudo docker run -d -p 80:5000 app:v${VAR}
curl http://localhost --connect-timeout 10 --retry 10 --retry-connrefused --retry-delay 3 --retry-all-errors