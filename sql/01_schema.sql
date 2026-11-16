CREATE SCHEMA mmt;
SET search_path TO mmt;


CREATE TABLE airports (
    iata_code       CHAR(3) PRIMARY KEY,
    airport_name    TEXT NOT NULL,
    city_name       TEXT NOT NULL,
    country_code    CHAR(2) NOT NULL,

    CONSTRAINT chk_airport_iata
        CHECK (iata_code ~ '^[A-Z]{3}$'),

    CONSTRAINT chk_airport_country
        CHECK (country_code ~ '^[A-Z]{2}$')
);


CREATE TABLE airlines (
    airline_code    VARCHAR(3) PRIMARY KEY,
    airline_name    TEXT NOT NULL,

    CONSTRAINT chk_airline_code
        CHECK (airline_code ~ '^[A-Z0-9]{2,3}$')
);


CREATE TABLE hotels (
    hotel_id        INTEGER PRIMARY KEY,
    hotel_name      TEXT NOT NULL,
    city_name       TEXT NOT NULL,
    star_rating     SMALLINT NOT NULL,
    user_rating     NUMERIC(2,1),
    amenities       JSONB NOT NULL,
    check_in_time   TIME NOT NULL,
    check_out_time  TIME NOT NULL,

    CONSTRAINT chk_hotel_star_rating
        CHECK (star_rating BETWEEN 1 AND 5),

    CONSTRAINT chk_hotel_user_rating
        CHECK (user_rating IS NULL OR user_rating BETWEEN 0 AND 5),

    CONSTRAINT chk_hotel_amenities_object
        CHECK (jsonb_typeof(amenities) = 'object')
);


CREATE TABLE room_types (
    room_type_id    INTEGER PRIMARY KEY,
    hotel_id        INTEGER NOT NULL,
    room_name       TEXT NOT NULL,
    max_guests      SMALLINT NOT NULL,
    price_per_night NUMERIC(10,2) NOT NULL,
    total_rooms     INTEGER NOT NULL,

    CONSTRAINT fk_room_hotel
        FOREIGN KEY (hotel_id)
        REFERENCES hotels(hotel_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_room_max_guests
        CHECK (max_guests > 0),

    CONSTRAINT chk_room_price
        CHECK (price_per_night >= 0),

    CONSTRAINT chk_room_count
        CHECK (total_rooms > 0),

    CONSTRAINT uq_room_type_hotel_name
        UNIQUE (hotel_id, room_name)
);


CREATE TABLE customers (
    customer_id     INTEGER PRIMARY KEY,
    full_name       TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    phone           VARCHAR(20) NOT NULL UNIQUE,
    loyalty_tier    VARCHAR(20) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL,

    CONSTRAINT chk_customer_email
        CHECK (position('@' IN email) > 1),

    CONSTRAINT chk_customer_phone
        CHECK (length(phone) >= 10),

    CONSTRAINT chk_loyalty_tier
        CHECK (loyalty_tier IN ('BLUE', 'SILVER', 'GOLD', 'PLATINUM'))
);


CREATE TABLE flights (
    flight_id       INTEGER PRIMARY KEY,
    airline_code    VARCHAR(3) NOT NULL,
    flight_no       VARCHAR(20) NOT NULL,
    origin          CHAR(3) NOT NULL,
    destination     CHAR(3) NOT NULL,
    departure_at    TIMESTAMPTZ NOT NULL,
    arrival_at      TIMESTAMPTZ NOT NULL,
    aircraft        VARCHAR(50) NOT NULL,
    total_seats     INTEGER NOT NULL,
    base_fare       NUMERIC(10,2) NOT NULL,
    status          VARCHAR(20) NOT NULL,

    CONSTRAINT fk_flight_airline
        FOREIGN KEY (airline_code)
        REFERENCES airlines(airline_code)
        ON DELETE RESTRICT,

    CONSTRAINT fk_flight_origin
        FOREIGN KEY (origin)
        REFERENCES airports(iata_code)
        ON DELETE RESTRICT,

    CONSTRAINT fk_flight_destination
        FOREIGN KEY (destination)
        REFERENCES airports(iata_code)
        ON DELETE RESTRICT,

    CONSTRAINT chk_flight_number_format
        CHECK (flight_no ~ '^[A-Z0-9]+-[A-Z0-9]+$'),

    CONSTRAINT chk_flight_route
        CHECK (origin <> destination),

    CONSTRAINT chk_flight_times
        CHECK (arrival_at > departure_at),

    CONSTRAINT chk_flight_seats
        CHECK (total_seats > 0),

    CONSTRAINT chk_flight_fare
        CHECK (base_fare >= 0),

    CONSTRAINT chk_flight_status
        CHECK (status IN ('SCHEDULED', 'DELAYED', 'LANDED', 'DEPARTED', 'CANCELLED'))

);


CREATE TABLE coupons (
    coupon_code     VARCHAR(30) PRIMARY KEY,
    applies_to      VARCHAR(10) NOT NULL,
    discount_pct    NUMERIC(5,2) NOT NULL,
    max_discount    NUMERIC(10,2) NOT NULL,
    valid_from      DATE NOT NULL,
    valid_to        DATE NOT NULL,

    CONSTRAINT chk_coupon_applies_to
        CHECK (applies_to IN ('FLIGHT', 'HOTEL', 'ALL')),

    CONSTRAINT chk_coupon_discount_pct
        CHECK (discount_pct BETWEEN 0 AND 100),

    CONSTRAINT chk_coupon_max_discount
        CHECK (max_discount >= 0),

    CONSTRAINT chk_coupon_dates
        CHECK (valid_to >= valid_from)
);


CREATE TABLE bookings (
    booking_id      INTEGER PRIMARY KEY,
    booking_ref     VARCHAR(20) NOT NULL UNIQUE,
    customer_id     INTEGER NOT NULL,
    booking_type    VARCHAR(10) NOT NULL,
    booked_at       TIMESTAMPTZ NOT NULL,
    total_amount    NUMERIC(12,2) NOT NULL,
    coupon_code     VARCHAR(30),
    discount        NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_method  VARCHAR(20) NOT NULL,
    status          VARCHAR(20) NOT NULL,
    cancelled_at    TIMESTAMPTZ,
    refund_amount   NUMERIC(12,2),

    CONSTRAINT fk_booking_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_booking_coupon
        FOREIGN KEY (coupon_code)
        REFERENCES coupons(coupon_code)
        ON DELETE RESTRICT,

    CONSTRAINT chk_booking_ref_format
        CHECK (booking_ref ~ '^[A-Z0-9]+$'),

    CONSTRAINT chk_booking_type
        CHECK (booking_type IN ('FLIGHT', 'HOTEL')),

    CONSTRAINT chk_booking_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_booking_discount
        CHECK (discount >= 0 AND discount <= total_amount),

    CONSTRAINT chk_booking_coupon_discount
        CHECK (coupon_code IS NOT NULL OR discount = 0),

    CONSTRAINT chk_booking_payment_method CHECK (
    payment_method IN ('CARD', 'EMI', 'NETBANKING', 'UPI', 'WALLET')),

    CONSTRAINT chk_booking_status
        CHECK (status IN ('PENDING_PAYMENT', 'CONFIRMED', 'COMPLETED', 'CANCELLED')),

    CONSTRAINT chk_booking_cancellation
        CHECK (
            (status = 'CANCELLED' AND cancelled_at IS NOT NULL)
            OR
            (status <> 'CANCELLED' AND cancelled_at IS NULL)
        ),

    CONSTRAINT chk_booking_refund
        CHECK (
            refund_amount IS NULL
            OR (
                status = 'CANCELLED'
                AND refund_amount >= 0
                AND refund_amount <= total_amount
            )
        )
);


CREATE TABLE flight_bookings (
    booking_id      INTEGER PRIMARY KEY,
    flight_id       INTEGER NOT NULL,
    cabin           VARCHAR(20) NOT NULL,
    passengers      SMALLINT NOT NULL,
    fare_paid       NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_flight_booking_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_flight_booking_flight
        FOREIGN KEY (flight_id)
        REFERENCES flights(flight_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_flight_booking_cabin 
        CHECK (cabin IN ('BUSINESS', 'ECONOMY', 'PREMIUM')),

    CONSTRAINT chk_flight_booking_passengers
        CHECK (passengers > 0),

    CONSTRAINT chk_flight_booking_fare
        CHECK (fare_paid >= 0)
);


CREATE TABLE passengers (
    booking_id      INTEGER NOT NULL,
    seq_no          SMALLINT NOT NULL,
    full_name       TEXT NOT NULL,
    age             SMALLINT NOT NULL,
    gender          VARCHAR(10) NOT NULL,
    seat_no         VARCHAR(10),

    PRIMARY KEY (booking_id, seq_no),

    CONSTRAINT fk_passenger_booking
        FOREIGN KEY (booking_id)
        REFERENCES flight_bookings(booking_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_passenger_sequence
        CHECK (seq_no > 0),

    CONSTRAINT chk_passenger_seat_format
        CHECK (seat_no IS NULL OR seat_no ~ '^[0-9]+[A-Z]$'),

    CONSTRAINT chk_passenger_age
        CHECK (age >= 0 AND age <= 120),

    CONSTRAINT chk_passenger_gender CHECK (
    gender IN ('F', 'M', 'X'))
);


CREATE TABLE hotel_bookings (
    booking_id      INTEGER PRIMARY KEY,
    hotel_id        INTEGER NOT NULL,
    room_type_id    INTEGER NOT NULL,
    check_in        DATE NOT NULL,
    check_out       DATE NOT NULL,
    rooms           INTEGER NOT NULL,
    guests          INTEGER NOT NULL,
    room_number     VARCHAR(20),

    CONSTRAINT fk_hotel_booking_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_hotel_booking_hotel
        FOREIGN KEY (hotel_id)
        REFERENCES hotels(hotel_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_hotel_booking_room_type
        FOREIGN KEY (room_type_id)
        REFERENCES room_types(room_type_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_hotel_booking_dates
        CHECK (check_out > check_in),

    CONSTRAINT chk_hotel_booking_rooms
        CHECK (rooms > 0),

    CONSTRAINT chk_hotel_booking_guests
        CHECK (guests > 0)
);


CREATE TABLE hotel_reviews (
    review_id       INTEGER PRIMARY KEY,
    booking_id      INTEGER NOT NULL,
    hotel_id        INTEGER NOT NULL,
    rating          SMALLINT NOT NULL,
    title           TEXT,
    review_text     TEXT,
    created_at      TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_review_booking
        FOREIGN KEY (booking_id)
        REFERENCES hotel_bookings(booking_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_hotel
        FOREIGN KEY (hotel_id)
        REFERENCES hotels(hotel_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_review_rating
        CHECK (rating BETWEEN 1 AND 5)
);
