-- =========================================================
-- MakeMyTrip Travel Booking Database
-- Phase 2 - Load Seed Data
-- PostgreSQL 15+
-- =========================================================

SET search_path TO mmt;


-- Parent tables first
\copy airports FROM 'seed_data/airports.csv' WITH (FORMAT csv, HEADER true);

\copy airlines FROM 'seed_data/airlines.csv' WITH (FORMAT csv, HEADER true);

\copy hotels FROM 'seed_data/hotels.csv' WITH (FORMAT csv, HEADER true);

\copy customers FROM 'seed_data/customers.csv' WITH (FORMAT csv, HEADER true);

\copy coupons FROM 'seed_data/coupons.csv' WITH (FORMAT csv, HEADER true);


-- Tables depending on parents
\copy room_types FROM 'seed_data/room_types.csv' WITH (FORMAT csv, HEADER true);

\copy flights FROM 'seed_data/flights.csv' WITH (FORMAT csv, HEADER true);

\copy bookings FROM 'seed_data/bookings.csv' WITH (FORMAT csv, HEADER true);


-- Child booking tables
\copy flight_bookings FROM 'seed_data/flight_bookings.csv' WITH (FORMAT csv, HEADER true);

\copy hotel_bookings FROM 'seed_data/hotel_bookings.csv' WITH (FORMAT csv, HEADER true);

\copy passengers FROM 'seed_data/passengers.csv' WITH (FORMAT csv, HEADER true);

\copy hotel_reviews FROM 'seed_data/hotel_reviews.csv' WITH (FORMAT csv, HEADER true);


-- Update planner statistics
ANALYZE;


-- =========================================================
-- Row-count verification
-- =========================================================

SELECT 'airports' AS table_name, COUNT(*) AS row_count FROM airports
UNION ALL
SELECT 'airlines', COUNT(*) FROM airlines
UNION ALL
SELECT 'flights', COUNT(*) FROM flights
UNION ALL
SELECT 'hotels', COUNT(*) FROM hotels
UNION ALL
SELECT 'room_types', COUNT(*) FROM room_types
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'coupons', COUNT(*) FROM coupons
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'flight_bookings', COUNT(*) FROM flight_bookings
UNION ALL
SELECT 'passengers', COUNT(*) FROM passengers
UNION ALL
SELECT 'hotel_bookings', COUNT(*) FROM hotel_bookings
UNION ALL
SELECT 'hotel_reviews', COUNT(*) FROM hotel_reviews
ORDER BY table_name;


-- =========================================================
-- Integrity check 1:
-- Every flight booking should have the same number of
-- passenger rows as the passengers column.
-- =========================================================

SELECT
    fb.booking_id,
    fb.passengers AS expected_passengers,
    COUNT(p.seq_no) AS actual_passengers
FROM flight_bookings fb
LEFT JOIN passengers p
    ON p.booking_id = fb.booking_id
GROUP BY fb.booking_id, fb.passengers
HAVING fb.passengers <> COUNT(p.seq_no);


-- =========================================================
-- Integrity check 2:
-- No flight booking should be made after the flight departed.
-- =========================================================

SELECT
    fb.booking_id,
    b.booked_at,
    f.departure_at
FROM flight_bookings fb
JOIN bookings b
    ON b.booking_id = fb.booking_id
JOIN flights f
    ON f.flight_id = fb.flight_id
WHERE b.booked_at > f.departure_at;


-- =========================================================
-- Integrity check 3:
-- A booking must belong to exactly one product:
-- flight OR hotel, never both.
-- =========================================================

SELECT
    b.booking_id,
    b.booking_type,
    (fb.booking_id IS NOT NULL) AS has_flight,
    (hb.booking_id IS NOT NULL) AS has_hotel
FROM bookings b
LEFT JOIN flight_bookings fb
    ON fb.booking_id = b.booking_id
LEFT JOIN hotel_bookings hb
    ON hb.booking_id = b.booking_id
WHERE
    (fb.booking_id IS NOT NULL AND hb.booking_id IS NOT NULL)
    OR
    (fb.booking_id IS NULL AND hb.booking_id IS NULL);


-- =========================================================
-- End
-- =========================================================