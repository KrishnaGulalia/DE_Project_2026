SET search_path TO mmt;

-- Phase 5: Partitioning design for bookings
-- Strategy: RANGE partitioning by booked_at.
--
-- Time-based partitioning is appropriate because several workload
-- queries filter bookings using booked_at ranges.
--
-- PostgreSQL requires a partitioned table's primary key to include
-- the partition key.

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

    PRIMARY KEY (booking_id, booked_at),

    CONSTRAINT chk_bookings_p_type
        CHECK (booking_type IN ('FLIGHT', 'HOTEL')),

    CONSTRAINT chk_bookings_p_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_bookings_p_discount
        CHECK (discount >= 0 AND discount <= total_amount),

    CONSTRAINT chk_bookings_p_payment
        CHECK (
            payment_method IN
            ('CARD', 'EMI', 'NETBANKING', 'UPI', 'WALLET')
        ),

    CONSTRAINT chk_bookings_p_status
        CHECK (
            status IN
            ('PENDING_PAYMENT', 'CONFIRMED', 'COMPLETED', 'CANCELLED')
        )
)
PARTITION BY RANGE (booked_at);


CREATE TABLE bookings_2025_h1
PARTITION OF bookings_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-07-01');

CREATE TABLE bookings_2025_h2
PARTITION OF bookings_partitioned
FOR VALUES FROM ('2025-07-01') TO ('2026-01-01');

CREATE TABLE bookings_2026_h1
PARTITION OF bookings_partitioned
FOR VALUES FROM ('2026-01-01') TO ('2026-07-01');

CREATE TABLE bookings_2026_h2
PARTITION OF bookings_partitioned
FOR VALUES FROM ('2026-07-01') TO ('2027-01-01');

CREATE TABLE bookings_default
PARTITION OF bookings_partitioned DEFAULT;


-- Index useful for customer-centric lookups.
CREATE INDEX idx_bookings_partitioned_customer_id
ON bookings_partitioned(customer_id);


-- Populate the demonstration table with the large database booking rows.
INSERT INTO bookings_partitioned SELECT * FROM bookings;
ANALYZE bookings_partitioned;

-- Confirm distribution and partitioning coverage.
SELECT tableoid::regclass AS partition_name, count(*) AS rows
FROM bookings_partitioned GROUP BY tableoid ORDER BY 1;

-- Demonstration of partition pruning.
-- Only the 2026_h1 partition should be scanned for this range.

EXPLAIN (ANALYZE, BUFFERS)
SELECT booking_id, booking_ref, customer_id, total_amount
FROM bookings_partitioned
WHERE booked_at >= '2026-06-01'
  AND booked_at < '2026-07-01';


-- Demonstration of pruning across a two-month range.

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM bookings_partitioned
WHERE booked_at >= '2026-05-01'
  AND booked_at < '2026-07-01';
