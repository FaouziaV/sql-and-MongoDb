// MongoDB 8.0 – run with mongosh against a replica set.
const alerts = db.getSiblingDB("hospital").getCollection("ward_alerts");

const stream = alerts.watch([
  {
    $match: {
      operationType: "insert",
      "fullDocument.severity": "critical"
    }
  }
]);

print("Watching hospital.ward_alerts for critical alerts. Press Ctrl+C to stop.");

while (stream.hasNext()) {
  const change = stream.next();
  const alert = change.fullDocument;

  printjson({
    ward: alert.ward,
    time: alert.time ?? alert.createdAt ?? change.clusterTime,
    alert: alert
  });
}
