-- Create Schema
CREATE SCHEMA ecommerce;
SET search_path TO ecommerce;

-----------------------------------------------------
-- Traditional Table
-----------------------------------------------------

CREATE TABLE orders_traditional
(
    order_id BIGSERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_amount NUMERIC(10,2),
    status VARCHAR(20),
    payment_type VARCHAR(20),
    city VARCHAR(50),
    order_date DATE
);

-----------------------------------------------------
-- Partitioned Table
-----------------------------------------------------

CREATE TABLE orders_partitioned
(
    order_id BIGINT,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_amount NUMERIC(10,2),
    status VARCHAR(20),
    payment_type VARCHAR(20),
    city VARCHAR(50),
    order_date DATE
)
PARTITION BY RANGE(order_date);

-----------------------------------------------------
-- Monthly Partitions
-----------------------------------------------------

CREATE TABLE orders_2025_01 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE orders_2025_02 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE orders_2025_03 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE orders_2025_04 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

CREATE TABLE orders_2025_05 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');

CREATE TABLE orders_2025_06 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE orders_2025_07 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

CREATE TABLE orders_2025_08 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE orders_2025_09 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE orders_2025_10 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE orders_2025_11 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE orders_2025_12 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');