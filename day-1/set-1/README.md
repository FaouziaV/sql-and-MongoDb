# Day 1 — Set 1: Retail Order Desk

This assignment focuses on order searching, sorting, duplicate detection, stack and queue operations, and the coin change problem using Python.

## Files

| File | Description |
|---|---|
| `set1.py` | Python source code implementing all five tasks. |
| `orders.csv` | Input dataset containing 50,003 order records. |
| `output_and_complexity.md` | Console output from running the supplied code, together with time/space complexity analysis and data-structure rationale. |

## Requirements

- Python 3
- No external Python packages are required.

## How to Run

Keep `set1.py` and `orders.csv` in the same folder. The program opens the input file using the exact filename `orders.csv`.

```bash
python set1.py
```

If your downloaded CSV has a different name, rename it to `orders.csv` before running the script.

## Tasks Covered

1. **Searching:** Linear search and binary search to retrieve an order by ID.
2. **Sorting:** Bubble sort and merge sort to rank orders by amount in descending order.
3. **Duplicate Detection:** A set-based approach using `customerId`, `amount`, and the creation minute.
4. **Stack and Queue:** Custom stack for undo operations and custom queue for dispatch.
5. **Coin Change:** Greedy and dynamic-programming approaches using amount `6` and denominations `[1, 3, 4]`.

## Results and Complexity

See [`output_and_complexity.md`](output_and_complexity.md) for the captured console output and the complexity analysis based on the supplied `set1.py`.

