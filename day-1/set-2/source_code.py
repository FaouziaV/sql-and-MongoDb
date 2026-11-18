
from datetime import datetime

def linear_search(ids, target):
    comparisons = 0

    for i in range(len(ids)):
        comparisons += 1

        if ids[i] == target:
            return i, comparisons

    return -1, comparisons

def binary_search(ids, target):
    low = 0
    high = len(ids) - 1
    comparisons = 0
    while low <= high:
        mid = (low + high) // 2
        comparisons += 1
        if ids[mid] == target:
            return mid, comparisons
        elif ids[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1, comparisons

def insertion_sort(transactions):
    arr = transactions.copy()
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and arr[j]["date"] > key["date"]:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
    return arr

def merge_sort(transactions):
    if len(transactions) <= 1:
        return transactions
    mid = len(transactions) // 2
    left = merge_sort(transactions[:mid])
    right = merge_sort(transactions[mid:])
    return merge(left, right)

def merge(left, right):
    result = []
    i = 0
    j = 0
    while i < len(left) and j < len(right):
        if left[i]["date"] <= right[j]["date"]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result

def find_duplicates(transactions):
    seen = {}
    duplicates = []
    for t in transactions:
        key = (t["account"], t["amount"], t["merchant"])
        current_time = datetime.strptime(
            t["time"], "%Y-%m-%d %H:%M:%S"
        )
        if key not in seen:
            seen[key] = []
        duplicate_found = False
        for previous_time in seen[key]:
            difference = abs(
                (current_time - previous_time).total_seconds()
            )
            if difference <= 60:
                duplicate_found = True
                break
        if duplicate_found:
            duplicates.append(t["id"])
        seen[key].append(current_time)
    return duplicates

class Queue:
    def __init__(self, capacity):
        self.items = [None] * capacity
        self.front = 0
        self.rear = -1
        self.count = 0
        self.capacity = capacity
    def enqueue(self, item):
        if self.count == self.capacity:
            print("Queue is full")
            return
        self.rear = (self.rear + 1) % self.capacity
        self.items[self.rear] = item
        self.count += 1
    def dequeue(self):
        if self.count == 0:
            print("Queue is empty")
            return None
        item = self.items[self.front]
        self.items[self.front] = None
        self.front = (self.front + 1) % self.capacity
        self.count -= 1
        return item

class Stack:
    def __init__(self, capacity):
        self.items = [None] * capacity
        self.top = -1
        self.capacity = capacity
    def push(self, item):
        if self.top == self.capacity - 1:
            print("Stack is full")
            return
        self.top += 1
        self.items[self.top] = item
    def pop(self):
        if self.top == -1:
            print("Stack is empty")
            return None
        item = self.items[self.top]
        self.items[self.top] = None
        self.top -= 1
        return item

def find_min_max(arr, low, high):
    if low == high:
        return arr[low], arr[low]
    if high == low + 1:
        if arr[low] < arr[high]:
            return arr[low], arr[high]
        else:
            return arr[high], arr[low]
    mid = (low + high) // 2
    left_min, left_max = find_min_max(arr, low, mid)
    right_min, right_max = find_min_max(arr, mid + 1, high)
    return min(left_min, right_min), max(left_max, right_max)

def brute_force_min_max(arr):
    minimum = arr[0]
    maximum = arr[0]
    for value in arr:
        if value < minimum:
            minimum = value
        if value > maximum:
            maximum = value
    return minimum, maximum


print("\nTASK 1: SEARCHING")
ids = list(range(100001, 200001))
target = 200000
position, linear_count = linear_search(ids, target)
print("Linear Search Position:", position)
print("Linear Search Comparisons:", linear_count)
position, binary_count = binary_search(ids, target)
print("Binary Search Position:", position)
print("Binary Search Comparisons:", binary_count)

print("\nTASK 2: SORTING")
transactions = [
    {"id": 101, "date": "2026-11-10 10:30:00", "amount": 500},
    {"id": 102, "date": "2026-11-10 09:15:00", "amount": 200},
    {"id": 103, "date": "2026-11-10 10:30:00", "amount": 800},
    {"id": 104, "date": "2026-11-10 08:45:00", "amount": 300},
    {"id": 105, "date": "2026-11-10 11:00:00", "amount": 100}
]
insertion_result = insertion_sort(transactions)
merge_result = merge_sort(transactions)
print("\nInsertion Sort Result:")
for t in insertion_result:
    print(t)

print("\nMerge Sort Result:")
for t in merge_result:
    print(t)
print("\nStability:")
print("Transactions 101 and 103 have the same timestamp.")
print("Both algorithms preserve their original order.")

print("\nTASK 3: DUPLICATE DETECTION")
transactions = [
    {"id": 201, "account": "A101", "amount": 500,
        "merchant": "Amazon", "time": "2026-11-10 10:00:00"},
    {"id": 202, "account": "A101", "amount": 500,
        "merchant": "Amazon", "time": "2026-11-10 10:00:45"},
    {"id": 203, "account": "A102", "amount": 300,
        "merchant": "Flipkart", "time": "2026-11-10 10:05:00"},
    {"id": 204, "account": "A101", "amount": 500,
        "merchant": "Amazon", "time": "2026-11-10 10:03:00"}
]
duplicates = find_duplicates(transactions)
print("Duplicate Transaction IDs:", duplicates)

print("\nTASK 4: QUEUE AND STACK")
review_queue = Queue(5)
review_queue.enqueue("Transaction 301")
review_queue.enqueue("Transaction 302")
review_queue.enqueue("Transaction 303")
print("Manual Review:", review_queue.dequeue())
adjustment_stack = Stack(5)
adjustment_stack.push("Adjustment 100")
adjustment_stack.push("Adjustment 200")
adjustment_stack.push("Adjustment 300")
print("Undo Last Adjustment:", adjustment_stack.pop())

print("\nTASK 5: DIVIDE AND CONQUER VS BRUTE FORCE")
amounts = [500, 1200, 250, 3000, 750, 100, 1800, 450]
minimum, maximum = find_min_max(
    amounts, 0, len(amounts) - 1
)
print("Divide and Conquer:")
print("Lowest Amount:", minimum)
print("Highest Amount:", maximum)
minimum, maximum = brute_force_min_max(amounts)
print("\nBrute Force:")
print("Lowest Amount:", minimum)
print("Highest Amount:", maximum)

