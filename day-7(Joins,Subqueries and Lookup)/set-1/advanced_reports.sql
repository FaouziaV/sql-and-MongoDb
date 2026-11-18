----creating databse

--create database logistics_db;
--use logistics_db;

--creating tables
--CREATE TABLE hubs (
--    hub_id   INT PRIMARY KEY,
--    hub_name VARCHAR(100) NOT NULL,
--    city     VARCHAR(100)
--);

--CREATE TABLE carriers (
--    carrier_id   INT PRIMARY KEY,
--    carrier_name VARCHAR(100) NOT NULL
--);

--CREATE TABLE customers (
--    customer_id   INT PRIMARY KEY,
--    customer_name VARCHAR(120) NOT NULL
--);

--CREATE TABLE employees (
--    employee_id   INT PRIMARY KEY,
--    employee_name VARCHAR(120) NOT NULL,
--    supervisor_id INT NULL,
--    CONSTRAINT FK_employees_supervisor
--        FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id)
--);

--CREATE TABLE shipments (
--    shipment_id        INT PRIMARY KEY,
--    customer_id        INT NOT NULL,
--    carrier_id         INT NOT NULL,
--    origin_hub_id      INT NOT NULL,
--    destination_hub_id INT NOT NULL,
--    shipment_date      DATETIME2 NOT NULL,
--    delivery_date      DATETIME2 NULL,
--    shipping_cost      DECIMAL(10,2) NOT NULL CHECK (shipping_cost >= 0),
--    status             VARCHAR(30) NOT NULL,
--    CONSTRAINT FK_shipments_customer FOREIGN KEY (customer_id)
--        REFERENCES customers(customer_id),
--    CONSTRAINT FK_shipments_carrier FOREIGN KEY (carrier_id)
--        REFERENCES carriers(carrier_id),
--    CONSTRAINT FK_shipments_origin_hub FOREIGN KEY (origin_hub_id)
--        REFERENCES hubs(hub_id),
--    CONSTRAINT FK_shipments_destination_hub FOREIGN KEY (destination_hub_id)
--        REFERENCES hubs(hub_id)
--);
--CREATE TABLE delivery_events (
--    event_id    INT PRIMARY KEY,
--    shipment_id INT NOT NULL,
--    event_time  DATETIME2 NOT NULL,
--    event_type  VARCHAR(60) NOT NULL,
--    notes       VARCHAR(MAX),
--    CONSTRAINT FK_delivery_events_shipment FOREIGN KEY (shipment_id)
--        REFERENCES shipments(shipment_id)
--);


--inserting datas
--INSERT INTO hubs (hub_id, hub_name, city) VALUES
--(1, 'Coimbatore Hub', 'Coimbatore'),
--(2, 'Chennai Hub', 'Chennai'),
--(3, 'Bengaluru Hub', 'Bengaluru'),
--(4, 'Hyderabad Hub', 'Hyderabad'),
--(5, 'Kochi Hub', 'Kochi');

--INSERT INTO carriers (carrier_id, carrier_name) VALUES
--(1, 'Swift Express'),
--(2, 'BlueLine Logistics'),
--(3, 'SafeRoute Cargo'),
--(4, 'Metro Express');

--INSERT INTO customers (customer_id, customer_name) VALUES
--(1, 'Apex Retail'),
--(2, 'GreenMart'),
--(3, 'Nova Electronics'),
--(4, 'Urban Stores'),
--(5, 'Prime Foods');

--INSERT INTO employees (employee_id, employee_name, supervisor_id) VALUES
--(1, 'Arun Kumar', NULL),
--(2, 'Divya Ravi', 1),
--(3, 'Karthik S', 1),
--(4, 'Meena P', 2),
--(5, 'Rahul N', 2);

--INSERT INTO shipments
--(shipment_id, customer_id, carrier_id, origin_hub_id, destination_hub_id,
-- shipment_date, delivery_date, shipping_cost, status)
--VALUES
--(101, 1, 1, 1, 2, '2026-10-01T09:00:00', '2026-10-05T12:00:00', 850.00, 'Delivered'),
--(102, 1, 2, 2, 3, '2026-10-02T10:00:00', '2026-10-03T15:00:00', 620.00, 'Delivered'),
--(103, 2, 1, 1, 3, '2026-10-04T08:00:00', '2026-10-08T11:00:00', 920.00, 'Delivered'),
--(104, 2, 3, 3, 4, '2026-10-05T11:00:00', '2026-10-06T16:00:00', 700.00, 'Delivered'),
--(105, 3, 2, 2, 4, '2026-10-06T07:00:00', '2026-10-10T18:00:00', 1100.00, 'Delivered'),
--(106, 3, 1, 4, 1, '2026-10-07T09:00:00', '2026-10-08T14:00:00', 780.00, 'Delivered'),
--(107, 4, 3, 3, 2, '2026-10-08T10:00:00', '2026-10-12T10:00:00', 990.00, 'Delivered'),
--(108, 4, 4, 1, 4, '2026-10-09T12:00:00', NULL, 1250.00, 'In Transit'),
--(109, 5, 2, 2, 1, '2026-10-10T08:00:00', '2026-10-11T12:00:00', 540.00, 'Delivered'),
--(110, 5, 4, 4, 3, '2026-10-11T09:00:00', NULL, 680.00, 'In Transit'),
--(111, 1, 3, 3, 1, '2026-10-12T10:00:00', '2026-10-13T11:00:00', 760.00, 'Delivered');

--INSERT INTO delivery_events (event_id, shipment_id, event_time, event_type, notes) VALUES
--(1, 101, '2026-10-01T09:00:00', 'Picked Up', 'Collected from sender'),
--(2, 101, '2026-10-03T13:00:00', 'In Transit', 'Reached sorting facility'),
--(3, 101, '2026-10-05T12:00:00', 'Delivered', 'Received by customer'),
--(4, 103, '2026-10-04T08:00:00', 'Picked Up', 'Shipment collected'),
--(5, 103, '2026-10-08T11:00:00', 'Delivered', 'Delivery completed'),
--(6, 108, '2026-10-09T12:00:00', 'Picked Up', 'Collected from sender'),
--(7, 108, '2026-10-10T17:00:00', 'In Transit', 'Departed origin hub');

--Shipments delayed by more than two days, with carrier names.
--INNER JOIN: only matching carrier records are required.
SELECT s.shipment_id, c.carrier_name, s.shipment_date, s.delivery_date,
       DATEDIFF(DAY, s.shipment_date, s.delivery_date) AS transit_days
FROM shipments AS s
INNER JOIN carriers AS c ON c.carrier_id = s.carrier_id
WHERE s.delivery_date IS NOT NULL
  AND s.delivery_date > DATEADD(DAY, 2, s.shipment_date)
ORDER BY transit_days DESC;

--Hubs with no outbound shipments.
--LEFT JOIN: retain hubs even when no shipment starts there.
SELECT h.hub_id, h.hub_name
FROM hubs AS h
LEFT JOIN shipments AS s ON s.origin_hub_id = h.hub_id
WHERE s.shipment_id IS NULL;

--Employees and their supervisors.
--SELF JOIN: supervisor and employee are in the same table.
SELECT e.employee_id, e.employee_name,
       m.employee_id AS supervisor_id, m.employee_name AS supervisor_name
FROM employees AS e
LEFT JOIN employees AS m ON m.employee_id = e.supervisor_id;

--Shipment details with customer and carrier names.
--INNER JOIN: show shipments with matching customer and carrier rows.
SELECT s.shipment_id, cu.customer_name, ca.carrier_name,
       s.status, s.shipping_cost
FROM shipments AS s
INNER JOIN customers AS cu ON cu.customer_id = s.customer_id
INNER JOIN carriers AS ca ON ca.carrier_id = s.carrier_id;

--Every hub and its inbound shipment count, including zero.
--LEFT JOIN: hubs without inbound shipments must also appear.
SELECT h.hub_id, h.hub_name, COUNT(s.shipment_id) AS inbound_shipments
FROM hubs AS h
LEFT JOIN shipments AS s ON s.destination_hub_id = h.hub_id
GROUP BY h.hub_id, h.hub_name
ORDER BY inbound_shipments DESC;

--Hubs and shipments associated as origin or destination.
--FULL OUTER JOIN: preserve unmatched rows from both sides.
SELECT h.hub_id, h.hub_name, s.shipment_id,
       s.origin_hub_id, s.destination_hub_id
FROM hubs AS h
FULL OUTER JOIN shipments AS s
  ON h.hub_id = s.origin_hub_id OR h.hub_id = s.destination_hub_id
ORDER BY h.hub_id, s.shipment_id;

--Shipments with delivery events, including shipments without events.
--LEFT JOIN: preserve shipments that have no event records.
SELECT s.shipment_id, s.status, de.event_id, de.event_time,
       de.event_type, de.notes
FROM shipments AS s
LEFT JOIN delivery_events AS de ON de.shipment_id = s.shipment_id
ORDER BY s.shipment_id, de.event_time;

--Customers and shipment count, including customers with no shipments.
--LEFT JOIN: preserve every customer.
SELECT cu.customer_id, cu.customer_name, COUNT(s.shipment_id) AS shipment_count
FROM customers AS cu
LEFT JOIN shipments AS s ON s.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.customer_name
ORDER BY shipment_count DESC;

--Carriers and average transit days, including carriers with no deliveries.
--LEFT JOIN: preserve every carrier.
SELECT ca.carrier_id, ca.carrier_name,
       CAST(AVG(CAST(DATEDIFF(SECOND, s.shipment_date, s.delivery_date) AS DECIMAL(18,2))
           / 86400.0) AS DECIMAL(10,2)) AS avg_transit_days
FROM carriers AS ca
LEFT JOIN shipments AS s
  ON s.carrier_id = ca.carrier_id AND s.delivery_date IS NOT NULL
GROUP BY ca.carrier_id, ca.carrier_name
ORDER BY avg_transit_days DESC;

--Pairs of shipments handled by the same carrier.
--SELF JOIN: compare rows from shipments; less-than avoids duplicate pairs.
SELECT s1.carrier_id, s1.shipment_id AS shipment_1,
       s2.shipment_id AS shipment_2
FROM shipments AS s1
INNER JOIN shipments AS s2
  ON s1.carrier_id = s2.carrier_id
 AND s1.shipment_id < s2.shipment_id
ORDER BY s1.carrier_id, shipment_1, shipment_2;

--Customers who have shipped to every hub.
--Double NOT EXISTS checks that no destination hub is missing.
SELECT cu.customer_id, cu.customer_name
FROM customers AS cu
WHERE NOT EXISTS (
    SELECT 1
    FROM hubs AS h
    WHERE NOT EXISTS (
        SELECT 1
        FROM shipments AS s
        WHERE s.customer_id = cu.customer_id
          AND s.destination_hub_id = h.hub_id
    )
);

--Customers who have shipped to at least one known hub.
--IN compares customer IDs against a subquery result.
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM shipments
    WHERE destination_hub_id IN (SELECT hub_id FROM hubs)
);

--Carriers whose average delay exceeds the overall average delay.
--ANY is used to compare each carrier average with the set of carrier averages.
--The overall-average condition is also applied.
WITH shipment_delays AS (
    SELECT carrier_id,
           CASE
             WHEN COALESCE(delivery_date, SYSDATETIME()) > DATEADD(DAY, 2, shipment_date)
             THEN DATEDIFF(SECOND, DATEADD(DAY, 2, shipment_date),
                           COALESCE(delivery_date, SYSDATETIME())) / 86400.0
             ELSE 0.0
           END AS delay_days
    FROM shipments
),
carrier_avg AS (
    SELECT carrier_id, AVG(delay_days) AS avg_delay
    FROM shipment_delays
    GROUP BY carrier_id
),
overall_avg AS (
    SELECT AVG(delay_days) AS avg_delay
    FROM shipment_delays
)
SELECT c.carrier_id, c.carrier_name, ca.avg_delay
FROM carrier_avg AS ca
INNER JOIN carriers AS c ON c.carrier_id = ca.carrier_id
CROSS JOIN overall_avg AS oa
WHERE ca.avg_delay > oa.avg_delay
  AND ca.avg_delay > ANY (SELECT avg_delay FROM carrier_avg);

--Carriers whose average shipping cost is greater than every other carrier.
--ALL requires the average to be greater than every value in the subquery.
SELECT c.carrier_id, c.carrier_name, AVG(s.shipping_cost) AS avg_shipping_cost
FROM carriers AS c
INNER JOIN shipments AS s ON s.carrier_id = c.carrier_id
GROUP BY c.carrier_id, c.carrier_name
HAVING AVG(s.shipping_cost) > ALL (
    SELECT AVG(s2.shipping_cost)
    FROM shipments AS s2
    WHERE s2.carrier_id <> c.carrier_id
    GROUP BY s2.carrier_id
);

--Subquery version: customers who have shipments.
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM shipments);

--JOIN version: DISTINCT avoids repeating customers with many shipments.
--JOIN is useful when columns from both tables are needed in the output.
SELECT DISTINCT cu.customer_id, cu.customer_name
FROM customers AS cu
INNER JOIN shipments AS s ON s.customer_id = cu.customer_id;

--Subquery version: shipments handled by carriers with "Express" in name.
SELECT shipment_id, carrier_id, shipping_cost
FROM shipments
WHERE carrier_id IN (
    SELECT carrier_id
    FROM carriers
    WHERE carrier_name LIKE '%Express%'
);

--JOIN version: clearer when carrier information is also required.
SELECT s.shipment_id, s.carrier_id, s.shipping_cost, c.carrier_name
FROM shipments AS s
INNER JOIN carriers AS c ON c.carrier_id = s.carrier_id
WHERE c.carrier_name LIKE '%Express%';

--Return all shipments tied at the second distinct highest cost for each destination hub.
SELECT s1.destination_hub_id AS hub_id,
       s1.shipment_id,
       s1.shipping_cost
FROM shipments AS s1
WHERE s1.shipping_cost = (
    SELECT MAX(s2.shipping_cost)
    FROM shipments AS s2
    WHERE s2.destination_hub_id = s1.destination_hub_id
      AND s2.shipping_cost < (
          SELECT MAX(s3.shipping_cost)
          FROM shipments AS s3
          WHERE s3.destination_hub_id = s1.destination_hub_id
      )
)
ORDER BY hub_id, s1.shipment_id;
