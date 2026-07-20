CREATE INDEX idx_traditional_order_date
ON orders_traditional(order_date);

CREATE INDEX idx_traditional_customer
ON orders_traditional(customer_id);

CREATE INDEX idx_traditional_status
ON orders_traditional(status);

CREATE INDEX idx_partitioned_order_date
ON orders_partitioned(order_date);

CREATE INDEX idx_partitioned_customer
ON orders_partitioned(customer_id);

CREATE INDEX idx_partitioned_status
ON orders_partitioned(status);

ANALYZE orders_traditional;
ANALYZE orders_partitioned;