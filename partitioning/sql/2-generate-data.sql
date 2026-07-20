CREATE TABLE orders_staging AS
SELECT
    gs AS order_id,
    (random()*50000)::INT AS customer_id,
    (random()*10000)::INT AS product_id,
    (random()*5+1)::INT AS quantity,
    ROUND((random()*1000)::numeric,2) AS order_amount,
    (
        ARRAY[
            'Pending',
            'Delivered',
            'Cancelled',
            'Shipped'
        ]
    )[floor(random()*4+1)] AS status,
    (
        ARRAY[
            'UPI',
            'Card',
            'Net Banking',
            'Cash'
        ]
    )[floor(random()*4+1)] AS payment_type,
    (
        ARRAY[
            'Bangalore',
            'Mumbai',
            'Delhi',
            'Hyderabad',
            'Pune'
        ]
    )[floor(random()*5+1)] AS city,
    DATE '2025-01-01' + (random()*364)::INT AS order_date
FROM generate_series(1,1000000) gs;

INSERT INTO orders_traditional
SELECT * FROM orders_staging;

INSERT INTO orders_partitioned
SELECT * FROM orders_staging;