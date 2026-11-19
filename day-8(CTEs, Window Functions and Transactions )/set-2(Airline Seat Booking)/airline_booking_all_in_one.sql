CREATE DATABASE AirlineDB;

USE AirlineDB;

/* 1. Create tables */
CREATE TABLE Flights (
    FlightID INT PRIMARY KEY,
    FlightNo VARCHAR(10) NOT NULL,
    FlightDate DATE NOT NULL
);


CREATE TABLE Seats (
    FlightID INT NOT NULL,
    SeatNo VARCHAR(5) NOT NULL,
    SeatStatus VARCHAR(15) NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT PK_Seats PRIMARY KEY (FlightID, SeatNo),
    CONSTRAINT FK_Seats_Flights FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    CONSTRAINT CK_Seats_Status CHECK (SeatStatus IN ('AVAILABLE', 'BOOKED'))
);


CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    FlightID INT NOT NULL,
    SeatNo VARCHAR(5) NOT NULL,
    PassengerName VARCHAR(100) NOT NULL,
    Fare DECIMAL(10,2) NOT NULL,
    BookingDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Bookings_Seats FOREIGN KEY (FlightID, SeatNo)
        REFERENCES Seats(FlightID, SeatNo),
    CONSTRAINT CK_Bookings_Fare CHECK (Fare >= 0),
    CONSTRAINT UQ_Bookings_Flight_Seat UNIQUE (FlightID, SeatNo)
);


/* 2. Sample data */
INSERT INTO Flights (FlightID, FlightNo, FlightDate)
VALUES (1, 'AI101', '2026-12-01'),
       (2, 'AI202', '2026-12-02');


INSERT INTO Seats (FlightID, SeatNo, SeatStatus)
VALUES (1, '12A', 'AVAILABLE'),
       (1, '12B', 'AVAILABLE'),
       (1, '12C', 'AVAILABLE'),
       (1, '13A', 'AVAILABLE'),
       (2, '10A', 'AVAILABLE'),
       (2, '10B', 'AVAILABLE');


/* 3. Atomic booking transaction. Change passenger/flight/seat/fare as needed. */
DECLARE @FlightID INT = 1;
DECLARE @SeatNo VARCHAR(5) = '12A';
DECLARE @PassengerName VARCHAR(100) = 'Asha Kumar';
DECLARE @Fare DECIMAL(10,2) = 5500.00;

BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE Seats WITH (UPDLOCK, HOLDLOCK)
    SET SeatStatus = 'BOOKED'
    WHERE FlightID = @FlightID
      AND SeatNo = @SeatNo
      AND SeatStatus = 'AVAILABLE';

    IF @@ROWCOUNT = 0
        THROW 50001, 'Seat is unavailable or does not exist.', 1;


    INSERT INTO Bookings (FlightID, SeatNo, PassengerName, Fare)
    VALUES (@FlightID, @SeatNo, @PassengerName, @Fare);


    COMMIT TRANSACTION;
    PRINT 'Booking completed successfully.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Booking failed. Transaction rolled back.';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;


/* 4. Deliberate failure example (uses seat 12B).
   The seat update is undone when the error occurs after it. */
DECLARE @FailFlightID INT = 1;
DECLARE @FailSeatNo VARCHAR(5) = '12B';

SELECT 'Before deliberate failure' AS CheckPoint, FlightID, SeatNo, SeatStatus
FROM Seats WHERE FlightID = @FailFlightID AND SeatNo = @FailSeatNo;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Seats WITH (UPDLOCK, HOLDLOCK)
    SET SeatStatus = 'BOOKED'
    WHERE FlightID = @FailFlightID
      AND SeatNo = @FailSeatNo
      AND SeatStatus = 'AVAILABLE';

    IF @@ROWCOUNT = 0
        THROW 50002, 'Seat is not available for rollback demo.', 1;

    THROW 50003, 'DEMO ERROR: forced failure after seat update.', 1;

    COMMIT TRANSACTION; 
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Expected failure occurred; rollback completed.';
    PRINT ERROR_MESSAGE();
END CATCH;


SELECT 'After deliberate failure (status should still be AVAILABLE)' AS CheckPoint,
       FlightID, SeatNo, SeatStatus
FROM Seats WHERE FlightID = @FailFlightID AND SeatNo = @FailSeatNo;


/* 7. Verify bookings and seat status */
SELECT f.FlightNo, f.FlightDate, s.SeatNo, s.SeatStatus,
       b.PassengerName, b.Fare, b.BookingDate
FROM Flights f
JOIN Seats s ON s.FlightID = f.FlightID
LEFT JOIN Bookings b ON b.FlightID = s.FlightID AND b.SeatNo = s.SeatNo
ORDER BY f.FlightNo, s.SeatNo;

/* TASK 3 & 4 - FARE RANKING AND RUNNING REVENUE REPORT */
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Seats SET SeatStatus='BOOKED'
    WHERE FlightID=1 AND SeatNo IN ('12B','12C','13A') AND SeatStatus='AVAILABLE';

    INSERT INTO Bookings (FlightID, SeatNo, PassengerName, Fare)
    SELECT 1, v.SeatNo, v.PassengerName, v.Fare
    FROM (VALUES
        ('12B','Ravi',5500.00),
        ('12C','Meena',5500.00),
        ('13A','Kiran',4200.00)
    ) v(SeatNo,PassengerName,Fare)
    WHERE NOT EXISTS (
        SELECT 1 FROM Bookings b WHERE b.FlightID=1 AND b.SeatNo=v.SeatNo
    );

    UPDATE Seats SET SeatStatus='BOOKED'
    WHERE FlightID=2 AND SeatNo IN ('10A','10B') AND SeatStatus='AVAILABLE';

    INSERT INTO Bookings (FlightID, SeatNo, PassengerName, Fare)
    SELECT 2, v.SeatNo, v.PassengerName, v.Fare
    FROM (VALUES
        ('10A','Priya',7000.00),
        ('10B','Arun',6500.00)
    ) v(SeatNo,PassengerName,Fare)
    WHERE NOT EXISTS (
        SELECT 1 FROM Bookings b WHERE b.FlightID=2 AND b.SeatNo=v.SeatNo
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;


/* Task 3: RANK and DENSE_RANK by fare per flight.*/

SELECT
    FlightID,
    PassengerName,
    Fare,
    RANK() OVER (PARTITION BY FlightID ORDER BY Fare DESC) AS FareRank,
    DENSE_RANK() OVER (PARTITION BY FlightID ORDER BY Fare DESC) AS DenseFareRank
FROM Bookings
ORDER BY FlightID, Fare DESC, PassengerName;


/* Task 4: CTE with ranking and running revenue total per flight.
   Running total uses booking order (BookingID) for a deterministic sequence. */
WITH FlightFareReport AS
(
    SELECT
        BookingID,
        FlightID,
        PassengerName,
        Fare,
        BookingDate,
        RANK() OVER (PARTITION BY FlightID ORDER BY Fare DESC) AS FareRank,
        DENSE_RANK() OVER (PARTITION BY FlightID ORDER BY Fare DESC) AS DenseFareRank
    FROM Bookings
)
SELECT
    BookingID,
    FlightID,
    PassengerName,
    Fare,
    FareRank,
    DenseFareRank,
    SUM(Fare) OVER (
        PARTITION BY FlightID
        ORDER BY BookingID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningRevenue
FROM FlightFareReport
ORDER BY FlightID, BookingID;
