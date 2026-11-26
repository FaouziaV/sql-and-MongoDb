// MongoDB 8.0 – run with mongosh against a replica set.
const dbName = "retail";
const coll = db.getSiblingDB(dbName).getCollection("products");

const stream = coll.watch(
  [{ $match: { operationType: "update" } }],
  { fullDocument: "updateLookup" }
);

print("Watching retail.products for price changes. Press Ctrl+C to stop.");

while (stream.hasNext()) {
  const change = stream.next();
  const updated = change.updateDescription?.updatedFields ?? {};

  if (Object.prototype.hasOwnProperty.call(updated, "price")) {
    printjson({
      productId: change.documentKey._id,
      newPrice: updated.price,
      fullDocument: change.fullDocument,
      clusterTime: change.clusterTime
    });
  }
}
