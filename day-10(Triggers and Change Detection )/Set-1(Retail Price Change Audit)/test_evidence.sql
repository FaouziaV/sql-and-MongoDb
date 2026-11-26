
SET NOCOUNT ON;
GO

PRINT 'Test 1: single-row valid update';
UPDATE product_price
SET CurrentPrice = 1300.00
WHERE ProductID = 101;

SELECT 'Products after single-row update' AS Evidence, *
FROM product_price WHERE ProductID = 101;
SELECT 'Price audit after single-row update' AS Evidence, *
FROM price_audit WHERE ProductID = 101;
GO

PRINT 'Test 2: multi-row valid update';
UPDATE product_price
SET CurrentPrice = CurrentPrice + 100.00
WHERE ProductID IN (102, 103);

SELECT 'Products after multi-row update' AS Evidence, *
FROM product_price WHERE ProductID IN (102, 103);
SELECT 'Price audit after multi-row update' AS Evidence, *
FROM price_audit WHERE ProductID IN (102, 103)
ORDER BY AuditID;
GO

PRINT 'Test 3: rejected single-row update (below cost)';
UPDATE product_price
SET CurrentPrice = 200.00
WHERE ProductID = 102;

SELECT 'Product remains unchanged after rejection' AS Evidence, *
FROM product_price WHERE ProductID = 102;
SELECT 'Rejected attempt is logged' AS Evidence, *
FROM price_rejection_audit ORDER BY RejectionID;
GO

PRINT 'Test 4: rejected multi-row update; whole statement is rejected';
UPDATE product_price
SET CurrentPrice = CASE WHEN ProductID = 104 THEN 100.00 ELSE CurrentPrice + 50.00 END
WHERE ProductID IN (101, 104);

SELECT 'Both rows remain unchanged by rejected batch' AS Evidence, *
FROM product_price WHERE ProductID IN (101, 104);
SELECT 'Rejected rows logged' AS Evidence, *
FROM price_rejection_audit ORDER BY RejectionID;
GO
