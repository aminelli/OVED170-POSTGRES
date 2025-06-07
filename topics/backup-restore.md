# BACKUP / RESTORE

PostgreSQL 17 offre diversi strumenti potenti per il backup e restore dei database. 

Ecco una guida dettagliata sui principali tools:

---

## pg_dump e pg_restore

**pg_dump** è lo strumento principale per creare backup logici di singoli database.

### Sintassi base di pg_dump:
```bash
pg_dump [opzioni] [nome_database]
```

### Opzioni principali:
- `-h hostname` - specifica l'host del server
- `-p porta` - specifica la porta (default 5432)
- `-U username` - specifica l'utente
- `-W` - richiede password
- `-f file_output` - specifica il file di destinazione
- `-F formato` - specifica il formato (c=custom, t=tar, p=plain text)
- `-v` - modalità verbose
- `-s` - solo schema (senza dati)
- `-a` - solo dati (senza schema)
- `-t tabella` - backup di una singola tabella
- `-n schema` - backup di un singolo schema

### Esempi pratici:

**Backup completo in formato custom:**
```bash
pg_dump -h localhost -U postgres -F c -f database_backup.dump mydatabase
```

**Backup solo schema:**
```bash
pg_dump -h localhost -U postgres -s -f schema_only.sql mydatabase
```

**Backup di una singola tabella:**
```bash
pg_dump -h localhost -U postgres -t users -f users_backup.sql mydatabase
```

---

## pg_restore

**pg_restore** ripristina backup creati con pg_dump in formato custom o tar.

### Sintassi base:
```bash
pg_restore [opzioni] file_backup
```

### Opzioni principali:
- `-h hostname` - host del server di destinazione
- `-p porta` - porta del server
- `-U username` - utente
- `-d database` - database di destinazione
- `-v` - modalità verbose
- `-c` - pulisce (DROP) gli oggetti prima del restore
- `-C` - crea il database prima del restore
- `-1` - esegue il restore in una singola transazione
- `-j numero` - numero di job paralleli
- `-t tabella` - ripristina solo una tabella specifica
- `-s` - ripristina solo lo schema
- `-a` - ripristina solo i dati

### Esempi di restore:

**Restore completo:**
```bash
pg_restore -h localhost -U postgres -d mydatabase -v database_backup.dump
```

**Restore con creazione database:**
```bash
pg_restore -h localhost -U postgres -C -d postgres database_backup.dump
```

**Restore parallelo (più veloce):**
```bash
pg_restore -h localhost -U postgres -d mydatabase -j 4 database_backup.dump
```

---

## pg_dumpall

**pg_dumpall** crea backup di tutti i database del cluster PostgreSQL, inclusi ruoli e tablespace.

### Sintassi:
```bash
pg_dumpall [opzioni] > backup_completo.sql
```

### Opzioni principali:
- `-g` - solo ruoli globali
- `-r` - solo ruoli
- `-t` - solo tablespace
- `-s` - solo schema
- `-v` - modalità verbose

### Esempio:
```bash
pg_dumpall -h localhost -U postgres -v > cluster_backup.sql
```

---

## pg_basebackup

**pg_basebackup** crea backup fisici completi del cluster, utili per il Point-in-Time Recovery (PITR).

### Sintassi:
```bash
pg_basebackup [opzioni]
```

### Opzioni principali:
- `-D directory` - directory di destinazione
- `-F formato` - formato (plain o tar)
- `-z` - compressione
- `-P` - mostra progresso
- `-v` - modalità verbose
- `-W numero` - numero di writer paralleli
- `-S slot_name` - usa uno slot di replicazione specifico

### Esempio:
```bash
pg_basebackup -h localhost -U replicator -D /backup/base -F tar -z -P -v
```

---

## Strategie di Backup

### Backup Logico vs Fisico

**Backup Logico (pg_dump):**
- Indipendente dalla versione
- Selettivo (singole tabelle/schemi)
- Più lento per database grandi
- Formato SQL leggibile

**Backup Fisico (pg_basebackup):**
- Più veloce per database grandi
- Backup completo del cluster
- Dipendente dalla versione
- Supporta Point-in-Time Recovery

### Automazione con Script

Esempio di script per backup automatico:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DATABASE="mydatabase"

# Backup logico
pg_dump -h localhost -U postgres -F c -f "$BACKUP_DIR/backup_$DATABASE_$DATE.dump" $DATABASE

# Rimuovi backup più vecchi di 7 giorni
find $BACKUP_DIR -name "backup_$DATABASE_*.dump" -mtime +7 -delete
```

## Novità PostgreSQL 17

PostgreSQL 17 ha introdotto alcuni miglioramenti nei tools di backup:

- Miglioramenti nelle performance di pg_dump per database di grandi dimensioni
- Supporto migliorato per il backup incrementale
- Ottimizzazioni nella compressione
- Migliore gestione degli errori e logging

## Best Practices

1. **Testa sempre i backup** con restore su ambiente di test
2. **Usa backup multipli** (logico + fisico)
3. **Monitora le dimensioni** dei backup nel tempo
4. **Automatizza il processo** con cron job
5. **Conserva i backup** in location multiple
6. **Documenta la procedura** di recovery
7. **Usa compressione** per risparmiare spazio
8. **Verifica l'integrità** dei file di backup

Questi strumenti forniscono una soluzione completa per la gestione dei backup in PostgreSQL 17, permettendo di implementare strategie robuste di disaster recovery adatte a diverse esigenze aziendali.