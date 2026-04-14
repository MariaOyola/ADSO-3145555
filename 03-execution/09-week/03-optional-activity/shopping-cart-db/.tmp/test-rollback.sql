-- Lock Database
UPDATE public.databasechangeloglock SET LOCKED = TRUE, LOCKEDBY = '9e046779b73f (172.26.0.3)', LOCKGRANTED = NOW() WHERE ID = 1 AND LOCKED = FALSE;

-- *********************************************************************
-- Rollback 3 Change(s) Script
-- *********************************************************************
-- Change Log: changelog-master.yaml
-- Ran at: 3/26/26, 2:57 PM
-- Against: shopping_cart_user@jdbc:postgresql://postgres:5432/shopping_cart
-- Liquibase version: 5.0.2
-- *********************************************************************

-- Rolling Back ChangeSet: db/changelog/changes/001_base/005_create_billing_tables.sql::005-create-billing-tables::corhuila
DROP TABLE IF EXISTS bill.bill_item CASCADE;

DROP TABLE IF EXISTS bill.bill CASCADE;

DELETE FROM public.databasechangelog WHERE ID = '005-create-billing-tables' AND AUTHOR = 'corhuila' AND FILENAME = 'db/changelog/changes/001_base/005_create_billing_tables.sql';

-- Rolling Back ChangeSet: db/changelog/changes/001_base/004_create_inventory_tables.sql::004-create-inventory-tables::corhuila
DROP TABLE IF EXISTS inventory.inventory CASCADE;

DROP TABLE IF EXISTS inventory.product CASCADE;

DROP TABLE IF EXISTS inventory.category CASCADE;

DELETE FROM public.databasechangelog WHERE ID = '004-create-inventory-tables' AND AUTHOR = 'corhuila' AND FILENAME = 'db/changelog/changes/001_base/004_create_inventory_tables.sql';

-- Rolling Back ChangeSet: db/changelog/changes/001_base/003_create_security_tables.sql::003-create-security-tables::corhuila
DROP TABLE IF EXISTS security.form CASCADE;

DROP TABLE IF EXISTS security."user" CASCADE;

DROP TABLE IF EXISTS security.role CASCADE;

DELETE FROM public.databasechangelog WHERE ID = '003-create-security-tables' AND AUTHOR = 'corhuila' AND FILENAME = 'db/changelog/changes/001_base/003_create_security_tables.sql';

-- Release Database Lock
UPDATE public.databasechangeloglock SET LOCKED = FALSE, LOCKEDBY = NULL, LOCKGRANTED = NULL WHERE ID = 1;

