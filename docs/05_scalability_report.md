# CP4 Scalability Report — MakeMyTrip Travel Booking Database

## Data and methodology

The 12 CSVs supplied as `large_data.zip` contain **10,439,710 data records**, including **2,897,285 bookings**, **800,000 customers**, and **3,272,394 passengers**. These are verified CSV record counts, not independently re-counted PostgreSQL rows.

Using PostgreSQL with the CP1 schema and CP3 indexes, the 30-query workload was measured with `EXPLAIN (ANALYZE, BUFFERS)` **three times per query** and averaged. Writes were rolled back after each run. Raw plans are saved under `benchmarks/results/large/`. Results are machine- and cache-dependent.

## Measured scalability comparisons

| Query | Category | Seed after (ms) | Large (ms) | Growth | Target (ms) | Pass? | Scan nodes (large) |
|---|---|---:|---:|---:|---:|---|---|
| R01 | Real-time | 1.763 | 1.719 | 0.98× | < 5 | PASS | Seq Scan on flights ;  Index Scan using idx_flight_bookings_flight_id on flight_bookings ;  Index Scan using bookings_pkey on bookings |
| R02 | Real-time | 0.885 | 0.810 | 0.92× | < 5 | PASS | Seq Scan on flights |
| R03 | Real-time | 0.268 | 4.376 | 16.33× | < 5 | PASS | Seq Scan on hotels |
| R04 | Real-time | 2.233 | 20.778 | 9.30× | < 5 | **FAIL** | Seq Scan on hotel_bookings ;  Seq Scan on room_types ;  Index Scan using bookings_pkey on bookings |
| R05 | Real-time | 5.813 | 50.321 | 8.66× | < 5 | **FAIL** | Seq Scan on bookings ;  Index Scan using flight_bookings_pkey on flight_bookings ;  Index Scan using flights_pkey on flights ;  Index Scan using hotel_bookings_pkey on hotel_bookings |
| R06 | Real-time | 0.031 | 0.030 | 0.97× | < 5 | PASS | Index Scan using bookings_booking_ref_key on bookings |
| R07 | Real-time | 0.111 | 1.269 | 11.43× | < 5 | PASS | Index Scan using idx_flight_bookings_flight_id on flight_bookings ;  Index Scan using bookings_pkey on bookings ;  Index Scan using passengers_pkey on passengers |
| R08 | Interactive | 1.580 | 16.463 | 10.42× | < 250 | PASS | Seq Scan on flights ;  Index Scan using idx_flight_bookings_flight_id on flight_bookings |
| R09 | Analytics | 7.254 | 59.169 | 8.16× | < 5000 | PASS | Seq Scan on flight_bookings ;  Index Scan using idx_bookings_booked_at_desc on bookings ;  Seq Scan on flights |
| R10 | Real-time | 0.664 | 0.755 | 1.14× | < 5 | PASS | Seq Scan on flights |
| R11 | Real-time | 4.833 | 59.115 | 12.23× | < 5 | **FAIL** | Seq Scan on bookings |
| R12 | Analytics | 22.020 | 309.486 | 14.05× | < 5000 | PASS | Seq Scan on bookings |
| R13 | Interactive | 11.483 | 183.174 | 15.95× | < 250 | PASS | Seq Scan on bookings ;  Seq Scan on coupons |
| R14 | Analytics | 31.533 | 442.146 | 14.02× | < 5000 | PASS | Seq Scan on bookings ;  Seq Scan on flight_bookings ;  Seq Scan on flights ;  Seq Scan on airlines |
| R15 | Analytics | 13.957 | 125.361 | 8.98× | < 5000 | PASS | Seq Scan on bookings ;  Seq Scan on hotel_bookings ;  Seq Scan on hotels |
| R16 | Analytics | 58.549 | 1106.220 | 18.89× | < 5000 | PASS | Seq Scan on bookings ;  Seq Scan on customers ;  Seq Scan on flight_bookings ;  Seq Scan on flights ;  Seq Scan on hotel_bookings |
| R17 | Analytics | 13.428 | 361.851 | 26.95× | < 5000 | PASS | Index Scan using idx_bookings_booked_at_desc on bookings |
| R18 | Interactive | 4.194 | 37.023 | 8.83× | < 250 | PASS | Seq Scan on hotel_reviews ;  Index Scan using hotels_pkey on hotels |
| R19 | Analytics | 4.464 | 126.757 | 28.40× | < 5000 | PASS | Seq Scan on flights ;  Index Scan using idx_flight_bookings_flight_id on flight_bookings ;  Index Only Scan using passengers_pkey on passengers |
| R20 | Analytics | 9.893 | 81.246 | 8.21× | < 5000 | PASS | Seq Scan on bookings |
| R21 | Analytics | 17.066 | 155.688 | 9.12× | < 5000 | PASS | Seq Scan on passengers ;  Seq Scan on flight_bookings ;  Seq Scan on flights |
| R22 | Interactive | 8.486 | 9.994 | 1.18× | < 250 | PASS | Index Scan using idx_bookings_booked_at_desc on bookings |
| R23 | Real-time | 0.041 | 0.031 | 0.76× | < 5 | PASS | Index Scan using idx_customers_lower_email on customers |
| R24 | Interactive | 1.434 | 34.763 | 24.24× | < 250 | PASS | Seq Scan on hotel_reviews ;  Seq Scan on hotels |
| R25 | Analytics | 14.684 | 187.080 | 12.74× | < 5000 | PASS | Seq Scan on flight_bookings ;  Index Scan using idx_bookings_booked_at_desc on bookings ;  Seq Scan on flights |
| W01 | Real-time | 0.496 | 0.664 | 1.34× | < 5 | PASS | (no scan) |
| W02 | Real-time | 9.188 | 240.472 | 26.17× | < 5 | **FAIL** | Index Scan using bookings_pkey on bookings |
| W03 | Real-time | 0.179 | 0.237 | 1.32× | < 5 | PASS | Index Scan using bookings_booking_ref_key on bookings |
| W04 | Batch | 0.988 | 1.830 | 1.85× | < 1000 | PASS | Seq Scan on flights |
| W05 | Interactive | 2.172 | 46.488 | 21.40× | < 250 | PASS | Seq Scan on hotel_bookings ;  Index Scan using bookings_pkey on bookings |

## Target results

**26/30 measured queries passed** their category's average-time target.

Queries requiring attention: R04 (20.778 ms, target < 5 ms), R05 (50.321 ms, target < 5 ms), R11 (59.115 ms, target < 5 ms), W02 (240.472 ms, target < 5 ms).

Largest runtime growth relative to the indexed seed benchmark: R19 (28.40×), R17 (26.95×), W02 (26.17×), R24 (24.24×), W05 (21.40×).

## Interpretation and limitations

- Growth factors use the earlier `after/summary.csv` timings as the baseline. These are indexed-seed measurements, not necessarily the same SQL text as every CP4 query; compare cautiously.
- A sequential scan is not automatically a bad plan: broad aggregates can be faster with sequential/parallel scanning. Investigate `BUFFERS` hit/read counts and returned row counts before modifying indexes.
- Small seed runtime values can make growth ratios unstable. Use absolute latency and workload targets alongside ratios.
- The benchmark script runs queries sequentially without explicit concurrency; these figures do not prove capacity at high simultaneous user load.

## Partitioning evidence

`sql/08_partitioning.sql` builds a range-partitioned **demonstration copy** of bookings by `booked_at` (2025 H1/H2, 2026 H1/H2, plus default), copies booking rows, runs `ANALYZE`, records partition row counts, and tests bounded date predicates. See `benchmarks/results/large/partitioning_plans.txt` for the actual output. Pruning only applies when the planner can constrain the partition key. This is not a production drop-in replacement due to key and FK dependencies.

## 100× growth architecture (proposed; not measured)

At roughly 100× current data, plan for **monthly booking partitions** with retention/archival, **read replicas** for analytics, a bounded **cache** for hot flight and hotel search, and carefully evaluated **sharding** by customer/booking scope only after one tuned primary is insufficient. Use connection pooling, batch ETL, off-peak index maintenance and backups. Monitor p95/p99 latency, index bloat, vacuum lag, IO utilization, lock contention, disk space, and replica lag. Cross-shard joins, globally unique IDs, data movement and transaction boundaries increase complexity.

## Reproduction

Run `./run_cp4.sh` from the repository root to load CSVs, create indexes, produce raw `EXPLAIN (ANALYZE, BUFFERS)` plans, populate `benchmarks/results/large/summary.csv`, execute the partition test, and regenerate this report.
