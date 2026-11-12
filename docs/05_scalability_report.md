Good. **CP4 is partially set up**, but we should not fabricate the large-data results before `large_data.zip` is released.

The next thing is to put the **actual partitioning evidence** into `docs/05_scalability_report.md`.

Paste this:

```markdown
# Scalability Report

## 1. Large-Dataset Scalability

The faculty-provided large dataset is expected to contain approximately 20× the seed-data volume. The large-data benchmark will be completed once `large_data.zip` is provided.

The optimized queries from `sql/06_optimized_queries.sql` will be benchmarked on the large dataset using the same methodology as the seed benchmark:

- `EXPLAIN (ANALYZE, BUFFERS)`
- 3 executions per query
- Average execution time reported
- Write queries executed inside `BEGIN; ... ROLLBACK;`

The original 30-query workload will not be run directly against the large dataset because some queries may take an excessive amount of time.

## 2. Performance Targets

| Query Group | Queries | Target |
|---|---|---:|
| Real-time / customer-facing | R01, R02, R03, R04, R05, R06, R07, R10, R11, R23, W01, W02, W03 | < 5 ms |
| Interactive partner tools | R08, R13, R18, R22, R24, W05 | < 250 ms |
| Reports and analytics | R09, R12, R14, R15, R16, R17, R19, R20, R21, R25 | < 5,000 ms |
| Batch jobs | W04 | < 1,000 ms |

Large-data execution times and target status will be added after the faculty dataset is released.

## 3. Partitioning Design

### 3.1 Strategy

The `bookings` table is a good candidate for **RANGE partitioning on `booked_at`**.

The main reason is that several workload queries operate over time ranges. Partitioning by booking date allows PostgreSQL to eliminate partitions that cannot contain rows relevant to a query.

For the design demonstration, the partitioned table was created as:

```sql
CREATE TABLE bookings_partitioned (
    booking_id INTEGER NOT NULL,
    booking_ref VARCHAR(20) NOT NULL,
    customer_id INTEGER NOT NULL,
    booking_type VARCHAR(10) NOT NULL,
    booked_at TIMESTAMPTZ NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    coupon_code VARCHAR(30),
    discount NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    cancelled_at TIMESTAMPTZ,
    refund_amount NUMERIC(12,2),

    PRIMARY KEY (booking_id, booked_at)
)
PARTITION BY RANGE (booked_at);
```

The seed dataset was divided into the following time ranges:

| Partition | Range | Rows |
|---|---|---:|
| `bookings_2025_h1` | Jan 2025 – Jun 2025 | 47,994 |
| `bookings_2025_h2` | Jul 2025 – Dec 2025 | 48,774 |
| `bookings_2026_h1` | Jan 2026 – Jun 2026 | 48,024 |
| `bookings_2026_h2` | Jul 2026 – Dec 2026 | 0 |
| `bookings_default` | Other dates | 0 |

The total is:

**47,994 + 48,774 + 48,024 = 144,792 bookings**, matching the original seed dataset.

### 3.2 Partition Pruning

A partition-pruning test was executed using:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT booking_id, booking_ref, customer_id, total_amount
FROM bookings_partitioned
WHERE booked_at >= '2026-06-01'
  AND booked_at < '2026-07-01';
```

PostgreSQL produced a plan using:

```text
Index Scan using bookings_2026_h1_pkey on bookings_2026_h1
```

This demonstrates that the June 2026 date range can be isolated to the `bookings_2026_h1` partition rather than scanning all partitions.

### 3.3 Primary-Key Rule

For a partitioned table, PostgreSQL requires a primary key or unique constraint defined on the partitioned table to include the partition key.

Therefore, the partitioned design uses:

```sql
PRIMARY KEY (booking_id, booked_at)
```

instead of only:

```sql
PRIMARY KEY (booking_id)
```

because `booked_at` is the partition key.

## 4. Large-Data Results

This section will be completed after `large_data.zip` is released.

| Query | Optimized on Seed (ms) | Optimized on Large (ms) | Growth | Meets Target? | Change Required |
|---|---:|---:|---:|---|---|
| R01 | 1.427 | TBD | TBD | TBD | TBD |
| R02 | 0.785 | TBD | TBD | TBD | TBD |
| R03 | 0.266 | TBD | TBD | TBD | TBD |
| R04 | 2.203 | TBD | TBD | TBD | TBD |
| R05 | 6.056 | TBD | TBD | TBD | TBD |
| R06 | 0.030 | TBD | TBD | TBD | TBD |
| R07 | 0.112 | TBD | TBD | TBD | TBD |
| R08 | 1.703 | TBD | TBD | TBD | TBD |
| R09 | 7.497 | TBD | TBD | TBD | TBD |
| R10 | 0.642 | TBD | TBD | TBD | TBD |
| R11 | 4.573 | TBD | TBD | TBD | TBD |
| R12 | 22.210 | TBD | TBD | TBD | TBD |
| R13 | 10.981 | TBD | TBD | TBD | TBD |
| R14 | 25.625 | TBD | TBD | TBD | TBD |
| R15 | 13.762 | TBD | TBD | TBD | TBD |
| R16 | 54.923 | TBD | TBD | TBD | TBD |
| R17 | 13.449 | TBD | TBD | TBD | TBD |
| R18 | 4.832 | TBD | TBD | TBD | TBD |
| R19 | 4.656 | TBD | TBD | TBD | TBD |
| R20 | 5.053 | TBD | TBD | TBD | TBD |
| R21 | 15.771 | TBD | TBD | TBD | TBD |
| R22 | 8.524 | TBD | TBD | TBD | TBD |
| R23 | 8.606 | TBD | TBD | TBD | TBD |
| R24 | 1.517 | TBD | TBD | TBD | TBD |
| R25 | 17.672 | TBD | TBD | TBD | TBD |
| W01 | 0.437 | TBD | TBD | TBD | TBD |
| W02 | 13.289 | TBD | TBD | TBD | TBD |
| W03 | 0.180 | TBD | TBD | TBD | TBD |
| W04 | 0.966 | TBD | TBD | TBD | TBD |
| W05 | 2.197 | TBD | TBD | TBD | TBD |

## 5. Growth Analysis

The growth behavior of the optimized queries will be analyzed after benchmarking the large dataset.

Queries using selective indexes are expected to scale differently from queries involving large sequential scans, joins, aggregations, and sorting. The actual classification will be based on measured execution times and execution plans.

## 6. Storage

Seed and large-dataset storage measurements will be recorded after the large dataset is available.

The report will compare:

- Total database size
- Table size
- Index size
- Seed dataset versus large dataset

## 7. Architecture for 100× Volume

### Partitioning

RANGE partitioning by `booked_at` is proposed for `bookings` because booking-related analytical queries frequently operate over time periods.

Partition pruning reduces the amount of data that needs to be examined for date-restricted queries.

### Sharding

A final sharding strategy will be selected using the large-data measurements.

The main alternatives considered are:

- Sharding by customer
- Sharding by product type
- Sharding by travel date

Customer-based sharding could make customer "My Trips" queries efficient but could make flight-manifest queries cross-shard.

Travel-date sharding aligns naturally with time-based booking analytics but customer histories could span multiple shards.

### Read Replicas and Caching

Read-heavy analytical and customer-facing queries can potentially be routed to read replicas.

Frequently repeated, relatively stable read queries can also be candidates for caching.

Write operations and queries requiring the most current transactional state should remain on the primary database.

### Maintenance

At larger scale, regular maintenance will be important:

- VACUUM/autovacuum for frequently modified tables
- ANALYZE after major data changes
- Archiving old booking data where appropriate
- Refreshing summary tables for expensive recurring analytical queries

## 8. Conclusion

The seed-data implementation successfully loads all 144,792 bookings and the partitioning design demonstrates effective partition pruning for date-restricted queries.

Final conclusions about readiness for the expected 20× volume will be made after the faculty-provided large dataset is benchmarked. Remaining risks will be identified from the large-data execution plans, timing growth, storage measurements, and any queries that fail their performance targets.
```
