// ============================================
// SET 3 - TELECOM LOW-BALANCE FOLLOW-UP
// ============================================

// 1. Create / switch database
use TelecomLowBalance;

// 2. Insert Subscribers
db.Subscribers.insertMany([
  {
    subscriberId: 101,
    name: "Arun",
    type: "Prepaid",
    balance: 35,
    plan: "Basic 28 Days"
  },
  {
    subscriberId: 102,
    name: "Priya",
    type: "Prepaid",
    balance: 120,
    plan: "Value 56 Days"
  },
  {
    subscriberId: 103,
    name: "Rahul",
    type: "Prepaid",
    balance: 15,
    plan: "Basic 28 Days"
  },
  {
    subscriberId: 104,
    name: "Divya",
    type: "Postpaid",
    balance: 80,
    plan: "Basic 28 Days"
  },
  {
    subscriberId: 105,
    name: "Kiran",
    type: "Prepaid",
    balance: 48,
    plan: "Basic 28 Days"
  }
]);

// 3. Insert Notification Log
db.NotificationLog.insertMany([
  {
    subscriberId: 101,
    message: "Low balance alert",
    isRead: false,
    date: new Date()
  },
  {
    subscriberId: 102,
    message: "Recharge reminder",
    isRead: true,
    date: new Date()
  },
  {
    subscriberId: 103,
    message: "Low balance alert",
    isRead: false,
    date: new Date()
  },
  {
    subscriberId: 104,
    message: "Postpaid account reminder",
    isRead: true,
    date: new Date()
  },
  {
    subscriberId: 105,
    message: "Low balance alert",
    isRead: false,
    date: new Date()
  }
]);

// 4. Create MongoDB View
// Unread notification count per subscriber
db.createView(
  "vw_unread_notification_count",
  "NotificationLog",
  [
    {
      $match: {
        isRead: false
      }
    },
    {
      $group: {
        _id: "$subscriberId",
        unreadCount: {
          $sum: 1
        }
      }
    },
    {
      $project: {
        _id: 0,
        subscriberId: "$_id",
        unreadCount: 1
      }
    },
    {
      $sort: {
        subscriberId: 1
      }
    }
  ]
);

// 5. Display Subscribers
db.Subscribers.find();

// 6. Display Notification Log
db.NotificationLog.find();

// 7. Display View Result
db.vw_unread_notification_count.find();