# Day 8 – CTEs, Window Functions and Transactions

**Python Track | Mavericks Segue 2026 | Hexaware**  
**Topics:** Correlated Subqueries, Common Table Expressions (CTEs), Window Functions, Transactions and ACID, MongoDB Multi-document Transactions.

## Overview

This assignment explores SQL Server transactions, reporting with CTEs and window functions, and equivalent transaction operations in MongoDB. It contains three business scenarios.

## Set 1 – Bank Funds Transfer

A bank transfer must be atomic: either both the debit and credit succeed, or neither does.

Tasks:
- Implement a transfer using `BEGIN TRAN`, `COMMIT`, `ROLLBACK`, `TRY...CATCH`, and `THROW`.
- Validate account balance and account status before debiting.
- Demonstrate a failure after debit and verify rollback leaves balances unchanged.
- Use a `SAVEPOINT` to roll back only fee posting while retaining the transfer.
- Create a monthly statement report using a CTE, `ROW_NUMBER()`, and `LAG()` to display the previous balance.
- Explain `READ COMMITTED` and `SNAPSHOT` isolation using a two-session example.
- Demonstrate the transfer using a MongoDB multi-document transaction and discuss its cost.



## Set 2 – Airline Seat Booking

The booking service must reserve a seat and record the booking atomically, including when multiple customers select the same seat.

Tasks:
- Check seat availability, insert a booking, and update the seat status within a transaction.
- Simulate two sessions trying to book the same seat and compare `READ COMMITTED` and `SERIALIZABLE` behavior.
- Rank passengers by fare for each flight using `RANK()` and `DENSE_RANK()`; explain ties.
- Rewrite the report using a CTE and calculate a running revenue total per flight using `SUM() OVER`.
- Implement the equivalent MongoDB transaction that updates a seat document and inserts a booking document.



## Set 3 – Retail Inventory Reservation

An online retailer reserves stock when an order is placed and releases it if payment fails.

Tasks:
- Decrement stock and insert the order and order lines in one transaction.
- Demonstrate rollback when stock is insufficient.
- Use a correlated subquery to find products whose stock is below their category average.
- Rank products by sales within each category using `ROW_NUMBER()` and `PARTITION BY`, and return the top three.
- Use `LEAD()` and `LAG()` to calculate month-on-month sales changes per product.
- Explain when MongoDB transactions are needed versus single-document atomic updates; demonstrate a stock update using `$inc`.


## Technologies

- SQL Server / T-SQL
- MongoDB 8.0
- MongoDB Shell (`mongosh`) for MongoDB JavaScript scripts

## Concepts Practiced

- Transaction control: `BEGIN TRAN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`
- Error handling: `TRY...CATCH`, `THROW`
- ACID properties
- Isolation levels: `READ COMMITTED`, `SNAPSHOT`, `SERIALIZABLE`
- Correlated subqueries
- Common Table Expressions (CTEs)
- Window functions: `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `SUM() OVER`
- Partitioning and running totals
- MongoDB sessions, transactions, and atomic updates using `$inc`

## Running the Scripts

### SQL Server

1. Open SQL Server Management Studio (SSMS).
2. Open the relevant `.sql` file.
3. Execute the script against your SQL Server instance.
4. Review the result sets and rollback evidence where included.

### MongoDB

1. Open MongoDB Compass and access the **Mongosh** shell.
2. Ensure transaction scripts are run on a replica set or supported sharded cluster when multi-document transactions are used.
3. Copy and execute the relevant `.js` shell script in Mongosh.
4. Review the output and final document states.

