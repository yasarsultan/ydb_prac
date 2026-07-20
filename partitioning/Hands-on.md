# PostgreSQL Table Partitioning

This chapter contains my hands-on exploration of **Table Partitioning in PostgreSQL**. Instead of only learning the theory, I created a local PostgreSQL environment, generated **1 million realistic OLTP records**, implemented both a traditional table and a partitioned table, and compared their behavior using `EXPLAIN ANALYZE`.

The goal was to understand **when partitioning improves performance, when it doesn't, and why**.

---

# Objectives

- Understand how PostgreSQL table partitioning works.
- Learn Range Partitioning using `order_date`.
- Compare a normal table with a partitioned table.
- Observe partition pruning.
- Compare execution plans.
- Measure query performance under different workloads.
- Understand the limitations of partitioning.

---

# Dataset

A synthetic e-commerce dataset was generated to simulate a real OLTP workload.

## Dataset Characteristics

| Property | Value |
|----------|------:|
| Total Rows | 1,000,000 |
| Customers | 50,000 |
| Products | 10,000 |
| Year | 2025 |
| Partitioning Strategy | Monthly Range Partitioning |
| Number of Partitions | 12 |

Each order contains:

- Order ID
- Customer ID
- Product ID
- Quantity
- Order Amount
- Status
- Payment Type
- City
- Order Date

The exact same dataset was inserted into:

- `orders_traditional`
- `orders_partitioned`

This ensures both tables contain identical data for fair comparison.

---

# Table Design

## Traditional Table

```text
orders_traditional
```

Contains all one million rows in a single table.

---

## Partitioned Table

```text
orders_partitioned
```

Partitioned by:

```sql
PARTITION BY RANGE(order_date)
```

Monthly partitions:

```
orders_2025_01
orders_2025_02
...
orders_2025_12
```

Each partition stores data for one calendar month.

---

# Indexes

Both implementations use identical indexes.

- order_date
- customer_id
- status

This ensures benchmark results reflect the effect of partitioning rather than indexing differences.

---

# Benchmark Methodology

Every benchmark was executed using:

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

The experiments compare:

- Planning Time
- Execution Time
- Query Plan
- Partition Pruning
- Scan Method
- Overall Performance

---

# Benchmark Results

| Experiment | Traditional | Partitioned | Winner |
|------------|------------:|------------:|--------|
| COUNT(*) | 679 ms | 885 ms | Traditional |
| Single Month Query | 966 ms | 421 ms | Partitioned |
| Three Month Query | 1143 ms | 622 ms | Partitioned |
| Entire Year Query | 2273 ms | 2430 ms | Traditional |
| Customer Lookup | 3.28 ms | 13.58 ms | Traditional |
| Monthly SUM | 938 ms | 158 ms | Partitioned |
| Monthly GROUP BY | 2096 ms | 1892 ms | Partitioned |
| ORDER BY + LIMIT | 2245 ms | 2627 ms | Traditional |
| Insert 10,000 Rows | 1078 ms | 878 ms | Partitioned |
| Delete Old Data | 10.25 s | 2.50 s* | Partitioned |

> A partitioned table can delete old data by dropping an entire partition instead of deleting individual rows, making bulk data removal much faster.

---

# Experiment Analysis

## 1. Full Table Scan

**Query**

```sql
SELECT COUNT(*)
FROM orders;
```

### Observation

The traditional table performed better.

### Why?

Both implementations had to read the entire dataset.

The partitioned table introduced additional overhead because PostgreSQL had to visit all twelve partitions before aggregating the result.

### Takeaway

Partitioning does **not** improve full-table scans.

---

## 2. Single Month Query

**Filter**

```sql
WHERE order_date >= '2025-03-01'
AND order_date < '2025-04-01'
```

### Observation

Execution time reduced from **966 ms** to **421 ms**.

### Why?

PostgreSQL performed **Partition Pruning**.

Instead of scanning the entire dataset, it directly accessed:

```
orders_2025_03
```

The remaining eleven partitions were skipped.

### Takeaway

This is the primary advantage of partitioning.

---

## 3. Three Month Query

Filtering March through May resulted in PostgreSQL scanning only three partitions.

Execution time improved from:

```
1143 ms
```

to

```
622 ms
```

This demonstrates that PostgreSQL prunes all unrelated partitions before executing the query.

---

## 4. Entire Year Query

Filtering the complete year required scanning every partition.

Since no partitions could be skipped, performance was nearly identical to the traditional table.

### Takeaway

Partitioning provides little benefit when almost all data must be accessed.

---

## 5. Lookup Using Non-Partition Key

**Query**

```sql
WHERE customer_id = 25000
```

### Observation

Traditional table:

```
3.28 ms
```

Partitioned table:

```
13.58 ms
```

### Why?

The table is partitioned by **order_date**, not **customer_id**.

Therefore PostgreSQL searched every partition individually.

### Takeaway

Partition pruning only works when queries filter using the partition key.

---

## 6. Monthly Aggregation

Computing the monthly revenue:

```sql
SUM(order_amount)
```

Execution time reduced from:

```
938 ms
```

to

```
158 ms
```

because only one partition needed to be scanned.

---

## 7. Monthly GROUP BY

Grouping all one million rows by month produced only a small improvement.

Although PostgreSQL executed the query in parallel across partitions, every row still had to be processed.

### Takeaway

Partitioning helps only marginally when the entire dataset participates in the aggregation.

---

## 8. ORDER BY + LIMIT

Sorting the complete dataset was actually slower on the partitioned table.

Reason:

- Every partition was scanned.
- PostgreSQL merged results from all partitions.
- Additional planning and merge overhead outweighed any benefit.

---

## 9. Bulk Insert

Inserting 10,000 rows into March completed slightly faster on the partitioned table.

Since all rows belonged to the same partition, PostgreSQL routed inserts directly into `orders_2025_03`.

---

## 10. Data Retention

Traditional table:

```sql
DELETE
WHERE order_date < '2025-02-01'
```

Execution time:

```
10.25 seconds
```

Partitioned table:

```sql
DROP TABLE orders_2025_01;
```

Execution time:

```
2.50 seconds
```

Removing an old partition is significantly faster than deleting individual rows.

This is one of the biggest operational advantages of partitioning.

---

# Storage

Traditional table:

```
225 MB
```

Partition sizes ranged between:

```
27 MB – 35 MB
```

Partitioning does not significantly reduce storage usage, but it organizes data into manageable physical units that simplify maintenance and lifecycle management.

---

# Key Learnings

- Partitioning is primarily a **data management technique**, not a universal performance optimization.
- The biggest benefit comes from **Partition Pruning**.
- Queries filtering on the partition key become significantly faster.
- Queries that scan the entire dataset usually see little or no benefit.
- Queries using non-partition columns may become slower because PostgreSQL must search every partition.
- Dropping old partitions is much more efficient than deleting millions of rows.
- Good partition design depends on understanding application query patterns.

---

# When to Use Partitioning

Partitioning is a good choice when:

- Tables contain millions of rows.
- Data naturally grows over time.
- Most queries filter by date or another partition key.
- Old data must be archived or removed regularly.
- Maintenance operations (VACUUM, backups, retention) need to be simplified.

---

# When Not to Use Partitioning

Avoid partitioning when:

- Tables are relatively small.
- Most queries require scanning the entire dataset.
- Queries rarely filter using the partition key.
- The added complexity outweighs the performance benefits.

---

# Conclusion

This hands-on exercise demonstrates that PostgreSQL partitioning is **not a universal performance feature**. Its effectiveness depends entirely on how well the partitioning strategy aligns with application query patterns.

When queries filter on the partition key, PostgreSQL can eliminate irrelevant partitions through partition pruning, resulting in significantly faster execution. However, workloads that require scanning the full dataset or filtering on non-partitioned columns gain little benefit and may even experience additional overhead.

The biggest practical advantage of partitioning is operational: it simplifies large-table maintenance, enables efficient data retention through partition drops, and improves scalability for time-based datasets.

Overall, partitioning should be viewed as a **data organization and maintenance strategy** that can also provide substantial performance improvements when used appropriately.