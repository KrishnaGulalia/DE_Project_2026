SET search_path TO mmt;

CREATE INDEX idx_flight_bookings_flight_id
ON flight_bookings(flight_id);

CREATE INDEX idx_bookings_booked_at_desc
ON bookings(booked_at DESC);

CREATE INDEX idx_customers_lower_email
ON customers (LOWER(email));

