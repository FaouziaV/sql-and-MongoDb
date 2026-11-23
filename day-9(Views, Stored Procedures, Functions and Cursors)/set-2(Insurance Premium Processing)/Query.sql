
CREATE DATABASE InsurancePremiumProcessing;
GO
USE InsurancePremiumProcessing;
GO

-- 1. TABLES
CREATE TABLE Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(150),
    Phone VARCHAR(25)
);
GO

CREATE TABLE Agents
(
    AgentID INT IDENTITY(1,1) PRIMARY KEY,
    AgentName VARCHAR(100) NOT NULL,
    Email VARCHAR(150)
);
GO

CREATE TABLE Policies
(
    PolicyID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES Customers(CustomerID),
    AgentID INT NOT NULL REFERENCES Agents(AgentID),
    PolicyType VARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    ExpiryDate DATE NOT NULL,
    Premium DECIMAL(10,2) NOT NULL CHECK (Premium >= 0),
    PolicyStatus VARCHAR(20) NOT NULL DEFAULT 'Active'
);
GO

CREATE TABLE Claims
(
    ClaimID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID INT NOT NULL REFERENCES Policies(PolicyID),
    ClaimDate DATE NOT NULL DEFAULT GETDATE(),
    ClaimAmount DECIMAL(10,2) NOT NULL CHECK (ClaimAmount >= 0),
    ClaimStatus VARCHAR(20) NOT NULL DEFAULT 'Pending'
);
GO

CREATE TABLE RenewalAudit
(
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID INT NOT NULL REFERENCES Policies(PolicyID),
    OldPremium DECIMAL(10,2) NOT NULL,
    NewPremium DECIMAL(10,2) NOT NULL,
    RenewalDate DATETIME NOT NULL DEFAULT GETDATE(),
    AuditNote VARCHAR(250)
);
GO

CREATE TABLE PolicyStatusLog
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID INT NOT NULL REFERENCES Policies(PolicyID),
    OldStatus VARCHAR(20) NOT NULL,
    NewStatus VARCHAR(20) NOT NULL,
    LogDate DATETIME NOT NULL DEFAULT GETDATE(),
    LogNote VARCHAR(250)
);
GO

-- 2. SAMPLE DATA
INSERT INTO Customers (CustomerName, Email, Phone) VALUES
('Ananya Rao','ananya@example.com','9000000001'),
('Karthik S','karthik@example.com','9000000002'),
('Meera N','meera@example.com','9000000003'),
('Vikram P','vikram@example.com','9000000004');
GO
INSERT INTO Agents (AgentName, Email) VALUES
('Agent A','agent.a@example.com'),
('Agent B','agent.b@example.com');
GO
INSERT INTO Policies (CustomerID, AgentID, PolicyType, StartDate, ExpiryDate, Premium, PolicyStatus) VALUES
(1,1,'Health',DATEADD(YEAR,-1,GETDATE()),DATEADD(DAY,15,GETDATE()),12000,'Active'),
(2,1,'Vehicle',DATEADD(YEAR,-1,GETDATE()),DATEADD(DAY,25,GETDATE()),8500,'Active'),
(3,2,'Life',DATEADD(YEAR,-2,GETDATE()),DATEADD(DAY,60,GETDATE()),15000,'Active'),
(4,2,'Health',DATEADD(YEAR,-1,GETDATE()),DATEADD(DAY,-10,GETDATE()),10000,'Active'),
(1,2,'Vehicle',DATEADD(YEAR,-1,GETDATE()),DATEADD(DAY,10,GETDATE()),7000,'Active');
GO
INSERT INTO Claims (PolicyID, ClaimDate, ClaimAmount, ClaimStatus) VALUES
(2,DATEADD(DAY,-5,GETDATE()),2500,'Pending'),
(3,DATEADD(DAY,-40,GETDATE()),4000,'Approved');
GO

-- 3. VIEW: POLICIES DUE WITHIN 30 DAYS (excludes sensitive columns)
CREATE VIEW vw_policy_due
AS
SELECT
    p.PolicyID,
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Phone,
    p.PolicyType,
    p.StartDate,
    p.ExpiryDate,
    p.Premium,
    p.PolicyStatus,
    p.AgentID
FROM Policies p
JOIN Customers c ON p.CustomerID = c.CustomerID
WHERE p.PolicyStatus = 'Active'
  AND p.ExpiryDate >= CAST(GETDATE() AS DATE)
  AND p.ExpiryDate <= DATEADD(DAY,30,CAST(GETDATE() AS DATE));
GO
SELECT * FROM vw_policy_due;
GO

-- 4. SCALAR FUNCTION: 10% NO-CLAIM DISCOUNT
CREATE FUNCTION fn_PremiumWithNoClaimDiscount (@Premium DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Premium * 0.90;
END;
GO


-- 5. TABLE-VALUED FUNCTION: RENEWAL QUOTES FOR AN AGENT
-- Quotes are for active policies expiring within 30 days with no pending claim.
CREATE FUNCTION fn_AgentRenewalQuotes (@AgentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.PolicyID,
        p.CustomerID,
        c.CustomerName,
        p.PolicyType,
        p.ExpiryDate,
        p.Premium AS CurrentPremium,
        dbo.fn_PremiumWithNoClaimDiscount(p.Premium) AS RenewalQuote
    FROM Policies p
    JOIN Customers c ON c.CustomerID = p.CustomerID
    WHERE p.AgentID = @AgentID
      AND p.PolicyStatus = 'Active'
      AND p.ExpiryDate >= CAST(GETDATE() AS DATE)
      AND p.ExpiryDate <= DATEADD(DAY,30,CAST(GETDATE() AS DATE))
      AND NOT EXISTS
      (
          SELECT 1 FROM Claims cl
          WHERE cl.PolicyID = p.PolicyID
            AND cl.ClaimStatus = 'Pending'
      )
);
GO
SELECT * FROM dbo.fn_AgentRenewalQuotes(1);
GO

-- 6. STORED PROCEDURE: RENEW POLICY
-- Requires active policy and no pending claim. Renews for one year,
-- applies the 10% no-claim discount, and writes an audit row transactionally.
CREATE PROCEDURE usp_RenewPolicy
    @PolicyID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldPremium DECIMAL(10,2),
                @NewPremium DECIMAL(10,2),
                @ExpiryDate DATE,
                @PolicyStatus VARCHAR(20);

        SELECT @OldPremium = Premium,
               @ExpiryDate = ExpiryDate,
               @PolicyStatus = PolicyStatus
        FROM Policies
        WHERE PolicyID = @PolicyID;

        IF @OldPremium IS NULL
            THROW 50001, 'Policy not found.', 1;

        IF @PolicyStatus <> 'Active'
            THROW 50002, 'Only active policies can be renewed.', 1;

        IF EXISTS
        (
            SELECT 1 FROM Claims
            WHERE PolicyID = @PolicyID AND ClaimStatus = 'Pending'
        )
            THROW 50003, 'Policy has a pending claim and cannot be renewed.', 1;

        SET @NewPremium = dbo.fn_PremiumWithNoClaimDiscount(@OldPremium);

        UPDATE Policies
        SET Premium = @NewPremium,
            StartDate = CASE WHEN ExpiryDate < CAST(GETDATE() AS DATE)
                           THEN CAST(GETDATE() AS DATE) ELSE ExpiryDate END,
            ExpiryDate = DATEADD(YEAR, 1,
                         CASE WHEN ExpiryDate < CAST(GETDATE() AS DATE)
                              THEN CAST(GETDATE() AS DATE) ELSE ExpiryDate END)
        WHERE PolicyID = @PolicyID;

        INSERT INTO RenewalAudit (PolicyID, OldPremium, NewPremium, AuditNote)
        VALUES (@PolicyID, @OldPremium, @NewPremium, 'Policy renewed for one year with 10% no-claim discount');

        COMMIT TRANSACTION;
        SELECT @PolicyID AS RenewedPolicyID, @OldPremium AS OldPremium, @NewPremium AS NewPremium;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Test renewal procedure (Policy 1 has no pending claim)
EXEC usp_RenewPolicy @PolicyID = 1;
GO


-- 7. CURSOR: MARK EXPIRED ACTIVE POLICIES AS LAPSED AND LOG EACH
CREATE PROCEDURE usp_LapsePolicies_Cursor
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PolicyID INT;

    DECL PolicyCursor CURSOR FOR
        SELECT PolicyID
        FROM Policies
        WHERE PolicyStatus = 'Active'
          AND ExpiryDate < CAST(GETDATE() AS DATE);

    OPEN PolicyCursor;
    FETCH NEXT FROM PolicyCursor INTO @PolicyID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Policies
        SET PolicyStatus = 'Lapsed'
        WHERE PolicyID = @PolicyID;

        INSERT INTO PolicyStatusLog (PolicyID, OldStatus, NewStatus, LogNote)
        VALUES (@PolicyID, 'Active', 'Lapsed', 'Policy expired; status updated by cursor procedure');

        FETCH NEXT FROM PolicyCursor INTO @PolicyID;
    END;

    CLOSE PolicyCursor;
    DEALLOCATE PolicyCursor;
END;
GO
-- Run cursor version
EXEC usp_LapsePolicies_Cursor;
GO

-- 8. SET-BASED VERSION: UPDATE ALL EXPIRED POLICIES AND LOG CHANGES
BEGIN TRANSACTION;
INSERT INTO PolicyStatusLog (PolicyID, OldStatus, NewStatus, LogNote)
SELECT PolicyID, PolicyStatus, 'Lapsed', 'Policy expired; status updated by set-based statement'
FROM Policies
WHERE PolicyStatus = 'Active'
  AND ExpiryDate < CAST(GETDATE() AS DATE);

UPDATE Policies
SET PolicyStatus = 'Lapsed'
WHERE PolicyStatus = 'Active'
  AND ExpiryDate < CAST(GETDATE() AS DATE);
COMMIT TRANSACTION;
GO

-- 9. TEST / DISPLAY DATA
SELECT * FROM Customers;
SELECT * FROM Agents;
SELECT * FROM Policies;
SELECT * FROM Claims;
SELECT * FROM RenewalAudit;
SELECT * FROM PolicyStatusLog;
SELECT * FROM vw_policy_due;
SELECT * FROM dbo.fn_AgentRenewalQuotes(1);
GO
