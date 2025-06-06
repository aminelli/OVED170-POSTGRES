Citus è un'estensione di PostgreSQL che permette di distribuire i dati su più nodi per creare un database distribuito. Ecco come creare una tabella con replica e shard usando Citus:

## Prerequisiti

Prima di tutto, assicurati di avere Citus installato e configurato:

```sql
-- Abilita l'estensione Citus
CREATE EXTENSION citus;
```

## Creazione di una tabella distribuita

### 1. Creare la tabella normale

```sql
-- Esempio: tabella degli ordini
CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT NOW(),
    total_amount DECIMAL(10,2),
    status VARCHAR(50)
);
```

### 2. Distribuire la tabella (sharding)

```sql
-- Distribuisce la tabella su più shard usando customer_id come chiave di distribuzione
SELECT create_distributed_table('orders', 'customer_id');
```

### 3. Configurare la replica

```sql
-- Imposta il fattore di replica (numero di copie per ogni shard)
-- Esempio: 2 copie per ogni shard
ALTER TABLE orders SET (shard_replication_factor = 2);
```

## Configurazione avanzata

### Specificare il numero di shard

```sql
-- Crea una tabella distribuita con un numero specifico di shard
SELECT create_distributed_table('orders', 'customer_id', shard_count => 32);
```

### Configurare la replica durante la creazione

```sql
-- Imposta la replica durante la distribuzione
SELECT create_distributed_table('orders', 'customer_id', 
    colocate_with => 'none', 
    shard_count => 32,
    replication_factor => 2
);
```

### Esempio completo con tabelle correlate

```sql
-- Tabella clienti (tabella di riferimento)
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Distribuisci come tabella di riferimento (replicata su tutti i nodi)
SELECT create_reference_table('customers');

-- Tabella ordini distribuita
CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT NOW(),
    total_amount DECIMAL(10,2),
    status VARCHAR(50)
);

-- Distribuisci gli ordini con replica
SELECT create_distributed_table('orders', 'customer_id', 
    shard_count => 32, 
    replication_factor => 2
);

-- Tabella dettagli ordine (co-localizzata con orders)
CREATE TABLE order_items (
    item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT,
    product_id INTEGER,
    quantity INTEGER,
    price DECIMAL(10,2)
);

-- Co-localizza con la tabella orders
SELECT create_distributed_table('order_items', 'order_id', 
    colocate_with => 'orders'
);
```

## Monitoraggio e gestione

### Verificare la distribuzione

```sql
-- Visualizza informazioni sui shard
SELECT * FROM pg_dist_shard WHERE logicalrelid = 'orders'::regclass;

-- Visualizza il posizionamento degli shard
SELECT * FROM pg_dist_shard_placement WHERE shardid IN (
    SELECT shardid FROM pg_dist_shard WHERE logicalrelid = 'orders'::regclass
);
```

### Ribilanciare gli shard

```sql
-- Riequilibra gli shard tra i nodi
SELECT rebalance_table_shards('orders');
```

## Considerazioni importanti

1. **Scelta della chiave di distribuzione**: Scegli una colonna che distribuisca i dati uniformemente
2. **Co-localizzazione**: Tabelle correlate dovrebbero essere co-localizzate per performance ottimali
3. **Tabelle di riferimento**: Piccole tabelle di lookup dovrebbero essere replicate su tutti i nodi
4. **Transazioni**: Le transazioni multi-shard hanno limitazioni
5. **Monitoraggio**: Monitora regolarmente la distribuzione dei dati per evitare sbilanciamenti

Questo approccio ti permette di scalare orizzontalmente PostgreSQL mantenendo la familiarità con SQL standard e garantendo alta disponibilità attraverso la replica.