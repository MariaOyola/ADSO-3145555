DELETE FROM security.role
WHERE name IN (
    'ADMIN',
    'CUSTOMER',
    'GUEST',
    'SELLER',
    'WAREHOUSE',
    'PAYMENT_MANAGER',
    'ORDER_MANAGER',
    'SUPPORT',
    'ANALYST',
    'AUDITOR'
);