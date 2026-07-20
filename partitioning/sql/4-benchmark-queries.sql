-----------------------------------------------------
-- Experiment 1
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT COUNT(*)
FROM orders_traditional;

EXPLAIN (ANALYZE,BUFFERS)
SELECT COUNT(*)
FROM orders_partitioned;

-----------------------------------------------------
-- Experiment 2
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_traditional
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-04-01';

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_partitioned
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-04-01';

-----------------------------------------------------
-- Experiment 3
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_traditional
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-06-01';

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_partitioned
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-06-01';

-----------------------------------------------------
-- Experiment 4
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_traditional
WHERE order_date >= DATE '2025-01-01'
AND order_date < DATE '2026-01-01';

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_partitioned
WHERE order_date >= DATE '2025-01-01'
AND order_date < DATE '2026-01-01';

-----------------------------------------------------
-- Experiment 5
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_traditional
WHERE customer_id = 25000;

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_partitioned
WHERE customer_id = 25000;

-----------------------------------------------------
-- Experiment 6
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT SUM(order_amount)
FROM orders_traditional
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-04-01';

EXPLAIN (ANALYZE,BUFFERS)
SELECT SUM(order_amount)
FROM orders_partitioned
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-04-01';

-----------------------------------------------------
-- Experiment 7
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT
DATE_TRUNC('month',order_date),
COUNT(*)
FROM orders_traditional
GROUP BY 1
ORDER BY 1;

EXPLAIN (ANALYZE,BUFFERS)
SELECT
DATE_TRUNC('month',order_date),
COUNT(*)
FROM orders_partitioned
GROUP BY 1
ORDER BY 1;

-----------------------------------------------------
-- Experiment 8
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_traditional
ORDER BY order_date DESC
LIMIT 100;

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM orders_partitioned
ORDER BY order_date DESC
LIMIT 100;

-----------------------------------------------------
-- Experiment 9
-----------------------------------------------------

EXPLAIN (ANALYZE)
INSERT INTO orders_traditional
(
customer_id,
product_id,
quantity,
order_amount,
status,
payment_type,
city,
order_date
)
SELECT
(random()*50000)::INT,
(random()*10000)::INT,
(random()*5+1)::INT,
(random()*1000)::NUMERIC(10,2),
'Delivered',
'UPI',
'Bangalore',
DATE '2025-03-15'
FROM generate_series(1,10000);

EXPLAIN (ANALYZE)
INSERT INTO orders_partitioned
(
customer_id,
product_id,
quantity,
order_amount,
status,
payment_type,
city,
order_date
)
SELECT
(random()*50000)::INT,
(random()*10000)::INT,
(random()*5+1)::INT,
(random()*1000)::NUMERIC(10,2),
'Delivered',
'UPI',
'Bangalore',
DATE '2025-03-15'
FROM generate_series(1,10000);

-----------------------------------------------------
-- Experiment 10
-----------------------------------------------------

EXPLAIN (ANALYZE,BUFFERS)
DELETE
FROM orders_traditional
WHERE order_date < DATE '2025-02-01';

DROP TABLE orders_2025_01;

-----------------------------------------------------
-- Experiment 11
-----------------------------------------------------

SELECT
tableoid::regclass,
pg_size_pretty(pg_total_relation_size(tableoid))
FROM orders_partitioned
GROUP BY tableoid
ORDER BY tableoid;

SELECT
pg_size_pretty(
pg_total_relation_size('orders_traditional')
);