use logistics_db;


db.createCollection("hubs");
db.createCollection("carriers");
db.createCollection("customers");
db.createCollection("employees");
db.createCollection("shipments");
db.createCollection("delivery_events");


// Hubs
db.hubs.insertMany([
  { hubId: 1, hubName: "Coimbatore Hub", city: "Coimbatore" },
  { hubId: 2, hubName: "Chennai Hub", city: "Chennai" },
  { hubId: 3, hubName: "Bengaluru Hub", city: "Bengaluru" },
  { hubId: 4, hubName: "Hyderabad Hub", city: "Hyderabad" },
  { hubId: 5, hubName: "Kochi Hub", city: "Kochi" }
]);

// Carriers
db.carriers.insertMany([
  { carrierId: 1, carrierName: "Swift Express" },
  { carrierId: 2, carrierName: "BlueLine Logistics" },
  { carrierId: 3, carrierName: "SafeRoute Cargo" },
  { carrierId: 4, carrierName: "Metro Express" }
]);

// Customers
db.customers.insertMany([
  { customerId: 1, customerName: "Apex Retail" },
  { customerId: 2, customerName: "GreenMart" },
  { customerId: 3, customerName: "Nova Electronics" },
  { customerId: 4, customerName: "Urban Stores" },
  { customerId: 5, customerName: "Prime Foods" }
]);

// Employees
db.employees.insertMany([
  { employeeId: 1, employeeName: "Arun Kumar", supervisorId: null },
  { employeeId: 2, employeeName: "Divya Ravi", supervisorId: 1 },
  { employeeId: 3, employeeName: "Karthik S", supervisorId: 1 },
  { employeeId: 4, employeeName: "Meena P", supervisorId: 2 },
  { employeeId: 5, employeeName: "Rahul N", supervisorId: 2 }
]);

// Shipments
db.shipments.insertMany([
  {
    shipmentId: 101, customerId: 1, carrierId: 1,
    originHubId: 1, destinationHubId: 2,
    shipmentDate: ISODate("2026-10-01T09:00:00Z"),
    deliveryDate: ISODate("2026-10-05T12:00:00Z"),
    shippingCost: 850, status: "Delivered"
  },
  {
    shipmentId: 102, customerId: 1, carrierId: 2,
    originHubId: 2, destinationHubId: 3,
    shipmentDate: ISODate("2026-10-02T10:00:00Z"),
    deliveryDate: ISODate("2026-10-03T15:00:00Z"),
    shippingCost: 620, status: "Delivered"
  },
  {
    shipmentId: 103, customerId: 2, carrierId: 1,
    originHubId: 1, destinationHubId: 3,
    shipmentDate: ISODate("2026-10-04T08:00:00Z"),
    deliveryDate: ISODate("2026-10-08T11:00:00Z"),
    shippingCost: 920, status: "Delivered"
  },
  {
    shipmentId: 104, customerId: 2, carrierId: 3,
    originHubId: 3, destinationHubId: 4,
    shipmentDate: ISODate("2026-10-05T11:00:00Z"),
    deliveryDate: ISODate("2026-10-06T16:00:00Z"),
    shippingCost: 700, status: "Delivered"
  },
  {
    shipmentId: 105, customerId: 3, carrierId: 2,
    originHubId: 2, destinationHubId: 4,
    shipmentDate: ISODate("2026-10-06T07:00:00Z"),
    deliveryDate: ISODate("2026-10-10T18:00:00Z"),
    shippingCost: 1100, status: "Delivered"
  },
  {
    shipmentId: 106, customerId: 3, carrierId: 1,
    originHubId: 4, destinationHubId: 1,
    shipmentDate: ISODate("2026-10-07T09:00:00Z"),
    deliveryDate: ISODate("2026-10-08T14:00:00Z"),
    shippingCost: 780, status: "Delivered"
  },
  {
    shipmentId: 107, customerId: 4, carrierId: 3,
    originHubId: 3, destinationHubId: 2,
    shipmentDate: ISODate("2026-10-08T10:00:00Z"),
    deliveryDate: ISODate("2026-10-12T10:00:00Z"),
    shippingCost: 990, status: "Delivered"
  },
  {
    shipmentId: 108, customerId: 4, carrierId: 4,
    originHubId: 1, destinationHubId: 4,
    shipmentDate: ISODate("2026-10-09T12:00:00Z"),
    deliveryDate: null,
    shippingCost: 1250, status: "In Transit"
  },
  {
    shipmentId: 109, customerId: 5, carrierId: 2,
    originHubId: 2, destinationHubId: 1,
    shipmentDate: ISODate("2026-10-10T08:00:00Z"),
    deliveryDate: ISODate("2026-10-11T12:00:00Z"),
    shippingCost: 540, status: "Delivered"
  },
  {
    shipmentId: 110, customerId: 5, carrierId: 4,
    originHubId: 4, destinationHubId: 3,
    shipmentDate: ISODate("2026-10-11T09:00:00Z"),
    deliveryDate: null,
    shippingCost: 680, status: "In Transit"
  },
  {
    shipmentId: 111, customerId: 1, carrierId: 3,
    originHubId: 3, destinationHubId: 1,
    shipmentDate: ISODate("2026-10-12T10:00:00Z"),
    deliveryDate: ISODate("2026-10-13T11:00:00Z"),
    shippingCost: 760, status: "Delivered"
  }
]);

// Delivery Events
db.delivery_events.insertMany([
  {
    eventId: 1, shipmentId: 101,
    eventTime: ISODate("2026-10-01T09:00:00Z"),
    eventType: "Picked Up",
    notes: "Collected from sender"
  },
  {
    eventId: 2, shipmentId: 101,
    eventTime: ISODate("2026-10-03T13:00:00Z"),
    eventType: "In Transit",
    notes: "Reached sorting facility"
  },
  {
    eventId: 3, shipmentId: 101,
    eventTime: ISODate("2026-10-05T12:00:00Z"),
    eventType: "Delivered",
    notes: "Received by customer"
  },
  {
    eventId: 4, shipmentId: 103,
    eventTime: ISODate("2026-10-04T08:00:00Z"),
    eventType: "Picked Up",
    notes: "Shipment collected"
  },
  {
    eventId: 5, shipmentId: 103,
    eventTime: ISODate("2026-10-08T11:00:00Z"),
    eventType: "Delivered",
    notes: "Delivery completed"
  },
  {
    eventId: 6, shipmentId: 108,
    eventTime: ISODate("2026-10-09T12:00:00Z"),
    eventType: "Picked Up",
    notes: "Collected from sender"
  },
  {
    eventId: 7, shipmentId: 108,
    eventTime: ISODate("2026-10-10T17:00:00Z"),
    eventType: "In Transit",
    notes: "Departed origin hub"
  }
]);



// 4. SHIPMENTS WITH DELIVERY EVENTS

db.shipments.aggregate([
  {
    $lookup: {
      from: "delivery_events",
      localField: "shipmentId",
      foreignField: "shipmentId",
      as: "deliveryEvents"
    }
  },
  {
    $project: {
      _id: 0,
      shipmentId: 1,
      customerId: 1,
      carrierId: 1,
      status: 1,
      deliveryEvents: 1
    }
  }
]);

// 5. CUSTOMERS WITH THEIR SHIPMENTS

db.customers.aggregate([
  {
    $lookup: {
      from: "shipments",
      localField: "customerId",
      foreignField: "customerId",
      as: "shipments"
    }
  },
  {
    $project: {
      _id: 0,
      customerId: 1,
      customerName: 1,
      shipmentCount: { $size: "$shipments" },
      shipments: 1
    }
  }
]);


// 6. CARRIERS WITH DELAY STATISTICS

db.carriers.aggregate([
  {
    $lookup: {
      from: "shipments",
      let: { carrierKey: "$carrierId" },
      pipeline: [
        {
          $match: {
            $expr: {
              $eq: ["$carrierId", "$$carrierKey"]
            },
            shipmentDate: { $exists: true, $ne: null }
          }
        },
        {
          $addFields: {
            delayDays: {
              $max: [
                0,
                {
                  $divide: [
                    {
                      $subtract: [
                        { $ifNull: ["$deliveryDate", "$$NOW"] },
                        {
                          $dateAdd: {
                            startDate: "$shipmentDate",
                            unit: "day",
                            amount: 2
                          }
                        }
                      ]
                    },
                    86400000
                  ]
                }
              ]
            }
          }
        },
        {
          $group: {
            _id: null,
            shipmentCount: { $sum: 1 },
            averageDelayDays: { $avg: "$delayDays" },
            maximumDelayDays: { $max: "$delayDays" }
          }
        }
      ],
      as: "delayStats"
    }
  },
  {
    $unwind: {
      path: "$delayStats",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $project: {
      _id: 0,
      carrierId: 1,
      carrierName: 1,
      shipmentCount: {
        $ifNull: ["$delayStats.shipmentCount", 0]
      },
      averageDelayDays: {
        $round: [
          { $ifNull: ["$delayStats.averageDelayDays", 0] },
          2
        ]
      },
      maximumDelayDays: {
        $round: [
          { $ifNull: ["$delayStats.maximumDelayDays", 0] },
          2
        ]
      }
    }
  },
  {
    $sort: { averageDelayDays: -1 }
  }
]);

// 7. EMBEDDING VS $LOOKUP

// Embedding is better for small child data frequently
// accessed together with its parent document.
//
// $lookup is better for large or shared data that
// changes independently or is queried separately.
