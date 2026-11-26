// MongoDB 8.0 – run with mongosh against a replica set.
const alerts = db.getSiblingDB("bank").getCollection("fraud_alerts");

const stream = alerts.watch(
  [{ $match: { operationType: "insert" } }]
);

print("Watching bank.fraud_alerts for new fraud alerts. Press Ctrl+C to stop.");

while (stream.hasNext()) {
  const change = stream.next();
  print("NEW FRAUD ALERT");
  printjson(change.fullDocument);
}
