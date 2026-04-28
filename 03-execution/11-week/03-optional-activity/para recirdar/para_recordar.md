### Crear categoría

#### POST
/categories
{
  "name": "Novela"
}
---------------------------------------
### Obtener todas

#### GET
/categories
------------------------------------------
### Buscar por nombre

#### GET
/categories/name/Novela
------------------------------------------
### Actualizar

#### PUT

/categories/{id}

{
  "name": "Ciencia ficción"
}
-----------------------------------------

### Eliminar

#### DELETE

/categories/{id}
--------------------------------------------