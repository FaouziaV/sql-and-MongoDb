# Set 1 – Pitfalls note

## Two trigger risks
1. **Hidden logic:** updates can cause audit/validation work that is not visible in the application statement. Developers may misunderstand why an update was rejected or why extra rows appeared in an audit table.
2. **Cascading/nested execution:** a trigger can issue DML that fires other triggers. This can create unexpected chains, recursion, performance costs, or loops.

## When application code is better
Use application/service-layer validation when the rule needs a user-friendly explanation, external service calls, configurable business policy, or a workflow spanning several systems. Keep database constraints as a final integrity boundary where possible.

## MongoDB change stream versus SQL Server trigger
- A SQL Server trigger executes synchronously as part of the transaction that changes the table; its failure can fail the originating DML statement.
- A MongoDB change stream is a consumer-facing feed of committed database changes. A separate process reads events and can react asynchronously.
- Change streams require a replica set (or a sharded cluster); they are not available on a standalone `mongod`.
- The watcher filters update events and checks `updateDescription.updatedFields.price`. `updateLookup` requests the document's current version, which may reflect a later update if writes happen rapidly.
- For production, persist resume tokens and handle reconnects; the simple assignment watcher is an educational example.
