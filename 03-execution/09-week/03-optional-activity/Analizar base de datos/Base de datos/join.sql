-- INNER JOIN

SELECT c.country_name, co.continent_name
FROM country c
INNER JOIN continent co 
ON c.continent_id = co.continent_id;

-- LEFT JOIN
-- Mostrar todos los países aunque no tengan continente

SELECT c.country_name, co.continent_name
FROM country c
LEFT JOIN continent co 
ON c.continent_id = co.continent_id;

--- País + continente + estado/provincia
SELECT 
    c.country_name,
    co.continent_name,
    sp.state_name
FROM country c
INNER JOIN continent co 
    ON c.continent_id = co.continent_id
INNER JOIN state_province sp 
    ON sp.country_id = c.country_id;

-- buscar por cuidad 

SELECT 
    co.continent_name,
    c.country_name,
    sp.state_name,
    ci.city_name
FROM continent co
INNER JOIN country c 
    ON c.continent_id = co.continent_id
INNER JOIN state_province sp 
    ON sp.country_id = c.country_id
INNER JOIN city ci 
    ON ci.state_province_id = sp.state_province_id;


--- UNION
SELECT country_name FROM country
UNION
SELECT continent_name FROM continent;

--- VER LOS PAISES 

CREATE PROCEDURE ver_paises()
LANGUAGE SQL
AS $$
    SELECT * FROM country;
$$;

CALL ver_paises();

-- TOTAL DE PAISES 

CREATE FUNCTION total_paises()
RETURNS INT
LANGUAGE SQL
AS $$
    SELECT COUNT(*) FROM country;
$$;

SELECT total_paises();

-- VER NOMBRE Y de paises y continenetes 
CREATE VIEW vista_geo AS
SELECT c.country_name, co.continent_name
FROM country c
INNER JOIN continent co 
ON c.continent_id = co.continent_id;

