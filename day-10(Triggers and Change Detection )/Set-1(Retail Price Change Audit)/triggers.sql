CREATE TABLE product_price
(
    ProductID   int           NOT NULL PRIMARY KEY,
    ProductName nvarchar(100) NOT NULL,
    CurrentPrice decimal(12,2) NOT NULL,
    CostPrice    decimal(12,2) NOT NULL,
    CONSTRAINT CK_product_price_nonnegative CHECK (CurrentPrice >= 0 AND CostPrice >= 0)
);
GO

CREATE TABLE price_audit
(
    AuditID bigint IDENTITY(1,1) PRIMARY KEY,
    ProductID int NOT NULL,
    OldPrice decimal(12,2) NOT NULL,
    NewPrice decimal(12,2) NOT NULL,
    ChangedBy sysname NOT NULL,
    ChangedAtUtc datetime2(3) NOT NULL
);
GO

CREATE TABLE price_rejection_audit
(
    RejectionID bigint IDENTITY(1,1) PRIMARY KEY,
    ProductID int NOT NULL,
    AttemptedPrice decimal(12,2) NOT NULL,
    CostPrice decimal(12,2) NOT NULL,
    AttemptedBy sysname NOT NULL,
    AttemptedAtUtc datetime2(3) NOT NULL,
    Reason nvarchar(250) NOT NULL
);
GO

INSERT product_price(ProductID, ProductName, CurrentPrice, CostPrice)
VALUES (101, N'Keyboard', 1200.00, 800.00),
       (102, N'Mouse', 500.00, 300.00),
       (103, N'Monitor', 9000.00, 7000.00),
       (104, N'USB Hub', 700.00, 450.00);
GO

/* INSTEAD OF trigger validates the complete submitted set.
   If any row is below cost, it records the offending rows and rejects
   the whole UPDATE without changing any product. */
CREATE TRIGGER tr_product_price_instead_update
ON product_price
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN product_price p ON p.ProductID = i.ProductID
        WHERE i.CurrentPrice < p.CostPrice
    )
    BEGIN
        INSERT price_rejection_audit
            (ProductID, AttemptedPrice, CostPrice, AttemptedBy, AttemptedAtUtc, Reason)
        SELECT i.ProductID, i.CurrentPrice, p.CostPrice,
               ORIGINAL_LOGIN(), SYSUTCDATETIME(),
               N'Attempted selling price is below cost'
        FROM inserted i
        JOIN product_price p ON p.ProductID = i.ProductID
        WHERE i.CurrentPrice < p.CostPrice;

        PRINT 'UPDATE rejected: one or more prices are below cost. See price_rejection_audit.';
        RETURN;
    END;

    /* Apply requested values to the base table. This causes the AFTER
       UPDATE audit trigger below to record the actual changes. */
    UPDATE p
       SET p.ProductName = i.ProductName,
           p.CurrentPrice = i.CurrentPrice,
           p.CostPrice = i.CostPrice
    FROM product_price p
    JOIN inserted i ON i.ProductID = p.ProductID;
END;
GO

/* Multi-row safe: inserted/deleted are joined by the primary key. */
CREATE TRIGGER tr_product_price_after_update
ON product_price
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT price_audit(ProductID, OldPrice, NewPrice, ChangedBy, ChangedAtUtc)
    SELECT d.ProductID, d.CurrentPrice, i.CurrentPrice,
           ORIGINAL_LOGIN(), SYSUTCDATETIME()
    FROM deleted d
    JOIN inserted i ON i.ProductID = d.ProductID
    WHERE d.CurrentPrice <> i.CurrentPrice;
END;
GO
