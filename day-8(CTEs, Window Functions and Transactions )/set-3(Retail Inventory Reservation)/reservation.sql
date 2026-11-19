
CREATE DATABASE RetailInventoryDB;
USE RetailInventoryDB;

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    stock_quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    order_date DATETIME NOT NULL DEFAULT GETDATE(),
    order_status VARCHAR(30) NOT NULL
);

CREATE TABLE OrderLines (
    order_line_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity_sold INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Products VALUES
(1,'Laptop','Electronics',10,65000.00),
(2,'Mouse','Electronics',50,800.00),
(3,'Keyboard','Electronics',25,1500.00),
(4,'Chair','Furniture',15,4500.00),
(5,'Desk','Furniture',8,9000.00),
(6,'Monitor','Electronics',12,12000.00);

INSERT INTO Sales VALUES
(1,1,'2026-01-05',3),(2,1,'2026-02-05',5),(3,1,'2026-03-05',4),
(4,2,'2026-01-12',20),(5,2,'2026-02-12',15),(6,2,'2026-03-12',18),
(7,3,'2026-01-20',10),(8,3,'2026-02-20',12),(9,3,'2026-03-20',8),
(10,4,'2026-01-10',4),(11,4,'2026-02-10',6),(12,4,'2026-03-10',5),
(13,5,'2026-01-15',2),(14,5,'2026-02-15',3),(15,5,'2026-03-15',1),
(16,6,'2026-01-25',5),(17,6,'2026-02-25',7),(18,6,'2026-03-25',6);

SELECT * FROM Products ORDER BY product_id;

-- TASK 1: Successful reservation transaction
DECLARE @OrderID INT=1001, @ProductID INT=1, @Quantity INT=2,
        @CustomerName VARCHAR(100)='Customer A', @UnitPrice DECIMAL(10,2), @CurrentStock INT;
BEGIN TRY
    BEGIN TRANSACTION;
    SELECT @CurrentStock=stock_quantity, @UnitPrice=unit_price
    FROM Products WITH (UPDLOCK,HOLDLOCK) WHERE product_id=@ProductID;
    IF @CurrentStock IS NULL THROW 50001,'Product does not exist.',1;
    IF @Quantity<=0 THROW 50002,'Quantity must be positive.',1;
    IF @CurrentStock<@Quantity THROW 50003,'Insufficient stock.',1;
    UPDATE Products SET stock_quantity=stock_quantity-@Quantity
    WHERE product_id=@ProductID AND stock_quantity>=@Quantity;
    IF @@ROWCOUNT<>1 THROW 50004,'Stock update failed.',1;
    INSERT INTO Orders(order_id,customer_name,order_status) VALUES(@OrderID,@CustomerName,'RESERVED');
    INSERT INTO OrderLines(order_line_id,order_id,product_id,quantity,unit_price)
    VALUES(2001,@OrderID,@ProductID,@Quantity,@UnitPrice);
    COMMIT TRANSACTION;
    PRINT 'Reservation successful: stock and order records committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    PRINT 'Reservation failed; transaction rolled back.';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;

SELECT product_id,product_name,stock_quantity FROM Products WHERE product_id=1;
SELECT * FROM Orders WHERE order_id=1001;
SELECT * FROM OrderLines WHERE order_id=1001;

-- BUSINESS SCENARIO: PAYMENT FAILURE - RELEASE RESERVED STOCK
DECLARE @PaymentFailedOrderID INT = 1001;
DECLARE @ReleaseProductID INT = 1;
DECLARE @ReleaseQuantity INT = 2;
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE Products
    SET stock_quantity = stock_quantity + @ReleaseQuantity
    WHERE product_id = @ReleaseProductID;
    IF @@ROWCOUNT <> 1 THROW 50201, 'Product not found while releasing stock.', 1;
    UPDATE Orders
    SET order_status = 'PAYMENT_FAILED_CANCELLED'
    WHERE order_id = @PaymentFailedOrderID;
    IF @@ROWCOUNT <> 1 THROW 50202, 'Order not found while cancelling.', 1;
    COMMIT TRANSACTION;
    PRINT 'Payment failed: reserved stock released and order cancelled.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Payment-failure release failed; compensation rolled back.';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;
GO
SELECT product_id, product_name, stock_quantity FROM Products WHERE product_id = 1;
SELECT order_id, order_status FROM Orders WHERE order_id = 1001;
GO

-- Insufficient stock rollback demonstration 
SELECT 'BEFORE FAILED ORDER' AS evidence, product_id,product_name,stock_quantity FROM Products WHERE product_id=2;
GO
DECLARE @BadOrderID INT=1002, @BadProductID INT=2, @BadQuantity INT=999,
        @BadCustomer VARCHAR(100)='Customer B', @BadPrice DECIMAL(10,2), @BadStock INT;
BEGIN TRY
    BEGIN TRANSACTION;
    SELECT @BadStock=stock_quantity,@BadPrice=unit_price FROM Products WITH (UPDLOCK,HOLDLOCK)
    WHERE product_id=@BadProductID;
    IF @BadStock IS NULL THROW 50101,'Product does not exist.',1;
    IF @BadQuantity<=0 THROW 50102,'Quantity must be positive.',1;
    IF @BadStock<@BadQuantity THROW 50103,'Insufficient stock. Reservation cancelled.',1;
    UPDATE Products SET stock_quantity=stock_quantity-@BadQuantity
    WHERE product_id=@BadProductID AND stock_quantity>=@BadQuantity;
    INSERT INTO Orders(order_id,customer_name,order_status) VALUES(@BadOrderID,@BadCustomer,'RESERVED');
    INSERT INTO OrderLines(order_line_id,order_id,product_id,quantity,unit_price)
    VALUES(2002,@BadOrderID,@BadProductID,@BadQuantity,@BadPrice);
    COMMIT TRANSACTION;
    PRINT 'Unexpected: failed-order test succeeded.';
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    PRINT 'EXPECTED FAILURE: insufficient stock; rollback performed.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT 'AFTER FAILED ORDER' AS evidence,product_id,product_name,stock_quantity FROM Products WHERE product_id=2;
SELECT * FROM Orders WHERE order_id=1002;
SELECT * FROM OrderLines WHERE order_line_id=2002;
GO

-- TASK 2: Correlated subquery: stock below average for its category
SELECT p.product_id,p.product_name,p.category,p.stock_quantity
FROM Products AS p
WHERE p.stock_quantity <
    (SELECT AVG(CAST(p2.stock_quantity AS DECIMAL(10,2)))
     FROM Products AS p2 WHERE p2.category=p.category)
ORDER BY p.category,p.stock_quantity;
GO

-- TASK 3: CTE ranking, top three products by units sold within category
WITH ProductSales AS (
    SELECT p.product_id,p.product_name,p.category,
           COALESCE(SUM(s.quantity_sold),0) AS total_units_sold
    FROM Products p LEFT JOIN Sales s ON s.product_id=p.product_id
    GROUP BY p.product_id,p.product_name,p.category
), RankedProducts AS (
    SELECT product_id,product_name,category,total_units_sold,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_units_sold DESC,product_id) AS row_num
    FROM ProductSales
)
SELECT product_id,product_name,category,total_units_sold,row_num
FROM RankedProducts WHERE row_num<=3 ORDER BY category,row_num;
GO
-- TASK 4: Monthly sales with LAG/LEAD and month-on-month change
WITH MonthlySales AS (
    SELECT product_id,DATEFROMPARTS(YEAR(sale_date),MONTH(sale_date),1) AS sales_month,
           SUM(quantity_sold) AS monthly_units_sold
    FROM Sales
    GROUP BY product_id,DATEFROMPARTS(YEAR(sale_date),MONTH(sale_date),1)
), SalesComparison AS (
    SELECT product_id,sales_month,monthly_units_sold,
           LAG(monthly_units_sold) OVER(PARTITION BY product_id ORDER BY sales_month) AS previous_month_sales,
           LEAD(monthly_units_sold) OVER(PARTITION BY product_id ORDER BY sales_month) AS next_month_sales
    FROM MonthlySales
)
SELECT product_id,sales_month,monthly_units_sold,previous_month_sales,next_month_sales,
       monthly_units_sold-previous_month_sales AS change_from_previous_month
FROM SalesComparison ORDER BY product_id,sales_month;
GO

SELECT * FROM Products ORDER BY product_id;
SELECT * FROM Orders ORDER BY order_id;
SELECT * FROM OrderLines ORDER BY order_line_id;
