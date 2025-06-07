# ESTENSIONI

PostgreSQL offre numerose estensioni che ampliano significativamente le sue funzionalità. 

Ecco i più importanti addon con istruzioni dettagliate per installazione e configurazione:

## 1. PostGIS (Dati Geospaziali)

**Installazione:**
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-contrib postgis postgresql-14-postgis-3

# CentOS/RHEL
sudo yum install postgis postgis-utils

# macOS con Homebrew
brew install postgis
```

**Configurazione:**
```sql
-- Connettersi al database
psql -U postgres -d nome_database

-- Abilitare l'estensione
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;

-- Verificare l'installazione
SELECT PostGIS_Version();
```

## 2. pg_stat_statements (Monitoraggio Query)

**Installazione:**
```bash
# Modificare postgresql.conf
sudo nano /etc/postgresql/14/main/postgresql.conf

# Aggiungere alla sezione shared_preload_libraries
shared_preload_libraries = 'pg_stat_statements'
```

**Configurazione:**
```sql
-- Riavviare PostgreSQL
sudo systemctl restart postgresql

-- Creare l'estensione
CREATE EXTENSION pg_stat_statements;

-- Configurare parametri aggiuntivi in postgresql.conf
pg_stat_statements.max = 10000
pg_stat_statements.track = all
pg_stat_statements.save = on
```

**Utilizzo:**
```sql
-- Visualizzare le query più lente
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;
```

## 3. pgcrypto (Crittografia)

**Installazione e configurazione:**
```sql
-- Creare l'estensione
CREATE EXTENSION pgcrypto;

-- Esempi di utilizzo
-- Hash di password
SELECT crypt('mia_password', gen_salt('bf'));

-- Crittografia simmetrica
SELECT pgp_sym_encrypt('testo_segreto', 'chiave_segreta');
SELECT pgp_sym_decrypt(data_crittografata, 'chiave_segreta');
```

## 4. uuid-ossp (Generazione UUID)

**Installazione:**
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-contrib-14
```

**Configurazione:**
```sql
CREATE EXTENSION "uuid-ossp";

-- Esempi di utilizzo
SELECT uuid_generate_v4();
SELECT uuid_generate_v1();

-- Creare tabella con UUID come chiave primaria
CREATE TABLE utenti (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100),
    email VARCHAR(255)
);
```

## 5. hstore (Coppie Chiave-Valore)

**Configurazione:**
```sql
CREATE EXTENSION hstore;

-- Esempio di utilizzo
CREATE TABLE prodotti (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    attributi hstore
);

INSERT INTO prodotti (nome, attributi) VALUES 
('Laptop', 'marca=>Dell, ram=>16GB, storage=>512GB');

-- Query su hstore
SELECT * FROM prodotti WHERE attributi->'marca' = 'Dell';
SELECT * FROM prodotti WHERE attributi ? 'ram';
```

## 6. pg_partman (Gestione Partizioni)

**Installazione:**
```bash
# Scaricare da GitHub
git clone https://github.com/pgpartman/pg_partman.git
cd pg_partman
make install

# O tramite package manager
sudo apt-get install postgresql-14-partman
```

**Configurazione:**
```sql
CREATE SCHEMA partman;
CREATE EXTENSION pg_partman SCHEMA partman;

-- Configurare il background worker in postgresql.conf
shared_preload_libraries = 'pg_partman_bgw'

-- Esempio di partizione per data
SELECT partman.create_parent(
    p_parent_table => 'public.vendite',
    p_control => 'data_vendita',
    p_type => 'range',
    p_interval => 'monthly'
);
```

## 7. pg_repack (Riorganizzazione Tabelle)

**Installazione:**
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-14-repack

# Compilare da sorgenti
git clone https://github.com/reorg/pg_repack.git
cd pg_repack
make && sudo make install
```

**Configurazione:**
```sql
CREATE EXTENSION pg_repack;

# Utilizzo da command line
pg_repack -d nome_database -t nome_tabella
pg_repack -d nome_database --all
```

## 8. TimescaleDB (Time Series)

**Installazione:**
```bash
# Ubuntu/Debian
sudo sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/ubuntu/ $(lsb_release -c -s) main' > /etc/apt/sources.list.d/timescaledb.list"
wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
sudo apt-get update
sudo apt-get install timescaledb-2-postgresql-14
```

**Configurazione:**
```bash
# Configurare automaticamente
sudo timescaledb-tune

# Modificare postgresql.conf manualmente
shared_preload_libraries = 'timescaledb'
```

```sql
CREATE EXTENSION timescaledb;

-- Creare hypertable
CREATE TABLE metriche (
    tempo TIMESTAMPTZ NOT NULL,
    device_id INTEGER,
    temperatura DOUBLE PRECISION,
    umidita DOUBLE PRECISION
);

SELECT create_hypertable('metriche', 'tempo');
```

## 9. Foreign Data Wrappers (FDW)

**postgres_fdw (collegare altri database PostgreSQL):**
```sql
CREATE EXTENSION postgres_fdw;

CREATE SERVER server_remoto
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'remote_host', port '5432', dbname 'remote_db');

CREATE USER MAPPING FOR LOCAL_USER
SERVER server_remoto
OPTIONS (user 'remote_user', password 'password');

CREATE FOREIGN TABLE tabella_remota (
    id INTEGER,
    nome TEXT
) SERVER server_remoto OPTIONS (table_name 'tabella_originale');
```

## 10. pg_trgm (Ricerca Fuzzy)

**Configurazione:**
```sql
CREATE EXTENSION pg_trgm;

-- Creare indice per ricerca fuzzy
CREATE INDEX idx_nome_trigram ON utenti USING gin (nome gin_trgm_ops);

-- Ricerca per similarità
SELECT * FROM utenti WHERE nome % 'mario';
SELECT nome, similarity(nome, 'mario') FROM utenti WHERE nome % 'mario';
```

## Configurazione Generale e Best Practices

**File di configurazione principale:**
```bash
# Localizzare postgresql.conf
sudo find /etc -name "postgresql.conf"

# Backup prima delle modifiche
sudo cp /etc/postgresql/14/main/postgresql.conf /etc/postgresql/14/main/postgresql.conf.backup
```

**Monitoraggio estensioni installate:**
```sql
-- Vedere tutte le estensioni disponibili
SELECT * FROM pg_available_extensions ORDER BY name;

-- Vedere estensioni installate
SELECT * FROM pg_extension;

-- Informazioni dettagliate su un'estensione
\dx+ nome_estensione
```

**Riavvio servizio dopo modifiche:**
```bash
# Ubuntu/Debian
sudo systemctl restart postgresql
sudo systemctl status postgresql

# Verificare i log
sudo tail -f /var/log/postgresql/postgresql-14-main.log
```

Queste estensioni trasformano PostgreSQL in una piattaforma estremamente versatile per applicazioni che spaziano dall'analisi geospaziale ai time series, dalla crittografia avanzata alla gestione di big data distribuiti.


Ecco altri importanti addon per PostgreSQL con configurazioni dettagliate:

## 11. pgvector (Ricerca Vettoriale e AI)

**Installazione:**
```bash
# Da sorgenti
git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install

# Ubuntu/Debian (repository ufficiale)
sudo apt install postgresql-16-pgvector
```

**Configurazione:**
```sql
CREATE EXTENSION vector;

-- Creare tabella con vettori
CREATE TABLE documenti (
    id SERIAL PRIMARY KEY,
    titolo TEXT,
    embedding vector(1536)  -- dimensione per OpenAI embeddings
);

-- Creare indici per performance
CREATE INDEX ON documenti USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON documenti USING hnsw (embedding vector_cosine_ops);

-- Ricerca per similarità
SELECT titolo, embedding <-> '[0.1,0.2,0.3,...]' AS distanza
FROM documenti
ORDER BY embedding <-> '[0.1,0.2,0.3,...]'
LIMIT 5;
```

## 12. pg_cron (Scheduler Integrato)

**Installazione:**
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-14-cron

# Configurare in postgresql.conf
shared_preload_libraries = 'pg_cron'
cron.database_name = 'postgres'
```

**Configurazione:**
```sql
CREATE EXTENSION pg_cron;

-- Esempi di scheduling
-- Pulizia giornaliera alle 02:00
SELECT cron.schedule('pulizia-logs', '0 2 * * *', 'DELETE FROM logs WHERE created_at < NOW() - INTERVAL ''30 days''');

-- Backup settimanale ogni domenica alle 03:00
SELECT cron.schedule('backup-settimanale', '0 3 * * 0', 'COPY (SELECT * FROM vendite) TO ''/backup/vendite.csv'' CSV HEADER');

-- Aggiornamento statistiche ogni ora
SELECT cron.schedule('stats-update', '0 * * * *', 'ANALYZE;');

-- Gestire i job
SELECT * FROM cron.job;
SELECT cron.unschedule('pulizia-logs');
```

## 13. pg_stat_monitor (Monitoraggio Avanzato)

**Installazione:**
```bash
# Percona repository
sudo apt-get install percona-pg-stat-monitor14

# Configurare postgresql.conf
shared_preload_libraries = 'pg_stat_monitor'
pg_stat_monitor.pgsm_max = 10000
pg_stat_monitor.pgsm_query_max_len = 2048
pg_stat_monitor.pgsm_enable_query_plan = on
```

**Configurazione:**
```sql
CREATE EXTENSION pg_stat_monitor;

-- Query più costose con piani di esecuzione
SELECT query, calls, total_exec_time, mean_exec_time, query_plan
FROM pg_stat_monitor
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Statistiche per database
SELECT datname, calls, total_exec_time
FROM pg_stat_monitor
GROUP BY datname;

-- Reset delle statistiche
SELECT pg_stat_monitor_reset();
```

## 14. pg_auto_failover (Alta Disponibilità)

**Installazione:**
```bash
# Ubuntu/Debian
sudo apt-get install pg-auto-failover-cli postgresql-14-auto-failover

# Configurazione nodo monitor
pg_autoctl create monitor --hostname node1 --pgdata /var/lib/postgresql/monitor
pg_autoctl run --pgdata /var/lib/postgresql/monitor &

# Configurazione primary
pg_autoctl create postgres --hostname node2 --pgdata /var/lib/postgresql/primary --monitor postgres://autoctl_node@node1:5432/pg_auto_failover

# Configurazione secondary
pg_autoctl create postgres --hostname node3 --pgdata /var/lib/postgresql/secondary --monitor postgres://autoctl_node@node1:5432/pg_auto_failover
```

**Monitoraggio:**
```sql
-- Stato del cluster
SELECT * FROM pgautofailover.node;

-- Performare failover manuale
SELECT pgautofailover.perform_failover();
```

## 15. pg_squeeze (Compressione Online)

**Installazione:**
```bash
git clone https://github.com/cybertec-postgresql/pg_squeeze.git
cd pg_squeeze
make && sudo make install

# Configurare postgresql.conf
shared_preload_libraries = 'pg_squeeze'
```

**Configurazione:**
```sql
CREATE EXTENSION pg_squeeze;

-- Registrare tabella per compressione automatica
SELECT squeeze.squeeze_table('public', 'tabella_grande', null, null, null);

-- Compressione manuale
SELECT squeeze.squeeze_table('public', 'log_table', 
    'created_at < NOW() - INTERVAL ''1 year''', 
    null, 
    null
);

-- Monitorare compressioni
SELECT * FROM squeeze.tables;
SELECT * FROM squeeze.log;
```

## 16. hypopg (Indici Ipotetici)

**Installazione:**
```bash
git clone https://github.com/HypoPG/hypopg.git
cd hypopg
make && sudo make install
```

**Configurazione:**
```sql
CREATE EXTENSION hypopg;

-- Creare indice ipotetico
SELECT hypopg_create_index('CREATE INDEX ON tabella_vendite (data_vendita, cliente_id)');

-- Testare query con indice ipotetico
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM tabella_vendite WHERE data_vendita > '2024-01-01' AND cliente_id = 100;

-- Vedere tutti gli indici ipotetici
SELECT * FROM hypopg();

-- Rimuovere indici ipotetici
SELECT hypopg_drop_index(indexrelid) FROM hypopg();
```

## 17. pg_partman (Gestione Avanzata Partizioni)

**Configurazione avanzata:**
```sql
-- Partizione con retention automatica
SELECT partman.create_parent(
    p_parent_table => 'public.eventi',
    p_control => 'timestamp_evento',
    p_type => 'range',
    p_interval => 'daily',
    p_premake => 7  -- pre-creare 7 partizioni future
);

-- Configurare retention (mantenere solo 90 giorni)
UPDATE partman.part_config 
SET retention = '90 days', 
    retention_keep_table = false,
    retention_keep_index = false
WHERE parent_table = 'public.eventi';

-- Abilitare background worker per manutenzione automatica
INSERT INTO partman.part_config_sub (sub_parent, sub_control, sub_partition_type, sub_partition_interval)
VALUES ('public.eventi', 'categoria', 'list', null);
```

## 18. pg_buffercache (Analisi Buffer Cache)

**Configurazione:**
```sql
CREATE EXTENSION pg_buffercache;

-- Analizzare utilizzo buffer cache
SELECT c.relname, count(*) as buffers, pg_size_pretty(count(*) * 8192) as size
FROM pg_buffercache b
INNER JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid)
WHERE b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))
GROUP BY c.relname
ORDER BY buffers DESC
LIMIT 20;

-- Percentuale di hit rate
SELECT 
    ROUND(100.0 * sum(CASE WHEN usagecount > 1 THEN 1 ELSE 0 END) / count(*), 2) as hit_rate
FROM pg_buffercache
WHERE reldatabase = (SELECT oid FROM pg_database WHERE datname = current_database());
```

## 19. pg_hint_plan (Controllo Query Planner)

**Installazione:**
```bash
git clone https://github.com/ossc-db/pg_hint_plan.git
cd pg_hint_plan
make && sudo make install

# Configurare postgresql.conf
shared_preload_libraries = 'pg_hint_plan'
```

**Configurazione:**
```sql
CREATE EXTENSION pg_hint_plan;

-- Forzare uso di indice specifico
/*+ IndexScan(tabella_vendite idx_data_vendita) */
SELECT * FROM tabella_vendite WHERE data_vendita > '2024-01-01';

-- Forzare nested loop join
/*+ NestLoop(v c) */
SELECT * FROM vendite v JOIN clienti c ON v.cliente_id = c.id;

-- Forzare parallel execution
/*+ Parallel(tabella_grande 4) */
SELECT count(*) FROM tabella_grande;
```

## 20. pg_qualstats (Statistiche Predicati)

**Installazione:**
```bash
git clone https://github.com/powa-team/pg_qualstats.git
cd pg_qualstats
make && sudo make install

# Configurare postgresql.conf
shared_preload_libraries = 'pg_qualstats'
```

**Configurazione:**
```sql
CREATE EXTENSION pg_qualstats;

-- Analizzare predicati più utilizzati
SELECT schemaname, tablename, attname, opname, count(*)
FROM pg_qualstats_by_query
WHERE schemaname = 'public'
GROUP BY schemaname, tablename, attname, opname
ORDER BY count(*) DESC;

-- Suggerimenti per nuovi indici
SELECT 'CREATE INDEX ON ' || schemaname || '.' || tablename || ' (' || attname || ');' as suggested_index
FROM pg_qualstats_by_query
WHERE schemaname = 'public'
GROUP BY schemaname, tablename, attname
HAVING count(*) > 100;
```

## 21. pg_prewarm (Pre-caricamento Cache)

**Configurazione:**
```sql
CREATE EXTENSION pg_prewarm;

-- Pre-caricare tabella specifica in cache
SELECT pg_prewarm('tabella_critica');

-- Pre-caricare solo gli indici
SELECT pg_prewarm('tabella_critica', 'read', 'main', 0, 
    (SELECT relpages FROM pg_class WHERE relname = 'idx_tabella_critica'));

-- Configurare pre-caricamento automatico al riavvio
# In postgresql.conf
shared_preload_libraries = 'pg_prewarm'
pg_prewarm.autoprewarm = on
pg_prewarm.autoprewarm_interval = 300
```

## 22. pg_background (Background Workers)

**Installazione:**
```bash
git clone https://github.com/vibhorkum/pg_background.git
cd pg_background
make && sudo make install
```

**Configurazione:**
```sql
CREATE EXTENSION pg_background;

-- Eseguire query in background
SELECT pg_background_launch('
    CREATE TABLE risultati_background AS 
    SELECT cliente_id, count(*) as ordini
    FROM ordini 
    WHERE data_ordine >= ''2024-01-01''
    GROUP BY cliente_id;
');

-- Monitorare processi background
SELECT * FROM pg_background_workers();
```

## Script di Monitoraggio Completo

```sql
-- Creare vista per monitoraggio estensioni
CREATE VIEW monitoring_estensioni AS
SELECT 
    e.extname as estensione,
    n.nspname as schema,
    e.extversion as versione,
    CASE 
        WHEN e.extname = ANY(string_to_array(current_setting('shared_preload_libraries'), ','))
        THEN 'Precaricata'
        ELSE 'Attiva'
    END as stato
FROM pg_extension e
JOIN pg_namespace n ON e.extnamespace = n.oid
ORDER BY e.extname;

-- Monitorare performance generale
CREATE VIEW performance_overview AS
SELECT 
    'Connessioni attive' as metrica,
    count(*)::text as valore
FROM pg_stat_activity WHERE state = 'active'
UNION ALL
SELECT 
    'Query più lenta (secondi)',
    COALESCE(max(EXTRACT(EPOCH FROM (now() - query_start)))::text, '0')
FROM pg_stat_activity WHERE state = 'active'
UNION ALL
SELECT 
    'Cache hit ratio (%)',
    ROUND(100.0 * sum(blks_hit) / NULLIF(sum(blks_hit + blks_read), 0), 2)::text
FROM pg_stat_database;
```

## Conclusioni

Questi addon aggiuntivi trasformano PostgreSQL in una piattaforma enterprise-grade con capacità di AI/ML, alta disponibilità, monitoraggio avanzato e ottimizzazione automatica delle performance.