# Phase 3 — Baseline Query Timings

## Benchmark Method

The 30 fixed workload queries from `queries/workload_30.sql` were executed using:

```text
EXPLAIN (ANALYZE, BUFFERS)
```

Each query was executed three times, and the average execution time reported by the benchmark script was recorded.

The benchmark was run using the `before` phase on the same development environment.

## Baseline Timing Results

| SQL Query | Type | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) |
|---|---|---:|---:|---:|---:|
| R01 | READ | 26.612 | 5.901 | 5.519 | 12.677 |
| R02 | READ | 0.738 | 0.672 | 0.645 | 0.685 |
| R03 | READ | 4.491 | 0.207 | 0.206 | 1.635 |
| R04 | READ | 11.646 | 1.821 | 1.732 | 5.066 |
| R05 | READ | 51.356 | 5.394 | 5.217 | 20.656 |
| R06 | READ | 0.951 | 0.030 | 0.024 | 0.335 |
| R07 | READ | 3.815 | 1.862 | 1.768 | 2.482 |
| R08 | READ | 5.478 | 5.286 | 5.192 | 5.319 |
| R09 | READ | 11.676 | 11.654 | 11.368 | 11.566 |
| R10 | READ | 0.693 | 0.616 | 0.602 | 0.637 |
| R11 | READ | 6.511 | 4.994 | 4.417 | 5.307 |
| R12 | READ | 22.602 | 22.255 | 21.995 | 22.284 |
| R13 | READ | 11.395 | 11.173 | 11.056 | 11.208 |
| R14 | READ | 27.664 | 27.555 | 27.462 | 27.560 |
| R15 | READ | 14.226 | 14.082 | 14.031 | 14.113 |
| R16 | READ | 105.036 | 72.860 | 62.387 | 80.094 |
| R17 | READ | 18.898 | 16.678 | 16.632 | 17.403 |
| R18 | READ | 7.522 | 4.522 | 4.355 | 5.466 |
| R19 | READ | 1163.339 | 1136.387 | 1128.056 | 1142.594 |
| R20 | READ | 6.815 | 6.556 | 6.286 | 6.552 |
| R21 | READ | 36.994 | 15.808 | 15.623 | 22.808 |
| R22 | READ | 31.996 | 31.912 | 31.859 | 31.922 |
| R23 | READ | 8.693 | 8.282 | 8.142 | 8.372 |
| R24 | READ | 1.404 | 1.400 | 1.388 | 1.397 |
| R25 | READ | 17.565 | 17.013 | 16.929 | 17.169 |
| W01 | WRITE | 0.891 | 0.396 | 0.384 | 0.557 |
| W02 | WRITE | 18.125 | 9.328 | 8.928 | 12.127 |
| W03 | WRITE | 0.195 | 0.161 | 0.159 | 0.172 |
| W04 | WRITE | 1.010 | 0.981 | 0.946 | 0.979 |
| W05 | WRITE | 2.621 | 2.152 | 2.073 | 2.282 |

## Baseline Observations

- All 30 workload queries completed successfully.
- R19 has the highest average execution time at **1142.594 ms**.
- R16 has the second-highest average execution time at **80.094 ms**.
- Among the WRITE queries, W02 has the highest average execution time at **12.127 ms**.
- The scan nodes and detailed execution plans are preserved in `benchmarks/results/before/`.
- The benchmark summary is stored in `benchmarks/results/before/summary.csv`.