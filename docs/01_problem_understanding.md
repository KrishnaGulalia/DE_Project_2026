# Problem Understanding — MakeMyTrip Travel Booking Database

## P1 — Flight Search, Fare Calendar and Seat Availability
- **Business need:** Users need to search for flights, compare fares across dates, and see available seats while planning a trip.
- **Affected stakeholder:** Travellers/customers.
- **Type:** Customer-facing / real-time.
- **Assumptions:** Flight, route, fare, schedule, and seat-availability information is stored and can be queried using the booking and flight data.

## P2 — Hotel Search and Room Availability
- **Business need:** Users need to search for hotels and determine which rooms are available for their selected stay.
- **Affected stakeholder:** Travellers/customers.
- **Type:** Customer-facing / real-time.
- **Assumptions:** Hotel, room type, room inventory, booking, check-in, and check-out information is available in the database.

## P3 — My Trips and Booking Lookup
- **Business need:** Users need to view their existing bookings and retrieve trip-related information after signing in.
- **Affected stakeholder:** Travellers/customers.
- **Type:** Customer-facing / real-time.
- **Assumptions:** Each booking can be associated with a customer and the relevant flight or hotel booking details.

## P4 — Airline Manifests, Load and Cancellations
- **Business need:** Airlines need booking and passenger information to prepare manifests, understand flight load, and handle cancellations.
- **Affected stakeholder:** Airline/operations staff.
- **Type:** Customer-facing / real-time.
- **Assumptions:** Passenger, booking, flight-booking, flight, and cancellation-related information can be connected through the database.

## P5 — Checkout, Payments and Cancellations
- **Business need:** The system needs to support booking checkout and maintain payment and cancellation-related information.
- **Affected stakeholder:** Travellers/customers and booking/payment operations staff.
- **Type:** Customer-facing / real-time.
- **Assumptions:** Booking records contain the information required to identify transactions and their associated booking status.

## P6 — Coupon Usage Reporting
- **Business need:** The business needs to understand coupon usage and its impact across bookings.
- **Affected stakeholder:** Business/marketing teams.
- **Type:** Reporting / analytics.
- **Assumptions:** Coupon information can be associated with bookings so that usage can be aggregated and analyzed.

## P7 — Hotel Room-Nights and Check-In Analysis
- **Business need:** The business needs to analyze hotel room usage and check-in activity.
- **Affected stakeholder:** Hotel/operations and business teams.
- **Type:** Reporting / analytics.
- **Assumptions:** Hotel booking records contain the information required to determine stays, room usage, and check-in activity.

## P8 — Finance, Loyalty and Business Insights
- **Business need:** The business needs consolidated booking and customer information for financial, loyalty, and other business insights.
- **Affected stakeholder:** Finance, business and loyalty teams.
- **Type:** Reporting / analytics.
- **Assumptions:** Booking, customer, payment, coupon and related transactional data can be combined for analysis.