
SET NOCOUNT ON;
GO

PRINT 'Test 1: INSERT audit';
INSERT account_transaction(AccountID, Amount, TransactionType)
VALUES (1,250,'CREDIT');

PRINT 'Test 2: UPDATE audit';
UPDATE account_transaction
SET Amount = 275
WHERE TransactionID = SCOPE_IDENTITY();

PRINT 'Test 3: DELETE audit';
DELETE account_transaction
WHERE TransactionID = (SELECT MAX(TransactionID) FROM account_transaction);

SELECT 'INSERT/UPDATE/DELETE audit evidence' AS Evidence, *
FROM account_transaction_audit ORDER BY AuditID;
GO

PRINT 'Test 4: batch update of five accounts; one violates the rule';
BEGIN TRY
    UPDATE vw_accounts
       SET Balance = CASE AccountID
                       WHEN 1 THEN 1100
                       WHEN 2 THEN 1600
                       WHEN 3 THEN -25  -- invalid
                       WHEN 4 THEN 2600
                       WHEN 5 THEN 3100
                     END
     WHERE AccountID BETWEEN 1 AND 5;

    PRINT 'Unexpected: batch update succeeded.';
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

SELECT 'All five balances: batch should be atomic, so original values remain' AS Evidence,
       AccountID, Balance
FROM accounts
WHERE AccountID BETWEEN 1 AND 5
ORDER BY AccountID;
GO

PRINT 'Test 5: valid batch update of five accounts';
UPDATE vw_accounts
   SET Balance = Balance + 10
 WHERE AccountID BETWEEN 1 AND 5;

SELECT 'Valid batch result' AS Evidence, AccountID, Balance
FROM accounts WHERE AccountID BETWEEN 1 AND 5 ORDER BY AccountID;
GO

/* Nested/recursive trigger demonstration.
   The following is a safe inspection/configuration demonstration.
   Do not enable recursion on production systems without a bounded design. */
SELECT name, is_recursive_triggers_on
FROM sys.databases
WHERE database_id = DB_ID();

-- Database option controls direct recursive AFTER trigger firing.
-- ALTER DATABASE CURRENT SET RECURSIVE_TRIGGERS ON;
-- ALTER DATABASE CURRENT SET RECURSIVE_TRIGGERS OFF;

-- Server-level nested trigger setting (0 disables nested AFTER triggers).
SELECT name, value_in_use
FROM sys.configurations
WHERE name = 'nested triggers';

-- Example prevention pattern inside a trigger:
-- IF TRIGGER_NESTLEVEL() > 1 RETURN;
-- Better: avoid trigger-issued updates to the same table, make operations
-- idempotent, and use a clear trigger dependency design.
GO
