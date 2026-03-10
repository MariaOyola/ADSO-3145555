> ## Planteamiento del problema
_____________________________
En la cafetería en sí se presentan dificultades como la atención al cliente, ya que al tomar los pedidos se generan errores en la toma de aquellos pedidos, como agregar productos que no solicita el cliente o cantidades equivocadas, haciendo que el cliente quede insatisfecho con su pedido, además de las largas filas que se generan por la falta de registrar y realizar los pedidos, generando la demora de atención. 

Para eso se requiere un sistema de pedidos en el cual se lleve un control adecuado de las ventas y una mejor organización y eficiencia en el servicio. 

______________________________________________
> ## Objetivos generales
El objetivo para este programa es mejorar la gestión de pedidos de cafetería para el cliente, para que esté satisfecho con su encomienda.

__________________________________
>## Objetivos específicos
- Reducir las filas y el tiempo de toma de los pedidos de los clientes. 
- Minimizar los errores de las tomas de pedidos, como los productos y cantidades incorrectas
- Facilitar el uso del sistema para aquellas personas que lo van a usar como aprendices, instructores y personas del cafetín. 

____________________________________
>## Alcance 

#### (Lo que incluye) 
-	La idea del sistema es estar orientado a la atención de la cafetería, mejorando el registro de los pedidos realizados por los clientes de forma ordenada, para así evitar los errores ya comentados, que son reducir errores de productos y cantidades. 

#### (Lo que no incluye) 
-	Pagos por línea ni reportes financieros

______________________


> ## Requerimientos Funcionales
### - RF-1 – Visualizar productos disponibles

| Campo               | Detalle |
|---------------------|----------|
| Versión             | 1.0 |
| Actores             | Cliente |
| Objetivo asociado   | Permitir que el cliente consulte rápidamente el menú disponible sin hacer fila. |
| Descripción         | El sistema mostrará al cliente una lista clara y organizada de los productos disponibles (nombre, precio y disponibilidad). |
| Precondición        | El cliente debe ingresar al sistema. |

| Paso | Actor   | Acción                | Sistema |
|------|---------|----------------------|----------|
| 1    | Cliente | Ingresa al menú       | Muestra lista de productos disponibles |
| 2    | Cliente | Selecciona producto   | Muestra detalles (precio, descripción) |

#### Criterios de aceptación
- El menú debe cargar en menos de 3 segundos.
- Debe ser visualmente claro y fácil de entender.

______________________________

### - RF-2 – Agregar productos al carrito

| Campo               | Detalle |
|---------------------|----------|
| Versión             | 1.0 |
| Actores             | Cliente |
| Objetivo asociado   | Permitir que el cliente prepare su pedido de forma rápida y sin errores. |
| Descripción         | El sistema permitirá agregar productos al carrito y modificar cantidades antes de confirmar. |
| Precondición        | El cliente debe haber visualizado productos. |

| Paso | Actor   | Acción                     | Sistema |
|------|---------|---------------------------|----------|
| 1    | Cliente | Selecciona producto        | Agrega al carrito |
| 2    | Cliente | Modifica cantidad          | Actualiza total automáticamente |
| 3    | Cliente | Elimina producto (opcional)| Actualiza carrito |

#### Criterios de aceptación

- El total debe actualizarse automáticamente.

__________________________________________________________


### - RF-3 – Agregar productos al carrito

| Campo               | Detalle |
|---------------------|----------|
| Versión             | 1.0 |
| Actores             | Cliente |
| Objetivo asociado   | Enviar el pedido directamente al cafetin para reducir tiempos de espera y facilitar la identificación del cliente. |
| Descripción         | El cliente podrá revisar su pedido y confirmarlo. |
| Precondición        | - Debe existir al menos un producto en el carrito.<br>|

| Paso | Actor   | Acción                | Sistema |
|------|---------|----------------------|----------|
| 1    | Cliente | Revisa pedido         | Muestra resumen del pedido |
| 3    | Cliente | Confirma pedido       | Registra pedido con el nombre del cliente |
| 4    | Sistema | —                    | Envía pedido al personal del cafetín |

_________________________________________________


### - RF-4 Visualizar pedidos confirmados

| Campo               | Detalle |
|---------------------|----------|
| Versión             | 1.0 |
| Actores             | Personal del Cafetín |
| Objetivo asociado   | Organizar pedidos por orden de llegada para evitar desorden y retrasos. |
| Descripción         | El sistema mostrará al personal una lista en tiempo real de pedidos confirmados. |
| Precondición        | Debe existir al menos un pedido confirmado. |

| Paso | Actor     | Acción            | Sistema |
|------|------------|------------------|----------|
| 1    | Personal   | Ingresa al panel | Muestra pedidos pendientes |
| 2    | Personal   | Selecciona pedido| Muestra detalle del pedido |

#### Criterios de aceptación

- Los pedidos deben mostrarse en orden cronológico.
- La actualización debe ser automática (sin recargar la página).

___________________________________________

### -  RF-5 Marcar pedido como preparado y entregado

| Campo               | Detalle |
|---------------------|----------|
| Versión             | 1.0 |
| Actores             | Personal del Cafetín |
| Objetivo asociado   | Mantener control del estado del pedido y reducir confusión. |
| Descripción         | El personal podrá cambiar el estado del pedido (Preparado → Entregado). |
| Precondición        | El pedido debe estar confirmado. |

| Paso | Actor     | Acción                   | Sistema |
|------|------------|--------------------------|----------|
| 1    | Personal   | Marca como preparado     | Cambia estado |
| 2    | Personal   | Marca como entregado     | Finaliza pedido |
| 3    | Sistema    | —                        | Notifica que el pedido fue completado |

#### Criterios de aceptación

- El cambio de estado debe ser inmediato.
- Solo el personal autorizado puede cambiar estados.
___________________________________________________ 

>## Requerimientos no Funcionales

-  RN1.El sistema debe ser fácil de usar para aprendices, instructores y personal del cafetín.
- RN2. El sistema debe permitir una toma de pedidos rápida para reducir filas y tiempos de espera.
- RN3. El sistema debe mostrar la información de los pedidos de forma clara y ordenada.
_____________________

 >## Reglas de negocio
- 	RN1. Todo pedido debe ser confirmado por el usuario antes de ser procesado.
- 	RN2. Un pedido debe contener al menos un producto para poder registrarse.
-	RN3. Los pedidos deben ser atendidos en el orden en que fueron recibidos.
___________


>## Priorización MoSCoW

### (Must) (Debe tener)
-	visualizar los productos disponibles.
-	 Agregar productos a un carrito y modificar sus cantidades. 
-	Confirmar los pedidos que se van a pedir antes de enviarlos. 
-	 Visualizar aquellos productos confirmados. 

### (Should) (Debería tener)
-	Que el personal pueda marcar los pedidos como preparados o entregados. 

______________________________

>## Mockup inicial (baja fidelidad)
____________
Las pantallas de este sistema son: 

-  Página Principal / Menú de Productos.
-  Pagina de catalogo (Muetra los pedidos y el carrito).
- Carrito de compras (Muestra productos seleccionados por el usuario).
- Muestra pedido confirmado
- confirmamos
_______________________
### Cafetin
-  muestra los productos
-  cambia su estado

https://www.figma.com/design/uW8upzhkHEf2k8cdLpJZi7/Cafet%C3%ADn-SENA?node-id=0-1&t=Bh1OH2RXdDOx2f8D-1

_________________

## Backlog / Plan de trabajo
_______________________

### Historial de Usuario

#### HU1 - Visualizar productos

> Como usuario, quiero ver los productos disponibles para así elegir lo que quiero compara

### Criterios de aceptación:
- Se muestran todos los productos disponibles.

- Cada producto tiene nombre y precio.

- Existe un botón para agregar al carrito.

#### HU2 – Agregar productos al carrito

> Como usuario, quiero agregar productos al carrito para poder realizar un pedido.
### Criterios de aceptación:

-  El usuario puede agregar uno o más productos.
- El carrito muestra los productos agregados.
- Se puede eliminar un producto.

#### HU3 – Confirmar pedido

>Como usuario, quiero confirmar mi pedido antes de enviarlo para asegurar que sea correcto.

### Criterios de aceptación:
- Se muestra un resumen del pedido.
- El usuario debe presionar “Confirmar pedido”.

#### HU4 – Visualizar pedidos (Personal)

> Como Personal,  quiero visualizar los pedidos confirmados para poder prepararlos.

### Criterios de aceptación:

- Se muestran solo pedidos confirmados.

#### HU5 – Cambiar estado del pedido
> Como personal,  quiero marcar los pedidos como preparados y entregados. 


### Criterios de aceptación:

- El pedido puede cambiar de estado (Pendiente → Preparado → Entregado).

- El sistema actualiza el estado correctamente.

- El estado se muestra claramente.

### Priorizacion 

> Alta // HU1, HU2, HU3

> Media // HU4, HU5

### Estimación

> HU1 -- 1 día

> HU2 -- 2 día 

> HU3 --  1 día

> HU4 -- 2 día

> HU5 -- 1 día

________________

## Modelo de datos (propuesto)

Entidades :

### Persona
- id_persona (PK)
- nombre 
- apellido
- numero_telefonico
- correo

(Relacion 1:1 con Usuario)
_____________

### Usuario 
- id_usuario (PK)
- nombre_usuario
- contraseña
- id_persona (FK)

(Relacion 1:1 con Persona)

(Relacion N:M con Rol)
_________

### Rol 
- id_rol (PK)
- nombre_rol
- description

(Relacion N:M con Usuario)
__________
#### Usuario_rol
- id_rol (FK) 
- id_usuario (FK)

(Pivote)
___________________

#### Producto 
- id_producto (PK)
- nombre_producto
- precio
- descripcion
- estado
- id_categoria (FK)

(Relacion 1:N con categoria)

____

#### Categoria
- id_categoria (PK)
- nombre_categoria

(Relacion 1:N con Producto)
____________

#### pedido
- id_pedido (PK)
- id_usuario (FK)
- fecha 
- estado (Pendiente → Preparado → Entregado).
- total 
- id_usuario (FK)

(Relacion 1:N con Usuario)
________

#### DetallePedido
- id_DetallePedido (PK)
- cantidad
- subtotal
- id_pedido (FK)
- id_producto (FK)

(Relacion 1:N con pedido)

(Relacion 1:N con Producto)
________

#### Factura
- id_factura (PK)
- fecha
- total
- id_pedido (FK)

(Relacion 1:1 con pedido)
______________
#### DetalleFactura

- id_detalleFactura (PK)
- cantidad
- precio_unitario
- subtotal
- id_factura (FK)
- id_producto (FK) 

(Relacion 1:N con Factura)

(Relacion 1:N con   Producto)







