CREATE TABLE accounts
(
    AccountID int NOT NULL PRIMARY KEY,
    CustomerName nvarchar(100) NOT NULL,
    AccountType varchar(20) NOT NULL,
    Balance decimal(14,2) NOT NULL,
    CONSTRAINT CK_accounts_type CHECK (AccountType IN ('SAVINGS','CURRENT')),
    CONSTRAINT CK_accounts_nonnegative CHECK (Balance >= 0)
);
GO

CREATE TABLE account_transaction
(
    TransactionID bigint IDENTITY(1,1) PRIMARY KEY,
    AccountID int NOT NULL,
    Amount decimal(14,2) NOT NULL,
    TransactionType varchar(10) NOT NULL,
    CreatedAtUtc datetime2(3) NOT NULL CONSTRAINT DF_account_transaction_time DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_transaction_account FOREIGN KEY(AccountID) REFERENCES accounts(AccountID),
    CONSTRAINT CK_transaction_type CHECK (TransactionType IN ('CREDIT','DEBIT'))
);
GO

CREATE TABLE account_transaction_audit
(
    AuditID bigint IDENTITY(1,1) PRIMARY KEY,
    OperationType varchar(10) NOT NULL,
    TransactionID bigint NULL,
    AccountID int NULL,
    OldAmount decimal(14,2) NULL,
    NewAmount decimal(14,2) NULL,
    OldTransactionType varchar(10) NULL,
    NewTransactionType varchar(10) NULL,
    ChangedBy sysname NOT NULL,
    ChangedAtUtc datetime2(3) NOT NULL
);
GO

INSERT accounts(AccountID, CustomerName, AccountType, Balance)
VALUES (1,N'Asha','SAVINGS',1000),(2,N'Bala','SAVINGS',1500),
       (3,N'Charan','SAVINGS',2000),(4,N'Diya','SAVINGS',2500),
       (5,N'Eshan','SAVINGS',3000),(6,N'Farah','CURRENT',500);
GO

CREATE VIEW vw_accounts
AS
SELECT AccountID, CustomerName, AccountType, Balance
FROM accounts;
GO

/* One set-based audit trigger covers INSERT, UPDATE and DELETE. */
CREATE TRIGGER tr_account_transaction_audit
ON account_transaction
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT account_transaction_audit
    (
        OperationType, TransactionID, AccountID,
        OldAmount, NewAmount, OldTransactionType, NewTransactionType,
        ChangedBy, ChangedAtUtc
    )
    SELECT
        CASE WHEN d.TransactionID IS NULL THEN 'INSERT'
             WHEN i.TransactionID IS NULL THEN 'DELETE'
             ELSE 'UPDATE' END,
        COALESCE(i.TransactionID, d.TransactionID),
        COALESCE(i.AccountID, d.AccountID),
        d.Amount, i.Amount, d.TransactionType, i.TransactionType,
        ORIGINAL_LOGIN(), SYSUTCDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d
      ON i.TransactionID = d.TransactionID;
END;
GO

/* Updating through the view is allowed only if every affected savings
   account remains non-negative. A violating row rejects the whole batch. */
CREATE TRIGGER tr_vw_accounts_balance_guard
ON vw_accounts
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN accounts a ON a.AccountID = i.AccountID
        WHERE i.AccountType = 'SAVINGS'
          AND i.Balance < 0
    )
    BEGIN
        THROW 51001, 'Update rejected: a savings account balance cannot be negative.', 1;
    END;

    UPDATE a
       SET a.CustomerName = i.CustomerName,
           a.AccountType = i.AccountType,
           a.Balance = i.Balance
    FROM accounts a
    JOIN inserted i ON i.AccountID = a.AccountID;
END;
GO
