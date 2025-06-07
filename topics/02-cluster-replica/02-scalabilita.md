# SCALABILITA' E VARIE

PostgreSQL offre diverse **strategie di scalabilità**, **replica** e **clustering**, sia **native** che tramite **soluzioni di terze parti**. Di seguito sono elencate:

1. ✅ Tutte le **soluzioni native** (replica, scalabilità, clustering).
2. 🌐 Le principali **soluzioni di terze parti** (aggiornate e diffuse).
3. 📊 Una **tabella comparativa dettagliata** con pro/contro.

---

## ✅ Soluzioni **Native** di PostgreSQL

### 1. **Streaming Replication** (fisica)

Replica binaria sincrona/asincrona dei WAL.

* 📌 Tipo: Replica **fisica**.
* 📖 Replica il cluster intero, non tabelle selettive.
* ✅ Alta affidabilità, **warm standby**/failover.
* ❌ Non supporta query su nodi standby (read-only solo in hot standby).

### 2. **Hot Standby**

Replica fisica + letture su standby.

* Estensione della streaming replication.
* 📌 Nodo replica può eseguire query **read-only**.
* Ottimo per **scalabilità in lettura**.

### 3. **Logical Replication**

Replica a livello di **tabelle**/database.

* 📌 Tipo: Replica **logica** (DDL e DML).
* ✅ Replica selettiva (tabelle, colonne).
* ✅ Utile per **migrazioni**, **upgrade zero-downtime**.
* ❌ Non replica tutto (es. sequenze, funzioni, DDL avanzato).

### 4. **Foreign Data Wrapper (FDW) + postgres\_fdw**

Accesso a dati remoti tra istanze PostgreSQL.

* 📌 Tipo: Federazione dati.
* ✅ Accesso remoto a tabelle da altri cluster.
* Usato per **sharding manuale** o query distribuite.

---

## 🌐 Soluzioni di **Terze Parti** moderne e usatissime

### 1. **Patroni**

Failover automatico e HA per streaming replication.

* Usa etcd/Consul/Zookeeper per coordinamento.
* Compatibile con **pgBackRest**, **repmgr**.

### 2. **Citus** (by Microsoft)

Estende PostgreSQL per **scalabilità orizzontale** (sharding + distributed execution).

* Shard automatico delle tabelle.
* Supporta **OLTP/HTAP** workload.
* Usato in Azure Database for PostgreSQL – Hyperscale.

### 3. **Pgpool-II**

Middleware per load balancing, failover, connection pooling.

* Supporta:

  * Load balancing in lettura.
  * Failover detection.
  * Query routing.
* Non è un cluster vero, ma migliora scalabilità in lettura.

### 4. **Barman / pgBackRest**

Gestione di backup e replica da file WAL.

* Supportano PITR, compressione, multi-destinazione.
* Perfetti per disaster recovery con replica fisica.

### 5. **repmgr** (obsoleto ma ancora usato)

Gestione avanzata della streaming replication + failover manuale/automatico.

---

## 📊 Tabella Comparativa: Replica e Clustering in PostgreSQL

| **Tecnologia**        | **Tipo**         | **Scalabilità** | **Failover Auto** | **Read Scaling**     | **Sharding** | **Nota**                                     |
| --------------------- | ---------------- | --------------- | ----------------- | -------------------- | ------------ | -------------------------------------------- |
| Streaming Replication | Fisica           | ❌               | ❌ (manuale)       | 🔶 (con Hot Standby) | ❌            | Replica binaria WAL, semplice                |
| Hot Standby           | Fisica           | 🔶 Lettura      | ❌ (o via Patroni) | ✅                    | ❌            | Standby eseguono query read-only             |
| Logical Replication   | Logica           | 🔶              | ❌                 | ✅                    | 🔶 (man.)    | Replica tabelle specifiche                   |
| postgres\_fdw         | Federazione      | 🔶 Manuale      | ❌                 | ✅                    | 🔶 (man.)    | Richiede query rewrite/shard awareness       |
| Citus                 | Sharding + Dist. | ✅ (orizzontale) | ✅ (HA integrata)  | ✅                    | ✅            | Scalabilità distribuita automatica           |
| Patroni               | HA Coordinator   | ❌               | ✅                 | 🔶                   | ❌            | Aggiunge failover automatico                 |
| Pgpool-II             | Middleware       | 🔶 Lettura      | ✅ (parziale)      | ✅                    | ❌            | Load balancing + pooling                     |
| repmgr                | Gestione replica | ❌               | ✅ (con script)    | 🔶                   | ❌            | Legacy, usato con SR                         |
| Barman/pgBackRest     | Backup+replica   | ❌               | ❌                 | ❌                    | ❌            | Usato per DR e PITR, integrabile con Patroni |

---

## 📌 Quale scegliere?

| Scenario                           | Soluzione consigliata           |
| ---------------------------------- | ------------------------------- |
| HA semplice                        | Streaming Replication + Patroni |
| Scalabilità in lettura             | Hot Standby + Pgpool-II         |
| Replica selettiva o cross-versione | Logical Replication             |
| Scalabilità orizzontale (sharding) | **Citus** (nativo e potente)    |
| Accesso federato                   | `postgres_fdw`                  |
| Replica e failover gestiti legacy  | repmgr + SR                     |
| Disaster recovery                  | pgBackRest o Barman             |


---

## Conclusioni

PostgreSQL supporta diversi tipi di replica per garantire alta disponibilità, bilanciamento del carico e ridondanza dei dati; riepilogando: 

### 1. **Replica Fisica (Streaming Replication)**
   - **Replica sincrona**: Il primary aspetta la conferma dal standby prima di considerare una transazione completata.
   - **Replica asincrona**: Il primary non attende la conferma dal standby, migliorando le prestazioni ma con un rischio di perdita di dati in caso di failover.
   - **Cascading Replication**: Un standby può replicare a sua volta su altri standby, riducendo il carico sul primary.

### 2. **Logical Replication**
   - Replica a livello di tabella (non basata sui WAL fisici, ma sui cambiamenti logici).
   - Utile per:
     - Aggiornamenti di versione senza downtime.
     - Consolidamento di dati da più database.
     - Replica selettiva (solo alcune tabelle).
   - Basata sulle **pubblicazioni (publisher)** e **sottoscrizioni (subscriber)**.

### 3. **Replica basata su WAL (File-based Log Shipping)**
   - Invio dei file WAL (Write-Ahead Log) a un standby tramite archiviazione condivisa o trasferimento manuale/automatico.
   - Modalità:
     - **Restore Command**: Configurazione manuale per recuperare i WAL.
     - **Archive Mode**: PostgreSQL archivia automaticamente i WAL in una posizione specifica.

### 4. **Replica con Slots di Replica (Replication Slots)**
   - Garantisce che i WAL non vengano eliminati finché non sono stati ricevuti dai standby.
   - Utile per evitare la perdita di dati in caso di disconnessione prolungata di un standby.

### 5. **Replica Multi-Master (Estensioni esterne)**
   - PostgreSQL nativamente supporta solo la replica **single-master** (un primary e uno o più standby).
   - Per la replica **multi-master** (più nodi scrivibili), sono necessarie estensioni esterne come:
     - **BDR (Bi-Directional Replication)** (obsoleto in PG 10+).
     - **Pgpool-II** (con modalità di replica e bilanciamento del carico).
     - **Citus** (per sharding e distribuzione orizzontale).

### 6. **Replica con Quorum Commit (PostgreSQL 14+)**
   - Permette di configurare un quorum di standby sincroni per garantire la ridondanza prima del commit.

### 7. **Replica Geografica (Geo-Replication)**
   - Configurazione di standby in location remote per disaster recovery.

### Confronto tra Replica Fisica e Logica:
| **Caratteristica**       | **Replica Fisica**               | **Replica Logica**               |
|--------------------------|----------------------------------|----------------------------------|
| **Granularità**          | Intero cluster                  | Singole tabelle                 |
| **Overhead**             | Basso (WAL streaming)           | Medio (decodifica logica)       |
| **Usi comuni**           | HA, failover, backup            | ETL, aggiornamenti, reporting   |
| **Versioni supportate**  | Tutte                           | PostgreSQL 10+ (nativamente)    |

PostgreSQL offre grande flessibilità nella scelta della replica in base alle esigenze di **disponibilità**, **performance** e **scalabilità**. 

La scelta dipende dal caso d’uso specifico (HA, scalabilità in lettura, distribuzione di dati, ecc.).