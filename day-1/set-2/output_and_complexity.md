# Day 1 — Set 2: Retail Banking Transaction Review
## Actual Console Output

```text

TASK 1: SEARCHING
Linear Search Position: 99999
Linear Search Comparisons: 100000
Binary Search Position: 99999
Binary Search Comparisons: 17

TASK 2: SORTING

Insertion Sort Result:
{'id': 104, 'date': '2026-11-10 08:45:00', 'amount': 300}
{'id': 102, 'date': '2026-11-10 09:15:00', 'amount': 200}
{'id': 101, 'date': '2026-11-10 10:30:00', 'amount': 500}
{'id': 103, 'date': '2026-11-10 10:30:00', 'amount': 800}
{'id': 105, 'date': '2026-11-10 11:00:00', 'amount': 100}

Merge Sort Result:
{'id': 104, 'date': '2026-11-10 08:45:00', 'amount': 300}
{'id': 102, 'date': '2026-11-10 09:15:00', 'amount': 200}
{'id': 101, 'date': '2026-11-10 10:30:00', 'amount': 500}
{'id': 103, 'date': '2026-11-10 10:30:00', 'amount': 800}
{'id': 105, 'date': '2026-11-10 11:00:00', 'amount': 100}

Stability:
Transactions 101 and 103 have the same timestamp.
Both algorithms preserve their original order.

TASK 3: DUPLICATE DETECTION
Duplicate Transaction IDs: [202]

TASK 4: QUEUE AND STACK
Manual Review: Transaction 301
Undo Last Adjustment: Adjustment 300

TASK 5: DIVIDE AND CONQUER VS BRUTE FORCE
Divide and Conquer:
Lowest Amount: 100
Highest Amount: 3000

Brute Force:
Lowest Amount: 100
Highest Amount: 3000
```

---

## Complexity and Data-Structure Rationale

# Complexity and Data-Structure Rationale

This analysis is based on the supplied `set2.py` implementation.

| Task | Approach | Best case | Average case | Worst case | Extra space | Rationale |
|---|---|---:|---:|---:|---:|---|
| 1. Linear search | Sequential scan | O(1) | O(n) | O(n) | O(1) | Can find the target immediately, but may inspect every ID. |
| 1. Binary search | Halves the sorted search interval | O(1) | O(log n) | O(log n) | O(1) | Suitable for the already sorted transaction ID list. |
| 2. Insertion sort | Inserts each item into the sorted prefix | O(n) | O(n²) | O(n²) | O(n) for copied list | Adaptive and stable; efficient for small or nearly sorted statements. |
| 2. Merge sort | Divide, recursively sort, and merge | O(n log n) | O(n log n) | O(n log n) | O(n) auxiliary | Stable when equal-date items are taken from the left half first; scales well to larger statements. |
| 3. Duplicate detection | Dictionary keyed by account, amount, and merchant; compare stored timestamps | O(n) average when key groups are small | O(n + group comparisons) | O(n²) if many records share one key | O(n) | Dictionary groups likely matches and avoids comparing unrelated transactions. |
| 4. Queue | Fixed-size circular array | O(1) | O(1) | O(1) | O(capacity) | FIFO: earliest review item is removed first. |
| 4. Stack | Fixed-size array | O(1) | O(1) | O(1) | O(capacity) | LIFO: most recent adjustment is reversed first. |
| 5. Divide and conquer min/max | Recursively split and combine extrema | O(n) | O(n) | O(n) | O(log n) recursion | Finds both extrema by combining results from smaller subarrays. |
| 5. Brute-force min/max | One pass tracking minimum and maximum | O(n) | O(n) | O(n) | O(1) | Simple baseline with constant auxiliary space. |

Here, `n` is the number of IDs or transactions, and `capacity` is the fixed size of the queue or stack.

## Notes specific to the supplied code

- Task 1 creates 100,000 sorted IDs (`100001` through `200000`) and searches for `200000`. The code counts one comparison per inspected ID in both search functions.
- Task 2 uses five sample transactions. Transactions 101 and 103 share the same timestamp. Insertion sort shifts only strictly later dates, and merge sort chooses from the left side on equal dates, so both preserve their original relative order.
- Task 3 checks the absolute time difference against 60 seconds for matching `(account, amount, merchant)` keys. The inner loop means worst-case time can become quadratic if many transactions share the same key.
- Task 4 implements both structures directly with fixed-size arrays; no library collection is used.
- Task 5 compares recursive divide-and-conquer with a brute-force scan. Both return the same minimum and maximum for the supplied amount list.

## Stability

A stable sort keeps records with equal sort keys in their original relative order. This matters for statements because transactions sharing a timestamp remain in their input order, rather than being arbitrarily reordered. The supplied insertion sort and merge sort are stable for the date key.
