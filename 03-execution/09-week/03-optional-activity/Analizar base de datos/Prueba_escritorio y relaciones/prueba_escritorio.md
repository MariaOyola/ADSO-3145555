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


#### Personas 

Registrar una persona con documento y contacto

![alt text](image-4.png)
![alt text](image-5.png)



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

