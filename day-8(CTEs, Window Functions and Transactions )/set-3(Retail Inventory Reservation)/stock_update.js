
db = db.getSiblingDB("RetailInventoryDB");

db.products.updateOne(
  { productId: 501 },
  { $setOnInsert: { productId: 501, productName: "Wireless Mouse", category: "Accessories", stock: 25, price: 1200 } },
  { upsert: true }
);

print("STOCK BEFORE:");
db.products.find({ productId: 501 }, { _id: 0, productId: 1, productName: 1, stock: 1 }).forEach(printjson);

const reserveQty = 3;

const result = db.products.updateOne(
  { productId: 501, stock: { $gte: reserveQty } },
  { $inc: { stock: -reserveQty } }
);

if (result.modifiedCount === 1) print("Reservation successful. Reserved quantity: " + reserveQty);
else print("Reservation rejected: product missing or insufficient stock.");

print("STOCK AFTER:");
db.products.find({ productId: 501 }, { _id: 0, productId: 1, productName: 1, stock: 1 }).forEach(printjson);

const excessiveQty = 999;
const failed = db.products.updateOne(
  { productId: 501, stock: { $gte: excessiveQty } },
  { $inc: { stock: -excessiveQty } }
);
if (failed.modifiedCount === 1) print("Unexpected: excessive reservation succeeded.");
else print("Expected: excessive reservation rejected; stock remains unchanged.");

print("FINAL STOCK:");
db.products.find({ productId: 501 }, { _id: 0, productId: 1, productName: 1, stock: 1 }).forEach(printjson);
