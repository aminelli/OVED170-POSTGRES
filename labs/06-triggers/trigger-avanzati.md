# Esercizio: Trigger Avanzati e HSTORE

In questo esercizio vengono mostrati alcuni esempi avanzati di trigger su PostgreSQL che coprono diversi scenari d'uso:

## 1. **Audit Completo con HSTORE**
- Registra automaticamente tutte le modifiche (INSERT, UPDATE, DELETE)
- Usa HSTORE per memorizzare i valori old/new in formato flessibile
- Traccia solo i campi effettivamente modificati
- Include informazioni di sessione e timestamp

## 2. **Validazione Business Rules Complesse**
- Controlla che il prezzo non superi il 300% della media di categoria
- Limita il numero di prodotti per fornitore
- Aggiorna automaticamente campi come `updated_at`

## 3. **Gestione Stock Automatica**
- Verifica disponibilità prima di creare ordini
- Aggiorna automaticamente le quantità in stock
- Ripristina stock quando gli ordini vengono cancellati
- Calcola totali automaticamente

## 4. **Sistema di Notifiche e Alert**
- Genera alert per stock basso/esaurito
- Invia notifiche PostgreSQL in tempo reale
- Diversi livelli di priorità (medium, high, critical)
- Memorizza alert in tabella per tracking

## 5. **Cache e Denormalizzazione**
- Mantiene statistiche aggregate in tempo reale
- Aggiorna contatori e medie automaticamente
- Gestisce spostamenti tra categorie

## 6. **Trigger Condizionali Configurabili**
- Abilita/disabilita trigger tramite configurazione
- Supporta configurazioni JSON per flessibilità
- Permette controllo granulare su quali tabelle processare

**Caratteristiche Avanzate:**
- Uso di `HSTORE` per storage flessibile
- Gestione errori con `RAISE EXCEPTION`
- Notifiche asincrone con `pg_notify`
- Configurazione dinamica tramite tabelle
- Ottimizzazioni per performance

Tutti i trigger includono gestione degli errori robusta e sono progettati per essere efficienti anche su tabelle con molti record.

---

## HSTORE

Per abilitare l'estensione hstore su PostgreSQL, seguire i seguenti passaggi:

### 1. Connettiti al database come superuser
```sql
psql -U postgres -d nome_del_database
```

### 2. Abilita l'estensione hstore
```sql
CREATE EXTENSION IF NOT EXISTS hstore;
```

### 3. Verifica che l'estensione sia stata installata
```sql
SELECT * FROM pg_extension WHERE extname = 'hstore';
```

oppure

```sql
\dx hstore
```

### 4. Esempio di utilizzo
Una volta abilitata, puoi usare hstore per memorizzare coppie chiave-valore:

```sql
-- Creare una tabella con colonna hstore
CREATE TABLE prodotti (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    attributi hstore
);

-- Inserire dati
INSERT INTO prodotti (nome, attributi) VALUES 
('Laptop', 'marca=>Dell, ram=>16GB, ssd=>512GB'),
('Smartphone', 'marca=>Samsung, storage=>128GB, colore=>nero');

-- Query sui dati hstore
SELECT nome, attributi->'marca' AS marca 
FROM prodotti 
WHERE attributi ? 'ram';
```

## Note importanti
- Devi avere privilegi di superuser per creare estensioni
- L'estensione hstore è inclusa in PostgreSQL di default dalla versione 9.1+
- Se ottieni errori di permessi, contatta l'amministratore del database

L'estensione sarà ora disponibile per tutti gli utenti del database in cui l'hai abilitata.

---

## TRIGGER AVANZATI: Codice SQL


```sql

-- =====================================================
-- ESEMPI AVANZATI DI TRIGGER POSTGRESQL
-- =====================================================

-- 1. TRIGGER PER AUDIT COMPLETO CON HSTORE
-- =====================================================

-- Tabella di audit che registra tutte le modifiche
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    old_values HSTORE,
    new_values HSTORE,
    changed_fields TEXT[],
    user_name TEXT DEFAULT current_user,
    timestamp TIMESTAMP DEFAULT now(),
    session_id TEXT DEFAULT inet_client_addr()::text
);

-- Funzione generica per audit
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    old_record HSTORE;
    new_record HSTORE;
    changed_fields TEXT[];
    key TEXT;
BEGIN
    -- Converti i record in HSTORE
    IF TG_OP = 'DELETE' THEN
        old_record = hstore(OLD);
        INSERT INTO audit_log (table_name, operation, old_values)
        VALUES (TG_TABLE_NAME, TG_OP, old_record);
        RETURN OLD;
    ELSIF TG_OP = 'INSERT' THEN
        new_record = hstore(NEW);
        INSERT INTO audit_log (table_name, operation, new_values)
        VALUES (TG_TABLE_NAME, TG_OP, new_record);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        old_record = hstore(OLD);
        new_record = hstore(NEW);
        
        -- Trova i campi modificati
        FOR key IN SELECT unnest(akeys(new_record)) LOOP
            IF old_record->key IS DISTINCT FROM new_record->key THEN
                changed_fields = array_append(changed_fields, key);
            END IF;
        END LOOP;
        
        -- Inserisci solo se ci sono cambiamenti
        IF array_length(changed_fields, 1) > 0 THEN
            INSERT INTO audit_log (table_name, operation, old_values, new_values, changed_fields)
            VALUES (TG_TABLE_NAME, TG_OP, old_record, new_record, changed_fields);
        END IF;
        
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 2. TRIGGER PER CONTROLLO BUSINESS RULES COMPLESSE
-- =====================================================

-- Tabella prodotti con vincoli complessi
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INTEGER,
    supplier_id INTEGER,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    is_active BOOLEAN DEFAULT true
);

-- Tabella ordini
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    order_date TIMESTAMP DEFAULT now(),
    status VARCHAR(20) DEFAULT 'pending'
);

-- Funzione per validazione business rules
CREATE OR REPLACE FUNCTION validate_product_business_rules()
RETURNS TRIGGER AS $$
DECLARE
    avg_price DECIMAL(10,2);
    supplier_product_count INTEGER;
BEGIN
    -- Regola 1: Il prezzo non può essere più del 300% della media di categoria
    SELECT AVG(price) INTO avg_price 
    FROM products 
    WHERE category = NEW.category AND id != COALESCE(NEW.id, 0);
    
    IF avg_price IS NOT NULL AND NEW.price > avg_price * 3 THEN
        RAISE EXCEPTION 'Prezzo troppo alto: %.2f supera il 300%% della media di categoria (%.2f)', 
                       NEW.price, avg_price;
    END IF;
    
    -- Regola 2: Un fornitore non può avere più di 100 prodotti attivi
    SELECT COUNT(*) INTO supplier_product_count
    FROM products 
    WHERE supplier_id = NEW.supplier_id 
    AND is_active = true 
    AND id != COALESCE(NEW.id, 0);
    
    IF supplier_product_count >= 100 THEN
        RAISE EXCEPTION 'Il fornitore % ha già raggiunto il limite di 100 prodotti attivi', 
                       NEW.supplier_id;
    END IF;
    
    -- Regola 3: Aggiorna automaticamente updated_at
    NEW.updated_at = now();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. TRIGGER PER GESTIONE STOCK AUTOMATICA
-- =====================================================

CREATE OR REPLACE FUNCTION manage_stock_on_order()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INTEGER;
    product_name VARCHAR(100);
BEGIN
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.quantity != NEW.quantity) THEN
        -- Verifica disponibilità stock
        SELECT stock_quantity, name INTO current_stock, product_name
        FROM products 
        WHERE id = NEW.product_id;
        
        IF current_stock < NEW.quantity THEN
            RAISE EXCEPTION 'Stock insufficiente per il prodotto "%": richiesti %, disponibili %', 
                           product_name, NEW.quantity, current_stock;
        END IF;
        
        -- Aggiorna stock
        UPDATE products 
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE id = NEW.product_id;
        
        -- Se era un update, ripristina la quantità precedente
        IF TG_OP = 'UPDATE' THEN
            UPDATE products 
            SET stock_quantity = stock_quantity + OLD.quantity
            WHERE id = OLD.product_id;
        END IF;
        
        -- Calcola totale automaticamente
        NEW.total_amount = NEW.quantity * NEW.unit_price;
        
    ELSIF TG_OP = 'DELETE' THEN
        -- Ripristina stock quando l'ordine viene cancellato
        UPDATE products 
        SET stock_quantity = stock_quantity + OLD.quantity
        WHERE id = OLD.product_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. TRIGGER PER NOTIFICHE E ALERT
-- =====================================================

-- Tabella per notifiche
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    message TEXT,
    priority VARCHAR(10) DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT now(),
    acknowledged BOOLEAN DEFAULT false
);

CREATE OR REPLACE FUNCTION stock_alert_trigger()
RETURNS TRIGGER AS $$
DECLARE
    alert_message TEXT;
    priority_level VARCHAR(10);
BEGIN
    -- Alert per stock basso
    IF NEW.stock_quantity <= 10 AND NEW.stock_quantity > 0 THEN
        priority_level = 'high';
        alert_message = format('ALERT: Stock basso per il prodotto "%s" (ID: %s). Quantità rimanente: %s',
                              NEW.name, NEW.id, NEW.stock_quantity);
        
    -- Alert per stock esaurito
    ELSIF NEW.stock_quantity <= 0 THEN
        priority_level = 'critical';
        alert_message = format('CRITICAL: Stock esaurito per il prodotto "%s" (ID: %s)',
                              NEW.name, NEW.id);
        
    -- Alert per prezzo molto basso (possibile errore)
    ELSIF NEW.price < 1.00 THEN
        priority_level = 'medium';
        alert_message = format('WARNING: Prezzo molto basso per il prodotto "%s": %.2f',
                              NEW.name, NEW.price);
    END IF;
    
    -- Invia notifica se necessario
    IF alert_message IS NOT NULL THEN
        INSERT INTO notifications (message, priority)
        VALUES (alert_message, priority_level);
        
        -- Invia anche una notifica PostgreSQL
        PERFORM pg_notify('stock_alerts', 
                         json_build_object(
                             'product_id', NEW.id,
                             'product_name', NEW.name,
                             'stock', NEW.stock_quantity,
                             'message', alert_message,
                             'priority', priority_level
                         )::text);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. TRIGGER PER CACHE E DENORMALIZZAZIONE
-- =====================================================

-- Tabella categorie con statistiche cache
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    total_products INTEGER DEFAULT 0,
    avg_price DECIMAL(10,2) DEFAULT 0,
    total_stock INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT now()
);

CREATE OR REPLACE FUNCTION update_category_stats()
RETURNS TRIGGER AS $$
DECLARE
    category_name VARCHAR(100);
    old_category_name VARCHAR(100);
BEGIN
    -- Gestisce INSERT
    IF TG_OP = 'INSERT' THEN
        category_name = NEW.category;
        
        UPDATE categories 
        SET total_products = total_products + 1,
            total_stock = total_stock + NEW.stock_quantity,
            avg_price = (
                SELECT AVG(price) 
                FROM products 
                WHERE category = NEW.category
            ),
            last_updated = now()
        WHERE name = category_name;
        
    -- Gestisce UPDATE
    ELSIF TG_OP = 'UPDATE' THEN
        -- Se la categoria è cambiata
        IF OLD.category != NEW.category THEN
            -- Aggiorna vecchia categoria
            UPDATE categories 
            SET total_products = total_products - 1,
                total_stock = total_stock - OLD.stock_quantity,
                avg_price = (
                    SELECT COALESCE(AVG(price), 0)
                    FROM products 
                    WHERE category = OLD.category
                ),
                last_updated = now()
            WHERE name = OLD.category;
            
            -- Aggiorna nuova categoria
            UPDATE categories 
            SET total_products = total_products + 1,
                total_stock = total_stock + NEW.stock_quantity,
                avg_price = (
                    SELECT AVG(price)
                    FROM products 
                    WHERE category = NEW.category
                ),
                last_updated = now()
            WHERE name = NEW.category;
        ELSE
            -- Solo aggiorna statistiche per la stessa categoria
            UPDATE categories 
            SET total_stock = total_stock - OLD.stock_quantity + NEW.stock_quantity,
                avg_price = (
                    SELECT AVG(price)
                    FROM products 
                    WHERE category = NEW.category
                ),
                last_updated = now()
            WHERE name = NEW.category;
        END IF;
        
    -- Gestisce DELETE
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE categories 
        SET total_products = total_products - 1,
            total_stock = total_stock - OLD.stock_quantity,
            avg_price = (
                SELECT COALESCE(AVG(price), 0)
                FROM products 
                WHERE category = OLD.category
            ),
            last_updated = now()
        WHERE name = OLD.category;
        
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. TRIGGER CONDIZIONALE CON CONFIGURAZIONE
-- =====================================================

-- Tabella di configurazione
CREATE TABLE trigger_config (
    name VARCHAR(50) PRIMARY KEY,
    enabled BOOLEAN DEFAULT true,
    config JSONB
);

-- Inserisci alcune configurazioni
INSERT INTO trigger_config (name, enabled, config) VALUES
('audit_enabled', true, '{"tables": ["products", "orders"]}'),
('stock_alerts', true, '{"low_threshold": 10, "critical_threshold": 0}'),
('price_validation', true, '{"max_multiplier": 3.0}');

CREATE OR REPLACE FUNCTION conditional_audit_trigger()
RETURNS TRIGGER AS $$
DECLARE
    config_enabled BOOLEAN;
    allowed_tables TEXT[];
BEGIN
    -- Verifica se l'audit è abilitato
    SELECT enabled, config->'tables' INTO config_enabled, allowed_tables
    FROM trigger_config 
    WHERE name = 'audit_enabled';
    
    -- Esci se disabilitato o tabella non inclusa
    IF NOT config_enabled OR NOT (TG_TABLE_NAME = ANY(SELECT jsonb_array_elements_text(config->'tables') FROM trigger_config WHERE name = 'audit_enabled')) THEN
        RETURN COALESCE(NEW, OLD);
    END IF;
    
    -- Procedi con l'audit normale
    RETURN audit_trigger_function();
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- CREAZIONE DEI TRIGGER
-- =====================================================

-- Trigger di audit
CREATE TRIGGER products_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Trigger di validazione business rules
CREATE TRIGGER products_validation_trigger
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION validate_product_business_rules();

-- Trigger gestione stock
CREATE TRIGGER orders_stock_trigger
    BEFORE INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION manage_stock_on_order();

-- Trigger per alert
CREATE TRIGGER products_alert_trigger
    AFTER INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION stock_alert_trigger();

-- Trigger per cache statistiche
CREATE TRIGGER products_stats_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION update_category_stats();

-- =====================================================
-- ESEMPI DI UTILIZZO E TEST
-- =====================================================

-- Inserisci alcune categorie
INSERT INTO categories (name) VALUES ('Electronics'), ('Books'), ('Clothing');

-- Inserisci alcuni prodotti per testare i trigger
INSERT INTO products (name, category, price, stock_quantity, supplier_id) VALUES
('Laptop', 'Electronics', 999.99, 5, 1),
('Book SQL', 'Books', 29.99, 100, 2),
('T-Shirt', 'Clothing', 19.99, 50, 1);

-- Testa alert per stock basso
UPDATE products SET stock_quantity = 3 WHERE name = 'Laptop';

-- Testa creazione di un ordine
INSERT INTO orders (product_id, quantity, unit_price) VALUES (1, 2, 999.99);

-- Verifica audit log
SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT 10;

-- Verifica notifiche
SELECT * FROM notifications ORDER BY created_at DESC;

-- Verifica statistiche categorie
SELECT * FROM categories;

```