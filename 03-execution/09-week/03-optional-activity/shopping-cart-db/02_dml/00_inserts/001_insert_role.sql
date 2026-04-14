INSERT INTO security.role (name, description, created_by)
VALUES
('ADMIN', 'Acceso total al sistema, gestión de usuarios, roles y configuración general', 'system'),
('CUSTOMER', 'Cliente que realiza compras en el carrito', 'system'),
('GUEST', 'Usuario no autenticado con acceso limitado al catálogo', 'system'),
('SELLER', 'Vendedor encargado de gestionar productos y precios', 'system'),
('WAREHOUSE', 'Encargado de inventario y control de stock', 'system'),
('PAYMENT_MANAGER', 'Gestión de pagos, validación y conciliación', 'system'),
('ORDER_MANAGER', 'Gestión de órdenes, estados y seguimiento de pedidos', 'system'),
('SUPPORT', 'Atención al cliente y resolución de incidencias', 'system'),
('ANALYST', 'Acceso a reportes y analítica del sistema', 'system'),
('AUDITOR', 'Revisión de logs, trazabilidad y cumplimiento', 'system');