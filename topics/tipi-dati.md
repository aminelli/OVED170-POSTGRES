# Tipi di dati in PostgreSQL 17

PostgreSQL 17 offre una vasta gamma di tipi di dati per definire i campi delle tabelle. 


## Categorie principali di tipi di dati

1. **Tipi numerici**
2. **Tipi di carattere/testo**
3. **Tipi binari**
4. **Tipi data/ora**
5. **Tipi booleani**
6. **Tipi enumerativi**
7. **Tipi geometrici**
8. **Tipi di rete**
9. **Tipi bit string**
10. **Tipi testo search**
11. **Tipi UUID**
12. **Tipi JSON/XML**
13. **Tipi array**
14. **Tipi compositi**
15. **Tipi range**
16. **Tipi dominio**
17. **Tipi pseudo**

## Tabella comparativa dei tipi di dati principali

| Categoria         | Tipo               | Dimensioni | Descrizione                           | Esempio                                  |
| ----------------- | ------------------ | ---------- | ------------------------------------- | ---------------------------------------- |
| **Numerici**      | `smallint`         | 2 byte     | Intero piccolo                        | `123`                                    |
|                   | `integer`          | 4 byte     | Intero standard                       | `123456`                                 |
|                   | `bigint`           | 8 byte     | Intero grande                         | `1234567890`                             |
|                   | `decimal(p,s)`     | variabile  | Precisione esatta                     | `123.45`                                 |
|                   | `numeric(p,s)`     | variabile  | Sinonimo di decimal                   | `123.45`                                 |
|                   | `real`             | 4 byte     | Floating point a precisione singola   | `123.45`                                 |
|                   | `double precision` | 8 byte     | Floating point a doppia precisione    | `123.456789`                             |
|                   | `serial`           | 4 byte     | Auto-increment intero                 | `1, 2, 3,...`                            |
|                   | `bigserial`        | 8 byte     | Auto-increment bigint                 | `1, 2, 3,...`                            |
| **Testo**         | `character(n)`     | fisso      | Stringa a lunghezza fissa             | `'abc '` (riempita con spazi)            |
|                   | `varchar(n)`       | variabile  | Stringa a lunghezza variabile (max n) | `'abc'`                                  |
|                   | `text`             | variabile  | Stringa a lunghezza illimitata        | `'testo lungo...'`                       |
| **Binari**        | `bytea`            | variabile  | Dati binari                           | `E'\\xDEADBEEF'`                         |
| **Booleani**      | `boolean`          | 1 byte     | Valore vero/falso                     | `TRUE`, `'t'`, `'yes'`, `1`              |
| **Data/Ora**      | `date`             | 4 byte     | Data (senza ora)                      | `'2025-06-04'`                           |
|                   | `time`             | 8 byte     | Ora (senza fuso orario)               | `'15:30:00'`                             |
|                   | `timetz`           | 12 byte    | Ora con fuso orario                   | `'15:30:00+02'`                          |
|                   | `timestamp`        | 8 byte     | Data e ora (senza fuso)               | `'2025-06-04 15:30:00'`                  |
|                   | `timestamptz`      | 8 byte     | Data e ora con fuso                   | `'2025-06-04 15:30:00+02'`               |
|                   | `interval`         | 16 byte    | Intervallo di tempo                   | `'1 day 2 hours'`                        |
| **Geometrici**    | `point`            | 16 byte    | Punto sul piano                       | `(3,5)`                                  |
|                   | `line`             | 32 byte    | Linea infinita                        | `{3,5,2}`                                |
|                   | `lseg`             | 32 byte    | Segmento di linea                     | `[(1,2),(3,4)]`                          |
|                   | `box`              | 32 byte    | Rettangolo                            | `(3,3),(1,1)`                            |
|                   | `path`             | variabile  | Percorso aperto/chiuso                | `[(1,2),(3,4)]`                          |
|                   | `polygon`          | variabile  | Poligono                              | `((1,2),(3,4))`                          |
|                   | `circle`           | 24 byte    | Cerchio                               | `<(1,2),3>`                              |
| **Rete**          | `cidr`             | 7-19 byte  | Indirizzo di rete IPv4/IPv6           | `'192.168.1.0/24'`                       |
|                   | `inet`             | 7-19 byte  | Host o rete IP                        | `'192.168.1.1'`                          |
|                   | `macaddr`          | 6 byte     | Indirizzo MAC                         | `'08:00:2b:01:02:03'`                    |
|                   | `macaddr8`         | 8 byte     | Indirizzo MAC (EUI-64)                | `'08:00:2b:ff:fe:01:02:03'`              |
| **Bit string**    | `bit(n)`           | fisso      | Stringa di bit a lunghezza fissa      | `B'101'`                                 |
|                   | `bit varying(n)`   | variabile  | Stringa di bit a lunghezza variabile  | `B'101'`                                 |
| **Ricerca testo** | `tsvector`         | variabile  | Documento ottimizzato per ricerca     | `'quick' & 'brown'`                      |
|                   | `tsquery`          | variabile  | Query di ricerca                      | `'quick' & 'brown'`                      |
| **UUID**          | `uuid`             | 16 byte    | Identificatore univoco                | `'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'` |
| **JSON/XML**      | `json`             | variabile  | Dati JSON (non validati)              | `'{"key": "value"}'`                     |
|                   | `jsonb`            | variabile  | Dati JSON binari (validati)           | `'{"key": "value"}'`                     |
|                   | `xml`              | variabile  | Dati XML                              | `'<tag>value</tag>'`                     |
| **Array**         | `integer[]`        | variabile  | Array di interi                       | `'{1,2,3}'`                              |
|                   | `text[]`           | variabile  | Array di testo                        | `'{"a","b"}'`                            |
| **Range**         | `int4range`        | variabile  | Range di integer                      | `[1,10)`                                 |
|                   | `int8range`        | variabile  | Range di bigint                       | `[1,100]`                                |
|                   | `numrange`         | variabile  | Range di numeric                      | `[1.0,2.0)`                              |
|                   | `tsrange`          | variabile  | Range di timestamp                    | `['2025-01-01','2025-12-31']`            |
|                   | `tstzrange`        | variabile  | Range di timestamptz                  | `['2025-01-01','2025-12-31']`            |
|                   | `daterange`        | variabile  | Range di date                         | `['2025-01-01','2025-12-31']`            |
| **Altri**         | `money`            | 8 byte     | Valuta                                | `'12.34'`                                |
|                   | `pg_lsn`           | 8 byte     | Log Sequence Number                   | `'0/1ABCDEF'`                            |
|                   | `txid_snapshot`    | variabile  | Snapshot transazione                  | `'10:20:10,14,15'`                       |

## Tipi speciali

- **Tipi compositi**: Creati dall'utente con `CREATE TYPE`
- **Tipi dominio**: Sottotipi con vincoli aggiuntivi (`CREATE DOMAIN`)
- **Tipi pseudo**: `any`, `anyarray`, `anyelement`, `anyenum`, `anynonarray`, `anyrange`, `cstring`, `internal`, `language_handler`, `fdw_handler`, `record`, `trigger`, `void`, `opaque`

PostgreSQL 17 continua ad espandere questa lista con ottimizzazioni e nuovi tipi, mantenendo la flessibilità che lo caratterizza.