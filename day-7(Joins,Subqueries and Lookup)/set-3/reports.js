
use retail_returns_db;

db.createCollection("stores");
db.createCollection("customers");
db.createCollection("products");
db.createCollection("employees");
db.createCollection("sales");
db.createCollection("returns");
db.createCollection("refunds");
db.createCollection("returns_feedback");


// Stores
db.stores.insertMany([
  { storeId: 1, storeName: "Coimbatore Central", region: "South" },
  { storeId: 2, storeName: "Chennai Mall", region: "South" },
  { storeId: 3, storeName: "Bengaluru Plaza", region: "South" },
  { storeId: 4, storeName: "Mumbai Market", region: "West" },
  { storeId: 5, storeName: "Pune City Store", region: "West" }
]);

// Customers
db.customers.insertMany([
  { customerId: 1, customerName: "Arun Kumar", email: "arun@example.com" },
  { customerId: 2, customerName: "Divya Ravi", email: "divya@example.com" },
  { customerId: 3, customerName: "Karthik S", email: "karthik@example.com" },
  { customerId: 4, customerName: "Meena P", email: "meena@example.com" },
  { customerId: 5, customerName: "Rahul N", email: "rahul@example.com" },
  { customerId: 6, customerName: "Priya M", email: "priya@example.com" }
]);

// Products
db.products.insertMany([
  { productId: 1, productName: "Wireless Mouse", category: "Electronics", price: 800 },
  { productId: 2, productName: "Keyboard", category: "Electronics", price: 1500 },
  { productId: 3, productName: "Travel Bag", category: "Accessories", price: 2200 },
  { productId: 4, productName: "Water Bottle", category: "Home", price: 400 },
  { productId: 5, productName: "Headphones", category: "Electronics", price: 2500 },
  { productId: 6, productName: "Desk Lamp", category: "Home", price: 1200 }
]);

// Employees
db.employees.insertMany([
  { employeeId: 1, employeeName: "Ramesh", managerId: null },
  { employeeId: 2, employeeName: "Suresh", managerId: 1 },
  { employeeId: 3, employeeName: "Anitha", managerId: 1 },
  { employeeId: 4, employeeName: "Kavya", managerId: 2 },
  { employeeId: 5, employeeName: "Manoj", managerId: 2 },
  { employeeId: 6, employeeName: "Priya", managerId: 3 }
]);

// Sales
db.sales.insertMany([
  { saleId: 101, productId: 1, customerId: 1, storeId: 1, employeeId: 2, saleDate: ISODate("2026-01-05"), quantity: 10, unitPrice: 800 },
  { saleId: 102, productId: 2, customerId: 2, storeId: 1, employeeId: 3, saleDate: ISODate("2026-01-08"), quantity: 8, unitPrice: 1500 },
  { saleId: 103, productId: 3, customerId: 1, storeId: 2, employeeId: 4, saleDate: ISODate("2026-01-10"), quantity: 5, unitPrice: 2200 },
  { saleId: 104, productId: 4, customerId: 3, storeId: 2, employeeId: 5, saleDate: ISODate("2026-01-12"), quantity: 20, unitPrice: 400 },
  { saleId: 105, productId: 5, customerId: 4, storeId: 3, employeeId: 6, saleDate: ISODate("2026-01-15"), quantity: 10, unitPrice: 2500 },
  { saleId: 106, productId: 1, customerId: 5, storeId: 3, employeeId: 2, saleDate: ISODate("2026-01-18"), quantity: 5, unitPrice: 800 },
  { saleId: 107, productId: 2, customerId: 6, storeId: 4, employeeId: 3, saleDate: ISODate("2026-01-20"), quantity: 10, unitPrice: 1500 },
  { saleId: 108, productId: 3, customerId: 2, storeId: 4, employeeId: 4, saleDate: ISODate("2026-01-22"), quantity: 4, unitPrice: 2200 },
  { saleId: 109, productId: 5, customerId: 3, storeId: 5, employeeId: 5, saleDate: ISODate("2026-01-25"), quantity: 6, unitPrice: 2500 },
  { saleId: 110, productId: 6, customerId: 4, storeId: 5, employeeId: 6, saleDate: ISODate("2026-01-28"), quantity: 10, unitPrice: 1200 },
  { saleId: 111, productId: 1, customerId: 6, storeId: 1, employeeId: 2, saleDate: ISODate("2026-02-01"), quantity: 5, unitPrice: 800 },
  { saleId: 112, productId: 4, customerId: 5, storeId: 2, employeeId: 4, saleDate: ISODate("2026-02-03"), quantity: 10, unitPrice: 400 }
]);

// Returns
db.returns.insertMany([
  { returnId: 201, saleId: 101, returnDate: ISODate("2026-02-05"), returnQuantity: 2, reason: "Damaged" },
  { returnId: 202, saleId: 102, returnDate: ISODate("2026-02-06"), returnQuantity: 1, reason: "Wrong item" },
  { returnId: 203, saleId: 103, returnDate: ISODate("2026-02-08"), returnQuantity: 1, reason: "Size issue" },
  { returnId: 204, saleId: 105, returnDate: ISODate("2026-02-10"), returnQuantity: 2, reason: "Defective" },
  { returnId: 205, saleId: 106, returnDate: ISODate("2026-02-12"), returnQuantity: 1, reason: "Damaged" },
  { returnId: 206, saleId: 108, returnDate: ISODate("2026-02-14"), returnQuantity: 1, reason: "Changed mind" },
  { returnId: 207, saleId: 109, returnDate: ISODate("2026-02-16"), returnQuantity: 2, reason: "Defective" },
  { returnId: 208, saleId: 111, returnDate: ISODate("2026-02-18"), returnQuantity: 1, reason: "Damaged" }
]);

// Refunds
db.refunds.insertMany([
  { refundId: 301, returnId: 201, refundDate: ISODate("2026-02-07"), refundAmount: 1600 },
  { refundId: 302, returnId: 202, refundDate: ISODate("2026-02-08"), refundAmount: 1500 },
  { refundId: 303, returnId: 204, refundDate: ISODate("2026-02-12"), refundAmount: 5000 },
  { refundId: 304, returnId: 205, refundDate: ISODate("2026-02-14"), refundAmount: 800 },
  { refundId: 305, returnId: 207, refundDate: ISODate("2026-02-18"), refundAmount: 5000 }
]);

// Returns Feedback
db.returns_feedback.insertMany([
  { feedbackId: 401, returnId: 201, feedbackDate: ISODate("2026-02-08"), rating: 2, comments: "Product arrived damaged" },
  { feedbackId: 402, returnId: 202, feedbackDate: ISODate("2026-02-09"), rating: 3, comments: "Incorrect product received" },
  { feedbackId: 403, returnId: 203, feedbackDate: ISODate("2026-02-10"), rating: 4, comments: "Return process was easy" },
  { feedbackId: 404, returnId: 204, feedbackDate: ISODate("2026-02-13"), rating: 1, comments: "Product was defective" },
  { feedbackId: 405, returnId: 205, feedbackDate: ISODate("2026-02-15"), rating: 2, comments: "Packaging was poor" },
  { feedbackId: 406, returnId: 207, feedbackDate: ISODate("2026-02-19"), rating: 3, comments: "Refund received" }
]);

// 4. PIPELINE 1: RETURNS WITH CUSTOMER DETAILS

// $lookup joins returns, sales and customers.
// Feedback is also included.

db.returns.aggregate([
  {
    $lookup: {
      from: "sales",
      localField: "saleId",
      foreignField: "saleId",
      as: "saleDetails"
    }
  },
  {
    $unwind: "$saleDetails"
  },
  {
    $lookup: {
      from: "customers",
      localField: "saleDetails.customerId",
      foreignField: "customerId",
      as: "customerDetails"
    }
  },
  {
    $unwind: "$customerDetails"
  },
  {
    $lookup: {
      from: "returns_feedback",
      localField: "returnId",
      foreignField: "returnId",
      as: "feedback"
    }
  },
  {
    $project: {
      _id: 0,
      returnId: 1,
      reason: 1,
      returnQuantity: 1,
      customerName: "$customerDetails.customerName",
      feedback: 1
    }
  }
]);

// 5. PIPELINE 2: STORES WITH REFUND DETAILS

// Calculates total refund value for each store.

db.stores.aggregate([
  {
    $lookup: {
      from: "sales",
      localField: "storeId",
      foreignField: "storeId",
      as: "salesDetails"
    }
  },
  {
    $unwind: {
      path: "$salesDetails",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: "returns",
      localField: "salesDetails.saleId",
      foreignField: "saleId",
      as: "returnDetails"
    }
  },
  {
    $unwind: {
      path: "$returnDetails",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: "refunds",
      localField: "returnDetails.returnId",
      foreignField: "returnId",
      as: "refundDetails"
    }
  },
  {
    $unwind: {
      path: "$refundDetails",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $group: {
      _id: "$storeId",
      storeName: { $first: "$storeName" },
      region: { $first: "$region" },
      totalRefund: {
        $sum: { $ifNull: ["$refundDetails.refundAmount", 0] }
      }
    }
  },
  {
    $project: {
      _id: 0,
      storeId: "$_id",
      storeName: 1,
      region: 1,
      totalRefund: 1
    }
  },
  {
    $sort: { totalRefund: -1 }
  }
]);

// 6. PIPELINE 3: PRODUCT RETURN RATE WITH FEEDBACK

// Calculates product return rate.
// Also retrieves customer feedback for each return.

db.products.aggregate([
  {
    $lookup: {
      from: "sales",
      localField: "productId",
      foreignField: "productId",
      as: "salesDetails"
    }
  },
  {
    $unwind: {
      path: "$salesDetails",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: "returns",
      localField: "salesDetails.saleId",
      foreignField: "saleId",
      as: "returnDetails"
    }
  },
  {
    $unwind: {
      path: "$returnDetails",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: "returns_feedback",
      localField: "returnDetails.returnId",
      foreignField: "returnId",
      as: "feedback"
    }
  },
  {
    $group: {
      _id: "$productId",
      productName: { $first: "$productName" },
      totalSold: {
        $sum: { $ifNull: ["$salesDetails.quantity", 0] }
      },
      totalReturned: {
        $sum: { $ifNull: ["$returnDetails.returnQuantity", 0] }
      },
      feedback: { $push: "$feedback" }
    }
  },
  {
    $project: {
      _id: 0,
      productId: "$_id",
      productName: 1,
      totalSold: 1,
      totalReturned: 1,
      returnRate: {
        $cond: [
          { $gt: ["$totalSold", 0] },
          {
            $multiply: [
              { $divide: ["$totalReturned", "$totalSold"] },
              100
            ]
          },
          0
        ]
      },
      feedback: 1
    }
  },
  {
    $sort: { returnRate: -1 }
  }
]);

