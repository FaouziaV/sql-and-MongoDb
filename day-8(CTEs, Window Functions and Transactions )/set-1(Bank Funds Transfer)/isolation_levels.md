# SQL Server Isolation Levels and MongoDB Transaction Cost

## READ COMMITTED (SQL Server default)
READ COMMITTED prevents reading uncommitted changes (dirty reads). A second session waits for locks or sees committed data, but the same query later in a transaction can return a different committed value (non-repeatable read). Locks are generally held while statements execute; behavior depends on locking and configuration.

### Two-session demonstration
Open two SSMS query windows and run the setup once:

```sql
USE BankTransferDB;
SELECT current_balance FROM Accounts WHERE account_id = 1001;
```

**Session A:**
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT current_balance FROM Accounts WHERE account_id = 1001;
WAITFOR DELAY '00:00:10';
SELECT current_balance FROM Accounts WHERE account_id = 1001;
COMMIT;
```

 It commits a change, so Session A's second SELECT can see the newly committed balance:
```sql
USE BankTransferDB;
BEGIN TRANSACTION;
UPDATE Accounts SET current_balance = current_balance + 100 WHERE account_id = 1001;
COMMIT;
```

## SNAPSHOT (SQL Server)
SNAPSHOT gives a transaction a consistent version of the data as of its start. Readers usually do not block writers, and writers usually do not block readers, because row versions are used. It can reduce reader/writer blocking but uses version-store resources (in tempdb, depending on configuration). Concurrent updates to the same row may produce an update conflict and one transaction may need to retry.

Enable SNAPSHOT once for the database (requires permission):
```sql
ALTER DATABASE BankTransferDB SET ALLOW_SNAPSHOT_ISOLATION ON;
```

**Session A:**
```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
SELECT current_balance FROM Accounts WHERE account_id = 1001;
WAITFOR DELAY '00:00:10';
SELECT current_balance FROM Accounts WHERE account_id = 1001;
COMMIT;
```
While Session A waits, run the Session B update shown above. Session A's second SELECT continues to show its original snapshot; a new transaction sees the committed update.

## MongoDB multi-document transaction
The companion `transaction.js` uses a session and `withTransaction()` to debit one account, credit the other, and insert ledger records atomically. If an operation fails, the driver aborts the transaction. It requires a replica set or sharded cluster; standalone MongoDB does not support multi-document transactions.

### Costs / tradeoffs
- More latency and coordination than single-document writes.
- Locks/conflict handling and retries can affect throughput.
- Transaction state and oplog/replication work add overhead.
- Transactions can increase resource use and should be kept short.
- On sharded deployments, cross-shard transactions are more expensive than transactions contained on one shard.
- Prefer modeling operations atomically in one document where practical; use multi-document transactions when true cross-document atomicity is required.
