# Insurance Premium Processing — Cursor vs Set-Based Notes

## Cursor approach
A cursor handles records one by one. In this assignment, it finds policies that are still marked `Active` but whose expiry date is earlier than today. For each policy, it updates the status to `Lapsed` and inserts a row into `PolicyStatusLog`.

### Flow
1. Select expired active policies.
2. Open the cursor.
3. Fetch one PolicyID.
4. Update that policy's status to `Lapsed`.
5. Insert a log record for that policy.
6. Fetch the next PolicyID and repeat.
7. Close and deallocate the cursor.

## Set-based approach
The set-based method operates on all matching policies in statements, instead of looping through each policy individually. It first inserts log records for the expired active policies, then updates all qualifying policies to `Lapsed`.

## Comparison
| Cursor | Set-based |
|---|---|
| Processes one row at a time | Processes the matching set together |
| Uses FETCH and WHILE loop | Uses `INSERT...SELECT` and `UPDATE` |
| More code and control flow | Shorter, more direct SQL |
| Often slower for bulk work | Usually faster and easier for SQL Server to optimize |
| Useful when each row needs distinct sequential logic | Preferred for bulk changes with the same rule |

## Conclusion
For this assignment, the set-based method is preferred because every expired active policy receives the same status change and logging action. A cursor is useful when row-by-row processing is genuinely required, but it adds overhead for this uniform bulk task.

## Important execution note
The SQL script includes both methods for demonstration. Run the cursor method first, then the set-based method: because the cursor already changes expired policies to `Lapsed`, the set-based statement will find no remaining `Active` expired policies during that same run. To compare both methods on the same starting data, reset/reload the sample data between tests or execute each method against a separate copy of the database.
