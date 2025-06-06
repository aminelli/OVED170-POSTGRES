# logical replication 
if [ "$SERVER_NAME" == "replicalogical" ]; then
  sleep 30
  psql -U postgres -c "drop database pagila;" postgres
  psql -U postgres -c "create database pagila;" postgres
  psql -U postgres -c "alter database pagila owner to postgres" postgres
  #psql -U postgres -c "CREATE SCHEMA forum AUTHORIZATION forum" pagila
  psql -U postgres -c "CREATE TABLE public.actor (actor_id integer NOT NULL , first_name text NOT NULL, last_name text NOT NULL, last_update timestamp NOT NULL)" pagila
  #psql -U postgres -c "ALTER TABLE forum.users OWNER TO forum" pagila
  psql -U postgres -c "grant ALL PRIVILEGES ON  public.actor to postgres;" pagila
  psql -U postgres -c "CREATE SUBSCRIPTION actor_sub CONNECTION 'host=primary port=5432 dbname=pagila user=logicalreplicarole password=corso2025 ' PUBLICATION actor_pub WITH (copy_data = true, create_slot = true, enabled = true)" pagila

fi


# CREATE SUBSCRIPTION users_sub
# CONNECTION 'host=publisher_host port=5432 dbname=mydb user=repl_user password=securepassword'
# PUBLICATION users_pub
# WITH (
#     copy_data = true,          -- Copia i dati esistenti all'inizio
#     create_slot = true,        -- Crea automaticamente uno slot di replica
#     enabled = true,
#     slot_name = 'users_slot'   -- Nome dello slot (opzionale)
# );


#CREATE SUBSCRIPTION actor_sub
#    CONNECTION 'host=replica port=5432 user=logicalreplicarole dbname=pagila connect_timeout=10 sslmode=disable'
#    PUBLICATION users_pub
#    WITH (connect = true, enabled = true, copy_data = true, create_slot = false, 
#    synchronous_commit = 'off', binary = false, streaming = 'False', two_phase = false, 
#    disable_on_error = false, run_as_owner = false, password_required = true, origin = 'any');