# Ejercicio 05 - Solución

## ✔ Consulta con INNER JOIN

Se construyó una vista `vw_aircraft_maintenance_overview` que relaciona:

- aircraft
- airline
- aircraft_model
- aircraft_manufacturer
- maintenance_event
- maintenance_type
- maintenance_provider

Cumpliendo el requerimiento de más de 5 tablas.

Permite visualizar:

- aeronave
- aerolínea
- modelo
- fabricante
- tipo de mantenimiento
- proveedor
- estado
- fechas

---

## ✔ Trigger AFTER

Se implementó un trigger:

trg_after_maintenance_event

Tipo:
AFTER INSERT OR UPDATE

Tabla:
maintenance_event

### Función

Registra automáticamente cada cambio en:

aircraft_maintenance_log

Esto permite trazabilidad sin modificar el modelo base.

---

## ✔ Procedimiento almacenado

Nombre:

sp_register_maintenance_event

Permite registrar eventos de mantenimiento con:

- aeronave
- tipo
- proveedor
- estado
- fechas
- notas

Encapsula la lógica de inserción.

---

## ✔ Integración trigger + procedimiento

Cuando el procedimiento inserta un mantenimiento:

1. Se crea el registro en maintenance_event
2. Se dispara el trigger AFTER
3. Se registra automáticamente en aircraft_maintenance_log

---

## ✔ Validación

El demo prueba:

1. Inserción mediante procedimiento
2. Activación del trigger
3. Registro en tabla de log
4. Consulta consolidada mediante VIEW

---

## ✔ Cumplimiento de restricciones

✔ No se modificó el modelo base  
✔ Se usaron solo entidades existentes  
✔ INNER JOIN ≥ 5 tablas  
✔ Trigger AFTER implementado  
✔ Procedimiento funcional  
✔ Demo verificable  

---

## ✔ Conclusión

La solución implementa:

- Integración entre aeronaves y mantenimiento
- Automatización mediante trigger
- Encapsulamiento mediante procedimiento
- Trazabilidad completa del proceso

Cumpliendo completamente los requisitos del ejercicio.