## que es Liquibase
herramienta que controlaa cambios en la base de datos

### sirve principalmente para 
- crear tablas 
- modificar tablas ( osea agregar columnas, relaciones, atributos); 
- llevar historial de los cambios que se le hace a la base de datos


#### como por ejemplo 

#### si hacemos una base manuel como 

> CREATE TABLE usuario 
.....

> ALTER TABLE usuario ADD email   ( osea selecciona la tabla existente)

y esto puede tener problemas ya que se nos puede olvidar mas adelante, no se sabe en general los cambios que se realizan.


#### con Liquibase

en el changelog.xml ( que es principalmente el archivo donde definimos los cambios, y es como la lista de instrucciones para la base de datos), 

se hace esto

> changeSet id="1" author="maria">
>  createTable tableName="usuario">
        ...
> /createTable>
> /changeSet>

- esto Ejecuta los cambios a la base de datos 
- lo guarda 

#### Qué es un changeSet

esto es un bloque de cambio que : 

- tiene Un id unico 
- tiene autor 
- tiene una accion ya sea (crear tablas,  modificar, etc) 
en este caso estoy creado una tabla ( segun el ejemplo); 

el flujo en general es

#### 1. crear changelog
#### 2. agregar el changeSet
#### 3. Ejecutas Liquibase
#### 4. Se actualiza la BD. 




