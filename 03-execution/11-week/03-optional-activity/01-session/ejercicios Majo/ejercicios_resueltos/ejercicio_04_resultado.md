# Ejercicio 04 Resuelto - Acumulación de millas y actualización de nivel

## 1. Descripción general

El modelo corresponde a un sistema de aerolínea con múltiples dominios.  
Este ejercicio se enfoca en CUSTOMER AND LOYALTY.

---

## 2. Restricción respetada

No se modificó ninguna tabla ni estructura del modelo base.  
Solo se crearon:
- función
- trigger
- procedimiento

---

## 3. Contexto

El sistema requiere:

1. Consultar clientes con su programa de fidelización
2. Registrar acumulación de millas
3. Actualizar información de nivel automáticamente

---

## 4. Consulta INNER JOIN

Se relacionan 7 tablas:

- customer
- person
- loyalty_account
- loyalty_program
- loyalty_account_tier
- loyalty_tier
- sale

Permite ver:

- cliente
- persona
- cuenta
- programa
- nivel
- fecha de asignación
- actividad comercial

---

## 5. Trigger AFTER

### Acción

```sql
UPDATE loyalty_account_tier
SET assigned_at = now()