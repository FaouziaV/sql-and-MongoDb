# Retail Inventory Reservation — Explanation Note

## 1. SQL reservation transaction
The SQL Server transaction checks that the product exists, the requested quantity is positive, and sufficient stock is available. It decrements stock, inserts an order, and inserts an order line inside one transaction. If any step fails, `ROLLBACK` reverses all transaction changes so stock cannot be decremented without the corresponding order records.

The insufficient-stock test requests 999 units when the sample product has fewer. The validation raises an error before stock/order changes. The expected error is caught and rolled back. Evidence queries show stock remains the same and no failed order or order line was inserted.

## 2. Correlated subquery
The inner query calculates average stock for the same category as the outer product. The outer query returns products with stock below that category average. It is correlated because the inner query references `p.category` from the outer query.

## 3. CTE ranking
The first CTE totals sold units by product. The second assigns `ROW_NUMBER()` separately within each category (`PARTITION BY category`), with highest sales first. Filtering row number <= 3 returns the top three per category. A product ID tie-breaker makes ordering deterministic.

## 4. Month-on-month change
Sales are aggregated by product and month. `LAG()` returns the prior month's total and `LEAD()` the next month's total. Current month minus previous month gives the change. A NULL previous value means the first month in that product's available sales data.

## 5. MongoDB: single-document update vs transaction
A conditional single-document update is atomic. The filter `stock: { $gte: reserveQty }` verifies enough inventory, while `$inc: { stock: -reserveQty }` decrements it atomically. If the filter doesn't match, no stock is changed.

A multi-document transaction is needed when reservation must atomically update multiple documents—for example, decrement stock and create an order/order-lines document(s), or update inventory plus a separate payment/reservation record. Transactions add coordination, conflict handling, and operational overhead. For a single product stock document alone, the conditional `$inc` is simpler and generally preferred.
