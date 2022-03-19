#!/bin/bash
ENV=$1 #stg, prd, dev, pocstg
VAR=$2
APP="localfood"

sudo docker rmi $(sudo docker images -q) --force
rm -rf app.tar

git pull
sudo docker image build -t app .
sudo docker tag app:latest app:v${VAR}
sudo docker save app:v${VAR} > app.tar

scp app.tar ${APP}-${ENV}:~
scp deploy_remote.sh ${APP}-${ENV}:~
ssh ${APP}-${ENV} "bash -l -i ~/deploy_remote.sh ${VAR}"