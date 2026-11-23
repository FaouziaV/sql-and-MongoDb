
CREATE DATABASE TelecomLowBalance;
GO
USE TelecomLowBalance;
GO

-- 1. TABLES
CREATE TABLE Plans
(
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    PlanName VARCHAR(100) NOT NULL,
    MinimumRecharge DECIMAL(10,2) NOT NULL CHECK (MinimumRecharge > 0),
    ValidityDays INT NOT NULL CHECK (ValidityDays > 0),
    IsActive BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Subscribers
(
    SubscriberID INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    SubscriberType VARCHAR(20) NOT NULL CHECK (SubscriberType IN ('Prepaid','Postpaid')),
    Balance DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (Balance >= 0),
    PlanID INT REFERENCES Plans(PlanID),
    ValidityEndDate DATE
);
GO

CREATE TABLE RechargeHistory
(
    RechargeID INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberID INT NOT NULL REFERENCES Subscribers(SubscriberID),
    PlanID INT NOT NULL REFERENCES Plans(PlanID),
    RechargeAmount DECIMAL(10,2) NOT NULL CHECK (RechargeAmount > 0),
    RechargeDate DATETIME NOT NULL DEFAULT GETDATE(),
    BalanceAfterRecharge DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE NotificationLog
(
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberID INT NOT NULL REFERENCES Subscribers(SubscriberID),
    NotificationMessage VARCHAR(250) NOT NULL,
    NotificationDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0
);
GO

-- 2. SAMPLE DATA
INSERT INTO Plans (PlanName, MinimumRecharge, ValidityDays, IsActive)
VALUES ('Basic 28 Days', 100, 28, 1),
       ('Value 56 Days', 200, 56, 1),
       ('Inactive Plan', 50, 14, 0);
GO

INSERT INTO Subscribers (SubscriberName, PhoneNumber, SubscriberType, Balance, PlanID, ValidityEndDate)
VALUES ('Arun Kumar', '9876500001', 'Prepaid', 35, 1, DATEADD(DAY, 12, GETDATE())),
       ('Priya S', '9876500002', 'Prepaid', 120, 1, DATEADD(DAY, 20, GETDATE())),
       ('Rahul M', '9876500003', 'Prepaid', 15, 2, DATEADD(DAY, -2, GETDATE())),
       ('Divya R', '9876500004', 'Postpaid', 80, 1, DATEADD(DAY, 25, GETDATE())),
       ('Kiran P', '9876500005', 'Prepaid', 48, 2, DATEADD(DAY, 5, GETDATE()));
GO
INSERT INTO RechargeHistory (SubscriberID, PlanID, RechargeAmount, RechargeDate, BalanceAfterRecharge)
VALUES (1,1,100,DATEADD(DAY,-10,GETDATE()),135),
       (1,1,50,DATEADD(DAY,-4,GETDATE()),85),
       (2,1,200,DATEADD(DAY,-8,GETDATE()),320),
       (3,2,200,DATEADD(DAY,-15,GETDATE()),215),
       (5,2,200,DATEADD(DAY,-3,GETDATE()),248);
GO

-- 3. VIEWS
-- Prepaid-only view: postpaid subscribers are hidden
CREATE VIEW vw_prepaid_subscribers
AS
SELECT SubscriberID, SubscriberName, PhoneNumber, Balance, PlanID, ValidityEndDate
FROM Subscribers
WHERE SubscriberType = 'Prepaid';
GO

-- Recharge summary per subscriber (no sensitive columns)
CREATE VIEW vw_recharge_summary
AS
SELECT s.SubscriberID, s.SubscriberName, COUNT(r.RechargeID) AS RechargeCount,
       ISNULL(SUM(r.RechargeAmount), 0) AS TotalRecharged,
       MAX(r.RechargeDate) AS LastRechargeDate
FROM Subscribers s
LEFT JOIN RechargeHistory r ON s.SubscriberID = r.SubscriberID
GROUP BY s.SubscriberID, s.SubscriberName;
GO
SELECT * FROM vw_prepaid_subscribers;
SELECT * FROM vw_recharge_summary;
GO

-- 4. STORED PROCEDURE: RECHARGE (returns updated balance via OUTPUT)
CREATE PROCEDURE usp_Recharge
    @SubscriberID INT,
    @PlanID INT,
    @Amount DECIMAL(10,2),
    @NewBalance DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Amount <= 0
            THROW 50001, 'Recharge amount must be greater than zero.', 1;

        IF NOT EXISTS (SELECT 1 FROM Subscribers WHERE SubscriberID = @SubscriberID AND SubscriberType = 'Prepaid')
            THROW 50002, 'Subscriber not found or is not prepaid.', 1;

        IF NOT EXISTS (SELECT 1 FROM Plans WHERE PlanID = @PlanID AND IsActive = 1)
            THROW 50003, 'Plan is invalid or inactive.', 1;

        IF @Amount < (SELECT MinimumRecharge FROM Plans WHERE PlanID = @PlanID)
            THROW 50004, 'Recharge amount is below the plan minimum.', 1;

        UPDATE Subscribers
        SET Balance = Balance + @Amount,
            PlanID = @PlanID,
            ValidityEndDate = CASE
                WHEN ValidityEndDate IS NULL OR ValidityEndDate < CAST(GETDATE() AS DATE)
                    THEN DATEADD(DAY, (SELECT ValidityDays FROM Plans WHERE PlanID = @PlanID), CAST(GETDATE() AS DATE))
                ELSE DATEADD(DAY, (SELECT ValidityDays FROM Plans WHERE PlanID = @PlanID), ValidityEndDate)
            END
        WHERE SubscriberID = @SubscriberID;

        SELECT @NewBalance = Balance FROM Subscribers WHERE SubscriberID = @SubscriberID;

        INSERT INTO RechargeHistory (SubscriberID, PlanID, RechargeAmount, BalanceAfterRecharge)
        VALUES (@SubscriberID, @PlanID, @Amount, @NewBalance);


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


-- 5. SCALAR FUNCTION: DAYS OF VALIDITY LEFT
CREATE FUNCTION fn_ValidityDaysLeft (@SubscriberID INT)
RETURNS INT
AS
BEGIN
    DECLARE @DaysLeft INT;
    SELECT @DaysLeft = DATEDIFF(DAY, CAST(GETDATE() AS DATE), ValidityEndDate)
    FROM Subscribers WHERE SubscriberID = @SubscriberID;
    RETURN ISNULL(@DaysLeft, 0);
END;
GO
SELECT dbo.fn_ValidityDaysLeft(1) AS ValidityDaysLeft;
GO

-- 6. TABLE-VALUED FUNCTION: SUBSCRIBER'S LAST FIVE RECHARGES
CREATE FUNCTION fn_LastFiveRecharges (@SubscriberID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 5 RechargeID, SubscriberID, PlanID, RechargeAmount, RechargeDate, BalanceAfterRecharge
    FROM RechargeHistory
    WHERE SubscriberID = @SubscriberID
    ORDER BY RechargeDate DESC, RechargeID DESC
);
GO
SELECT * FROM dbo.fn_LastFiveRecharges(1);
GO

-- 7. CURSOR PROCEDURE: CREATE LOW-BALANCE NOTIFICATIONS
CREATE PROCEDURE usp_LowBalanceNotifications_Cursor
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SubscriberID INT;
    DECLARE LowBalanceCursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT SubscriberID FROM Subscribers
        WHERE SubscriberType = 'Prepaid' AND Balance < 50;
    OPEN LowBalanceCursor;
    FETCH NEXT FROM LowBalanceCursor INTO @SubscriberID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO NotificationLog (SubscriberID, NotificationMessage)
        VALUES (@SubscriberID, 'Your prepaid balance is below 50. Please recharge.');
        FETCH NEXT FROM LowBalanceCursor INTO @SubscriberID;
    END;
    CLOSE LowBalanceCursor;
    DEALLOCATE LowBalanceCursor;
END;
GO

-- 8. SET-BASED VERSION (single INSERT...SELECT)
CREATE PROCEDURE usp_LowBalanceNotifications_SetBased
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO NotificationLog (SubscriberID, NotificationMessage)
    SELECT SubscriberID, 'Your prepaid balance is below 50. Please recharge.'
    FROM Subscribers
    WHERE SubscriberType = 'Prepaid' AND Balance < 50;
END;
GO

-- 9. TEST BOTH METHODS AND MEASURE ELAPSED TIME
-- Cursor timing
DECLARE @CursorStart DATETIME2 = SYSDATETIME();
EXEC usp_LowBalanceNotifications_Cursor;
DECLARE @CursorMs INT = DATEDIFF(MILLISECOND, @CursorStart, SYSDATETIME());
SELECT 'Cursor' AS Method, @CursorMs AS ElapsedMilliseconds;
GO
-- Set-based timing
DECLARE @SetStart DATETIME2 = SYSDATETIME();
EXEC usp_LowBalanceNotifications_SetBased;
DECLARE @SetMs INT = DATEDIFF(MILLISECOND, @SetStart, SYSDATETIME());
SELECT 'Set-based' AS Method, @SetMs AS ElapsedMilliseconds;
GO
-- 10. TEST RECHARGE PROCEDURE
DECLARE @BalanceAfter DECIMAL(10,2);
EXEC usp_Recharge @SubscriberID = 1, @PlanID = 1, @Amount = 100, @NewBalance = @BalanceAfter OUTPUT;
SELECT @BalanceAfter AS NewBalance;
GO
-- 11. VIEW DATA / CHECK NOTIFICATIONS
SELECT * FROM Subscribers;
SELECT * FROM Plans;
SELECT * FROM RechargeHistory;
SELECT * FROM NotificationLog;
GO
