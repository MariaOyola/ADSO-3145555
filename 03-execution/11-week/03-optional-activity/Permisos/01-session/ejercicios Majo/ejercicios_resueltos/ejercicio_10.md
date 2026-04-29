# Ejercicio 10 Resuelto - Identidad de pasajeros, documentos y medios de contacto

## 1. Descripción general del modelo

El modelo corresponde a un sistema integral de aerolínea con más de 60 entidades normalizadas. Soporta trazabilidad end-to-end desde la identidad del pasajero hasta la reserva, tiquete, abordaje y facturación.

---

## 2. Restricción general respetada

La solución no modifica ninguna tabla, columna, relación ni constraint del modelo base. Todos los objetos creados (función, trigger, procedimiento) operan únicamente sobre entidades y atributos existentes en el DDL entregado.

---

## 3. Contexto del ejercicio

El área de servicio al cliente necesita:

1. Consultar la identidad completa de los pasajeros: tipo de persona, documentos, medios de contacto y su participación en reservas.
2. Automatizar una acción verificable sobre la ficha de la persona cada vez que se registre un nuevo medio de contacto.
3. Encapsular el registro de contactos en un procedimiento reutilizable con validaciones de integridad.

---

## 4. Dominios y datos reales involucrados

| Dominio | Entidades usadas | Datos del seed |
|---|---|---|
| IDENTITY | `person`, `person_type`, `person_document`, `document_type`, `person_contact`, `contact_type` | Ana Garcia, Carlos Mendoza, Laura Torres |
| CUSTOMER / LOYALTY | `customer` | (referenciado indirectamente vía person) |
| SALES / TICKETING | `reservation_passenger`, `reservation` | RES-FY-001, RES-FY-002, RES-FY-003 |

### Datos reales del seed usados en el demo

| Elemento | Valor real del seed | Fuente |
|---|---|---|
| Persona elegida | `Carlos Mendoza` (CC71234567 — ADULT) | seed canónico |
| Contactos previos | 2 — EMAIL (principal) y MOBILE | seed canónico |
| Tipo nuevo | `WHATSAPP` — no primario | seed canónico |
| Valor registrado | `+573107654321` | demo |
| Efecto verificable | `person.updated_at` actualizado por trigger | DDL: campo mutable real |

### ¿Por qué Carlos Mendoza y el tipo WHATSAPP?

El seed canónico registra los siguientes contactos por pasajero:

| Persona | Contactos registrados |
|---|---|
| Ana Garcia | EMAIL (principal), MOBILE |
| Carlos Mendoza | EMAIL (principal), MOBILE |
| Laura Torres | EMAIL (principal) |

Carlos Mendoza ya tiene EMAIL y MOBILE pero **no tiene WHATSAPP**. Agregar un WHATSAPP no primario satisface tres condiciones ideales para el demo: la persona existe en el seed, el tipo de contacto existe en el catálogo, y no hay riesgo de violar la restricción de contacto principal duplicado. Además, el número `+573107654321` coincide con el MOBILE ya registrado para Carlos, lo que hace coherente el escenario (mismo número para MOBILE y WHATSAPP es un caso real y frecuente).

---

## 5. Contactos existentes en el seed canónico

| Persona | Tipo | Valor | Principal |
|---|---|---|---|
| Ana Garcia | EMAIL | ana.garcia@email.co | Sí |
| Ana Garcia | MOBILE | +573001234567 | No |
| Carlos Mendoza | EMAIL | carlos.mendoza@email.co | Sí |
| Carlos Mendoza | MOBILE | +573107654321 | No |
| Laura Torres | EMAIL | laura.torres@email.co | Sí |

---

## 6. Decisión técnica del trigger: el problema de 3FN

### El reto

El enunciado pide que el trigger sobre `person_contact` produzca una acción verificable sobre la ficha de la persona. La solución intuitiva sería actualizar un campo de "último contacto registrado" o un contador de contactos en `person`. Sin embargo, el DDL no tiene esa columna derivada: el modelo preserva la **tercera forma normal (3FN)** y no almacena estados calculados en `person`.

Modificar el modelo para agregar ese campo violaría la restricción del ejercicio.

### La solución correcta

El único campo mutable de `person` sin derivar datos es `updated_at`, presente en todas las tablas del modelo. Actualizar `person.updated_at` cuando se inserta un contacto es:

- **Correcto**: atributo real del DDL.
- **Verificable**: se puede comparar el valor antes y después del trigger.
- **Coherente con el negocio**: la ficha de la persona refleja que su perfil de contacto fue modificado, lo que es relevante para auditorías de servicio al cliente.
- **Sin romper 3FN**: no almacena ningún valor derivado.

---

## 7. Teoría base aplicada

### ¿Por qué trigger sobre person_contact (INSERT) y no sobre person_document?

El enunciado permite elegir entre `person_document` y `person_contact`. Se elige `person_contact` porque:

1. Los documentos de identidad son datos relativamente estáticos (un pasaporte tiene vigencia de 10 años). Los medios de contacto cambian con mayor frecuencia: un pasajero puede agregar WhatsApp, cambiar su número de teléfono o actualizar su correo antes de un vuelo.
2. El área de **servicio al cliente** opera principalmente a través de medios de contacto (email, mobile, WhatsApp) para enviar notificaciones de vuelo, cambios de itinerario y alertas operativas. El trigger sobre `person_contact` es más relevante para ese contexto.
3. En el seed canónico, Laura Torres solo tiene EMAIL registrado, lo que demuestra que hay pasajeros con perfil de contacto incompleto. El procedimiento y el trigger están diseñados exactamente para ese caso de uso.

### ¿Por qué la consulta principal usa INNER JOIN en las 8 tablas?

La consulta busca el perfil completo del pasajero para servicio al cliente: solo tienen valor las personas que tienen documento registrado, al menos un contacto registrado **y** participan en al menos una reserva. Si cualquiera de esas condiciones faltara, la persona no es un pasajero activo en el sistema y no es relevante para el área de servicio al cliente. Los `INNER JOIN` en las 8 tablas garantizan ese filtro de forma implícita.

### ¿Por qué la validación 3 usa INNER JOIN sobre reservation_passenger en el resumen?

El resumen de la validación 3 mantiene `INNER JOIN` sobre `reservation_passenger` deliberadamente para mostrar solo las personas que participan en reservas, que es el universo de trabajo de servicio al cliente. Un empleado como Diego Ramirez o Patricia Vargas existe en `person` pero no en `reservation_passenger` y no aparecería en ese resumen, lo cual es correcto: el área de servicio al cliente trabaja con pasajeros, no con empleados.

### ¿Por qué procedimiento almacenado con 4 validaciones?

La validación más crítica es la cuarta: impedir que se registren dos contactos principales del mismo tipo para la misma persona. En el modelo aeronáutico, el contacto principal (`is_primary = true`) es el que recibe las comunicaciones operativas críticas (cambios de vuelo, cancelaciones). Si existieran dos emails principales para la misma persona, los sistemas de notificación podrían enviar mensajes duplicados o contradictorios. El procedimiento protege esa regla de negocio antes de que el dato quede persistido.

---

## 8. Consulta resuelta con INNER JOIN

### Tablas involucradas: 8 (todos INNER JOIN)

| # | Tabla | Propósito |
|---|---|---|
| 1 | `person` | Nombre completo, fecha de nacimiento, género |
| 2 | `person_type` | Tipo: ADULT, CHILD, EMPLOYEE, CONTRACTOR |
| 3 | `person_document` | Documento registrado: número, emisión, vencimiento |
| 4 | `document_type` | Tipo de documento: PASS, NID, DL, RES |
| 5 | `person_contact` | Medio de contacto: valor e indicador de principal |
| 6 | `contact_type` | Tipo de contacto: EMAIL, MOBILE, WHATSAPP... |
| 7 | `reservation_passenger` | Participación en reserva: secuencia y tipo de pasajero |
| 8 | `reservation` | Código de la reserva relacionada |

### Resultado con datos reales del seed (antes del demo)

La consulta genera un producto cartesiano controlado por los JOINs: cada persona aparece tantas veces como combinaciones de (documento × contacto × reserva) tenga. Para Carlos Mendoza con 1 documento, 2 contactos y 1 reserva, el resultado genera 2 filas (una por cada tipo de contacto).

| persona | tipo | documento | número_doc | tipo_contacto | valor_contacto | reserva |
|---|---|---|---|---|---|---|
| Carlos Mendoza | Adulto | Documento nacional | CC71234567 | Correo electrónico | carlos.mendoza@email.co | RES-FY-002 |
| Carlos Mendoza | Adulto | Documento nacional | CC71234567 | Telefono movil | +573107654321 | RES-FY-002 |

### Resultado tras ejecutar el demo (después del CALL)

Carlos Mendoza aparece con 3 filas: EMAIL, MOBILE y el nuevo WHATSAPP `+573107654321`.

### Explicación paso a paso de cada JOIN

1. **`person`** → ficha maestra de la persona. Punto de entrada del dominio IDENTITY.
2. **`person_type`** → clasifica a la persona: ADULT, CHILD, EMPLOYEE. Necesario para filtrar pasajeros vs empleados en los reportes de servicio al cliente.
3. **`person_document`** → documento de identidad registrado. Crítico para la verificación en el check-in y el control migratorio.
4. **`document_type`** → tipo legible del documento: Pasaporte, Documento nacional, Licencia de conducción. Determina qué documentos son válidos para cada tipo de vuelo (doméstico vs internacional).
5. **`person_contact`** → medio de contacto registrado. Incluye el indicador `is_primary` que define qué canal recibe las comunicaciones operativas.
6. **`contact_type`** → tipo legible del contacto: Correo electrónico, Teléfono móvil, WhatsApp. Permite segmentar el canal de comunicación.
7. **`reservation_passenger`** → vincula la persona con una reserva concreta. Incluye la secuencia dentro de la reserva y el tipo de pasajero (ADULT, CHILD, INFANT).
8. **`reservation`** → reserva relacionada. Cierra el ciclo identidad → actividad comercial que requiere el área de servicio al cliente.

---

## 9. Trigger resuelto

### Acción implementada

Cada vez que se inserta un registro en `person_contact`, la ficha de la persona asociada queda marcada con el timestamp de la modificación mediante `UPDATE person SET updated_at = now()`. Esto es verificable, sin romper 3FN y coherente con el negocio: el perfil del pasajero refleja que su información de contacto fue actualizada, lo que es relevante para auditorías de servicio al cliente y notificaciones operativas.

---

## 10. Procedimiento almacenado resuelto

### Parámetros de entrada

| Parámetro | Columna del DDL | Tipo | Constraint aplicado |
|---|---|---|---|
| `p_person_id` | `person_contact.person_id` | uuid | FK a `person` |
| `p_contact_type_id` | `person_contact.contact_type_id` | uuid | FK a `contact_type` |
| `p_contact_value` | `person_contact.contact_value` | varchar(200) | NOT NULL, no vacío |
| `p_is_primary` | `person_contact.is_primary` | boolean | Regla de unicidad de principal por tipo |

### Validaciones internas (4 checks)

1. `person_id` debe existir en `person`.
2. `contact_type_id` debe existir en `contact_type`.
3. `p_contact_value` no puede ser nulo ni vacío.
4. Si `p_is_primary = true`, no puede existir ya otro contacto principal del mismo tipo para la misma persona.

---

## 11. Script de demostración

### ¿Qué demuestra?

1. Resuelve `Carlos Mendoza` del seed canónico y verifica su `updated_at` inicial.
2. Confirma que tiene 2 contactos previos (EMAIL y MOBILE) y ningún WHATSAPP.
3. Resuelve el `contact_type_id` del tipo `WHATSAPP`.
4. Invoca `sp_register_person_contact` con `+573107654321` como valor no primario.
5. El procedimiento valida los 4 constraints e inserta en `person_contact`.
6. El trigger `AFTER INSERT` actualiza `person.updated_at` automáticamente.
7. Las 3 validaciones confirman el contacto insertado, la trazabilidad completa identidad → reserva y el resumen con `string_agg` de todos los contactos por persona.

---

## 12. Criterios de aceptación cumplidos

| Criterio | Estado | Evidencia |
|---|---|---|
| La consulta usa INNER JOIN | ✅ | 8 INNER JOINs sobre tablas reales del modelo |
| La consulta relaciona al menos 5 tablas reales del modelo | ✅ | 8 tablas reales del DDL |
| El trigger es AFTER INSERT | ✅ | `AFTER INSERT ON person_contact FOR EACH ROW` |
| El trigger produce efecto verificable sobre tablas reales | ✅ | Actualiza `person.updated_at` |
| Existe script que demuestra la ejecución | ✅ | `ejercicio_10_demo.sql` con `DO $$` y 3 validaciones |
| El procedimiento encapsula una operación útil del negocio | ✅ | Registro de contacto con 4 validaciones |
| Existe script que invoca el procedimiento | ✅ | `CALL sp_register_person_contact(...)` |
| La invocación evidencia el trigger | ✅ | `person.updated_at` cambia al registrar el contacto |
| No se alteró la estructura base del modelo | ✅ | Solo función, trigger y procedimiento |

---

## 13. Archivos entregados

| Archivo | Contenido |
|---|---|
| `ejercicio_10_setup.sql` | Función, trigger, procedimiento y consulta INNER JOIN con 8 tablas |
| `ejercicio_10_demo.sql` | Bloque `DO $$`, invocación del procedimiento y 3 validaciones |
| `ejercicio_10_resuelto.md` | Documentación completa con decisiones técnicas y criterios |