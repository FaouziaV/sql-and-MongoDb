use bank_loan_portfolio;

db.createCollection("branches");
db.createCollection("customers");
db.createCollection("loans");
db.createCollection("repayments");
db.createCollection("guarantors");

// Branches
db.branches.insertMany([
  { branchId: 1, branchName: "Coimbatore Main", city: "Coimbatore" },
  { branchId: 2, branchName: "Chennai Central", city: "Chennai" },
  { branchId: 3, branchName: "Bengaluru City", city: "Bengaluru" },
  { branchId: 4, branchName: "Madurai Branch", city: "Madurai" },
  { branchId: 5, branchName: "Salem Branch", city: "Salem" }
]);

// Customers
db.customers.insertMany([
  { customerId: 1, customerName: "Arun Kumar", phone: "9000000001" },
  { customerId: 2, customerName: "Divya Ravi", phone: "9000000002" },
  { customerId: 3, customerName: "Karthik S", phone: "9000000003" },
  { customerId: 4, customerName: "Meena P", phone: "9000000004" },
  { customerId: 5, customerName: "Rahul N", phone: "9000000005" },
  { customerId: 6, customerName: "Priya M", phone: "9000000006" },
  { customerId: 7, customerName: "Vijay K", phone: "9000000007" }
]);

// Loans
db.loans.insertMany([
  {
    loanId: 101, customerId: 1, branchId: 1,
    loanAmount: 500000, interestRate: 9.5,
    loanDate: ISODate("2025-01-10"),
    dueDate: ISODate("2026-01-10"),
    totalInstalments: 12, status: "Active"
  },
  {
    loanId: 102, customerId: 2, branchId: 1,
    loanAmount: 300000, interestRate: 8.75,
    loanDate: ISODate("2025-03-15"),
    dueDate: ISODate("2026-03-15"),
    totalInstalments: 12, status: "Active"
  },
  {
    loanId: 103, customerId: 1, branchId: 2,
    loanAmount: 750000, interestRate: 9,
    loanDate: ISODate("2025-02-01"),
    dueDate: ISODate("2026-02-01"),
    totalInstalments: 12, status: "Active"
  },
  {
    loanId: 104, customerId: 3, branchId: 2,
    loanAmount: 250000, interestRate: 10,
    loanDate: ISODate("2025-04-20"),
    dueDate: ISODate("2026-04-20"),
    totalInstalments: 10, status: "Active"
  },
  {
    loanId: 105, customerId: 4, branchId: 3,
    loanAmount: 900000, interestRate: 8.5,
    loanDate: ISODate("2025-01-05"),
    dueDate: ISODate("2026-01-05"),
    totalInstalments: 12, status: "Active"
  },
  {
    loanId: 106, customerId: 5, branchId: 3,
    loanAmount: 400000, interestRate: 9.25,
    loanDate: ISODate("2025-05-10"),
    dueDate: ISODate("2026-05-10"),
    totalInstalments: 10, status: "Active"
  },
  {
    loanId: 107, customerId: 6, branchId: 1,
    loanAmount: 150000, interestRate: 11,
    loanDate: ISODate("2025-06-01"),
    dueDate: ISODate("2026-06-01"),
    totalInstalments: 12, status: "Active"
  },
  {
    loanId: 108, customerId: 7, branchId: 4,
    loanAmount: 600000, interestRate: 9.75,
    loanDate: ISODate("2025-02-12"),
    dueDate: ISODate("2026-02-12"),
    totalInstalments: 12, status: "Active"
  }
]);

// Repayments
db.repayments.insertMany([
  {
    repaymentId: 1, loanId: 101,
    repaymentDate: ISODate("2026-09-01"),
    amount: 45000, instalmentNumber: 1
  },
  {
    repaymentId: 2, loanId: 101,
    repaymentDate: ISODate("2026-09-15"),
    amount: 45000, instalmentNumber: 2
  },
  {
    repaymentId: 3, loanId: 102,
    repaymentDate: ISODate("2026-08-10"),
    amount: 28000, instalmentNumber: 1
  },
  {
    repaymentId: 4, loanId: 103,
    repaymentDate: ISODate("2026-07-01"),
    amount: 65000, instalmentNumber: 1
  },
  {
    repaymentId: 5, loanId: 104,
    repaymentDate: ISODate("2026-10-20"),
    amount: 26000, instalmentNumber: 1
  },
  {
    repaymentId: 6, loanId: 105,
    repaymentDate: ISODate("2026-09-10"),
    amount: 80000, instalmentNumber: 1
  },
  {
    repaymentId: 7, loanId: 106,
    repaymentDate: ISODate("2026-06-15"),
    amount: 35000, instalmentNumber: 1
  },
  {
    repaymentId: 8, loanId: 107,
    repaymentDate: ISODate("2026-10-25"),
    amount: 14000, instalmentNumber: 1
  }
]);

// Guarantors
db.guarantors.insertMany([
  { guarantorId: 1, loanId: 101, guarantorCustomerId: 3 },
  { guarantorId: 2, loanId: 102, guarantorCustomerId: 4 },
  { guarantorId: 3, loanId: 103, guarantorCustomerId: 2 },
  { guarantorId: 4, loanId: 104, guarantorCustomerId: 1 },
  { guarantorId: 5, loanId: 105, guarantorCustomerId: 7 },
  { guarantorId: 6, loanId: 106, guarantorCustomerId: 2 },
  { guarantorId: 7, loanId: 107, guarantorCustomerId: 5 }
]);

// 4. PIPELINE 1: LOANS WITH CUSTOMER DETAILS

db.loans.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "customerId",
      foreignField: "customerId",
      as: "customerDetails"
    }
  },
  {
    $unwind: "$customerDetails"
  },
  {
    $project: {
      _id: 0,
      loanId: 1,
      loanAmount: 1,
      interestRate: 1,
      status: 1,
      customerName: "$customerDetails.customerName",
      phone: "$customerDetails.phone"
    }
  }
]);


// 5. PIPELINE 2: LOANS WITH ALL REPAYMENTS

db.loans.aggregate([
  {
    $lookup: {
      from: "repayments",
      localField: "loanId",
      foreignField: "loanId",
      as: "repaymentDetails"
    }
  },
  {
    $project: {
      _id: 0,
      loanId: 1,
      customerId: 1,
      loanAmount: 1,
      repaymentCount: {
        $size: "$repaymentDetails"
      },
      repaymentDetails: 1
    }
  }
]);

// 6. PIPELINE 3: LAST REPAYMENT FOR EACH LOAN

// $lookup with pipeline retrieves the latest repayment.
// $sort sorts repayments by date descending.
// $limit 1 returns only the latest repayment.

db.loans.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "customerId",
      foreignField: "customerId",
      as: "customerDetails"
    }
  },
  {
    $lookup: {
      from: "repayments",
      let: { loanKey: "$loanId" },
      pipeline: [
        {
          $match: {
            $expr: {
              $eq: ["$loanId", "$$loanKey"]
            }
          }
        },
        {
          $sort: {
            repaymentDate: -1
          }
        },
        {
          $limit: 1
        }
      ],
      as: "lastRepayment"
    }
  },
  {
    $unwind: {
      path: "$customerDetails",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $project: {
      _id: 0,
      loanId: 1,
      loanAmount: 1,
      customerName: "$customerDetails.customerName",
      lastRepayment: {
        $arrayElemAt: ["$lastRepayment", 0]
      }
    }
  },
  {
    $sort: {
      loanId: 1
    }
  }
]);
