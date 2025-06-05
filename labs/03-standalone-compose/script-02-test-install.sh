#!/bin/bash

# docker pull postgres


docker network create net-corso

docker volume create vol-postgres-test

docker run -d \
    --name postgres-test2 \
    --hostname postgres-test2 \
    --network net-corso \
    -p 5442:5432 \
    -e POSTGRES_USER=corso \
    -e POSTGRES_PASSWORD=ofima_2025_ \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
	-v vol-postgres-test:/var/lib/postgresql/data \
	ofima-wso2:v2

docker logs -f postgres-test2


