CREATE DATABASE BankTransferDB;
USE BankTransferDB;

--create tables
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    starting_balance DECIMAL(12,2) NOT NULL,
    current_balance DECIMAL(12,2) NOT NULL,
    account_status VARCHAR(20) NOT NULL
);

CREATE TABLE BankTransactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT NOT NULL,
    related_account_id INT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    description VARCHAR(200) NULL,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);


--insert values
INSERT INTO Accounts (account_id, account_name, starting_balance, current_balance, account_status)
VALUES
    (1001, 'Asha', 10000.00, 10000.00, 'ACTIVE'),
    (1002, 'Ravi',  5000.00,  5000.00, 'ACTIVE'),
    (9001, 'Bank Fee Account', 0.00, 0.00, 'ACTIVE');

SELECT * FROM Accounts ORDER BY account_id;

/* TASK 1: A NORMAL SUCCESSFUL TRANSFER
   Transfer 500 from account 1001 (Asha) to 1002 (Ravi). */
DECLARE @FromAccount INT = 1001;
DECLARE @ToAccount INT = 1002;
DECLARE @TransferAmount DECIMAL(12,2) = 500.00;


BEGIN TRY
    BEGIN TRANSACTION;

    IF @TransferAmount <= 0
        THROW 50001, 'Transfer amount must be greater than zero.', 1;

    IF @FromAccount = @ToAccount
        THROW 50002, 'Source and destination accounts must be different.', 1;

    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_id = @FromAccount AND account_status = 'ACTIVE')
        THROW 50003, 'Source account does not exist or is not active.', 1;

    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_id = @ToAccount AND account_status = 'ACTIVE')
        THROW 50004, 'Destination account does not exist or is not active.', 1;

    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_id = @FromAccount AND current_balance >= @TransferAmount)
        THROW 50005, 'Insufficient funds.', 1;

    UPDATE Accounts
    SET current_balance = current_balance - @TransferAmount
    WHERE account_id = @FromAccount
      AND account_status = 'ACTIVE'
      AND current_balance >= @TransferAmount;

    IF @@ROWCOUNT <> 1
        THROW 50006, 'Debit failed: balance or account status changed.', 1;

    UPDATE Accounts
    SET current_balance = current_balance + @TransferAmount
    WHERE account_id = @ToAccount
      AND account_status = 'ACTIVE';

    IF @@ROWCOUNT <> 1
        THROW 50007, 'Credit failed: destination account could not be updated.', 1;

    INSERT INTO BankTransactions (account_id, related_account_id, transaction_type, amount, description)
    VALUES
        (@FromAccount, @ToAccount, 'DEBIT', @TransferAmount, 'Funds transfer sent'),
        (@ToAccount, @FromAccount, 'CREDIT', @TransferAmount, 'Funds transfer received');

    COMMIT TRANSACTION;
    PRINT 'Successful transfer committed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    PRINT 'Transfer failed. Transaction rolled back.';
    THROW;
END CATCH;

SELECT account_id, account_name, current_balance FROM Accounts ORDER BY account_id;


/* TASK 2: DELIBERATE FAILURE AFTER DEBIT - ROLLBACK EVIDENCE */
SELECT 'Before forced rollback' AS evidence, account_id, current_balance
FROM Accounts WHERE account_id IN (1001, 1002) ORDER BY account_id;
GO


DECLARE @RollbackFrom INT = 1001;
DECLARE @RollbackTo INT = 1002;
DECLARE @RollbackAmount DECIMAL(12,2) = 250.00;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_id = @RollbackFrom AND account_status = 'ACTIVE' AND current_balance >= @RollbackAmount)
        THROW 50101, 'Rollback demo validation failed: source account unavailable or insufficient balance.', 1;

    UPDATE Accounts
    SET current_balance = current_balance - @RollbackAmount
    WHERE account_id = @RollbackFrom AND account_status = 'ACTIVE' AND current_balance >= @RollbackAmount;

    PRINT 'Sender debited inside transaction. Triggering deliberate error now...';
    THROW 50102, 'Deliberate failure after debit to demonstrate rollback.', 1;

    UPDATE Accounts SET current_balance = current_balance + @RollbackAmount WHERE account_id = @RollbackTo;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    PRINT 'Expected error caught. Debit has been rolled back.';
    PRINT ERROR_MESSAGE();
END CATCH;

SELECT 'After forced rollback - balances should match the before result' AS evidence,
       account_id, current_balance
FROM Accounts WHERE account_id IN (1001, 1002) ORDER BY account_id;


/* TASK 3: SAVEPOINT - ROLLBACK ONLY THE FEE, RETAIN THE TRANSFER
   Transfer 200 from Asha to Ravi. A fee of 10 is attempted, then
   rolled back to the savepoint. The transfer itself is committed. */
DECLARE @SavepointFrom INT = 1001;
DECLARE @SavepointTo INT = 1002;
DECLARE @SavepointAmount DECIMAL(12,2) = 200.00;
DECLARE @FeeAmount DECIMAL(12,2) = 10.00;


BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_id = @SavepointFrom AND account_status = 'ACTIVE' AND current_balance >= @SavepointAmount)
        THROW 50201, 'Savepoint demo: source account unavailable or insufficient balance.', 1;
    IF NOT EXISTS (SELECT 1 FROM Accounts WHERE account_id = @SavepointTo AND account_status = 'ACTIVE')
        THROW 50202, 'Savepoint demo: destination account unavailable.', 1;

    UPDATE Accounts SET current_balance = current_balance - @SavepointAmount
    WHERE account_id = @SavepointFrom AND current_balance >= @SavepointAmount AND account_status = 'ACTIVE';
    IF @@ROWCOUNT <> 1 THROW 50203, 'Savepoint demo debit failed.', 1;

    UPDATE Accounts SET current_balance = current_balance + @SavepointAmount
    WHERE account_id = @SavepointTo AND account_status = 'ACTIVE';
    IF @@ROWCOUNT <> 1 THROW 50204, 'Savepoint demo credit failed.', 1;

    INSERT INTO BankTransactions (account_id, related_account_id, transaction_type, amount, description)
    VALUES
        (@SavepointFrom, @SavepointTo, 'DEBIT', @SavepointAmount, 'Savepoint demo transfer sent'),
        (@SavepointTo, @SavepointFrom, 'CREDIT', @SavepointAmount, 'Savepoint demo transfer received');

    SAVE TRANSACTION TransferCompleted;
    PRINT 'Transfer completed. Savepoint created before fee posting.';

    -- Fee posting step (intentionally undone below).
    UPDATE Accounts SET current_balance = current_balance - @FeeAmount
    WHERE account_id = @SavepointTo AND account_status = 'ACTIVE' AND current_balance >= @FeeAmount;

    IF @@ROWCOUNT = 1
    BEGIN
        UPDATE Accounts SET current_balance = current_balance + @FeeAmount
        WHERE account_id = 9001 AND account_status = 'ACTIVE';

        INSERT INTO BankTransactions (account_id, related_account_id, transaction_type, amount, description)
        VALUES (@SavepointTo, 9001, 'FEE', @FeeAmount, 'Fee posting - will be rolled back to savepoint');
    END;


    ROLLBACK TRANSACTION TransferCompleted;
    PRINT 'Fee posting rolled back to savepoint. Transfer remains in transaction.';

    COMMIT TRANSACTION;
    PRINT 'Transfer committed; fee was not posted.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    PRINT 'Savepoint demo failed; full transaction rolled back.';
    THROW;
END CATCH;

SELECT account_id, account_name, current_balance FROM Accounts ORDER BY account_id;
SELECT * FROM BankTransactions ORDER BY transaction_id;



/* TASK 4: MONTHLY STATEMENT - CTE + ROW_NUMBER + LAG*/
DECLARE @StatementMonth DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @NextMonth DATE = DATEADD(MONTH, 1, @StatementMonth);

;WITH MonthlyTransactions AS
(
    SELECT
        t.transaction_id,
        t.account_id,
        a.account_name,
        t.related_account_id,
        t.transaction_type,
        t.amount,
        t.transaction_date,
        t.description,
        CASE
            WHEN t.transaction_type = 'DEBIT' THEN -t.amount
            WHEN t.transaction_type = 'CREDIT' THEN t.amount
            WHEN t.transaction_type = 'FEE' THEN -t.amount
            ELSE 0
        END AS signed_amount,
        a.starting_balance
    FROM BankTransactions AS t
    INNER JOIN Accounts AS a ON a.account_id = t.account_id
    WHERE t.transaction_date >= @StatementMonth
      AND t.transaction_date < @NextMonth
),
StatementRows AS
(
    SELECT
        transaction_id,
        account_id,
        account_name,
        related_account_id,
        transaction_type,
        amount,
        transaction_date,
        description,
        ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY transaction_date, transaction_id) AS row_num,
        starting_balance
            + SUM(signed_amount) OVER (
                PARTITION BY account_id
                ORDER BY transaction_date, transaction_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
              ) AS balance_after
    FROM MonthlyTransactions
)
SELECT
    account_id,
    account_name,
    row_num,
    transaction_id,
    transaction_date,
    transaction_type,
    amount,
    related_account_id,
    description,
    LAG(balance_after, 1, starting_balance) OVER (
        PARTITION BY account_id ORDER BY transaction_date, transaction_id
    ) AS previous_balance,
    balance_after
FROM StatementRows
ORDER BY account_id, transaction_date, transaction_id;


SELECT account_id, account_name, starting_balance, current_balance, account_status
FROM Accounts ORDER BY account_id;
