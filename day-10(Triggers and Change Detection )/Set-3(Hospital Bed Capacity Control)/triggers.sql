CREATE TABLE wards
(
    WardID int NOT NULL PRIMARY KEY,
    WardName nvarchar(100) NOT NULL,
    Capacity int NOT NULL,
    CONSTRAINT CK_wards_capacity CHECK (Capacity > 0)
);
GO

CREATE TABLE admissions
(
    AdmissionID bigint IDENTITY(1,1) PRIMARY KEY,
    PatientName nvarchar(100) NOT NULL,
    WardID int NOT NULL,
    Status varchar(20) NOT NULL,
    AdmittedAtUtc datetime2(3) NOT NULL CONSTRAINT DF_admissions_time DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_admissions_ward FOREIGN KEY(WardID) REFERENCES wards(WardID),
    CONSTRAINT CK_admissions_status CHECK (Status IN ('ADMITTED','DISCHARGED'))
);
GO

CREATE TABLE admission_audit
(
    AuditID bigint IDENTITY(1,1) PRIMARY KEY,
    OperationType varchar(10) NOT NULL,
    AdmissionID bigint NOT NULL,
    PatientName nvarchar(100) NULL,
    WardID int NULL,
    OldStatus varchar(20) NULL,
    NewStatus varchar(20) NULL,
    ChangedBy sysname NOT NULL,
    ChangedAtUtc datetime2(3) NOT NULL
);
GO

INSERT wards(WardID, WardName, Capacity)
VALUES (10,N'General',3),(20,N'ICU',2);
GO

INSERT admissions(PatientName, WardID, Status)
VALUES (N'Patient A',10,'ADMITTED'),
       (N'Patient B',10,'ADMITTED'),
       (N'Patient C',10,'ADMITTED'),
       (N'Patient D',20,'ADMITTED');
GO

/* Capacity guard: set-based and protects the ward rows while checking.
   If any ward would exceed capacity, the complete INSERT/UPDATE is rejected. */
CREATE TRIGGER tr_admissions_capacity_guard
ON admissions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedWards TABLE (WardID int PRIMARY KEY);

    INSERT @AffectedWards(WardID)
    SELECT DISTINCT WardID FROM inserted;

    IF EXISTS
    (
        SELECT 1
        FROM @AffectedWards aw
        JOIN wards w WITH (UPDLOCK, HOLDLOCK) ON w.WardID = aw.WardID
        CROSS APPLY
        (
            SELECT COUNT_BIG(*) AS OccupiedBeds
            FROM admissions a WITH (UPDLOCK, HOLDLOCK)
            WHERE a.WardID = aw.WardID
              AND a.Status = 'ADMITTED'
        ) occ
        WHERE occ.OccupiedBeds > w.Capacity
    )
    BEGIN
        THROW 51010, 'Admission rejected: ward capacity has been reached.', 1;
    END;
END;
GO

/* Audit all inserts, updates and deletes. Multi-row safe. */
CREATE TRIGGER tr_admissions_audit
ON admissions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT admission_audit
    (
        OperationType, AdmissionID, PatientName, WardID,
        OldStatus, NewStatus, ChangedBy, ChangedAtUtc
    )
    SELECT
        CASE WHEN d.AdmissionID IS NULL THEN 'INSERT'
             WHEN i.AdmissionID IS NULL THEN 'DELETE'
             ELSE 'UPDATE' END,
        COALESCE(i.AdmissionID, d.AdmissionID),
        COALESCE(i.PatientName, d.PatientName),
        COALESCE(i.WardID, d.WardID),
        d.Status, i.Status, ORIGINAL_LOGIN(), SYSUTCDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d
      ON i.AdmissionID = d.AdmissionID;
END;
GO
