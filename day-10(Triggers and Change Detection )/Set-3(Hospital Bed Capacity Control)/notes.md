# Set 3 – Written justification

## Trigger versus constraint versus stored procedure
- **Constraint:** best for simple row-level rules that can be expressed declaratively, such as `Capacity > 0`, a non-negative value, or a valid status. Constraints are easier to discover and generally simpler to maintain.
- **Stored procedure:** better when callers can be required to use one controlled operation, and the rule involves several steps, explicit transaction handling, locking, or a clear business-operation API.
- **Trigger:** useful when the rule must be enforced regardless of which application or user issues DML, and when automatic auditing is required. Triggers are less visible and need careful multi-row and concurrency handling.

## Multi-row insert behaviour
The capacity trigger evaluates the resulting occupancy for every affected ward, not one row at a time. If any affected ward exceeds capacity, `THROW` aborts the statement. SQL Server statement atomicity means no rows from that multi-row insert remain. The AFTER audit trigger's writes are part of the same transaction and are rolled back too.

## Concurrency consideration
The example uses `UPDLOCK` and `HOLDLOCK` when checking ward occupancy to reduce races between concurrent admissions. For a high-throughput production system, use a carefully designed transaction/procedure that serializes capacity allocation per ward (for example, locking the ward row before checking and inserting). Test under the database's actual isolation level and workload.

## MongoDB change stream
The watcher filters newly inserted documents in `ward_alerts` whose `fullDocument.severity` is `critical`, then prints the ward and time. The example accepts `time`, `createdAt`, or the change event's `clusterTime` as the displayed time field. Change streams require a replica set or sharded cluster.
