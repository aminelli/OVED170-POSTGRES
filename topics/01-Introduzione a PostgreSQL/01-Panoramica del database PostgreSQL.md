# Overview

## ✅ **1. Cos'è PostgreSQL**

**PostgreSQL** è un **sistema di gestione di basi di dati relazionali (RDBMS)** open source, **object-relational**, conforme agli standard **SQL:2011** e oltre. 

Nasce dal progetto **Ingres** e poi **Postgres** dell’università di Berkeley negli anni ’80. È scritto in C ed è disponibile su Linux, Windows, macOS e BSD.

**Key features:**

* ACID compliant (Atomicity, Consistency, Isolation, Durability)
* MVCC (Multi-Version Concurrency Control)
* Supporto per JSON, XML, hstore
* Stored procedures (PL/pgSQL, PL/Python, PL/Perl, ecc.)
* Estensibilità elevatissima
* Replicazione nativa
* Full-text search

---

## 🧱 **2. Architettura interna**

### 2.1 **Processi principali**

PostgreSQL utilizza un **modello a processi** (non a thread):

* **`postmaster`**: processo padre (gestisce connessioni e processi figli)
* **`postgres` (backend)**: un processo per ogni connessione client
* **`walwriter`**: scrive sul Write-Ahead Log
* **`bgwriter`**: scrive i buffer sporchi su disco
* **`checkpointer`**: forza il salvataggio dei dati su disco
* **`autovacuum`**: fa cleanup e analisi per evitare la crescita delle tabelle
* **`archiver`, `logical replication launcher`, `stats collector`**, ecc.

### 2.2 **Memory management**

* **Shared Buffers**: cache di pagine del disco (default 128MB)
* **Work Mem**: RAM per operazioni intermedie (sort, hash, ecc.)
* **WAL Buffers**: cache per i log delle transazioni
* **Temp Buffers**: per le query temporanee

---

## 🔧 **3. Storage engine e MVCC**

PostgreSQL utilizza **MVCC** per fornire letture coerenti senza bloccare scritture:

* Le tuple hanno due colonne nascoste: `xmin`, `xmax`
* Ogni modifica crea una **nuova versione della riga**
* Il **VACUUM** pulisce le versioni obsolete (per questo è fondamentale)
* Gli **indice non bloccano le scritture** (a differenza di molti altri RDBMS)

I dati sono memorizzati in **heap** (file `.rel`), con **TOAST** per gestire valori grandi (es. blob, testi lunghi).

---

## 🧮 **4. Tipi di dati**

PostgreSQL supporta:

* **Tipi standard SQL**: `INTEGER`, `TEXT`, `BOOLEAN`, `DATE`, ecc.
* **Tipi avanzati**: `JSONB`, `ARRAY`, `UUID`, `HSTORE`, `CIDR`, `INET`, `TSVECTOR`
* **Custom types**: è possibile definire **domini**, **enum**, **composite types** e persino nuovi tipi con C
* **Geometric types** e **tipi spaziali** (con estensione PostGIS)

---

## 📚 **5. Linguaggi procedurali e estendibilità**

Puoi scrivere funzioni in:

* **PL/pgSQL**: simile a PL/SQL di Oracle
* **PL/Python**, **PL/Perl**, **PL/V8** (JS), **PL/R** (statistica), ecc.
* Creazione di **operatori custom**, **tipi custom**, **index access methods**, **planner hook**

PostgreSQL supporta:

* **Extension System** (`CREATE EXTENSION`)
* **Foreign Data Wrappers (FDW)** per interrogare fonti esterne (Oracle, CSV, MongoDB, ecc.)

---

## 🔁 **6. Replicazione e High Availability**

### 6.1 Replicazione nativa

* **Streaming replication** (asincrona o sincronizzata)
* **Logical replication**: livello di riga, per replicazione selettiva
* **Physical replication**: basata su WAL

### 6.2 Clustering e Failover

* Non è "shared-nothing" come Oracle RAC
* Usa soluzioni esterne per clustering e failover:

  * **Patroni** + **Etcd/Consul**
  * **Pgpool-II**
  * **Repmgr**
  * **Stolon**

---

## 🔎 **7. Performance e ottimizzazione**

* **Query planner** molto potente (usa costi stimati, analizza piani esecuzione)
* **Explain/Explain Analyze** per vedere dettagli dei piani
* **Materialized views**
* **Indexing**:

  * B-Tree (default)
  * GIN (es. per JSONB e full-text)
  * GiST (geospaziali)
  * BRIN (ottimo per dati grandi ordinati)
  * Hash (poco usato)

---

## 🔐 **8. Sicurezza**

* **Authentication**:

  * Password (MD5, SCRAM-SHA-256)
  * GSSAPI, SSPI, Kerberos, LDAP, Certificati
* **Authorization**:

  * Ruoli e permessi granulari su schema, tabella, colonna, funzione
* **Row-Level Security** (RLS)
* **SSL/TLS** per cifrare connessioni

---

## 🔄 **9. Tooling e gestione**

* **CLI**: `psql`, `pg_dump`, `pg_restore`, `pg_basebackup`, `vacuumdb`
* **GUI**: pgAdmin, DBeaver, OmniDB
* **Backup**:

  * Logical: `pg_dump`, `pg_dumpall`
  * Physical: `pg_basebackup`, `Barman`, `pgBackRest`

---

## 🧪 **10. Use case avanzati**

* **Data warehousing** (con partizionamento e BRIN)
* **Microservizi e JSONB**: schema-flessibile
* **Event sourcing** con logical replication
* **Geospatial DB**: con PostGIS
* **ML pipelines**: tramite PL/Python o FDW verso Spark/Hadoop
* **Multitenancy**: tramite RLS o schema-based isolation

---

## 📈 **11. Roadmap e community**

* Rilasci annuali (es. PostgreSQL 16 è uscito nel 2023, 17 atteso nel 2024)
* PostgreSQL è **molto conservativo**: backwards compatibility importante
* Una community vastissima e molto attiva
* Integrazione con Kubernetes via **CrunchyData** o **Zalando Operator**

---

## 📦 Esempi di estensioni popolari

| Estensione               | Funzionalità             |
| ------------------------ | ------------------------ |
| **PostGIS**              | GIS avanzato             |
| **pg\_stat\_statements** | Profiling query          |
| **pg\_partman**          | Gestione partizioni      |
| **timescaledb**          | Time-series DB           |
| **citext**               | TEXT case-insensitive    |
| **pg\_hint\_plan**       | Forzare il query planner |

