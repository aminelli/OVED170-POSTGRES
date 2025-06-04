# PAaametri posgres



## 🔧 Parametri di Connessione

| Parametro          | Descrizione                                                                          |
| ------------------ | ------------------------------------------------------------------------------------ |
| `listen_addresses` | Indirizzi IP su cui il server ascolta le connessioni. Esempio: `'localhost'`, `'*'`. |
| `port`             | Porta su cui il server accetta le connessioni. Default: `5432`.                      |
| `max_connections`  | Numero massimo di connessioni simultanee al database. Default: `100`.                |


## 🧠 Parametri di Memoria

| Parametro              | Descrizione                                                                                           |
| ---------------------- | ----------------------------------------------------------------------------------------------------- |
| `shared_buffers`       | Quantità di memoria dedicata ai buffer condivisi. Raccomandato: 25–40% della RAM.                     |
| `work_mem`             | Memoria per operazioni di sort e hash per ogni operazione. Esempio: `4MB`.                            |
| `maintenance_work_mem` | Memoria per operazioni di manutenzione come VACUUM e CREATE INDEX. Esempio: `64MB`.                   |
| `effective_cache_size` | Stima della memoria disponibile per la cache del sistema operativo. Influenza il planner delle query. |


## 📝 Parametri di Logging

| Parametro                    | Descrizione                                                           |
| ---------------------------- | --------------------------------------------------------------------- |
| `logging_collector`          | Abilita la raccolta dei log in file separati. Default: `off`.         |
| `log_directory`              | Directory dove vengono salvati i file di log. Esempio: `'log'`.       |
| `log_filename`               | Nome del file di log. Esempio: `'postgresql-%Y-%m-%d_%H%M%S.log'`.    |
| `log_min_duration_statement` | Logga le query che impiegano più di un certo tempo. Esempio: `500ms`. |
| `log_connections`            | Logga ogni connessione al database. Default: `off`.                   |

## 🔄 Parametri WAL (Write-Ahead Logging)

| Parametro            | Descrizione                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| `wal_level`          | Livello di dettaglio del WAL. Valori: `minimal`, `replica`, `logical`. |
| `synchronous_commit` | Controlla la sincronizzazione dei commit. Valori: `on`, `off`.         |
| `checkpoint_timeout` | Intervallo tra i checkpoint. Esempio: `5min`.                          |
| `max_wal_size`       | Dimensione massima dei file WAL. Esempio: `1GB`.                       |
| `min_wal_size`       | Dimensione minima dei file WAL. Esempio: `80MB`.                       |


## 🧹 Parametri Autovacuum

| Parametro                      | Descrizione                                                              | 
| ------------------------------ | ------------------------------------------------------------------------ | 
| `autovacuum`                   | Abilita il processo di autovacuum. Default: `on`.                        | 
| `autovacuum_naptime`           | Intervallo tra le esecuzioni di autovacuum. Esempio: `1min`.             | 
| `autovacuum_vacuum_threshold`  | Soglia minima di tuple modificate per attivare il vacuum. Default: `50`. | 
| `autovacuum_analyze_threshold` | Soglia minima di tuple modificate per attivare l'analyze. Default: `50`. | 