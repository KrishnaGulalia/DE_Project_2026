SET search_path TO mmt;

-- @R07
-- Optimized using idx_flight_bookings_flight_id
SELECT p.full_name, p.age, p.gender, p.seat_no, b.booking_ref
FROM flight_bookings fb
JOIN bookings b   ON b.booking_id = fb.booking_id AND b.status <> 'CANCELLED'
JOIN passengers p ON p.booking_id = fb.booking_id
WHERE fb.flight_id = 13047
ORDER BY p.seat_no NULLS LAST, p.full_name;

-- @R08
-- Optimized using idx_flight_bookings_flight_id
SELECT f.flight_id, f.flight_no, f.departure_at, coalesce(sum(fb.passengers), 0) AS passengers
FROM flights f
LEFT JOIN flight_bookings fb ON fb.flight_id = f.flight_id
WHERE f.departure_at >= '2026-07-01' AND f.status = 'SCHEDULED'
GROUP BY f.flight_id, f.flight_no, f.departure_at
HAVING coalesce(sum(fb.passengers), 0) < 5
ORDER BY f.departure_at;

-- @R19
-- Optimized using idx_flight_bookings_flight_id
SELECT f.flight_id, f.flight_no, f.departure_at,
       (SELECT count(*) FROM passengers p JOIN flight_bookings fb ON fb.booking_id = p.booking_id
         WHERE fb.flight_id = f.flight_id) AS passengers
FROM flights f
WHERE f.departure_at >= '2026-06-01' AND f.departure_at < '2026-07-01'
ORDER BY passengers DESC, f.departure_at;

-- @R22
-- Optimized using idx_bookings_booked_at_desc
SELECT booking_id, booking_ref, booking_type, status, total_amount, booked_at
FROM bookings
ORDER BY booked_at DESC
OFFSET 100000
LIMIT 25;

-- @R23
-- Optimized using idx_customers_lower_email
SELECT customer_id, full_name, loyalty_tier
FROM customers
WHERE LOWER(email) = 'siddharth.sharma1021@rediffmail.com';