# 起動まで

```
$ sudo apt install -y gcc libmariadb-dev python3-dev python3-venv
$ git clone git@github.com:akiraak/datz.git
$ cd datz/server
$ python3 -m venv .pyenv
$ . .pyenv/bin/activate
$ pip install -r requirements.txt
```

# git clone した後にやること
git clone git@github.com:akiraak/local-food.git


# Docker デプロイの流れ
git clone git@github.com:akiraak/local-food.git
cd local-food
vi env_vars
. env_vars
./deploy.sh prd 1

sudo docker image build -t app .
sudo docker tag app:latest app:v1
sudo docker run --rm -d -p 5000:5000 --name app-v1 app:v1
sudo docker run --rm -d -p 80:5000 --name app-v1 app:v1
sudo docker container stop app
sudo docker save app:v1 > ../app-v1.tar
scp app-v1.tar localfood-prd:~
ssh localfood-prd
sudo docker container ls
sudo docker load < app-v1.tar
sudo docker stop app-v1
sudo docker images
sudo docker run -d -p 80:5000 app:v1
curl http://localhost
AWS: Target Group への追加
AWS: Route53 で ALB を指定

# Docker エラーチェック
"docker run" から "--rm" を削除して実行
sudo docker logs [CONTAINER ID]

# python3 チートコード
python3 -m venv .pyenv
python3 -m flask run

# mysql8 on WSL2(Ubuntu)
https://pen-y-fan.github.io/2021/08/08/How-to-install-MySQL-on-WSL-2-Ubuntu/
$ sudo apt update && sudo apt upgrade
$ sudo apt install mysql-server
$ mysql --version
$ sudo /etc/init.d/mysql start
$ sudo mysql_secure_installation

# docker on WSL2(Ubuntu)
sudo /etc/init.d/docker start

# DB Migration
sudo apt-get install python3-mysqldb
sudo apt-get install libmysqlclient-dev
pip3 install wheel
pip3 install mysqlclient
flask db init
flask db migrate -m "Initial migration."
flask db upgrade

drop database app;
create database app;
