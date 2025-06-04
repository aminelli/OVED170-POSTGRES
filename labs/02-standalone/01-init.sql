CREATE DATABASE ofima_corso;


-- Ruolo senza login (gruppo o ruolo applicativo)

CREATE ROLE revisori;

CREATE ROLE sviluppatori WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS;



-- Crea un ruolo con login "password"
CREATE ROLE antonio WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:fD7XCwRNAKKVUeFxB0GTxg==$2QH4tfLduxwCfemQbTVxZFBQ9u/XHmL2aIieyDCwy+M=:EQ7TFGzQH2AP3yGjroHpXNLLMCgZI74FAN9B9bJJois=';




CREATE ROLE backend_team WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS;

  CREATE ROLE pippo WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  NOREPLICATION
  NOBYPASSRLS;

-- CREATE USER ofiuser WITH PASSWORD 'init_2025_';

CREATE ROLE ofiuser WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  NOBYPASSRLS
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:KThBtaVwG73HGRPHyIbFow==$Mzse3RDO/XpH0fPAh38S/kcFj7HvhireOlOI+rXX6Xs=:2zbYWNORPGeZhm2/tbcs8qNF5a1e2AqKi6fMog42kLY=';

GRANT pippo TO ofiuser;
GRANT backend_team, revisori, sviluppatori TO antonio;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO backend_team;




-- Creazione utenza
CREATE DATABASE wso2_am_shared_db;
CREATE USER wso2 WITH PASSWORD 'Manager2025_ApiM';


-- Grant dei privilegi per l'utente wso2 sui database
GRANT ALL PRIVILEGES ON DATABASE wso2_am_shared_db      TO wso2;

-- Grant Connections
GRANT CONNECT ON DATABASE wso2_am_shared_db     TO wso2;
   
\connect wso2_am_shared_db

-- Grant sullo schema public
GRANT USAGE  ON SCHEMA public TO wso2;
GRANT CREATE ON SCHEMA public TO wso2;

-- Permessi su tutte le tabelle esistenti
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO wso2;
-- Permessi sulla creazione di nuove tabelle
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO wso2;

-- Permessi sequence
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO wso2;  
-- Permessi sequence sulla creazione nuove
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO wso2;

-- grant per wso2 se abilitata la parte analitycs
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO wso2;


