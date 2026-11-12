```markdown
# Optimization Report

## 1. Optimization Overview

Phase 3 optimization focused on identifying expensive queries from the
baseline workload and improving them using targeted PostgreSQL indexes.

The original `queries/workload_30.sql` was not modified. All optimized
changes were implemented separately in `sql/05_indexes.sql` and
`sql/06_optimized_queries.sql`.

## 2. Indexes Added

### Index 1 — Flight booking lookup

```sql
CREATE INDEX idx_flight_bookings_flight_id
ON flight_bookings(flight_id);
```

This index improves queries that locate flight bookings for a particular
flight.

### Index 2 — Booking date ordering

```sql
CREATE INDEX idx_bookings_booked_at_desc
ON bookings(booked_at DESC);
```

This index improves queries that retrieve bookings ordered by the newest
booking date, especially pagination queries.

### Index 3 — Case-insensitive customer email lookup

```sql
CREATE INDEX idx_customers_lower_email
ON customers (LOWER(email));
```

This functional index allows PostgreSQL to efficiently evaluate queries
using `LOWER(email)`.

## 3. Benchmark Results

Each query was benchmarked using:

```text
EXPLAIN (ANALYZE, BUFFERS)
```

The benchmark script executed each query three times and reported the
average execution time.

| Query | Before (ms) | After (ms) | Improvement |
|---|---:|---:|---:|
| R07 | 2.482 | 0.111 | ~22.4× |
| R08 | 5.319 | 1.580 | ~3.4× |
| R19 | 1142.594 | 4.464 | ~256× |
| R22 | 31.922 | 8.486 | ~3.8× |
| R23 | 8.372 | 0.041 | ~204× |

### R07 — Flight passenger lookup

Before optimization, `flight_bookings` was scanned sequentially.

After adding `idx_flight_bookings_flight_id`, PostgreSQL uses an index
scan on `flight_bookings(flight_id)`.

Execution time improved from 2.482 ms to 0.111 ms.

### R08 — Low-occupancy flights

The same `flight_bookings(flight_id)` index allows PostgreSQL to find
bookings associated with each flight more efficiently.

Execution time improved from 5.319 ms to 1.580 ms.

### R19 — Passengers booked on every June 2026 flight

R19 was the most expensive baseline query.

The original query repeatedly scanned `flight_bookings` for each
qualifying flight. The baseline execution time was 1142.594 ms.

After adding `idx_flight_bookings_flight_id`, PostgreSQL uses an index
scan when finding bookings for each flight.

Execution time decreased to 4.464 ms, approximately a 256× improvement.

### R22 — Deep booking pagination

The original query used:

```sql
ORDER BY booked_at DESC
OFFSET 100000
LIMIT 25;
```

The baseline plan performed a sequential scan followed by an external
sort.

After adding `idx_bookings_booked_at_desc`, PostgreSQL can read bookings
in the required order directly through the index.

Execution time improved from 31.922 ms to 8.486 ms.

### R23 — Case-insensitive customer lookup

The original query used:

```sql
WHERE lower(email) = 'siddharth.sharma1021@rediffmail.com'
```

Without a matching functional index, PostgreSQL performed a sequential
scan of all 40,000 customers.

After adding:

```sql
CREATE INDEX idx_customers_lower_email
ON customers (LOWER(email));
```

the plan changed to a Bitmap Index Scan followed by a Bitmap Heap Scan.

Execution time improved from 8.372 ms to 0.041 ms, approximately a
204× improvement.

## 4. Optimization Attempts That Were Not Kept

A partial index was tested for R12:

```sql
CREATE INDEX idx_bookings_2026_active
ON bookings(booked_at)
WHERE status <> 'CANCELLED';
```

It did not improve the measured execution time, so it was removed.

A rewritten R12 query using a direct date range was also tested:

```sql
booked_at >= '2026-01-01'
AND booked_at < '2027-01-01'
```

The measured execution time was 37.898 ms, compared with the original
average of approximately 22.210 ms. Therefore, this rewrite was not kept
as an optimization.

R14, R15, R16, R21, and R25 were also reviewed. Their execution plans
were dominated by large sequential scans, joins, or aggregations where
the tested indexes were not expected to provide a sufficiently useful
improvement. No additional indexes were added for these queries.

## 5. Trade-offs

Indexes improve read performance but introduce additional storage and
maintenance work for INSERT, UPDATE, and DELETE operations.

Therefore, indexes were added only where benchmark results demonstrated
a meaningful improvement.

The final index set is intentionally limited to targeted indexes that
support the workload rather than indexing every frequently queried
column.
```