# Day 1 — Set 3: Hospital Appointment Desk
## Actual Console Output

```text

TASK 1: SEARCHING
Number of Patients: 20000
Number of Lookups: 1000

Linear Search:
Total Comparisons: 19500500
Time: 1.185601 seconds

Binary Search:
Total Comparisons: 13371
Time: 0.002057 seconds

Binary Search is faster because it halves the search range.

TASK 2: SORTING

Selection Sort Result:
{'id': 104, 'urgency': 5, 'arrival': '11:00'}
{'id': 105, 'urgency': 4, 'arrival': '09:15'}
{'id': 102, 'urgency': 4, 'arrival': '10:00'}
{'id': 103, 'urgency': 3, 'arrival': '09:00'}
{'id': 101, 'urgency': 2, 'arrival': '09:30'}
{'id': 106, 'urgency': 1, 'arrival': '08:30'}
Selection Sort Swaps: 4
Selection Sort Time: 1.5e-05 seconds

Quick Sort Result:
{'id': 104, 'urgency': 5, 'arrival': '11:00'}
{'id': 105, 'urgency': 4, 'arrival': '09:15'}
{'id': 102, 'urgency': 4, 'arrival': '10:00'}
{'id': 103, 'urgency': 3, 'arrival': '09:00'}
{'id': 101, 'urgency': 2, 'arrival': '09:30'}
{'id': 106, 'urgency': 1, 'arrival': '08:30'}
Quick Sort Swaps: 4
Quick Sort Time: 1.3e-05 seconds

Sorting Order: Higher urgency first, then earlier arrival.

TASK 3: FINDING DOUBLE-BOOKED APPOINTMENTS
Double-Booked Appointment IDs: [203]

TASK 4: QUEUE AND STACK
Walk-in Queue:
Next Patient: Patient 301

Recent Patient History:
Last Viewed Patient: Patient 403

TASK 5: DIVIDE AND CONQUER VS GREEDY
Dynamic Programming:
Maximum Appointments: 4
Selected Appointment IDs: [1, 3, 4, 6]

Greedy Approach:
Maximum Appointments: 4
Selected Appointment IDs: [1, 3, 4, 6]
```

---

## Complexity and Data-Structure Rationale

# Complexity and Data-Structure Rationale

This analysis is based on the supplied `set3.py` implementation.

| Task | Approach | Best case | Average case | Worst case | Extra space | Rationale |
|---|---|---:|---:|---:|---:|---|
| 1. Linear search | Sequential patient-ID scan | O(1) | O(n) | O(n) | O(1) | Finds a first-position match immediately; may inspect all records. |
| 1. Binary search | Halves the sorted ID range | O(1) | O(log n) | O(log n) | O(1) | Efficient for patient records already sorted by ID. |
| 2. Selection sort | Selects the best remaining appointment each pass | O(n²) | O(n²) | O(n²) | O(n) for copied list | Simple and uses at most O(n) swaps; not stable in general. |
| 2. Quick sort | In-place partitioning around middle element pivot | O(n log n) | O(n log n) | O(n²) | O(log n) average recursion; O(n) worst | Usually faster on larger lists, but pivot/partition behavior affects worst case. |
| 3. Double-booking detection | Set keyed by `(patient_id, slot)` | O(n) average | O(n) average | O(n²) theoretical with hash collisions | O(n) | Set membership avoids scanning all earlier appointments for each record. |
| 4. Queue | Fixed-size circular array | O(1) | O(1) | O(1) | O(capacity) | FIFO serves walk-in patients in arrival order. |
| 4. Stack | Fixed-size array | O(1) | O(1) | O(1) | O(capacity) | LIFO returns the most recently viewed patient first. |
| 5. Weighted interval scheduling DP | Sort by end time, find compatible predecessor, fill DP table | O(n log n + n²) in this implementation | O(n²) | O(n²) | O(n) | Dynamic programming considers including or excluding each appointment. The predecessor search is a backward linear scan. |
| 5. Greedy comparison | Sort by end time and select compatible appointments | O(n log n) | O(n log n) | O(n log n) | O(n) | Earliest-finish-time greedy is optimal for maximizing the number of non-overlapping appointments when all appointments have equal value. |

Here, `n` is the number of patient records or appointments, and `capacity` is the fixed array size.

## Important observations from the supplied code

- Task 1 creates 20,000 patient records and performs 1,000 lookups for IDs near the end of the list. It measures total elapsed time and total comparisons for both search methods. The patient list is in ascending ID order, as binary search requires.
- Task 2 orders appointments by higher urgency first, then earlier arrival time. It reports swap counts and elapsed time for both algorithms.
- Task 3 uses a set for `(patient_id, slot)` keys and reports the appointment IDs that repeat that combination.
- Task 4 implements a circular-array queue and array-backed stack without importing collection classes.
- Task 5's DP is weighted-interval-scheduling style, but each appointment contributes a value of one. Therefore, the objective is to maximize the number of compatible appointments, not total appointment duration or revenue.
- The DP implementation finds each compatible predecessor using a backward scan, so its predecessor-building phase is O(n²). A binary-search predecessor lookup could reduce that phase to O(n log n).
- The greedy method is a valid comparison for the unweighted maximum-cardinality interval scheduling problem represented by this code.

## Sorting trace (selection sort)

The code's appointment priority is higher urgency first, then earlier arrival. The input order is:

`101(urgency 2, 09:30), 102(4, 10:00), 103(3, 09:00), 104(5, 11:00), 105(4, 09:15), 106(1, 08:30)`

Selection-sort passes (after each pass):

1. Select appointment 104 (urgency 5) and swap with 101: `104, 102, 103, 101, 105, 106`
2. Among the remaining records, select 105 (urgency 4, earlier arrival than 102) and swap with 102: `104, 105, 103, 101, 102, 106`
3. Select 102 (urgency 4) and swap with 103: `104, 105, 102, 101, 103, 106`
4. Select 101 (urgency 2) and swap with 103: `104, 105, 102, 103, 101, 106`
5. Remaining order is completed: `104, 105, 102, 103, 101, 106`

The first three passes show how the sorted prefix grows one appointment at a time.
