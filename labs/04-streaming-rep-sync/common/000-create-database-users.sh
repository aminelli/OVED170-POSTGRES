#!/bin/bash
set -e

psql -U postgres -c "CREATE USER replicarole WITH REPLICATION ENCRYPTED PASSWORD 'corso2025'" postgres
psql -U postgres -c "ALTER ROLE postgres PASSWORD 'corso2025'" postgres
psql -U postgres -c "CREATE DATABASE pagila;" postgres