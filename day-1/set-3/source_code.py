
import time

def linear_search(patients, target):
    comparisons = 0
    for i in range(len(patients)):
        comparisons += 1
        if patients[i]["id"] == target:
            return i, comparisons
    return -1, comparisons

def binary_search(patients, target):
    low = 0
    high = len(patients) - 1
    comparisons = 0
    while low <= high:
        mid = (low + high) // 2
        comparisons += 1
        if patients[mid]["id"] == target:
            return mid, comparisons
        elif patients[mid]["id"] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1, comparisons

def appointment_key(a):
    return (-a["urgency"], a["arrival"])

def selection_sort(appointments):
    arr = appointments.copy()
    swaps = 0
    for i in range(len(arr)):
        best = i
        for j in range(i + 1, len(arr)):
            if appointment_key(arr[j]) < appointment_key(arr[best]):
                best = j
        if best != i:
            arr[i], arr[best] = arr[best], arr[i]
            swaps += 1
    return arr, swaps

def quick_sort(appointments):
    arr = appointments.copy()
    swaps = [0]
    def sort(low, high):
        if low >= high:
            return
        pivot = appointment_key(arr[(low + high) // 2])
        i = low
        j = high
        while i <= j:
            while appointment_key(arr[i]) < pivot:
                i += 1
            while appointment_key(arr[j]) > pivot:
                j -= 1
            if i <= j:
                if i != j:
                    arr[i], arr[j] = arr[j], arr[i]
                    swaps[0] += 1
                i += 1
                j -= 1
        if low < j:
            sort(low, j)
        if i < high:
            sort(i, high)
    sort(0, len(arr) - 1)
    return arr, swaps[0]

def find_double_bookings(appointments):
    seen = set()
    duplicates = []
    for appointment in appointments:
        key = (appointment["patient_id"], appointment["slot"])
        if key in seen:
            duplicates.append(appointment["id"])
        else:
            seen.add(key)
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

def maximum_appointments(appointments):
    arr = sorted(appointments, key=lambda x: x["end"])
    n = len(arr)
    previous = []
    for i in range(n):
        p = -1
        for j in range(i - 1, -1, -1):
            if arr[j]["end"] <= arr[i]["start"]:
                p = j
                break
        previous.append(p)
    dp = [0] * (n + 1)
    for i in range(1, n + 1):
        include = 1 + dp[previous[i - 1] + 1]
        exclude = dp[i - 1]
        dp[i] = max(include, exclude)
    selected = []
    i = n
    while i > 0:
        include = 1 + dp[previous[i - 1] + 1]
        exclude = dp[i - 1]
        if include > exclude:
            selected.append(arr[i - 1])
            i = previous[i - 1] + 1
        else:
            i -= 1
    selected.reverse()
    return dp[n], selected

def greedy_appointments(appointments):
    arr = sorted(appointments, key=lambda x: x["end"])
    selected = []
    last_end = -1
    for appointment in arr:
        if appointment["start"] >= last_end:
            selected.append(appointment)
            last_end = appointment["end"]
    return selected


print("\nTASK 1: SEARCHING")
patients = []
for i in range(20000):
    patients.append({
        "id": 1001 + i,
        "name": "Patient" + str(i + 1)
    })
targets = [1001 + i for i in range(19000, 20000)]
start = time.perf_counter()
linear_comparisons = 0
for target in targets:
    position, comparisons = linear_search(patients, target)
    linear_comparisons += comparisons
linear_time = time.perf_counter() - start
start = time.perf_counter()
binary_comparisons = 0
for target in targets:
    position, comparisons = binary_search(patients, target)
    binary_comparisons += comparisons
binary_time = time.perf_counter() - start
print("Number of Patients:", len(patients))
print("Number of Lookups:", len(targets))
print("\nLinear Search:")
print("Total Comparisons:", linear_comparisons)
print("Time:", round(linear_time, 6), "seconds")
print("\nBinary Search:")
print("Total Comparisons:", binary_comparisons)
print("Time:", round(binary_time, 6), "seconds")
print("\nBinary Search is faster because it halves the search range.")

print("\nTASK 2: SORTING")
appointments = [
    {"id": 101, "urgency": 2, "arrival": "09:30"},
    {"id": 102, "urgency": 4, "arrival": "10:00"},
    {"id": 103, "urgency": 3, "arrival": "09:00"},
    {"id": 104, "urgency": 5, "arrival": "11:00"},
    {"id": 105, "urgency": 4, "arrival": "09:15"},
    {"id": 106, "urgency": 1, "arrival": "08:30"}
]
start = time.perf_counter()
selection_result, selection_swaps = selection_sort(appointments)
selection_time = time.perf_counter() - start
print("\nSelection Sort Result:")
for appointment in selection_result:
    print(appointment)
print("Selection Sort Swaps:", selection_swaps)
print("Selection Sort Time:", round(selection_time, 6), "seconds")
start = time.perf_counter()
quick_result, quick_swaps = quick_sort(appointments)
quick_time = time.perf_counter() - start
print("\nQuick Sort Result:")
for appointment in quick_result:
    print(appointment)
print("Quick Sort Swaps:", quick_swaps)
print("Quick Sort Time:", round(quick_time, 6), "seconds")
print("\nSorting Order: Higher urgency first, then earlier arrival.")

print("\nTASK 3: FINDING DOUBLE-BOOKED APPOINTMENTS")
booking_records = [
    {"id": 201, "patient_id": "P101", "slot": "09:00"},
    {"id": 202, "patient_id": "P102", "slot": "09:00"},
    {"id": 203, "patient_id": "P101", "slot": "09:00"},
    {"id": 204, "patient_id": "P103", "slot": "10:00"},
    {"id": 205, "patient_id": "P101", "slot": "10:00"}
]
duplicates = find_double_bookings(booking_records)
print("Double-Booked Appointment IDs:", duplicates)

print("\nTASK 4: QUEUE AND STACK")
token_queue = Queue(5)
token_queue.enqueue("Patient 301")
token_queue.enqueue("Patient 302")
token_queue.enqueue("Patient 303")
print("Walk-in Queue:")
print("Next Patient:", token_queue.dequeue())
history_stack = Stack(5)
history_stack.push("Patient 401")
history_stack.push("Patient 402")
history_stack.push("Patient 403")
print("\nRecent Patient History:")
print("Last Viewed Patient:", history_stack.pop())

print("\nTASK 5: DIVIDE AND CONQUER VS GREEDY")
appointment_slots = [
    {"id": 1, "start": 1, "end": 3},
    {"id": 2, "start": 2, "end": 5},
    {"id": 3, "start": 4, "end": 6},
    {"id": 4, "start": 6, "end": 7},
    {"id": 5, "start": 5, "end": 8},
    {"id": 6, "start": 8, "end": 10}
]
dp_count, dp_selected = maximum_appointments(appointment_slots)
print("Dynamic Programming:")
print("Maximum Appointments:", dp_count)
print("Selected Appointment IDs:",
        [a["id"] for a in dp_selected])
greedy_selected = greedy_appointments(appointment_slots)
print("\nGreedy Approach:")
print("Maximum Appointments:", len(greedy_selected))
print("Selected Appointment IDs:",
        [a["id"] for a in greedy_selected])



