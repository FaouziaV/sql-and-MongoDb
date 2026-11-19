# Set 2 – Airline Seat Booking: Observed Behaviour Notes

## Atomic booking
The SQL Server booking transaction conditionally changes the seat from AVAILABLE to BOOKED and inserts a booking row in the same transaction. If the seat update affects zero rows, or the booking insert fails, the transaction rolls back. This prevents a seat status change without a corresponding booking record.

## Two sessions: READ COMMITTED
Run Session A first. It conditionally marks seat 12C as booked and holds its transaction open for 10 seconds. Start Session B during that delay. B waits for A's write lock. When A commits, B resumes; its conditional update finds no AVAILABLE row, so B reports the seat as already booked. Only one booking should be committed.

## Two sessions: SERIALIZABLE
Reset seat 12C and its booking before repeating the test. SERIALIZABLE uses stricter locking and retains locks/range locks to protect the rows and key ranges accessed until the transaction ends. Conflicting work can block. The conditional update and unique constraint still ensure that only one booking can commit for the same flight-seat pair. Depending on the exact timing and lock pattern, the losing session may wait and then fail its availability check; a deadlock is possible in more complex lock patterns but is not guaranteed by this simple test.

## RANK vs DENSE_RANK
Both functions assign the same rank to passengers with equal fares. RANK leaves gaps after ties, while DENSE_RANK does not.
Example fares 5500, 5500, 4200:
- RANK: 1, 1, 3
- DENSE_RANK: 1, 1, 2

## Running revenue
The CTE report uses SUM(Fare) OVER (PARTITION BY FlightID ORDER BY BookingID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) to calculate a running total of revenue for each flight as bookings are ordered by BookingID.


## MongoDB transaction
The Mongosh script starts a session and transaction, conditionally updates the seat from AVAILABLE to BOOKED, inserts the booking document, and commits both changes. If an operation fails, abortTransaction() rolls both changes back. MongoDB transactions require a replica set or sharded cluster; a standalone MongoDB server does not support multi-document transactions.
