# Partitioning


Partitioning is a database design technique in which a single logical table is divided into multiple smaller physical tables called **partitions**. Each partition stores a subset of the data according to a predefined partitioning strategy, such as a range of dates, a list of values, or the output of a hash function.

Despite being physically divided, the partitions collectively behave as a **single logical table**. Applications continue to interact with only one table, while the database transparently manages how data is stored and retrieved.

---

## Definition

> **Table Partitioning** is the process of splitting one logically large table into multiple smaller physical partitions to improve query performance, maintenance, and scalability while preserving the abstraction of a single logical table.

---

# Why Partitioning Exists

As databases grow from thousands to millions or even billions of rows, managing data in a single table becomes increasingly inefficient.

Some common problems include:

- Large sequential scans
- Very large indexes that may no longer fit into RAM
- Increased disk I/O
- Slower query execution
- Longer VACUUM and ANALYZE operations
- Slower backups and restores
- Difficulty archiving or removing historical data

Partitioning addresses these challenges by allowing PostgreSQL to operate on only the relevant subset of data instead of the entire dataset.

---

# How Partitioning Works

In PostgreSQL, partitioning follows a **parent-child architecture**.

## Parent Table

The **parent table** (also called the **partitioned table**) defines:

- Table structure (columns)
- Partition key
- Partitioning method (Range, List, or Hash)

The parent table is **virtual** and stores **no actual data**.

Example:

```
orders
```

---

## Child Tables (Partitions)

Each child table stores a specific subset of the parent table's data according to the partitioning rule.

Example:

```
orders_2025_01
orders_2025_02
orders_2025_03
```

Each partition is an independent physical table managed internally by PostgreSQL.

---

## Data Insertion

Applications always insert data into the **parent table**.

PostgreSQL automatically determines which partition satisfies the partition key and routes the row to the correct child table.

This routing is completely transparent to the application.

---

## Data Retrieval

Applications always query the **parent table**.

During query planning, PostgreSQL determines which partitions may contain matching rows and scans only those partitions whenever possible.

The application never needs to specify individual partitions.

---

# Key Benefits

## 1. Partition Pruning

### Definition

Partition Pruning is a query optimization technique where PostgreSQL analyzes the query's `WHERE` clause and excludes partitions that cannot possibly contain matching rows.

Instead of scanning every partition, only the relevant partitions are accessed.

### Example

```sql
SELECT *
FROM orders
WHERE order_date >= DATE '2025-03-01'
  AND order_date < DATE '2025-04-01';
```

If the table is partitioned monthly, PostgreSQL scans only:

```
orders_2025_03
```

All other partitions are skipped.

### Benefits

- Reduces disk I/O
- Faster query execution
- Smaller index lookups
- Better memory utilization
- Lower CPU usage

---

## 2. Improved Query Performance

Queries that filter using the partition key examine significantly fewer rows.

Instead of searching billions of records, PostgreSQL searches only the relevant partition.

This reduces:

- Scan time
- Buffer reads
- CPU utilization

---

## 3. Smaller Indexes

Each partition maintains its own indexes.

Since every partition contains fewer rows than the complete table:

- Indexes become smaller
- Index lookups become faster
- More index pages remain cached in RAM

---

## 4. Faster Maintenance

Maintenance operations run on individual partitions rather than the entire table.

Examples include:

- VACUUM
- ANALYZE
- REINDEX
- CLUSTER

Smaller tables require less maintenance time.

---

## 5. Easier Data Archival

Historical data can be archived simply by detaching or dropping old partitions.

Example:

Instead of

```sql
DELETE FROM orders
WHERE order_date < '2023-01-01';
```

you can simply remove an entire partition.

Benefits include:

- Faster cleanup
- Minimal locking
- Reduced WAL generation

---

## 6. Better Scalability

Partitioning enables databases to efficiently manage datasets containing hundreds of millions or billions of rows.

Without partitioning, query performance and maintenance costs continue increasing as the table grows.

---

# Partition Pruning Example

Suppose an `orders` table is partitioned by month.

```
orders
├── orders_2025_01
├── orders_2025_02
├── orders_2025_03
├── orders_2025_04
└── orders_2025_05
```

Query:

```sql
SELECT *
FROM orders
WHERE order_date >= DATE '2025-03-01'
AND order_date < DATE '2025-04-01';
```

Without partition pruning:

```
Scan January
Scan February
Scan March
Scan April
Scan May
```

With partition pruning:

```
Skip January
Skip February
Scan March
Skip April
Skip May
```

Only one partition is accessed.

---

# Partition Key

A **partition key** is the column (or combination of columns) used to determine which partition stores a particular row.

Examples:

| Partition Key | Example |
|---------------|---------|
| Date | `order_date` |
| Region | `country` |
| Customer ID | `customer_id` |
| Department | `department` |

Choosing the correct partition key is critical because PostgreSQL performs partition pruning only when the query filters on the partition key.

---

# Advantages

- Faster queries through partition pruning
- Reduced disk I/O
- Smaller indexes
- Better memory utilization
- Faster maintenance operations
- Easier archival of historical data
- Better scalability for very large datasets
- Transparent to applications

---

# Limitations

Partitioning is **not** a universal performance optimization.

It introduces additional complexity and is beneficial only for certain workloads.

Some limitations include:

- Additional planning overhead
- More complex schema management
- Queries without the partition key may scan many or all partitions
- Excessive numbers of partitions can negatively impact planning time
- Choosing an incorrect partition key greatly reduces effectiveness

---

# When to Use Partitioning

Partitioning is recommended when:

- Tables contain tens or hundreds of millions of rows
- Queries frequently filter on a predictable column
- Historical data is archived regularly
- Maintenance operations are becoming expensive
- Data naturally divides into logical groups

Examples:

- Orders
- Transactions
- Event logs
- Sensor data
- Clickstream data
- Audit logs

---

# When Not to Use Partitioning

Avoid partitioning when:

- Tables are relatively small
- Most queries access the entire dataset
- No suitable partition key exists
- Maintenance complexity outweighs performance gains

---

# Key Takeaways

- Partitioning divides one logical table into multiple physical tables.
- Applications always interact with the parent table.
- PostgreSQL automatically routes inserts to the correct partition.
- Queries remain unchanged after partitioning.
- Partition pruning is the primary performance optimization.
- Smaller partitions result in faster scans, smaller indexes, and easier maintenance.
- Partitioning is most beneficial for very large tables with predictable query patterns.