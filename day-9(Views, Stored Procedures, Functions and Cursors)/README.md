# Day 9 – Views, Stored Procedures, Functions and Cursors

This repository contains the Day 9 assignment completed using **SQL Server** and **MongoDB**. The assignment is organized into three sets, each in its own folder.


## Folder Structure

```text
day-9/
├── set-1 (Retail Order Fulfilment)/
│   ├── Cursor_vs_Set_Based_Comparison.md
│   ├── mongo_view.js
│   └── query.sql
├── set-2 (Insurance Premium Processing)/
│   ├── Cursor_vs_Set_Based_Insurance_Notes.md
│   ├── Query.sql
│   └── mongo_view.js
└── set-3 (Telecom Low-Balance Follow-up)/
    ├── Query.sql
    ├── Telecom_Cursor_vs_SetBased_Notes.md
    └── mongo_view.js
```

## Set 1 – Retail Order Fulfilment
- SQL views for order summary and low stock.
- Stored procedure to place orders with stock validation and transaction handling.
- Functions to calculate order totals and retrieve customer orders.
- Cursor and set-based approaches for follow-up on pending orders.
- MongoDB view for order-status counts.


## Set 2 – Insurance Premium Processing
- View for policies due soon while omitting sensitive information.
- Stored procedure for policy renewal with validation, premium calculation, and audit logging.
- Functions for discounted premiums and renewal quotes.
- Cursor and set-based approaches for handling lapsed policies.
- MongoDB view for unresolved customer complaints.


## Set 3 – Telecom Low-Balance Follow-up
- Views for prepaid subscribers and recharge summaries.
- Recharge stored procedure with validation, transaction handling, and output balance.
- Functions for validity days remaining and last five recharges.
- Cursor and set-based approaches for low-balance notifications, with execution-time comparison.
- MongoDB view for unread notification counts per subscriber.


## Technologies Used
- Microsoft SQL Server
- SQL (Views, Stored Procedures, Functions, Transactions, Cursors)
- MongoDB 8.0
- MongoDB Aggregation Pipeline and Views


## How to Run
### SQL Server
1. Open the `Query.sql` or `query.sql` file inside the required set folder in SQL Server Management Studio.
2. Execute the script.
3. Review the output and test queries included in the script.

### MongoDB
1. Open MongoDB Compass and launch Mongosh.
2. Open the `mongo_view.js` file in the selected set folder.
3. Copy and run the script in Mongosh.
4. Query the created collections and views to verify the results.


## Cursor vs. Set-Based
Each set includes a comparison note describing the cursor-based solution and its set-based alternative. The comparison discusses their approach and, where applicable, execution-time observations.
