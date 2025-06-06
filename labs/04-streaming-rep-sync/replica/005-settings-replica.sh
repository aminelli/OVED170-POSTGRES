 
# physical replication
if [ "$SERVER_NAME" == "replica" ]; then
  sleep 20
  psql -U postgres -c "ALTER SYSTEM set wal_level = logical;" postgres
  psql -U postgres -c "ALTER SYSTEM set hot_standby_feedback = on;" postgres
  pg_ctl -U postgres -D "$PGDATA" -m fast -w stop
  rm -rf $PGDATA/*
  pg_basebackup -h primary -U replicarole -p 5432 -D $PGDATA -Fp -Xs -P -R -W -S master
  { echo "host    replication     logicalreplicarole     0.0.0.0/0      scram-sha-256"; } |  tee -a "$PGDATA/pg_hba.conf" > /dev/null
  chown -R postgres.postgres $PGDATA
  pg_ctl -U postgres -D "$PGDATA" start
fi
 