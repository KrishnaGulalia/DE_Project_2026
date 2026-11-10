# Normalization Analysis

## 1. Airports

### Attributes

- `iata_code`
- `airport_name`
- `city_name`
- `country_code`

### Primary Key

`iata_code`

### Functional Dependency

```text
iata_code → airport_name, city_name, country_code


## 2. Airlines

### Attributes

- `airline_code`
- `airline_name`

### Primary Key

`airline_code`

### Functional Dependency

```text
airline_code → airline_name

## 3. Hotels

### Attributes

- `hotel_id`
- `hotel_name`
- `city_name`
- `star_rating`
- `user_rating`
- `amenities`
- `check_in_time`
- `check_out_time`

### Primary Key

`hotel_id`

### Functional Dependency

```text
hotel_id → hotel_name, city_name, star_rating, user_rating,
           amenities, check_in_time, check_out_time

## 4. Room Types

### Attributes

- `room_type_id`
- `hotel_id`
- `room_name`
- `max_guests`
- `price_per_night`
- `total_rooms`

### Primary Key

`room_type_id`

### Alternate Candidate Key

`(hotel_id, room_name)`

The schema defines `UNIQUE (hotel_id, room_name)`, meaning that a room name
must be unique within a particular hotel.

### Functional Dependencies

```text
room_type_id → hotel_id, room_name, max_guests,
               price_per_night, total_rooms

(hotel_id, room_name) → room_type_id, max_guests,
                        price_per_night, total_rooms


## 5. Customers

### Attributes

- `customer_id`
- `full_name`
- `email`
- `phone`
- `loyalty_tier`
- `created_at`

### Primary Key

`customer_id`

### Alternate Candidate Keys

- `email`
- `phone`

Both `email` and `phone` have `UNIQUE` constraints in the schema.

### Functional Dependencies

```text
customer_id → full_name, email, phone, loyalty_tier, created_at

email → customer_id, full_name, phone, loyalty_tier, created_at

phone → customer_id, full_name, email, loyalty_tier, created_at


## 6. Flights

### Attributes

- `flight_id`
- `airline_code`
- `flight_no`
- `origin`
- `destination`
- `departure_at`
- `arrival_at`
- `aircraft`
- `total_seats`
- `base_fare`
- `status`

### Primary Key

`flight_id`

### Functional Dependency

```text
flight_id → airline_code, flight_no, origin, destination,
            departure_at, arrival_at, aircraft, total_seats,
            base_fare, status

## 7. Coupons

### Attributes

- `coupon_code`
- `applies_to`
- `discount_pct`
- `max_discount`
- `valid_from`
- `valid_to`

### Primary Key

`coupon_code`

### Functional Dependency

```text
coupon_code → applies_to, discount_pct, max_discount,
              valid_from, valid_to

## 8. Bookings

### Attributes

- `booking_id`
- `booking_ref`
- `customer_id`
- `booking_type`
- `booked_at`
- `total_amount`
- `coupon_code`
- `discount`
- `payment_method`
- `status`
- `cancelled_at`
- `refund_amount`

### Primary Key

`booking_id`

### Alternate Candidate Key

`booking_ref`

The schema defines `booking_ref` as `UNIQUE`, so it can uniquely identify
a booking.

### Functional Dependencies

```text
booking_id → booking_ref, customer_id, booking_type, booked_at,
             total_amount, coupon_code, discount, payment_method,
             status, cancelled_at, refund_amount

booking_ref → booking_id, customer_id, booking_type, booked_at,
              total_amount, coupon_code, discount, payment_method,
              status, cancelled_at, refund_amount


## 9. Flight Bookings

### Attributes

- `booking_id`
- `flight_id`
- `cabin`
- `passengers`
- `fare_paid`

### Primary Key

`booking_id`

### Functional Dependency

```text
booking_id → flight_id, cabin, passengers, fare_paid

## 10. Passengers

### Attributes

- `booking_id`
- `seq_no`
- `full_name`
- `age`
- `gender`
- `seat_no`

### Primary Key

Composite key:

```text
(booking_id, seq_no)

11. Hotel Bookings

### Attributes

- `booking_id`
- `hotel_id`
- `room_type_id`
- `check_in`
- `check_out`
- `rooms`
- `guests`
- `room_number`

### Primary Key

`booking_id`

### Functional Dependencies

```text
booking_id → hotel_id, room_type_id, check_in, check_out,
             rooms, guests, room_number

## 12. Hotel Reviews

### Attributes

- `review_id`
- `booking_id`
- `hotel_id`
- `rating`
- `title`
- `review_text`
- `created_at`

### Primary Key

`review_id`

### Functional Dependencies

```text
review_id → booking_id, hotel_id, rating, title,
            review_text, created_at

                     
