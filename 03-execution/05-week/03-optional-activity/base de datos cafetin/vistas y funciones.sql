CREATE VIEW view_product_status AS
SELECT p.name_product, p.price 
FROM product p
INNER JOIN status s ON p.id_status = s.id
WHERE s.name = 'activo';

SELECT * FROM  View_product_status;
--------------------------------------------
CREATE VIEW View_role AS
SELECT name_role, description
FROM  roles; 

SELECT * FROM View_roles; 
--------------------------------------------------------
CREATE VIEW View_modules AS
SELECT name_module, description
FROM  modules; 

SELECT * FROM View_modules;
--------------------------------------------------------
CREATE VIEW View_product_name AS
SELECT name_product, price
FROM  product; 

SELECT * FROM View_product_name; 

----------------------------------------------
CREATE VIEW View_category_name AS
SELECT name_category,category
FROM category; 


SELECT * FROM View_category_name;

------------------------------------------
---------- funciones -------------------

-- multiplicacion

CREATE FUNCTION function_product (precio NUMERIC, cantidad INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN precio * cantidad;
END;
$$;

SELECT function_product (10000, 5);

-------------------------------------------------
---suma

CREATE FUNCTION function_addition(a INT, b INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN a + b;
END;
$$;

SELECT function_addition(5, 3);


------------------------------------------------------
-- funcion que cree una vista 
CREATE OR REPLACE PROCEDURE create_view_person()
LANGUAGE plpgsql
AS $$
BEGIN
     CREATE OR REPLACE VIEW view_person AS
    SELECT name, email
    FROM person;
END; 
$$

CALL create_view_person(); 

------------------------------------------------

CREATE OR REPLACE PROCEDURE view_users()
LANGUAGE plpgsql
AS $$
BEGIN
SELECT * FROM users; 
END; 
$$

CALL  view_users(); 

------------------------------------







