FROM postgres:latest

RUN apt-get update \
 && apt-get install -y net-tools nano htop iputils-ping

COPY ./01-init.sql      /docker-entrypoint-initdb.d/01-init.sql
COPY ./02-create-db.sql /docker-entrypoint-initdb.d/02-create-db.sql


# ciao

