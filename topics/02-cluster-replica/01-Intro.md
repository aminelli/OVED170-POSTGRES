# Tipologie di Repliche in PostgreSQL

PostgreSQL offre diverse opzioni di replica per soddisfare varie esigenze di disponibilità, scalabilità e tolleranza ai guasti. Ecco le principali tipologie:

## 1. Replica Fisica (Streaming Replication)

**Caratteristiche:**
- Basata sulla copia fisica dei file WAL (Write-Ahead Log)
- Replica binaria a livello di blocco
- Può essere sincrona o asincrona

**Varianti:**
- **Replica asincrona**: Il primary non attende la conferma dal standby
- **Replica sincrona**: Il primary attende la conferma da almeno un standby prima di considerare la transazione completata

## 2. Replica Logica

**Caratteristiche:**
- Replica a livello di istruzione SQL anziché a livello di blocchi
- Permette di replicare solo tabelle specifiche
- Consente di avere schemi diversi tra primary e replica

**Vantaggi:**
- Possibilità di filtrare dati replicati
- Aggiornamenti dello schema possono essere applicati in modo indipendente
- Possibilità di replicare tra versioni diverse di PostgreSQL

## 3. Replica a Cascata (Cascading Replication)

**Caratteristiche:**
- Uno standby può fungere da sorgente per altri standby
- Riduce il carico sul primary
- Utile per distribuire il carico di replica in grandi ambienti

## 4. Punti di Ripristino (PITR - Point-In-Time Recovery)

**Caratteristiche:**
- Non una vera e propria replica continua
- Permette di ripristinare il database a uno specifico punto nel tempo
- Basato sull'archiviazione continua dei WAL

## 5. Soluzioni basate su Trigger

**Esempi:**
- Slony-I
- Londiste
- Bucardo

**Caratteristiche:**
- Basate su trigger per catturare le modifiche
- Maggiore flessibilità ma anche maggiore overhead
- Spesso usate per repliche logiche complesse

## 6. Soluzioni di terze parti

**Esempi popolari:**
- **pgPool-II**: Include funzionalità di bilanciamento del carico e replica
- **pgBouncer**: Principalmente un connection pooler ma usato in architetture di replica
- **WAL-G/WAL-E**: Per archiviazione e ripristino dei WAL

## 7. Replica Multimaster

**Soluzioni:**
- **PostgreSQL BDR** (Bi-Directional Replication)
- **Citus** (estensioni per distribuire il carico)

**Caratteristiche:**
- Più nodi possono accettare scritture
- Complessità maggiore nella risoluzione dei conflitti

## Confronto tra Replica Fisica e Logica

| Caratteristica          | Replica Fisica           | Replica Logica           |
|-------------------------|--------------------------|--------------------------|
| Granularità             | Intero cluster           | Singole tabelle          |
| Overhead                | Minore                   | Maggiore                 |
| Versioni DB             | Deve essere uguale       | Può essere diversa       |
| Filtraggio dati         | No                       | Sì                       |
| Modifiche schema        | Identico                 | Può essere diverso       |

La scelta del tipo di replica dipende dai requisiti specifici di disponibilità, latenza, overhead e flessibilità necessari per la vostra applicazione.