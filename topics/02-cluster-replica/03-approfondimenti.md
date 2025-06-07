# Approfondimenti

PostgreSQL supporta varie strategie di **scalabilità**, **replica** e **clustering**, sia **nativamente** che tramite **estensioni o strumenti esterni**. 

Di seguito, un elenco dettagliato delle principali modalità, organizzate per **tipologia di funzionalità** (replica, clustering, scalabilità orizzontale/verticale), con una **tabella comparativa finale**.

---

## 🧬 Tipologie di Replicazione in PostgreSQL

### 1. **Streaming Replication (nativa)**

* **Tipo**: Sincrona o asincrona
* **Replica a livello di WAL**
* **Read-only** nei nodi secondari (replica)
* **Failover** manuale o gestito da strumenti esterni (es. `repmgr`, `Patroni`)
* Usata per **HA (High Availability)**

### 2. **Logical Replication (nativa)**

* Replica a livello di **dato/logica (DDL + DML)**
* Supporta **replica selettiva** (solo alcune tabelle)
* Consente **scrittura** sul nodo secondario (con cautela)
* Utile per **migrazioni**, **integrazione dati**, o **multi-master parziale**

### 3. **Physical Replication (WAL shipping)**

* Metodo tradizionale a livello di **file system**
* Meno flessibile dello streaming, ma **robusto**
* Utilizzato per disaster recovery o backup

---

## 🧱 Clustering e Scalabilità Orizzontale

### 4. **Patroni**

* **HA Manager** per PostgreSQL
* Gestisce il **failover automatico**
* Usa **Etcd/Consul/Zookeeper** per coordinamento
* Supporta cluster **single-primary + standby**

### 5. **Citus**

* **Estensione per PostgreSQL** sviluppata da Microsoft
* Aggiunge **sharding** e **distribuzione dei dati**
* Permette **scrittura e lettura scalabili** su più nodi
* Supporta **transazioni distribuite**, **query parallele**

### 6. **Pgpool-II**

* Middleware tra client e PostgreSQL
* Supporta **load balancing**, **connection pooling**, **replica**, **query routing**
* Replica in modalità **statement-level**, meno precisa ma utile in certi casi

### 7. **BUCARO, BDR (Bi-Directional Replication)**

* Replicazione **multi-master**
* Supporta scrittura su più nodi
* Gestisce **conflitti** e **sincronizzazione** tra nodi
* Più complesso da configurare

---

## 📊 Tabella Comparativa

| Soluzione                 | Tipo Replica    | Supporta Scrittura su Replica | Failover        | Load Balancing | Multi-master | Livello Replica      | Complessità | Note                |
| ------------------------- | --------------- | ----------------------------- | --------------- | -------------- | ------------ | -------------------- | ----------- | ------------------- |
| **Streaming Replication** | Fisica (WAL)    | ❌                             | ✔ (con Patroni) | ❌              | ❌            | Blocco (binario)     | Bassa       | Nativo              |
| **Logical Replication**   | Logica (SQL)    | ✔ (parziale)                  | ❌               | ❌              | Parziale     | Tabella/logica       | Media       | Nativo              |
| **Physical Replication**  | File system     | ❌                             | ❌               | ❌              | ❌            | File system          | Bassa       | Tradizionale        |
| **Patroni**               | Coordinatore HA | ❌                             | ✔ Auto          | ❌              | ❌            | Nessuno (usa SR)     | Media       | Esterno             |
| **Citus**                 | Distribuito     | ✔                             | ✔               | ✔              | ❌            | Query/livello logico | Alta        | Richiede estensione |
| **Pgpool-II**             | Statement-level | ❌ / parziale                  | ✔ (limitato)    | ✔              | ❌            | SQL statement        | Media       | Middleware          |
| **BDR**                   | Bi-direzionale  | ✔                             | ✔               | ✔              | ✔            | Logico               | Alta        | Multi-master        |

---

## 🧩 Considerazioni sull’Uso

| Scenario                       | Soluzione consigliata             |
| ------------------------------ | --------------------------------- |
| Alta disponibilità (HA)        | Streaming Replication + Patroni   |
| Scalabilità in lettura         | Streaming Replication + Pgpool-II |
| Replica selettiva o migrazione | Logical Replication               |
| Scrittura distribuita          | Citus o BDR                       |
| Sharding su grandi volumi      | Citus                             |
| Semplice DR                    | Physical Replication              |

---

 Di seguito un **esempio pratico per ciascuno degli scenari** citati nella tabella "Considerazioni sull’Uso", comprensivi di contesto, tool coinvolti e una descrizione operativa concreta.

---

## ✅ 1. **Alta disponibilità (HA)**

### 🎯 Obiettivo: Failover automatico in caso di crash del nodo primario

### 🛠 Soluzione: **Streaming Replication + Patroni + Etcd**

#### 🔧 Architettura:

* 1 nodo **master PostgreSQL**
* 2 nodi **standby**
* Cluster di **Etcd** per consenso
* **Patroni** su ogni nodo

#### ⚙️ Passaggi:

1. Configura **Streaming Replication** tra i nodi (standby replica WAL dal master).
2. Installa e configura **Etcd** (o Consul).
3. Installa **Patroni** su ogni nodo.
4. Definisci un file di configurazione YAML per Patroni:

```yaml
scope: postgres
name: node1
restapi:
  listen: 0.0.0.0:8008
etcd:
  host: etcd-cluster.local:2379
postgresql:
  data_dir: /var/lib/postgresql/data
  bin_dir: /usr/lib/postgresql/15/bin
  parameters:
    wal_level: replica
    max_wal_senders: 10
    hot_standby: "on"
```

5. Avvia Patroni e verifica failover automatico spegnendo il master.

---

## ✅ 2. **Scalabilità in lettura**

### 🎯 Obiettivo: Distribuire le query SELECT su nodi replica

### 🛠 Soluzione: **Streaming Replication + Pgpool-II**

#### 🔧 Architettura:

* 1 nodo master
* 2 nodi standby
* **Pgpool-II** come proxy/load balancer

#### ⚙️ Passaggi:

1. Abilita streaming replication sui nodi standby.
2. Installa **Pgpool-II** su un server frontend.
3. Configura il file `pgpool.conf`:

```conf
backend_hostname0 = 'master-db'
backend_port0 = 5432
backend_weight0 = 1

backend_hostname1 = 'replica1'
backend_port1 = 5432
backend_weight1 = 2

load_balance_mode = on
master_slave_mode = on
```

4. Modifica la tua app per connettersi a **Pgpool-II**.
5. Verifica che le SELECT vengano distribuite ai nodi replica.

---

## ✅ 3. **Replica selettiva o migrazione**

### 🎯 Obiettivo: Migrare alcune tabelle su un'altra istanza

### 🛠 Soluzione: **Logical Replication**

#### ⚙️ Passaggi:

1. Sul nodo **publisher**:

```sql
CREATE PUBLICATION mypub FOR TABLE orders, customers;
```

2. Sul nodo **subscriber**:

```sql
CREATE SUBSCRIPTION mysub
  CONNECTION 'host=publisher_ip port=5432 user=replicator password=secret dbname=mydb'
  PUBLICATION mypub;
```

3. I dati di `orders` e `customers` iniziano a sincronizzarsi.
4. Il subscriber può essere su **versione diversa di PostgreSQL**, utile in migrazioni.

---

## ✅ 4. **Scrittura distribuita (multi-writer)**

### 🎯 Obiettivo: Gestire scritture su più nodi

### 🛠 Soluzione: **BDR (Bi-Directional Replication)**

#### ⚙️ Passaggi:

1. Usa una distribuzione che supporti **BDR** (es. [2ndQuadrant BDR](https://www.2ndquadrant.com/en/resources/bdr/)).
2. Configura ogni nodo per accettare connessioni da altri peer.
3. Definisci la topologia:

```sql
SELECT bdr.bdr_group_create(local_node_name := 'node1',
                            node_external_dsn := 'host=node1 port=5432 dbname=mydb');
```

4. Aggiungi altri nodi con:

```sql
SELECT bdr.bdr_group_join(local_node_name := 'node2',
                          node_external_dsn := 'host=node2 port=5432 dbname=mydb',
                          join_using_dsn := 'host=node1 port=5432 dbname=mydb');
```

5. Scritture da più nodi, gestione conflitti automatica (o con regole definite).

---

## ✅ 5. **Sharding su grandi volumi di dati**

### 🎯 Obiettivo: Partizionare automaticamente i dati su più nodi

### 🛠 Soluzione: **Citus**

#### 🔧 Architettura:

* 1 nodo coordinator
* 2+ nodi worker

#### ⚙️ Passaggi:

1. Installa **Citus** su tutti i nodi.
2. In `postgresql.conf` dei worker:

```conf
shared_preload_libraries = 'citus'
```

3. Sul nodo coordinator:

```sql
SELECT * from master_add_node('worker1', 5432);
SELECT * from master_add_node('worker2', 5432);

CREATE TABLE events (
  id bigint,
  user_id int,
  data jsonb
);

SELECT create_distributed_table('events', 'user_id');
```

4. Tutti gli insert su `events` vengono **shardati** su base `user_id`.
5. Query parallele automatiche su tutti i nodi.

---

## ✅ 6. **Semplice disaster recovery (DR)**

### 🎯 Obiettivo: Replica passiva per ripristino in caso di disastro

### 🛠 Soluzione: **Physical Replication via WAL shipping**

#### ⚙️ Passaggi:

1. Configura archiviazione WAL sul master:

```conf
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'
```

2. Copia un **base backup** sul nodo replica:

```bash
pg_basebackup -h master -D /var/lib/postgresql/data -U replicator -P
```

3. Configura `restore_command` sul replica:

```conf
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
```

4. Avvia il nodo replica in modalità **hot standby**:

```conf
hot_standby = on
```

5. In caso di disastro, promuovi il nodo:

```bash
pg_ctl promote
```

---

Di seguito, **script automatizzati e file di configurazione completi** per i principali scenari PostgreSQL, suddivisi per tecnologia utilizzata. Gli script sono pensati per ambienti **Linux (Debian/Ubuntu)** con PostgreSQL 15, ma facilmente adattabili ad altre versioni.

---

## ✅ 1. **Alta Disponibilità (HA)** con **Streaming Replication + Patroni + Etcd**

### 📁 Struttura file:

```
/opt/postgres-cluster/
├── patroni.yml
├── etcd.service
└── setup.sh
```

### 🧾 `patroni.yml` (esempio per nodo `node1`)

```yaml
scope: postgres
namespace: /db/
name: node1

restapi:
  listen: 0.0.0.0:8008
  connect_address: 192.168.0.101:8008

etcd:
  host: 192.168.0.10:2379

postgresql:
  listen: 0.0.0.0:5432
  connect_address: 192.168.0.101:5432
  data_dir: /var/lib/postgresql/15/main
  bin_dir: /usr/lib/postgresql/15/bin
  authentication:
    superuser:
      username: postgres
      password: postgres
    replication:
      username: replicator
      password: replicate123
  parameters:
    wal_level: replica
    max_wal_senders: 10
    hot_standby: "on"
    synchronous_commit: "on"
```

### ⚙️ `setup.sh` (installazione e avvio)

```bash
#!/bin/bash

apt update
apt install -y etcd postgresql-15 python3-pip
pip install patroni[etcd]

systemctl enable etcd
systemctl start etcd

# Patroni
cat > /etc/systemd/system/patroni.service <<EOF
[Unit]
Description=Patroni PostgreSQL HA
After=network.target

[Service]
User=postgres
ExecStart=/usr/local/bin/patroni /opt/postgres-cluster/patroni.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable patroni
systemctl start patroni
```

---

## ✅ 2. **Scalabilità in Lettura** con **Pgpool-II + Streaming Replication**

### 🧾 `pgpool.conf` (principali parametri)

```conf
listen_addresses = '*'
port = 9999

backend_hostname0 = 'master'
backend_port0 = 5432
backend_weight0 = 1
backend_flag0 = 'ALWAYS_MASTER'

backend_hostname1 = 'replica1'
backend_port1 = 5432
backend_weight1 = 2
backend_flag1 = 'DISALLOW_TO_FAILOVER'

load_balance_mode = on
master_slave_mode = on
replication_mode = off

sr_check_period = 10
sr_check_user = 'postgres'
sr_check_password = 'postgres'
```

### ⚙️ `setup_pgpool.sh`

```bash
#!/bin/bash

apt update
apt install -y pgpool2

cp /opt/postgres-cluster/pgpool.conf /etc/pgpool2/
systemctl restart pgpool2
systemctl enable pgpool2
```

---

## ✅ 3. **Logical Replication (replica selettiva)**

### 🔐 Permessi e utente

```sql
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicate123';
```

### 🧾 Script SQL su nodo publisher:

```sql
CREATE PUBLICATION mypub FOR TABLE public.orders, public.customers;
```

### 🧾 Script SQL su nodo subscriber:

```sql
CREATE SUBSCRIPTION mysub
  CONNECTION 'host=192.168.0.101 port=5432 user=replicator password=replicate123 dbname=mydb'
  PUBLICATION mypub;
```

---

## ✅ 4. **Scrittura distribuita con BDR (Multi-master)**

### ⚠️ Richiede PostgreSQL compatibile con BDR (2ndQuadrant)

### 🧾 Script su primo nodo:

```sql
SELECT bdr.bdr_group_create(
    local_node_name := 'node1',
    node_external_dsn := 'host=node1 port=5432 dbname=mydb'
);
```

### 🧾 Script su secondo nodo:

```sql
SELECT bdr.bdr_group_join(
    local_node_name := 'node2',
    node_external_dsn := 'host=node2 port=5432 dbname=mydb',
    join_using_dsn := 'host=node1 port=5432 dbname=mydb'
);
```

---

## ✅ 5. **Sharding e distribuzione con Citus**

### ⚙️ `setup_citus.sh` (coordinator e worker)

```bash
#!/bin/bash

apt install -y postgresql-15-citus

echo "shared_preload_libraries = 'citus'" >> /etc/postgresql/15/main/postgresql.conf
systemctl restart postgresql
```

### 🧾 SQL sul coordinator:

```sql
SELECT master_add_node('worker1', 5432);
SELECT master_add_node('worker2', 5432);

CREATE TABLE users (id bigint, name text);
SELECT create_distributed_table('users', 'id');

INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
```

---

## ✅ 6. **Disaster Recovery con WAL Shipping**

### 🧾 Master - `postgresql.conf`

```conf
wal_level = replica
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'
```

### ⚙️ Replica - `recovery.conf` o `postgresql.auto.conf`

```conf
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
standby_mode = on
primary_conninfo = 'host=master_ip port=5432 user=replicator password=replicate123'
```

### 🧾 Promozione in caso di disastro:

```bash
pg_ctl promote
```

---

### 🔧 Extra: Script per `pg_basebackup`

```bash
pg_basebackup -h master -D /var/lib/postgresql/15/main -U replicator -P --write-recovery-conf
```


