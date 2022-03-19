FROM python:3.8-slim-buster

WORKDIR /app

COPY . .
RUN apt-get update && \
    apt-get -y install gcc libmariadb-dev && \
    pip3 install -r requirements.txt

CMD ["./run.sh"]