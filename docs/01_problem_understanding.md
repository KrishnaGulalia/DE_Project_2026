# Problem Understanding — MakeMyTrip Travel Booking Database

| Problem | Business need | Affected stakeholder | Workload class |
|---|---|---|---|
| **P1 — Flight search and fares** | Find route/date flights, compare daily fares, and show current seats left while a traveller is choosing a trip. | Traveller | Customer-facing / real-time |
| **P2 — Hotel search and rooms** | Filter hotels by city, rating and amenities, then check room inventory across the requested stay dates. | Traveller | Customer-facing / real-time |
| **P3 — My Trips and lookup** | Retrieve a customer's confirmed trips and let support find a booking quickly by reference; sign-in lookup must also be responsive. | Traveller; customer support | Customer-facing / real-time |
| **P4 — Airline operations** | Supply passenger manifests and low-load flight information for operations; report cancellation rates to airline partners. | Airline partner | Mixed: real-time partner tools (manifest/load) and reporting / analytics (cancellation rate) |
| **P5 — Checkout and payments** | Create bookings, process pending-payment confirmations, and record cancellations/refunds reliably under checkout load. | Payments team; traveller | Customer-facing / real-time |
| **P6 — Coupon usage** | Identify coupons that have never appeared on a booking so marketing can assess campaign adoption. | Marketing | Reporting / analytics |
| **P7 — Hotel operations and performance** | Summarize room-nights by city for partners and assign rooms promptly at check-in. | Hotel partner; front desk | Mixed: reporting / analytics (room-nights) and real-time partner operations (check-in) |
| **P8 — Business insight and growth** | Produce revenue, route, lead-time, repeat-customer, concession and last-minute-booking views while the booking volume grows. | Finance; revenue management; loyalty team | Reporting / analytics |

## Assumptions

- A booking has one product type: flight or hotel; its detail row is stored in the matching subtype table.
- “Seats left” and “rooms left” are derived from inventory less non-cancelled bookings; availability is therefore a live transactional concern.
- The requested performance class follows the operation's use: manifests, checkout and check-in are time-sensitive, while trend, finance, loyalty and campaign summaries are analytical. P4 and P7 include both kinds of work.
