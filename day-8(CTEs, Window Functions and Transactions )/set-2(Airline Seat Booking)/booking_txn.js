db = db.getSiblingDB("AirlineDB");

db.flights.updateOne(
    { flightId: "FL101" },
    {
        $setOnInsert: {
            flightId: "FL101",
            flightName: "Coimbatore to Chennai",
            status: "ACTIVE"
        }
    },
    { upsert: true }
);

// 3. Create sample seats 
db.seats.updateOne(
    { flightId: "FL101", seatNo: "12A" },
    {
        $setOnInsert: {
            flightId: "FL101",
            seatNo: "12A",
            status: "AVAILABLE"
        }
    },
    { upsert: true }
);

db.seats.updateOne(
    { flightId: "FL101", seatNo: "12B" },
    {
        $setOnInsert: {
            flightId: "FL101",
            seatNo: "12B",
            status: "AVAILABLE"
        }
    },
    { upsert: true }
);

// 4. Display seat status before booking
print("===== SEAT STATUS BEFORE BOOKING =====");

db.seats.find(
    { flightId: "FL101" },
    { _id: 0, flightId: 1, seatNo: 1, status: 1 }
).forEach(printjson);



// 5. START TRANSACTION

const session = db.getMongo().startSession();
const sessionDB = session.getDatabase("AirlineDB");

session.startTransaction();

try {
    const flightId = "FL101";
    const seatNo = "12A";
    const passengerName = "Faouzia";
    const bookingId = "BK1001";

    // 6. Check flight
    const flight = sessionDB.flights.findOne({
        flightId: flightId,
        status: "ACTIVE"
    });

    if (flight == null) {
        throw new Error("Flight not found or inactive");
    }

    // 7. Check seat availability
    const seat = sessionDB.seats.findOne({
        flightId: flightId,
        seatNo: seatNo,
        status: "AVAILABLE"
    });

    if (seat == null) {
        throw new Error("Seat is already booked or unavailable");
    }

    // 8. Update seat status
    const seatUpdate = sessionDB.seats.updateOne(
        {
            flightId: flightId,
            seatNo: seatNo,
            status: "AVAILABLE"
        },
        {
            $set: {
                status: "BOOKED"
            }
        }
    );

    if (seatUpdate.modifiedCount !== 1) {
        throw new Error("Seat reservation failed");
    }

    // 9. Insert booking record
    sessionDB.bookings.insertOne({
        bookingId: bookingId,
        flightId: flightId,
        seatNo: seatNo,
        passengerName: passengerName,
        bookingDate: new Date(),
        status: "CONFIRMED"
    });

    // 10. Commit transaction
    session.commitTransaction();

    print("=================================");
    print("BOOKING SUCCESSFUL!");
    print("Passenger: " + passengerName);
    print("Flight: " + flightId);
    print("Seat: " + seatNo);
    print("=================================");

} catch (error) {

    // 11. Roll back if any operation fails
    session.abortTransaction();

    print("=================================");
    print("BOOKING FAILED!");
    print("Error: " + error.message);
    print("Transaction rolled back.");
    print("=================================");

} finally {
    session.endSession();
}


// 12. VERIFY FINAL SEAT STATUS

print("===== SEAT STATUS AFTER BOOKING =====");

db.seats.find(
    { flightId: "FL101" },
    { _id: 0, flightId: 1, seatNo: 1, status: 1 }
).forEach(printjson);


// 13. DISPLAY BOOKINGS

print("===== BOOKING RECORDS =====");

db.bookings.find(
    { flightId: "FL101" },
    { _id: 0 }
).forEach(printjson);