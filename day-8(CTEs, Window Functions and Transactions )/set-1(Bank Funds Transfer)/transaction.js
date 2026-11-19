use BankDB

db.accounts.updateOne(
    { accountId: 101 },
    {
        $setOnInsert: {
            accountId: 101,
            name: "Alice",
            balance: 5000,
            status: "ACTIVE"
        }
    },
    { upsert: true }
);

db.accounts.updateOne(
    { accountId: 102 },
    {
        $setOnInsert: {
            accountId: 102,
            name: "Bob",
            balance: 3000,
            status: "ACTIVE"
        }
    },
    { upsert: true }
);

// 3. Display balances before transfer
print("===== BALANCES BEFORE TRANSFER =====");
db.accounts.find(
    { accountId: { $in: [101, 102] } },
    { _id: 0, accountId: 1, name: 1, balance: 1, status: 1 }
).forEach(printjson);

// 4. START TRANSACTION

const session = db.getMongo().startSession();
const sessionDB = session.getDatabase("BankDB");

session.startTransaction();

try {
    const sender = sessionDB.accounts.findOne({ accountId: 101 });
    const receiver = sessionDB.accounts.findOne({ accountId: 102 });

    const transferAmount = 1000;

    // 5. Validate accounts
    if (sender == null || receiver == null) {
        throw new Error("Account not found");
    }

    if (sender.status !== "ACTIVE" || receiver.status !== "ACTIVE") {
        throw new Error("Account is inactive");
    }

    if (sender.balance < transferAmount) {
        throw new Error("Insufficient balance");
    }

    // 6. Debit sender
    const debitResult = sessionDB.accounts.updateOne(
        {
            accountId: 101,
            status: "ACTIVE",
            balance: { $gte: transferAmount }
        },
        {
            $inc: { balance: -transferAmount }
        }
    );

    if (debitResult.modifiedCount !== 1) {
        throw new Error("Debit failed");
    }

    // 7. Credit receiver
    const creditResult = sessionDB.accounts.updateOne(
        {
            accountId: 102,
            status: "ACTIVE"
        },
        {
            $inc: { balance: transferAmount }
        }
    );

    if (creditResult.modifiedCount !== 1) {
        throw new Error("Credit failed");
    }

    // 8. Insert transfer record
    sessionDB.transactions.insertOne({
        transferId: 1,
        fromAccount: 101,
        toAccount: 102,
        amount: transferAmount,
        transactionType: "TRANSFER",
        status: "SUCCESS",
        transactionDate: new Date()
    });

    // 9. Commit transaction
    session.commitTransaction();

    print("Transfer successful!");
    print("Rs. " + transferAmount + " transferred from Alice to Bob.");

} catch (error) {
    // 10. Roll back all changes if any operation fails
    session.abortTransaction();

    print("Transfer failed!");
    print("Error: " + error.message);
    print("All changes have been rolled back.");

} finally {
    session.endSession();
}

// 11. VERIFY FINAL BALANCES

print("===== BALANCES AFTER TRANSFER =====");

db.accounts.find(
    { accountId: { $in: [101, 102] } },
    { _id: 0, accountId: 1, name: 1, balance: 1, status: 1 }
).forEach(printjson);


print("===== TRANSACTION HISTORY =====");

db.transactions.find(
    {},
    { _id: 0 }
).forEach(printjson);