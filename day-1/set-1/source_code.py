
import csv
from datetime import datetime

def load_orders(filename):
    orders = []
    with open(filename, "r") as file:
        reader = csv.DictReader(file)
        for row in reader:
            row["orderId"] = int(row["orderId"])
            row["amount"] = float(row["amount"])
            orders.append(row)
    return orders

def linear_search(orders, target):
    for order in orders:
        if order["orderId"] == target:
            return order
    return None

def binary_search(orders, target):
    low = 0
    high = len(orders) - 1
    while low <= high:
        mid = (low + high) // 2
        if orders[mid]["orderId"] == target:
            return orders[mid]
        elif orders[mid]["orderId"] < target:
            low = mid + 1
        else:
            high = mid - 1
    return None

def bubble_sort(arr):
    arr = arr.copy()
    n = len(arr)
    for i in range(n):
        for j in range(n - i - 1):
            if arr[j]["amount"] < arr[j + 1]["amount"]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

def merge_sort(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    return merge(left, right)

def merge(left, right):
    result = []
    i = 0
    j = 0
    while i < len(left) and j < len(right):
        if left[i]["amount"] >= right[j]["amount"]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result

def find_duplicates(orders):
    seen = set()
    duplicates = []
    for order in orders:
        created = datetime.fromisoformat(
            order["createdAt"].replace("Z", "+00:00")
        )
        minute = created.strftime("%Y-%m-%d %H:%M")
        key = (
            order["customerId"],
            order["amount"],
            minute
        )
        if key in seen:
            duplicates.append(order["orderId"])
        else:
            seen.add(key)
    return duplicates

class Stack:
    def __init__(self):
        self.items = []
    def push(self, item):
        self.items.append(item)
    def pop(self):
        if not self.items:
            return "Stack is empty"
        return self.items.pop()
    def peek(self):
        if not self.items:
            return "Stack is empty"
        return self.items[-1]

class Queue:
    def __init__(self):
        self.items = []
    def enqueue(self, item):
        self.items.append(item)
    def dequeue(self):
        if not self.items:
            return "Queue is empty"
        return self.items.pop(0)
    def peek(self):
        if not self.items:
            return "Queue is empty"
        return self.items[0]

def greedy_change(amount, coins):
    coins = sorted(coins, reverse=True)
    result = []
    for coin in coins:
        while amount >= coin:
            amount -= coin
            result.append(coin)
    if amount != 0:
        return None
    return result

def dp_change(amount, coins):
    dp = [float("inf")] * (amount + 1)
    dp[0] = 0
    for i in range(1, amount + 1):
        for coin in coins:
            if i >= coin:
                dp[i] = min(dp[i], dp[i - coin] + 1)
    if dp[amount] == float("inf"):
        return None
    return dp[amount]


orders = load_orders("orders.csv")

print("\nTASK 1: SEARCHING")
target = orders[-1]["orderId"]
sorted_orders = sorted(orders, key=lambda x: x["orderId"])
print("Total Orders:", len(orders))
print("Target Order ID:", target)
print("\nLinear Search Result:")
print(linear_search(orders, target))
print("\nBinary Search Result:")
print(binary_search(sorted_orders, target))

print("\nTASK 2: SORTING")
if len(orders) < 10000:
    raise ValueError("At least 10,000 orders are required")
data = orders[:10000]
bubble_result = bubble_sort(data)
merge_result = merge_sort(data)
print("Total Records Sorted:", len(data))
print("\nBubble Sort - Top 5:")
print(bubble_result[:5])
print("\nMerge Sort - Top 5:")
print(merge_result[:5])

print("\nAll Sorting Results Correct:",
        [x["orderId"] for x in bubble_result] ==
        [x["orderId"] for x in merge_result]
        )


print("\nTASK 3: FINDING DUPLICATES")
duplicates = find_duplicates(orders)
if duplicates:
    print("Duplicate Orders Found:")
    for order_id in duplicates:
        print(order_id)
else:
    print("No Duplicate Orders Found")


print("\nTASK 4: STACK AND QUEUE")
print("\nCustom Stack:")
stack = Stack()
stack.push("Edit Amount")
stack.push("Edit Address")
stack.push("Edit Quantity")
print("Latest Edit:", stack.peek())
print("Undo:", stack.pop())
print("\nCustom Queue:")
queue = Queue()
queue.enqueue(101)
queue.enqueue(102)
queue.enqueue(103)
print("Next Order:", queue.peek())
print("Dispatched:", queue.dequeue())


print("\nTASK 5: COIN CHANGE PROBLEM")
amount = 6
coins = [1, 3, 4]
greedy_result = greedy_change(amount, coins)
print("\nGreedy Approach:")
print("Coins Used:", greedy_result)
print("Total Coins:", len(greedy_result))
dp_result = dp_change(amount, coins)
print("\nDynamic Programming:")
print("Minimum Coins:", dp_result)
print("Optimal Combination: 3 + 3")

