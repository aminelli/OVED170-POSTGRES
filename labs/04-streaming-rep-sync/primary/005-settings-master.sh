# MASTER
if [ "$SERVER_NAME" == "master" ]; then
  { echo "host    replication     replicarole      0.0.0.0/0      trust"; } |  tee -a "$PGDATA/pg_hba.conf" > /dev/null
  #wal level to logical
  psql -U postgres -c "CREATE ROLE logicalreplicarole WITH REPLICATION LOGIN PASSWORD 'corso2025' " postgres
  psql -U postgres -c "ALTER SYSTEM set wal_level = logical;" postgres
  pg_ctl -U postgres -D "$PGDATA" -m fast -w stop
  pg_ctl -U postgres -D "$PGDATA" start
  #Grant on schema
  psql -U postgres -c "grant usage ON schema public to logicalreplicarole; grant SELECT ON  public.actor to logicalreplicarole;" pagila
  # Create physical replication slot
  psql -U postgres -c "SELECT * FROM pg_create_physical_replication_slot('master');" postgres
  # Create  publication
  psql -U postgres -c "create publication actor_pub for table public.actor;" pagila

fi

