# Set 2 – Note on trigger limits

- Triggers run in the same transaction as the statement that fired them. They add latency and can make transaction behaviour harder to reason about.
- Trigger audit rows are not truly immutable merely because a trigger inserts them. Restrict UPDATE/DELETE permissions on the audit table, consider separate ownership/security, and protect backups/logs.
- A `THROW` from the view trigger rejects the entire five-row update if any row is invalid. SQL Server statement-level atomicity means none of the five balances change.
- In this example, the rejected update does not leave a separate rejection record: a write made by a trigger in the same transaction would also be rolled back when `THROW` aborts it. If rejected-attempt logging must survive, log it outside the failing transaction (for example, in the application/service or a separate durable queue).
- Nested triggers occur when a trigger's DML fires another trigger. Recursive triggers occur when a trigger eventually fires itself again. `RECURSIVE_TRIGGERS` controls direct recursion; the server `nested triggers` option controls nested AFTER trigger firing. `TRIGGER_NESTLEVEL()` can be used as a guard, but avoiding circular trigger dependencies is better.
- The MongoDB watcher filters `insert` events on `fraud_alerts` and prints the inserted document. A production consumer should persist resume tokens and implement reconnection/error handling.
