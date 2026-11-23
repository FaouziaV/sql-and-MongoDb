// ==========================================
// SET 2 - INSURANCE PREMIUM PROCESSING
// MONGODB SCRIPT
// ==========================================

// 1. CREATE / SELECT DATABASE
use InsurancePremiumProcessing


// ==========================================
// 2. INSERT CUSTOMERS
// ==========================================

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


// ==========================================
// 3. INSERT CUSTOMER COMMUNICATIONS
// ==========================================

db.CustomerCommunications.insertMany([
    {
        communicationId: 1,
        customerId: 1,
        communicationType: "Complaint",
        subject: "Premium payment issue",
        message: "Premium amount is incorrect",
        status: "Unresolved",
        communicationDate: new Date()
    },
    {
        communicationId: 2,
        customerId: 2,
        communicationType: "Complaint",
        subject: "Policy renewal delay",
        message: "Renewal confirmation not received",
        status: "Resolved",
    communicationDate: new Date()
    },
    {
        communicationId: 3,
        customerId: 3,
        communicationType: "Enquiry",
        subject: "Policy details",
        message: "Requesting policy information",
        status: "Unresolved",
        communicationDate: new Date()
    },
    {
        communicationId: 4,
        customerId: 1,
        communicationType: "Complaint",
        subject: "Claim status delay",
        message: "Claim status is not updated",
        status: "Unresolved",
        communicationDate: new Date()
    },
    {
        communicationId: 5,
        customerId: 2,
        communicationType: "Complaint",
        subject: "Incorrect customer details",
        message: "Customer details need correction",
        status: "Resolved",
        communicationDate: new Date()
    }
]);


// ==========================================
// 4. CREATE VIEW
//    UNRESOLVED CUSTOMER COMPLAINTS
// ==========================================

db.createView(
    "vw_unresolved_complaints",
    "CustomerCommunications",
    [
        {
            $match: {
                communicationType: "Complaint",
                status: "Unresolved"
            }
        }
    ]
);


// ==========================================
// 5. DISPLAY THE VIEW
// ==========================================

db.vw_unresolved_complaints.find();


// ==========================================
// 6. DISPLAY ALL COMMUNICATIONS
// ==========================================

db.CustomerCommunications.find();


// ==========================================
// 7. DISPLAY ALL CUSTOMERS
// ==========================================

db.Customers.find();


// ==========================================
// 8. COUNT UNRESOLVED COMPLAINTS
// ==========================================

db.vw_unresolved_complaints.countDocuments();


// ==========================================
// 9. SORT UNRESOLVED COMPLAINTS BY DATE
// ==========================================

db.vw_unresolved_complaints.find().sort({
    communicationDate: -1
});
