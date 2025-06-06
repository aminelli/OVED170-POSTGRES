
pg_restore /docker-entrypoint-initdb.d/pagila-data-apt-jsonb.backup -d pagila

pg_restore /docker-entrypoint-initdb.d/pagila-data-yum-jsonb.backup -d pagila