// ============================================
// RETAIL INVENTORY - STOCK RESERVATION
// ============================================

// 1. CREATE / USE DATABASE
use RetailInventoryDB;

// 2. CREATE COLLECTION
db.createCollection("products");

// 3. INSERT PRODUCT (UPSERT)
db.products.updateOne(
    { productId: 501 },
    {
        $setOnInsert: {
            productId: 501,
            productName: "Wireless Mouse",
            category: "Accessories",
            stock: 25,
            price: 1200
        }
    },
    { upsert: true }
);

// 4. DISPLAY STOCK BEFORE RESERVATION
print("===== STOCK BEFORE =====");

db.products.find(
    { productId: 501 },
    { _id: 0, productId: 1, productName: 1, stock: 1 }
).forEach(printjson);

// 5. RESERVE STOCK
const reserveQty = 3;

const result = db.products.updateOne(
    {
        productId: 501,
        stock: { $gte: reserveQty }
    },
    {
        $inc: { stock: -reserveQty }
    }
);

if (result.modifiedCount === 1) {
    print("Reservation successful. Reserved quantity: " + reserveQty);
} else {
    print("Reservation rejected: product missing or insufficient stock.");
}

// 6. DISPLAY STOCK AFTER RESERVATION
print("===== STOCK AFTER RESERVATION =====");

db.products.find(
    { productId: 501 },
    { _id: 0, productId: 1, productName: 1, stock: 1 }
).forEach(printjson);

// 7. TEST EXCESSIVE RESERVATION
const excessiveQty = 999;

const failed = db.products.updateOne(
    {
        productId: 501,
        stock: { $gte: excessiveQty }
    },
    {
        $inc: { stock: -excessiveQty }
    }
);

if (failed.modifiedCount === 1) {
    print("Unexpected: excessive reservation succeeded.");
} else {
    print("Expected: excessive reservation rejected; stock remains unchanged.");
}

// 8. DISPLAY FINAL STOCK
print("===== FINAL STOCK =====");

db.products.find(
    { productId: 501 },
    { _id: 0, productId: 1, productName: 1, stock: 1 }
).forEach(printjson);
