CREATE DATABASE RetailOrderFulfilment;
USE RetailOrderFulfilment;

-- 1. TABLE CREATION

CREATE TABLE Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(150),
    Phone VARCHAR(25)
);

CREATE TABLE Suppliers
(
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(150)
);

CREATE TABLE Products
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    SellingPrice DECIMAL(10,2) NOT NULL CHECK (SellingPrice >= 0),
    CostPrice DECIMAL(10,2) NOT NULL CHECK (CostPrice >= 0),
    SupplierID INT REFERENCES Suppliers(SupplierID),
    StockQuantity INT NOT NULL CHECK (StockQuantity >= 0),
    ReorderLevel INT DEFAULT 10 CHECK (ReorderLevel >= 0)
);

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES Customers(CustomerID),
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderStatus VARCHAR(20) DEFAULT 'Pending'
);

CREATE TABLE OrderLines
(
    OrderLineID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES Orders(OrderID),
    ProductID INT NOT NULL REFERENCES Products(ProductID),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0)
);

CREATE TABLE OrderFollowUps
(
    FollowUpID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL REFERENCES Orders(OrderID),
    FollowUpDate DATETIME DEFAULT GETDATE(),
    FollowUpNote VARCHAR(250)
);

-- 2. SAMPLE DATA

INSERT INTO Customers VALUES
('Arun Kumar','arun@example.com','9876500001'),
('Priya S','priya@example.com','9876500002'),
('Rahul M','rahul@example.com','9876500003');

INSERT INTO Suppliers VALUES
('ABC Distributors','abc@example.com'),
('XYZ Wholesale','xyz@example.com');

INSERT INTO Products
(ProductName,SellingPrice,CostPrice,SupplierID,StockQuantity,ReorderLevel)
VALUES
('Keyboard',750,500,1,40,10),
('Mouse',450,250,1,8,10),
('Monitor',8500,7000,2,15,5),
('USB Cable',150,80,2,4,10),
('Headset',1200,850,1,25,8);

INSERT INTO Orders (CustomerID,OrderDate,OrderStatus)
VALUES
(1,DATEADD(DAY,-5,GETDATE()),'Pending'),
(2,DATEADD(DAY,-2,GETDATE()),'Pending'),
(3,DATEADD(DAY,-7,GETDATE()),'Processing');

INSERT INTO OrderLines VALUES
(1,1,2,750),
(1,2,1,450),
(2,3,1,8500),
(3,5,2,1200);

-- 3. VIEW: ORDER SUMMARY
-- Hides CostPrice and SupplierID

CREATE VIEW vw_order_summary
AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.OrderStatus,
    c.CustomerID,
    c.CustomerName,
    p.ProductID,
    p.ProductName,
    ol.Quantity,
    ol.UnitPrice,
    ol.Quantity * ol.UnitPrice AS LineTotal
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderLines ol ON o.OrderID = ol.OrderID
JOIN Products p ON ol.ProductID = p.ProductID;

SELECT * FROM vw_order_summary;

-- 4. VIEW: LOW STOCK

CREATE VIEW vw_low_stock
AS
SELECT
    ProductID,
    ProductName,
    SellingPrice,
    StockQuantity,
    ReorderLevel
FROM Products
WHERE StockQuantity <= ReorderLevel;

SELECT * FROM vw_low_stock;

-- 5. UPDATABLE VIEW WITH CHECK OPTION

CREATE VIEW vw_low_stock_updatable
AS
SELECT
    ProductID,
    ProductName,
    SellingPrice,
    StockQuantity,
    ReorderLevel
FROM Products
WHERE StockQuantity <= ReorderLevel
WITH CHECK OPTION;

-- Valid update
UPDATE vw_low_stock_updatable
SET StockQuantity = 5
WHERE ProductID = 2;

-- Invalid update: violates the view condition
-- UPDATE vw_low_stock_updatable
-- SET StockQuantity = 100
-- WHERE ProductID = 2;

-- 6. TABLE TYPE FOR ORDER ITEMS

CREATE TYPE OrderLineType AS TABLE
(
    ProductID INT,
    Quantity INT
);
GO

-- 7. STORED PROCEDURE: PLACE ORDER

CREATE PROCEDURE usp_PlaceOrder
    @CustomerID INT,
    @OrderLines OrderLineType READONLY,
    @OrderNumber INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check customer
        IF NOT EXISTS
        (
            SELECT 1
            FROM Customers
            WHERE CustomerID = @CustomerID
        )
        BEGIN
            THROW 50001, 'Customer does not exist', 1;
        END;

        -- Check empty order
        IF NOT EXISTS (SELECT 1 FROM @OrderLines)
        BEGIN
            THROW 50002, 'Order is empty', 1;
        END;

        -- Check stock
        IF EXISTS
        (
            SELECT 1
            FROM @OrderLines ol
            JOIN Products p ON ol.ProductID = p.ProductID
            WHERE p.StockQuantity < ol.Quantity
        )
        BEGIN
            THROW 50003, 'Insufficient stock', 1;
        END;

        -- Insert order
        INSERT INTO Orders (CustomerID,OrderDate,OrderStatus)
        VALUES (@CustomerID,GETDATE(),'Pending');

        SET @OrderNumber = SCOPE_IDENTITY();

        -- Insert order lines
        INSERT INTO OrderLines
        (OrderID,ProductID,Quantity,UnitPrice)
        SELECT
            @OrderNumber,
            p.ProductID,
            ol.Quantity,
            p.SellingPrice
        FROM @OrderLines ol
        JOIN Products p ON ol.ProductID = p.ProductID;

        -- Update stock
        UPDATE Products
        SET StockQuantity = StockQuantity - ol.Quantity
        FROM Products p
        JOIN @OrderLines ol ON p.ProductID = ol.ProductID;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- 8. SCALAR FUNCTION: ORDER TOTAL WITH TAX

CREATE FUNCTION fn_OrderTotalWithTax(@OrderID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = SUM(Quantity * UnitPrice)
    FROM OrderLines
    WHERE OrderID = @OrderID;

    RETURN ISNULL(@Total,0) * 1.10;
END;
GO

-- Test scalar function
SELECT dbo.fn_OrderTotalWithTax(1) AS TotalWithTax;
GO

-- 9. INLINE TABLE VALUED FUNCTION: CUSTOMER ORDERS

CREATE FUNCTION fn_CustomerOrders(@CustomerID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.OrderDate,
        o.OrderStatus,
        SUM(ol.Quantity * ol.UnitPrice) AS TotalAmount
    FROM Orders o
    JOIN OrderLines ol ON o.OrderID = ol.OrderID
    WHERE o.CustomerID = @CustomerID
    GROUP BY o.OrderID,o.OrderDate,o.OrderStatus
);
GO

-- Test table-valued function
SELECT * FROM dbo.fn_CustomerOrders(1);
GO

-- 10. TEST PLACE ORDER PROCEDURE

DECLARE @Items OrderLineType;
INSERT INTO @Items VALUES (1,2),(5,1);

DECLARE @NewOrderID INT;

EXEC usp_PlaceOrder
    @CustomerID = 1,
    @OrderLines = @Items,
    @OrderNumber = @NewOrderID OUTPUT;

SELECT @NewOrderID AS NewOrderNumber;
GO

-- 11. CURSOR PROCEDURE

CREATE PROCEDURE usp_OrderFollowUp_Cursor
AS
BEGIN
    DECLARE @OrderID INT;

    DECL OrderCursor CURSOR FOR
    SELECT OrderID
    FROM Orders
    WHERE OrderStatus = 'Pending'
      AND OrderDate < DATEADD(DAY,-3,GETDATE());

    OPEN OrderCursor;

    FETCH NEXT FROM OrderCursor INTO @OrderID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO OrderFollowUps
        (OrderID,FollowUpNote)
        VALUES
        (@OrderID,'Order pending for more than 3 days');

        FETCH NEXT FROM OrderCursor INTO @OrderID;
    END;

    CLOSE OrderCursor;
    DEALLOCATE OrderCursor;
END;
GO

-- Execute cursor procedure
EXEC usp_OrderFollowUp_Cursor;
GO

-- 12. SET-BASED APPROACH (WITHOUT CURSOR)

INSERT INTO OrderFollowUps (OrderID,FollowUpNote)
SELECT
    OrderID,
    'Order pending for more than 3 days'
FROM Orders
WHERE OrderStatus = 'Pending'
  AND OrderDate < DATEADD(DAY,-3,GETDATE());
GO

-- 13. VIEW RESULTS

SELECT * FROM Customers;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderLines;
SELECT * FROM OrderFollowUps;
SELECT * FROM vw_order_summary;
SELECT * FROM vw_low_stock;
GO