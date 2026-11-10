# Data Dictionary

This document describes the tables, columns, data types, constraints,
and purpose of each attribute in the MakeMyTrip Travel Booking Database.

## 1. Airports

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `iata_code` | CHAR(3) | PK, NOT NULL, CHECK | Unique three-letter airport identifier |
| `airport_name` | TEXT | NOT NULL | Name of the airport |
| `city_name` | TEXT | NOT NULL | City where the airport is located |
| `country_code` | CHAR(2) | NOT NULL, CHECK | Two-letter country identifier |

## 2. Airlines

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `airline_code` | VARCHAR(3) | PK, NOT NULL, CHECK | Unique airline identifier |
| `airline_name` | TEXT | NOT NULL | Name of the airline |

## 3. Hotels

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `hotel_id` | INTEGER | PK | Unique hotel identifier |
| `hotel_name` | TEXT | NOT NULL | Name of the hotel |
| `city_name` | TEXT | NOT NULL | City where the hotel is located |
| `star_rating` | SMALLINT | NOT NULL, CHECK | Hotel star classification from 1 to 5 |
| `user_rating` | NUMERIC(2,1) | CHECK | User rating from 0 to 5; may be NULL |
| `amenities` | JSONB | NOT NULL | Structured hotel amenities |
| `check_in_time` | TIME | NOT NULL | Standard hotel check-in time |
| `check_out_time` | TIME | NOT NULL | Standard hotel check-out time |

## 4. Room Types

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `room_type_id` | INTEGER | PK | Unique room-type identifier |
| `hotel_id` | INTEGER | NOT NULL, FK | Hotel to which the room type belongs |
| `room_name` | TEXT | NOT NULL | Name/type of the room |
| `max_guests` | SMALLINT | NOT NULL, CHECK | Maximum guests supported |
| `price_per_night` | NUMERIC(10,2) | NOT NULL, CHECK | Price charged per night |
| `total_rooms` | INTEGER | NOT NULL, CHECK | Number of rooms of this type |


## 5. Customers

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `customer_id` | INTEGER | PK | Unique customer identifier |
| `full_name` | TEXT | NOT NULL | Customer's full name |
| `email` | TEXT | NOT NULL, UNIQUE, CHECK | Customer email address |
| `phone` | VARCHAR(20) | NOT NULL, UNIQUE, CHECK | Customer phone number |
| `loyalty_tier` | VARCHAR(20) | NOT NULL, CHECK | Customer loyalty membership tier |
| `created_at` | TIMESTAMPTZ | NOT NULL | Time when the customer account was created |

## 6. Flights

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `flight_id` | INTEGER | PK | Unique flight instance identifier |
| `airline_code` | VARCHAR(3) | NOT NULL, FK | Airline operating the flight |
| `flight_no` | VARCHAR(20) | NOT NULL | Flight number |
| `origin` | CHAR(3) | NOT NULL, FK | Departure airport |
| `destination` | CHAR(3) | NOT NULL, FK | Arrival airport |
| `departure_at` | TIMESTAMPTZ | NOT NULL | Scheduled departure time |
| `arrival_at` | TIMESTAMPTZ | NOT NULL, CHECK | Scheduled arrival time |
| `aircraft` | VARCHAR(50) | NOT NULL | Aircraft used for the flight |
| `total_seats` | INTEGER | NOT NULL, CHECK | Total available seats |
| `base_fare` | NUMERIC(10,2) | NOT NULL, CHECK | Base fare for the flight |
| `status` | VARCHAR(20) | NOT NULL, CHECK | Current flight status |

## 7. Coupons

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `coupon_code` | VARCHAR(30) | PK | Unique coupon identifier |
| `applies_to` | VARCHAR(10) | NOT NULL, CHECK | Indicates whether coupon applies to flight, hotel, or all bookings |
| `discount_pct` | NUMERIC(5,2) | NOT NULL, CHECK | Percentage discount offered |
| `max_discount` | NUMERIC(10,2) | NOT NULL, CHECK | Maximum discount amount |
| `valid_from` | DATE | NOT NULL | Start date of coupon validity |
| `valid_to` | DATE | NOT NULL, CHECK | End date of coupon validity |

## 8. Bookings

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `booking_id` | INTEGER | PK | Unique booking identifier |
| `booking_ref` | VARCHAR(20) | NOT NULL, UNIQUE | Human-readable booking reference |
| `customer_id` | INTEGER | NOT NULL, FK | Customer who made the booking |
| `booking_type` | VARCHAR(10) | NOT NULL, CHECK | Indicates flight or hotel booking |
| `booked_at` | TIMESTAMPTZ | NOT NULL | Time when booking was created |
| `total_amount` | NUMERIC(12,2) | NOT NULL, CHECK | Total booking amount |
| `coupon_code` | VARCHAR(30) | FK | Coupon applied to the booking, if any |
| `discount` | NUMERIC(12,2) | NOT NULL, CHECK | Discount amount applied |
| `payment_method` | VARCHAR(20) | NOT NULL, CHECK | Method used for payment |
| `status` | VARCHAR(20) | NOT NULL, CHECK | Current booking status |
| `cancelled_at` | TIMESTAMPTZ | — | Time when booking was cancelled |
| `refund_amount` | NUMERIC(12,2) | — | Refund amount associated with cancellation |

## 9. Flight Bookings

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `booking_id` | INTEGER | PK, FK | Links the flight booking to the main booking |
| `flight_id` | INTEGER | NOT NULL, FK | Flight selected for the booking |
| `cabin` | VARCHAR(20) | NOT NULL, CHECK | Cabin class selected |
| `passengers` | SMALLINT | NOT NULL, CHECK | Number of passengers in the flight booking |
| `fare_paid` | NUMERIC(12,2) | NOT NULL, CHECK | Fare amount paid for the flight booking |

## 10. Passengers

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `booking_id` | INTEGER | PK, FK | Identifies the flight booking |
| `seq_no` | SMALLINT | PK, CHECK | Sequential passenger number within a booking |
| `full_name` | TEXT | NOT NULL | Passenger's full name |
| `age` | SMALLINT | NOT NULL, CHECK | Passenger's age |
| `gender` | VARCHAR(10) | NOT NULL, CHECK | Passenger's gender |
| `seat_no` | VARCHAR(10) | — | Assigned seat number, if available |

The primary key is the composite key `(booking_id, seq_no)`.

## 11. Hotel Bookings

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `booking_id` | INTEGER | PK, FK | Links the hotel booking to the main booking |
| `hotel_id` | INTEGER | NOT NULL, FK | Hotel selected for the booking |
| `room_type_id` | INTEGER | NOT NULL, FK | Room type selected |
| `check_in` | DATE | NOT NULL | Hotel check-in date |
| `check_out` | DATE | NOT NULL, CHECK | Hotel check-out date |
| `rooms` | INTEGER | NOT NULL, CHECK | Number of rooms booked |
| `guests` | INTEGER | NOT NULL, CHECK | Number of guests |
| `room_number` | VARCHAR(20) | — | Assigned room number, if available |

## 12. Hotel Reviews

| Column | Data Type | Constraints | Purpose |
|---|---|---|---|
| `review_id` | INTEGER | PK | Unique review identifier |
| `booking_id` | INTEGER | NOT NULL, FK | Hotel booking associated with the review |
| `hotel_id` | INTEGER | NOT NULL, FK | Hotel being reviewed |
| `rating` | SMALLINT | NOT NULL, CHECK | Review rating from 1 to 5 |
| `title` | TEXT | — | Optional review title |
| `review_text` | TEXT | — | Optional review content |
| `created_at` | TIMESTAMPTZ | NOT NULL | Time when the review was created |

