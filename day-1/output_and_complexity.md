# Day 1 — Set 1: Retail Order Desk
## Console Output and Complexity Analysis

This document combines the actual console output from the supplied `set1.py` and `orders.csv` with the complexity analysis of that implementation.

---

# Part 1 — Console Output

```text
TASK 1: SEARCHING
Total Orders: 50003
Target Order ID: 150000

Linear Search Result:
{'orderId': 150000, 'customerId': 'CUST_2560', 'amount': 274.56, 'createdAt': '2026-01-07 13:26'}

Binary Search Result:
{'orderId': 150000, 'customerId': 'CUST_2560', 'amount': 274.56, 'createdAt': '2026-01-07 13:26'}

TASK 2: SORTING
Total Records Sorted: 10000

Bubble Sort - Top 5:
[{'orderId': 109920, 'customerId': 'CUST_5142', 'amount': 500.0, 'createdAt': '2026-01-05 16:00'}, {'orderId': 105274, 'customerId': 'CUST_1222', 'amount': 499.97, 'createdAt': '2026-01-06 21:18'}, {'orderId': 101082, 'customerId': 'CUST_9158', 'amount': 499.84, 'createdAt': '2026-01-07 02:40'}, {'orderId': 106997, 'customerId': 'CUST_1992', 'amount': 499.81, 'createdAt': '2026-01-07 09:16'}, {'orderId': 106106, 'customerId': 'CUST_6296', 'amount': 499.79, 'createdAt': '2026-01-08 03:06'}]

Merge Sort - Top 5:
[{'orderId': 109920, 'customerId': 'CUST_5142', 'amount': 500.0, 'createdAt': '2026-01-05 16:00'}, {'orderId': 105274, 'customerId': 'CUST_1222', 'amount': 499.97, 'createdAt': '2026-01-06 21:18'}, {'orderId': 101082, 'customerId': 'CUST_9158', 'amount': 499.84, 'createdAt': '2026-01-07 02:40'}, {'orderId': 106997, 'customerId': 'CUST_1992', 'amount': 499.81, 'createdAt': '2026-01-07 09:16'}, {'orderId': 106106, 'customerId': 'CUST_6296', 'amount': 499.79, 'createdAt': '2026-01-08 03:06'}]

All Sorting Results Correct: True

TASK 3: FINDING DUPLICATES
Duplicate Orders Found:
101050
102050
103050

TASK 4: STACK AND QUEUE

Custom Stack:
Latest Edit: Edit Quantity
Undo: Edit Quantity

Custom Queue:
Next Order: 101
Dispatched: 101

TASK 5: COIN CHANGE PROBLEM

Greedy Approach:
Coins Used: [4, 1, 1]
Total Coins: 3

Dynamic Programming:
Minimum Coins: 2
Optimal Combination: 3 + 3
```

---

# Part 2 — Complexity and Data-Structure Rationale

This note describes the implementation in `set1.py` as supplied.

| Task | Implementation in the supplied code | Time complexity | Extra space |
|---|---|---:|---:|
| 1. Linear search | Checks orders one by one until the target ID is found. | O(n) | O(1) |
| 1. Binary search | Repeatedly halves the search interval in an order-ID-sorted list. | O(log n) | O(1) |
| 1. Sorting before binary search | `sorted(orders, key=...)` prepares the searchable list. | O(n log n) | O(n) |
| 2. Bubble sort | Repeated adjacent comparisons and swaps; sorts a copied list. | O(n²) | O(n) for the copied list |
| 2. Merge sort | Recursively splits the list and merges sorted halves. | O(n log n) | O(n) auxiliary space, plus recursion |
| 3. Duplicate detection | A set stores `(customerId, amount, minute)` keys for constant-average-time membership checks. | O(n) average | O(n) |
| 4. Stack | Python list supports append, pop, and peek at the end. | O(1) average for each operation | O(n) |
| 4. Queue | Python list uses append and `pop(0)`. | enqueue O(1) average; dequeue O(n) | O(n) |
| 5. Greedy change | Sorts denominations descending, then repeatedly takes the largest usable coin. | O(d log d + amount/coin steps) | O(d + number of coins returned) |
| 5. Dynamic programming | Computes the minimum number of coins for each value up to the target. | O(amount × d) | O(amount) |

Here, `n` is the number of orders and `d` is the number of denominations.

## What the current program demonstrates

- It loads 50,003 rows from the provided CSV.
- It searches for the last order ID using both linear search and binary search. The binary search receives a list sorted by `orderId`.
- It sorts the first 10,000 records by amount in descending order using bubble sort and merge sort, and prints the top five from each.
- It checks duplicates using the customer ID, exact amount, and `createdAt` minute as the key.
- It demonstrates LIFO behavior with a custom stack and FIFO behavior with a custom list-based queue.
- It compares greedy and dynamic-programming coin change for amount 6 with denominations `[1, 3, 4]`.

## Important scope notes

The supplied Python file does not currently print elapsed-time benchmarks for linear vs binary search, compare sorting against Python's built-in `sorted()`, print the first three sorting passes, or compare the custom stack/queue with built-in alternatives. Those items are mentioned in the assignment brief, but are not implemented in the uploaded code. This output and README intentionally describe only what the supplied code actually runs.
