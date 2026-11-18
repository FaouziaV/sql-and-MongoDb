# Day 7 – Advanced SQL Joins, Subqueries and MongoDB Lookup

This folder contains the Day 7 database assignments completed during
Hexaware training. The assignments focus on advanced SQL joins,
correlated and nested subqueries, `EXISTS`, `NOT EXISTS`, `IN`, `ANY`,
`ALL`, and MongoDB aggregation using `$lookup`.

## Assignments

### Set 1 – Logistics Shipment Analysis

Analyses shipments across hubs, carriers, customers, and delivery
events.

| File                   | Description                                                                                                                                             |
|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `advanced_reports.sql` | Database and table creation, sample data, join-based business queries, subqueries, subquery-to-join rewrites, and second-highest shipping cost per hub. |
| `reports.js`           | MongoDB `$lookup` pipelines for shipments with delivery events, customers with shipments, and carrier delay statistics.                                 |

### Set 2 – Bank Loan Portfolio

Analyses loans, customers, branches, repayments, and guarantors.

| File                   | Description                                                                                                                                                  |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `advanced_reports.sql` | Database and table creation, sample data, join queries, correlated and uncorrelated subqueries, `EXISTS` / `NOT EXISTS`, and nested branch loan comparisons. |
| `reports.js`           | MongoDB `$lookup` pipelines combining loans with customer and repayment data, including the latest repayment for each loan.                                  |

### Set 3 – Retail Returns and Refunds

Analyses returns, refunds, products, customers, and stores.

| File                   | Description                                                                                                                                            |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| `advanced_reports.sql` | Database and table creation, sample data, join-based reports, `IN` / `NOT IN` and the NULL pitfall, `NOT EXISTS`, `ANY`, `ALL`, and nested subqueries. |
| `reports.js`           | MongoDB `$lookup` pipelines for returns with customer and feedback details, store refund totals, and product return rates with feedback.               |

## Technologies and Tools

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- MongoDB
- MongoDB Compass
- Mongosh

## Running the Scripts

- Run each `advanced_reports.sql` file in SQL Server Management Studio
  (SSMS).
- Run each `reports.js` file using MongoDB Shell (`mongosh`).
- The SQL scripts create their databases, tables, and sample records
  before executing the reports.
- The MongoDB scripts select their database, create collections, insert
  sample documents, and run aggregation pipelines.

## Folder Structure

``` text
day-7/
├── set-1/
│   ├── advanced_reports.sql
│   └── reports.js
├── set-2/
│   ├── advanced_reports.sql
│   └── reports.js
└── set-3/
    ├── advanced_reports.sql
    └── reports.js
```
