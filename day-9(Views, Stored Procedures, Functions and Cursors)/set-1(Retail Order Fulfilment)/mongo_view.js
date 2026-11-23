// ============================================
// RETAIL ORDER FULFILMENT - MONGODB
// ============================================

// 1. CREATE / SELECT DATABASE
use RetailOrderFulfilment

// ============================================
// 2. INSERT CUSTOMERS
// ============================================

db.Customers.insertMany([
    {
        customerId: 1,
        customerName: "Arun Kumar",
        email: "arun@example.com",
        phone: "9876500001"
    },
    {
        customerId: 2,
        customerName: "Priya S",
        email: "priya@example.com",
        phone: "9876500002"
    },
    {
        customerId: 3,
        customerName: "Rahul M",
        email: "rahul@example.com",
        phone: "9876500003"
    }
]);

// ============================================
// 3. INSERT SUPPLIERS
// ============================================

db.Suppliers.insertMany([
    {
        supplierId: 1,
        supplierName: "ABC Distributors",
        contactEmail: "abc@example.com"
    },
    {
        supplierId: 2,
        supplierName: "XYZ Wholesale",
        contactEmail: "xyz@example.com"
    }
]);

// ============================================
// 4. INSERT PRODUCTS
// ============================================

db.Products.insertMany([
    {
        productId: 1,
        productName: "Keyboard",
        sellingPrice: 750,
        costPrice: 500,
        supplierId: 1,
        stockQuantity: 40,
        reorderLevel: 10
    },
    {
        productId: 2,
        productName: "Mouse",
        sellingPrice: 450,
        costPrice: 250,
        supplierId: 1,
        stockQuantity: 8,
        reorderLevel: 10
    },
    {
        productId: 3,
        productName: "Monitor",
        sellingPrice: 8500,
        costPrice: 7000,
        supplierId: 2,
        stockQuantity: 15,
        reorderLevel: 5
    },
    {
        productId: 4,
        productName: "USB Cable",
        sellingPrice: 150,
        costPrice: 80,
        supplierId: 2,
        stockQuantity: 4,
        reorderLevel: 10
    },
    {
        productId: 5,
        productName: "Headset",
        sellingPrice: 1200,
        costPrice: 850,
        supplierId: 1,
        stockQuantity: 25,
        reorderLevel: 8
    }
]);

// ============================================
// 5. INSERT ORDERS
// ============================================

db.Orders.insertMany([
    {
        orderId: 1,
        customerId: 1,
        orderDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        orderStatus: "Pending"
    },
    {
        orderId: 2,
        customerId: 2,
        orderDate: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        orderStatus: "Pending"
    },
    {
        orderId: 3,
        customerId: 3,
        orderDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        orderStatus: "Processing"
    }
]);

// ============================================
// 6. INSERT ORDER LINES
// ============================================

db.OrderLines.insertMany([
    {
        orderLineId: 1,
        orderId: 1,
        productId: 1,
        quantity: 2,
        unitPrice: 750
    },
    {
        orderLineId: 2,
        orderId: 1,
        productId: 2,
        quantity: 1,
        unitPrice: 450
    },
    {
        orderLineId: 3,
        orderId: 2,
        productId: 3,
        quantity: 1,
        unitPrice: 8500
    },
    {
        orderLineId: 4,
        orderId: 3,
        productId: 5,
        quantity: 2,
        unitPrice: 1200
    }
]);

// ============================================
// 7. INSERT FOLLOW-UP RECORDS
// ============================================

db.OrderFollowUps.insertMany([
    {
        followUpId: 1,
        orderId: 1,
        followUpDate: new Date(),
        followUpNote: "Order pending for more than 3 days"
    }
]);

// ============================================
// 8. CREATE MONGODB VIEW
//    ORDER STATUS COUNTS
// ============================================

db.createView(
    "vw_order_status_counts",
    "Orders",
    [
        {
            $group: {
                _id: "$orderStatus",
                orderCount: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                status: "$_id",
                orderCount: 1
            }
        },
        {
            $sort: {
                status: 1
            }
        }
    ]
);

// ============================================
// 9. DISPLAY VIEW
// ============================================

db.vw_order_status_counts.find();

// ============================================
// 10. VIEW ALL COLLECTIONS
// ============================================

show collections

// ============================================
// 11. VIEW ALL DATA
// ============================================

db.Customers.find();
db.Suppliers.find();
db.Products.find();
db.Orders.find();
db.OrderLines.find();
db.OrderFollowUps.find();

// ============================================
// 12. FIND LOW-STOCK PRODUCTS
// ============================================

db.Products.find({
    $expr: {
        $lte: ["$stockQuantity", "$reorderLevel"]
    }
});

// ============================================
// 13. FIND PENDING ORDERS
// ============================================

db.Orders.find({
    orderStatus: "Pending"
});

// ============================================
// 14. FIND ORDERS PENDING FOR MORE THAN 3 DAYS
// ============================================

db.Orders.find({
    orderStatus: "Pending",
    orderDate: {
        $lt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)
    }
});

// ============================================
// 15. CALCULATE ORDER TOTALS
// ============================================

db.OrderLines.aggregate([
    {
        $group: {
            _id: "$orderId",
            totalAmount: {
                $sum: {
                    $multiply: ["$quantity", "$unitPrice"]
                }
            }
        }
    }
]);

// ============================================
// END OF SCRIPT
// ============================================