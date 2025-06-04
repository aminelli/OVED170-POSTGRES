#!/bin/bash

# docker pull postgres


docker network create net-corso

docker volume create vol-postgres

docker run -d \
    --name postgres-test \
    --hostname postgres-test \
    --network net-corso \
    -p 5432:5432 \
    -e POSTGRES_USER=corso \
    -e POSTGRES_PASSWORD=ofima_2025_ \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
	-v vol-postgres:/var/lib/postgresql/data \
	postgres


docker run -d \
    --name pgadmin \
    --hostname pgadmin \
    --network net-corso \
    -p 8081:80 \
    -e PGADMIN_DEFAULT_EMAIL=admin@corso.com \
    -e PGADMIN_DEFAULT_PASSWORD=admin \
    -v vol-pgadmin:/var/lib/pgadmin \
    dpage/pgadmin4:latest



docker run -d \
    --name adminer \
    --hostname adminer \
    --network net-corso \
    -p 8082:8080 \
    adminer