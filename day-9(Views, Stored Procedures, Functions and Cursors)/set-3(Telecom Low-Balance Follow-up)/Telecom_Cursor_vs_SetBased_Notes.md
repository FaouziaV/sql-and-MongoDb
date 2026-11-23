# Set 3 – Telecom Low-Balance Follow-up
## Cursor vs Set-Based Comparison and Timing Notes

### Cursor approach
A cursor processes qualifying prepaid subscribers one at a time. It fetches one subscriber with a balance below 50, inserts that subscriber's notification, fetches the next subscriber, and repeats until no rows remain.

**Steps:**
1. Select prepaid subscribers whose balance is below 50.
2. Open the cursor.
3. Fetch one subscriber ID.
4. Insert a low-balance notification for that subscriber.
5. Fetch the next subscriber and repeat.
6. Close and deallocate the cursor.

### Set-based approach
The set-based version performs the notification insert in one statement. SQL Server can optimize the operation as a set rather than repeatedly processing individual rows.

```sql
INSERT INTO NotificationLog (SubscriberID, NotificationMessage)
SELECT SubscriberID, 'Your prepaid balance is below 50. Please recharge.'
FROM Subscribers
WHERE SubscriberType = 'Prepaid' AND Balance < 50;
```

### Comparison
| Feature | Cursor | Set-Based |
|---|---|---|
| Processing | One subscriber at a time | All qualifying subscribers in one statement |
| Code | More steps | Shorter and simpler |
| Performance | Often slower as row count grows | Usually faster for bulk work |
| Overhead | Repeated fetch and insert operations | One set-based insert operation |
| Best fit | When each row needs different procedural handling | Bulk operations with the same rule |

### Timing comparison
The SQL script measures elapsed milliseconds around each procedure using `SYSDATETIME()` and `DATEDIFF(MILLISECOND, ...)`, then returns a result for Cursor and Set-Based.

**Note:** The sample dataset is small, so timing may be 0 ms or too close to reliably compare. For a meaningful benchmark, test with a larger dataset, run each method several times, and compare repeated results. The script inserts notifications for both methods, so running both will create duplicate notifications for the same low-balance subscribers; this is intentional for the assignment demonstration unless you add a duplicate-prevention rule.

### Conclusion
For the low-balance notification task, set-based processing is generally preferred because it inserts all matching notification rows with one `INSERT...SELECT`. A cursor is useful when each subscriber requires distinct, sequential processing that cannot easily be expressed as a set-based operation.
