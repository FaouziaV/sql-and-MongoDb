# Retail Order Fulfilment – Cursor vs Set-Based Notes

## 1. Cursor-Based Approach

A cursor processes query results one row at a time. In this assignment, it fetches each pending order older than three days, inserts a follow-up row for that order, and then moves to the next order.

### Steps
1. Declare the cursor for qualifying orders.
2. Open the cursor.
3. Fetch an order into a variable.
4. While a row is available, insert a follow-up record.
5. Fetch the next order.
6. Close and deallocate the cursor.

### Example
```sql
DECLARE @OrderID INT;

DECLARE OrderCursor CURSOR FOR
SELECT OrderID
FROM Orders
WHERE OrderStatus = 'Pending'
  AND OrderDate < DATEADD(DAY, -3, GETDATE());

OPEN OrderCursor;
FETCH NEXT FROM OrderCursor INTO @OrderID;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO OrderFollowUps (OrderID, FollowUpNote)
    VALUES (@OrderID, 'Order pending for more than 3 days');

    FETCH NEXT FROM OrderCursor INTO @OrderID;
END;

CLOSE OrderCursor;
DEALLOCATE OrderCursor;
```

## 2. Set-Based Approach

A set-based statement acts on all qualifying rows together rather than looping through each row individually. In this task, one `INSERT ... SELECT` creates follow-up rows for every pending order older than three days.

### Example
```sql
INSERT INTO OrderFollowUps (OrderID, FollowUpNote)
SELECT OrderID, 'Order pending for more than 3 days'
FROM Orders
WHERE OrderStatus = 'Pending'
  AND OrderDate < DATEADD(DAY, -3, GETDATE());
```

## 3. Comparison

| Feature | Cursor | Set-Based |
|---|---|---|
| Processing style | Row-by-row | Multiple rows in one statement |
| Performance | Usually slower for bulk work | Usually faster for bulk work |
| Code | More steps and boilerplate | Shorter and simpler |
| Scalability | Less suitable for large batches | Usually scales better for bulk operations |
| Best use | When each row needs distinct sequential logic | When the same operation can be applied to many rows |

## 4. Conclusion

For inserting follow-up records for all orders pending for more than three days, the set-based `INSERT ... SELECT` is generally preferred. It is simpler and usually more efficient because SQL Server can optimize the operation as a whole. A cursor is useful when processing truly requires separate sequential actions or row-specific logic.

## 5. Important Note

Do not run both approaches one after another against the same data without resetting or marking the processed orders; both can insert duplicate follow-up rows. For a fair comparison, test them on equivalent data and compare execution time and logical reads.
