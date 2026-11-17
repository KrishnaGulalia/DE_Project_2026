# Phase 2 — Schema Design and Seed-Data Validation

The schema is `mmt`; column names match the 12 CSV headers. Amounts use fixed-point `NUMERIC`, source timestamps with `+05:30` are `TIMESTAMPTZ`, calendar days use `DATE`, clock times use `TIME`, and hotel amenity flags use `JSONB`.

## Data dictionary

`PK` = primary key, `FK` = foreign key, `UQ` = unique, `NN` = not null. A check constraint is named where its rule is important; all other `NN` marks come from `NOT NULL` in the DDL. Nullable fields are explicitly marked `NULL`.

### airports

| Column | Type | Constraint | Why |
|---|---|---|---|
| `iata_code` | `CHAR(3)` | PK, NN, `chk_airport_iata` | Stable IATA identifier and flight join key; uppercase three-letter format. |
| `airport_name` | `TEXT` | NN | Airport display name. |
| `city_name` | `TEXT` | NN | Search/display city. |
| `country_code` | `CHAR(2)` | NN, `chk_airport_country` | Short ISO-style country code. |

### airlines

| Column | Type | Constraint | Why |
|---|---|---|---|
| `airline_code` | `VARCHAR(3)` | PK, NN, `chk_airline_code` | Two/three-character airline identifier. |
| `airline_name` | `TEXT` | NN | Display name. |

### flights

| Column | Type | Constraint | Why |
|---|---|---|---|
| `flight_id` | `INTEGER` | PK, NN | Identifies a dated flight instance. |
| `airline_code` | `VARCHAR(3)` | FK → `airlines`, NN | Operating airline; delete restricted while flights refer to it. |
| `flight_no` | `VARCHAR(20)` | NN, `chk_flight_number_format` | Flight number such as `6E-137`; operational identifier, not unique across dated instances. |
| `origin`, `destination` | `CHAR(3)` | FK → `airports`, NN; `chk_flight_route` | Airport codes; origin and destination must differ. |
| `departure_at`, `arrival_at` | `TIMESTAMPTZ` | NN, `chk_flight_times` | Offset-aware scheduled instants; arrival must follow departure. |
| `aircraft` | `VARCHAR(50)` | NN | Aircraft model/equipment label. |
| `total_seats` | `INTEGER` | NN, `chk_flight_seats` | Positive inventory count. |
| `base_fare` | `NUMERIC(10,2)` | NN, `chk_flight_fare` | Non-negative currency amount with paise precision. |
| `status` | `VARCHAR(20)` | NN, `chk_flight_status` | Limited to the observed/defined flight lifecycle values. |

Airline and airport foreign keys use `ON DELETE RESTRICT` to preserve flight history and prevent orphaned routes.

### hotels

| Column | Type | Constraint | Why |
|---|---|---|---|
| `hotel_id` | `INTEGER` | PK, NN | Hotel identifier. |
| `hotel_name`, `city_name` | `TEXT` | NN | Display name and search city. |
| `star_rating` | `SMALLINT` | NN, `chk_hotel_star_rating` | Small integer constrained to 1–5. |
| `user_rating` | `NUMERIC(2,1)` | NULL, `chk_hotel_user_rating` | Optional customer rating; absent for unrated hotels. |
| `amenities` | `JSONB` | NN, `chk_hotel_amenities_object` | Object of amenity-name → boolean flags (gym, spa, pool, wifi, parking, breakfast, pet_friendly). |
| `check_in_time`, `check_out_time` | `TIME` | NN | Local hotel clock times, not instants. |

### room_types

| Column | Type | Constraint | Why |
|---|---|---|---|
| `room_type_id` | `INTEGER` | PK, NN | Room-type identifier. |
| `hotel_id` | `INTEGER` | FK → `hotels`, NN, `ON DELETE RESTRICT` | Owning hotel. |
| `room_name` | `TEXT` | NN; `UNIQUE (hotel_id, room_name)` | Name is unique within its hotel. |
| `max_guests` | `SMALLINT` | NN, `chk_room_max_guests` | Positive occupancy limit. |
| `price_per_night` | `NUMERIC(10,2)` | NN, `chk_room_price` | Non-negative nightly price. |
| `total_rooms` | `INTEGER` | NN, `chk_room_count` | Positive room inventory. |

### customers

| Column | Type | Constraint | Why |
|---|---|---|---|
| `customer_id` | `INTEGER` | PK, NN | Customer identifier. |
| `full_name` | `TEXT` | NN | Customer name. |
| `email` | `TEXT` | NN, UQ, `chk_customer_email` | Required sign-in address; unique as stored. |
| `phone` | `VARCHAR(20)` | NN, UQ, `chk_customer_phone` | Preserve phone digits as text (not arithmetic); unique contact number. |
| `loyalty_tier` | `VARCHAR(20)` | NN, `chk_loyalty_tier` | Restricts tier to BLUE, SILVER, GOLD or PLATINUM. |
| `created_at` | `TIMESTAMPTZ` | NN | Offset-aware account creation instant. |

### coupons

| Column | Type | Constraint | Why |
|---|---|---|---|
| `coupon_code` | `VARCHAR(30)` | PK, NN | Stable coupon identifier. |
| `applies_to` | `VARCHAR(10)` | NN, `chk_coupon_applies_to` | FLIGHT, HOTEL or ALL product scope. |
| `discount_pct` | `NUMERIC(5,2)` | NN, `chk_coupon_discount_pct` | Percentage between 0 and 100. |
| `max_discount` | `NUMERIC(10,2)` | NN, `chk_coupon_max_discount` | Non-negative currency cap. |
| `valid_from`, `valid_to` | `DATE` | NN, `chk_coupon_dates` | Validity interval; end cannot precede start. |

### bookings

| Column | Type | Constraint | Why |
|---|---|---|---|
| `booking_id` | `INTEGER` | PK, NN | Booking identifier. |
| `booking_ref` | `VARCHAR(20)` | NN, UQ, `chk_booking_ref_format` | Unique public reference; uppercase alphanumeric form. |
| `customer_id` | `INTEGER` | FK → `customers`, NN, `ON DELETE RESTRICT` | Retains customer/booking history. |
| `booking_type` | `VARCHAR(10)` | NN, `chk_booking_type` | FLIGHT or HOTEL product discriminator. |
| `booked_at` | `TIMESTAMPTZ` | NN | Offset-aware booking instant. |
| `total_amount` | `NUMERIC(12,2)` | NN, `chk_booking_amount` | Non-negative total payable. |
| `coupon_code` | `VARCHAR(30)` | NULL, FK → `coupons`, `ON DELETE RESTRICT` | Optional applied coupon; null when no coupon was used. |
| `discount` | `NUMERIC(12,2)` | NN, default 0, `chk_booking_discount`, `chk_booking_coupon_discount` | Discount cannot be negative or exceed total; cannot be nonzero without a coupon. |
| `payment_method` | `VARCHAR(20)` | NN, `chk_booking_payment_method` | Restricts method to CARD, EMI, NETBANKING, UPI or WALLET. |
| `status` | `VARCHAR(20)` | NN, `chk_booking_status` | PENDING_PAYMENT, CONFIRMED, COMPLETED or CANCELLED. |
| `cancelled_at` | `TIMESTAMPTZ` | NULL, `chk_booking_cancellation` | Present exactly for cancelled bookings. |
| `refund_amount` | `NUMERIC(12,2)` | NULL, `chk_booking_refund` | Optional; if present, only on a cancelled booking and no greater than the booking total. |

Coupon deletion is restricted while referenced. Booking deletion cascades to its product-detail row and passengers/reviews, which are dependent records.

### flight_bookings

| Column | Type | Constraint | Why |
|---|---|---|---|
| `booking_id` | `INTEGER` | PK, FK → `bookings`, NN, `ON DELETE CASCADE` | One flight-detail row at most per booking. |
| `flight_id` | `INTEGER` | FK → `flights`, NN, `ON DELETE RESTRICT` | Flight instance booked. |
| `cabin` | `VARCHAR(20)` | NN, `chk_flight_booking_cabin` | BUSINESS, ECONOMY or PREMIUM. |
| `passengers` | `SMALLINT` | NN, `chk_flight_booking_passengers` | Positive declared passenger count. |
| `fare_paid` | `NUMERIC(12,2)` | NN, `chk_flight_booking_fare` | Non-negative fare snapshot for this flight booking. |

### passengers

| Column | Type | Constraint | Why |
|---|---|---|---|
| `booking_id` | `INTEGER` | PK part, FK → `flight_bookings`, NN, `ON DELETE CASCADE` | Passenger belongs to a flight booking. |
| `seq_no` | `SMALLINT` | PK part, NN, `chk_passenger_sequence` | Positive within-booking sequence; composite key allows multiple passengers. |
| `full_name` | `TEXT` | NN | Manifest name. |
| `age` | `SMALLINT` | NN, `chk_passenger_age` | Small non-negative age, capped at 120. |
| `gender` | `VARCHAR(10)` | NN, `chk_passenger_gender` | M, F or X, matching source values. |
| `seat_no` | `VARCHAR(10)` | NULL, `chk_passenger_seat_format` | Nullable until check-in assigns a seat; when set, row number plus seat letter. |

### hotel_bookings

| Column | Type | Constraint | Why |
|---|---|---|---|
| `booking_id` | `INTEGER` | PK, FK → `bookings`, NN, `ON DELETE CASCADE` | One hotel-detail row at most per booking. |
| `hotel_id` | `INTEGER` | FK → `hotels`, NN, `ON DELETE RESTRICT` | Hotel selected; retained directly for the supplied workload. |
| `room_type_id` | `INTEGER` | FK → `room_types`, NN, `ON DELETE RESTRICT` | Selected room type. |
| `check_in`, `check_out` | `DATE` | NN, `chk_hotel_booking_dates` | Stay interval; check-out must be later. |
| `rooms`, `guests` | `INTEGER` | NN, `chk_hotel_booking_rooms`, `chk_hotel_booking_guests` | Positive requested room and guest counts. |
| `room_number` | `VARCHAR(20)` | NULL | Assigned at check-in; blank before assignment. |

### hotel_reviews

| Column | Type | Constraint | Why |
|---|---|---|---|
| `review_id` | `INTEGER` | PK, NN | Review identifier. |
| `booking_id` | `INTEGER` | FK → `hotel_bookings`, NN, `ON DELETE CASCADE` | Review belongs to a hotel stay. |
| `hotel_id` | `INTEGER` | FK → `hotels`, NN, `ON DELETE RESTRICT` | Hotel reviewed; retained for direct hotel-page queries. |
| `rating` | `SMALLINT` | NN, `chk_review_rating` | Integer rating from 1 to 5. |
| `title`, `review_text` | `TEXT` | NULL | Optional headline/body; source permits an empty body. |
| `created_at` | `TIMESTAMPTZ` | NN | Offset-aware review timestamp. |

## Keys, relationships and delete behavior

- `airlines` 1:N `flights`; `airports` 1:N `flights` twice, as origin and destination.
- `hotels` 1:N `room_types`; `hotels` 1:N `hotel_bookings` and 1:N `hotel_reviews`.
- `customers` 1:N `bookings`; `coupons` 1:N `bookings` (each booking uses zero or one coupon).
- A `flight` has many `flight_bookings`; a `booking` has zero or one `flight_bookings` row and zero or one `hotel_bookings` row. The seed data has exactly one matching subtype per booking; cross-table subtype exclusivity is verified after loading because a row-level CHECK cannot enforce it.
- `flight_bookings` 1:N `passengers`; `room_types` 1:N `hotel_bookings`; `hotel_bookings` 1:N `hotel_reviews` in the schema (the seed currently has at most one review per stay).
- Dependent detail rows cascade when their booking is deleted. Master/reference rows (airlines, airports, flights, hotels, room types, coupons, customers) are restricted where history or a live reference remains.

Rendered ER diagram: [PNG](../diagrams/er_diagram.png) · Editable Mermaid source: [er_diagram.mmd](../diagrams/er_diagram.mmd).

## Functional dependencies and normal forms

For each table, the listed determinant(s) are candidate keys; all non-key attributes depend on the whole key and not on another non-key attribute. Therefore each relation is in 3NF and BCNF under the modeled dependencies.

| Table | Functional dependencies / candidate keys |
|---|---|
| `airports` | `iata_code → airport_name, city_name, country_code` |
| `airlines` | `airline_code → airline_name` |
| `flights` | `flight_id → airline_code, flight_no, origin, destination, departure_at, arrival_at, aircraft, total_seats, base_fare, status` |
| `hotels` | `hotel_id → hotel_name, city_name, star_rating, user_rating, amenities, check_in_time, check_out_time` |
| `room_types` | `room_type_id → hotel_id, room_name, max_guests, price_per_night, total_rooms`; `(hotel_id, room_name)` is also a candidate key. |
| `customers` | `customer_id → full_name, email, phone, loyalty_tier, created_at`; `email` and `phone` are separately unique candidate keys as stored. |
| `coupons` | `coupon_code → applies_to, discount_pct, max_discount, valid_from, valid_to` |
| `bookings` | `booking_id → booking_ref, customer_id, booking_type, booked_at, total_amount, coupon_code, discount, payment_method, status, cancelled_at, refund_amount`; `booking_ref` is also a candidate key. |
| `flight_bookings` | `booking_id → flight_id, cabin, passengers, fare_paid` |
| `passengers` | `(booking_id, seq_no) → full_name, age, gender, seat_no` |
| `hotel_bookings` | `booking_id → hotel_id, room_type_id, check_in, check_out, rooms, guests, room_number` |
| `hotel_reviews` | `review_id → booking_id, hotel_id, rating, title, review_text, created_at` |

### Derived or repeated values

- `flight_bookings.passengers` repeats the number of rows in `passengers`. It is retained because the supplied workload uses it for seat/load calculations; the integrity check confirms it matches the passenger rows in this seed.
- `bookings.total_amount`, `bookings.discount` and `flight_bookings.fare_paid` are monetary snapshots at different levels. `fare_paid` is retained as the flight-detail amount; it need not be recalculated from current fares or coupon rules.
- `hotel_bookings.hotel_id` can be inferred from its `room_type_id`, and `hotel_reviews.hotel_id` can be inferred from its `booking_id`. Both are retained because the supplied queries use them directly. The seed has no mismatches; the loader audit checks room-type ownership and review/stay hotel agreement. A future schema could enforce these cross-column equalities with composite unique keys and foreign keys.
- Availability, room-nights, running totals and review averages are query-derived values and are not stored in these base tables.

## NULLs and data findings

The empty CSV fields map to SQL `NULL` as follows; all other columns are populated in this seed.

| Optional field | NULL rows | Meaning |
|---|---:|---|
| `bookings.coupon_code` | 127,144 | Booking used no coupon. |
| `bookings.cancelled_at` | 133,298 | Booking is not cancelled. |
| `bookings.refund_amount` | 133,298 | Booking is not cancelled; every cancelled row in this seed has a refund value. |
| `passengers.seat_no` | 21,612 | Seat not yet assigned. |
| `hotel_bookings.room_number` | 6,815 | Room not assigned yet. |
| `hotels.user_rating` | 134 | Hotel has no user rating. |
| `hotel_reviews.review_text` | 4,812 | Review body omitted; title/rating may still be present. |

The JSON `amenities` values are objects containing boolean flags, not arrays or free-form text. Other checked patterns and values are accepted by the schema. No duplicate customer email/phone, orphaned references, mismatched subtype, inconsistent passenger count, booking-after-departure, room-type/hotel mismatch, or review/stay hotel mismatch was found in the provided seed.

## Load and integrity verification

Validated with PostgreSQL 18.6 in a fresh local scratch database using `psql -v ON_ERROR_STOP=1 -f sql/01_schema.sql`, followed by `psql -v ON_ERROR_STOP=1 -f sql/02_load_data.sql`. All 12 CSVs loaded without constraint errors. The loader's row-count query returned:

| Table | Expected | Loaded |
|---|---:|---:|
| airports | 16 | 16 |
| airlines | 5 | 5 |
| flights | 13,848 | 13,848 |
| hotels | 3,000 | 3,000 |
| room_types | 9,000 | 9,000 |
| customers | 40,000 | 40,000 |
| coupons | 30 | 30 |
| bookings | 144,792 | 144,792 |
| flight_bookings | 84,899 | 84,899 |
| passengers | 163,380 | 163,380 |
| hotel_bookings | 59,893 | 59,893 |
| hotel_reviews | 15,913 | 15,913 |

| Integrity check | Violations |
|---|---:|
| Every booking has exactly one matching product subtype (`booking_type` agrees with the subtype) | 0 |
| `flight_bookings.passengers` equals the number of passenger rows | 0 |
| No flight booking was made after its flight departure | 0 |
| Hotel booking's room type belongs to the selected hotel | 0 |
| Review hotel matches the hotel on its stay booking | 0 |

`sql/01_schema.sql` creates only PK, FK, UNIQUE, NOT NULL and CHECK constraints. PostgreSQL creates 16 indexes automatically from the 12 primary keys and four UNIQUE constraints (room name per hotel, customer email, customer phone and booking reference); no tuning indexes are present at this phase.
