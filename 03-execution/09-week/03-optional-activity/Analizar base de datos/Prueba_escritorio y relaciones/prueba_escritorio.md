## base de datos Gestión de aerolínea + vuelos + clientes + ventas + pagos
-------------------------------------

### Modulos que contiene 

#### GEOGRAFÍA

Contiene las Ubicación geográfica + dinero

![alt text](image-1.png)
![alt text](image-2.png)
![alt text](image-3.png)

#### RELACIONES

> continente → country
✔️ Tipo: 1 a muchos

👉 Un continente tiene muchos países
👉 Un país pertenece a un solo continente

> country → state_province

✔️ Tipo: 1 a muchos

👉 Un país tiene muchos departamentos
👉 Un departamento pertenece a un solo país

> state_province → city

✔️ Tipo: 1 a muchos

👉 Un departamento tiene muchas ciudades
👉 Una ciudad pertenece a un solo departamento

> city → district

✔️ Tipo: 1 a muchos

👉 Una ciudad tiene muchos distritos
👉 Un distrito pertenece a una sola ciudad

> district → address

✔️ Tipo: 1 a muchos

👉 Un distrito tiene muchas direcciones
👉 Una dirección pertenece a un solo distrito

> time_zone → city

✔️ Tipo: 1 a muchos

👉 Una zona horaria puede tener muchas ciudades
👉 Una ciudad solo tiene una zona horaria

> country → airline

✔️ Tipo: 1 a muchos

👉 Un país puede tener muchas aerolíneas
👉 Una aerolínea pertenece a un solo país

_____________________________________

#### Personas 

Registrar una persona con documento y contacto

![alt text](image-4.png)
![alt text](image-5.png)

#### RELACIONES

> person_type → person

✔️ Tipo: 1 a muchos

👉 Un tipo de persona (ej: pasajero) puede ser muchas personas
👉 Una persona tiene un solo tipo ( que es pasajero)

> country → person

✔️ Tipo: 1 a muchos

👉 Un país puede tener muchas personas (nacionalidad)
👉 Una persona tiene un país

> person → person_document

✔️ Tipo: 1 a muchos

👉 Una persona puede tener varios documentos
👉 Un documento pertenece a una sola persona

> document_type → person_document

✔️ Tipo: 1 a muchos

👉 Un tipo de documento (CC, pasaporte) se usa en muchos registros
👉 Cada documento tiene un tipo

> country → person_document

✔️ Tipo: 1 a muchos

👉 Un país puede emitir muchos documentos
👉 Un documento pertenece a un país emisor

 > person → person_contact

✔️ Tipo: 1 a muchos

👉 Una persona puede tener muchos contactos
👉 Un contacto pertenece a una persona

> contact_type → person_contact

✔️ Tipo: 1 a muchos

👉 Un tipo de contacto (email, teléfono) puede repetirse
👉 Cada contacto tiene un tipo

___________________________________
#### SECURITY

Crear un usuario con rol y permisos

👉 Ejemplo:

- Persona: María Pérez
- Usuario: maria123
- Rol: ADMIN
- Permiso: CREAR_USUARIO

![alt text](image.png)
![alt text](image-6.png)


#### RELACIONES

> user_status → user_account

✔️ Un estado tiene muchos usuarios
✔️ Un usuario tiene un estado

> person → user_account

✔️ Una persona tiene un usuario
✔️ (casi 1:1 por UNIQUE)

> user_account → user_role
✔️ Un usuario puede tener varios roles

> security_role → user_role
✔️ Un rol puede estar en muchos usuarios

> security_role → role_permission
✔️ Un rol tiene muchos permisos

> security_permission → role_permission
✔️ Un permiso puede estar en muchos roles

### MUCHOS A MUCHOS (N:M) – LAS MÁS IMPORTANTES

> user_account ↔ security_role

👉 Se resuelve con:
✔️ user_role

> user_account → user_account

✔️ Tipo: 1 a muchos
👉 Ejemplo:
un usuario crea a otro usuario

____________________________________

#### CUSTOMER & LOYALTY

Un cliente se registra en un programa de fidelización, gana millas y obtiene beneficios

Ejemplo:

- Cliente: María Pérez
- Aerolínea: Avianca
- Programa: LifeMiles
- Nivel: Gold
- Gana 500 millas

![alt text](image-7.png)

👉 depende de:
- aerolínea
- moneda

![alt text](image-8.png)

👉 depende de:
- persona
- aerolínea

![alt text](image-9.png)

- es cliente ✔️
- tiene cuenta de fidelización ✔️
- tiene nivel Gold ✔️
- tiene millas ✔️
- tiene beneficios ✔️

#### RELACIONES

> airline → loyalty_program
✔️ Una aerolínea tiene muchos programas

> currency → loyalty_program
✔️ Un programa usa una moneda

> loyalty_program → loyalty_tier
✔️ Un programa tiene muchos niveles

> airline → customer
✔️ Una aerolínea tiene muchos clientes

> person → customer
✔️ Una persona puede ser cliente

> customer_category → customer
✔️ Una categoría tiene muchos clientes

> customer → loyalty_account
✔️ Un cliente puede tener varias cuentas

> loyalty_program → loyalty_account
✔️ Un programa tiene muchas cuentas

> loyalty_account → miles_transaction
✔️ Una cuenta tiene muchas transacciones

> loyalty_account → loyalty_account_tier
✔️ Una cuenta tiene historial de niveles

>loyalty_tier → loyalty_account_tier
✔️ Un nivel puede estar en muchas cuentas

> customer → customer_benefit
✔️ Un cliente puede tener muchos beneficios

> benefit_type → customer_benefit
✔️ Un tipo de beneficio se repite en muchos clientes

#### MUCHOS A MUCHOS (N:M)

> customer ↔ benefit_type

> loyalty_account ↔ loyalty_tier

-------------------------------------------------------------

#### AIRPORT + AIRCRAFT + FLIGHT

![alt text](image-10.png)
![alt text](image-11.png)
![alt text](image-12.png)
![alt text](image-13.png)
![alt text](image-14.png)
![alt text](image-15.png)
![alt text](image-16.png)

#### ESTADOS Y CONFIGURACIÓN

![alt text](image-17.png)
![alt text](image-18.png)

#### RESERVA
![alt text](image-19.png)

#### PASAJEROS
![alt text](image-20.png)

#### VENTA
![alt text](image-21.png)

#### TARIFA

![alt text](image-22.png)

#### TICKETS 
![alt text](image-23.png)

#### SEGMENTOS DEL TICKET
![alt text](image-24.png)

#### ASIGNACIÓN DE ASIENTO
![alt text](image-25.png)

#### EQUIPAJE
![alt text](image-26.png)

#### BOARDING (ABORDAJE)

![alt text](image-27.png)

#### BOARDING PASS
![alt text](image-28.png)

#### VALIDACIÓN
![alt text](image-29.png)

#### PAGO 
![alt text](image-30.png)

#### TRANSACCIÓN
![alt text](image-31.png)

#### REEMBOLSO
![alt text](image-32.png)

#### FACTURA
![alt text](image-33.png)

#### DETALLE DE FACTURA
![alt text](image-34.png)

#### RELACIONES 

![alt text](image-35.png)
![alt text](image-36.png)