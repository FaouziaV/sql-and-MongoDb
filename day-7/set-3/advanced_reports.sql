--creating databases
CREATE DATABASE retail_returns_db;
USE retail_returns_db;

--creating tables
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    region VARCHAR(60) NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    email VARCHAR(150)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(120) NOT NULL,
    manager_id INT NULL REFERENCES employees(employee_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(product_id),
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    store_id INT NOT NULL REFERENCES stores(store_id),
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    sale_date DATE NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    sale_id INT NOT NULL REFERENCES sales(sale_id),
    return_date DATE NOT NULL,
    return_quantity INT NOT NULL CHECK (return_quantity > 0),
    reason VARCHAR(200)
);

CREATE TABLE refunds (
    refund_id INT PRIMARY KEY,
    return_id INT NOT NULL REFERENCES returns(return_id),
    refund_date DATE NOT NULL,
    refund_amount DECIMAL(12,2) NOT NULL CHECK (refund_amount >= 0)
);

CREATE TABLE returns_feedback (
    feedback_id INT PRIMARY KEY,
    return_id INT NOT NULL REFERENCES returns(return_id),
    feedback_date DATE NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments VARCHAR(500)
);

--inserting values
INSERT INTO stores VALUES
(1, 'Coimbatore Central', 'South'),
(2, 'Chennai Mall', 'South'),
(3, 'Bengaluru Plaza', 'South'),
(4, 'Mumbai Market', 'West'),
(5, 'Pune City Store', 'West');

INSERT INTO customers VALUES
(1, 'Arun Kumar', 'arun@example.com'),
(2, 'Divya Ravi', 'divya@example.com'),
(3, 'Karthik S', 'karthik@example.com'),
(4, 'Meena P', 'meena@example.com'),
(5, 'Rahul N', 'rahul@example.com'),
(6, 'Priya M', 'priya@example.com');

INSERT INTO products VALUES
(1, 'Wireless Mouse', 'Electronics', 800),
(2, 'Keyboard', 'Electronics', 1500),
(3, 'Travel Bag', 'Accessories', 2200),
(4, 'Water Bottle', 'Home', 400),
(5, 'Headphones', 'Electronics', 2500),
(6, 'Desk Lamp', 'Home', 1200);

INSERT INTO employees VALUES
(1, 'Ramesh', NULL),
(2, 'Suresh', 1),
(3, 'Anitha', 1),
(4, 'Kavya', 2),
(5, 'Manoj', 2),
(6, 'Priya', 3);

INSERT INTO sales VALUES
(101, 1, 1, 1, 2, '2026-01-05', 10, 800),
(102, 2, 2, 1, 3, '2026-01-08', 8, 1500),
(103, 3, 1, 2, 4, '2026-01-10', 5, 2200),
(104, 4, 3, 2, 5, '2026-01-12', 20, 400),
(105, 5, 4, 3, 6, '2026-01-15', 10, 2500),
(106, 1, 5, 3, 2, '2026-01-18', 5, 800),
(107, 2, 6, 4, 3, '2026-01-20', 10, 1500),
(108, 3, 2, 4, 4, '2026-01-22', 4, 2200),
(109, 5, 3, 5, 5, '2026-01-25', 6, 2500),
(110, 6, 4, 5, 6, '2026-01-28', 10, 1200),
(111, 1, 6, 1, 2, '2026-02-01', 5, 800),
(112, 4, 5, 2, 4, '2026-02-03', 10, 400);

INSERT INTO returns VALUES
(201, 101, '2026-02-05', 2, 'Damaged'),
(202, 102, '2026-02-06', 1, 'Wrong item'),
(203, 103, '2026-02-08', 1, 'Size issue'),
(204, 105, '2026-02-10', 2, 'Defective'),
(205, 106, '2026-02-12', 1, 'Damaged'),
(206, 108, '2026-02-14', 1, 'Changed mind'),
(207, 109, '2026-02-16', 2, 'Defective'),
(208, 111, '2026-02-18', 1, 'Damaged');

INSERT INTO refunds VALUES
(301, 201, '2026-02-07', 1600),
(302, 202, '2026-02-08', 1500),
(303, 204, '2026-02-12', 5000),
(304, 205, '2026-02-14', 800),
(305, 207, '2026-02-18', 5000);

INSERT INTO returns_feedback VALUES
(401, 201, '2026-02-08', 2, 'Product arrived damaged'),
(402, 202, '2026-02-09', 3, 'Incorrect product received'),
(403, 203, '2026-02-10', 4, 'Return process was easy'),
(404, 204, '2026-02-13', 1, 'Product was defective'),
(405, 205, '2026-02-15', 2, 'Packaging was poor'),
(406, 207, '2026-02-19', 3, 'Refund received');


--Products with a return rate above 10 percent.
--INNER JOIN links sales to products; LEFT JOIN includes products with no returns.
SELECT p.product_id, p.product_name,
       SUM(s.quantity) AS units_sold,
       ISNULL(SUM(r.return_quantity), 0) AS units_returned,
       CAST(100.0 * ISNULL(SUM(r.return_quantity), 0) /
            NULLIF(SUM(s.quantity), 0) AS DECIMAL(6,2)) AS return_rate_percent
FROM products p
INNER JOIN sales s ON s.product_id = p.product_id
LEFT JOIN returns r ON r.sale_id = s.sale_id
GROUP BY p.product_id, p.product_name
HAVING 100.0 * ISNULL(SUM(r.return_quantity), 0) /
       NULLIF(SUM(s.quantity), 0) > 10;

--Customers with returns but no refund.
--NOT EXISTS checks that no refund is linked to any of their returns.
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
INNER JOIN sales s ON s.customer_id = c.customer_id
INNER JOIN returns r ON r.sale_id = s.sale_id
WHERE NOT EXISTS (
    SELECT 1
    FROM refunds rf
    WHERE rf.return_id = r.return_id
);

--Stores ranked by total refund value.
--LEFT JOIN retains stores with zero refunds.
SELECT st.store_id, st.store_name,
       ISNULL(SUM(rf.refund_amount), 0) AS total_refund_value
FROM stores st
LEFT JOIN sales s ON s.store_id = st.store_id
LEFT JOIN returns r ON r.sale_id = s.sale_id
LEFT JOIN refunds rf ON rf.return_id = r.return_id
GROUP BY st.store_id, st.store_name
ORDER BY total_refund_value DESC;

--Employees and their managers.
--SELF JOIN: manager and employee are rows in employees.
SELECT e.employee_id, e.employee_name,
       m.employee_id AS manager_id, m.employee_name AS manager_name
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id;

--Return details with product and customer names.
SELECT r.return_id, p.product_name, c.customer_name,
       r.return_quantity, r.return_date, r.reason
FROM returns r
INNER JOIN sales s ON s.sale_id = r.sale_id
INNER JOIN products p ON p.product_id = s.product_id
INNER JOIN customers c ON c.customer_id = s.customer_id;

--All products and their returned quantities, including zero returns.
SELECT p.product_id, p.product_name,
       ISNULL(SUM(r.return_quantity), 0) AS returned_quantity
FROM products p
LEFT JOIN sales s ON s.product_id = p.product_id
LEFT JOIN returns r ON r.sale_id = s.sale_id
GROUP BY p.product_id, p.product_name;

--Customers and total refund amounts, including customers with no refunds.
SELECT c.customer_id, c.customer_name,
       ISNULL(SUM(rf.refund_amount), 0) AS total_refund
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
LEFT JOIN returns r ON r.sale_id = s.sale_id
LEFT JOIN refunds rf ON rf.return_id = r.return_id
GROUP BY c.customer_id, c.customer_name;

--Returns with their feedback, including returns without feedback.
SELECT r.return_id, r.reason, f.rating, f.comments
FROM returns r
LEFT JOIN returns_feedback f ON f.return_id = r.return_id;

--Stores with return count and refund total by region.
SELECT st.store_id, st.store_name, st.region,
       COUNT(DISTINCT r.return_id) AS return_count,
       ISNULL(SUM(rf.refund_amount), 0) AS refund_total
FROM stores st
LEFT JOIN sales s ON s.store_id = st.store_id
LEFT JOIN returns r ON r.sale_id = s.sale_id
LEFT JOIN refunds rf ON rf.return_id = r.return_id
GROUP BY st.store_id, st.store_name, st.region;

--Sales with product, store, customer and employee information.
SELECT s.sale_id, p.product_name, st.store_name,
       c.customer_name, e.employee_name, s.quantity, s.unit_price
FROM sales s
INNER JOIN products p ON p.product_id = s.product_id
INNER JOIN stores st ON st.store_id = s.store_id
INNER JOIN customers c ON c.customer_id = s.customer_id
INNER JOIN employees e ON e.employee_id = s.employee_id;

--IN: customers who made at least one return.
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (
    SELECT s.customer_id
    FROM sales s
    INNER JOIN returns r ON r.sale_id = s.sale_id
);

--NOT IN demonstration: NULL in the subquery can make the result UNKNOWN.
--This demonstration intentionally adds NULL to the returned customer IDs.
SELECT customer_id, customer_name
FROM customers
WHERE customer_id NOT IN (
    SELECT s.customer_id
    FROM sales s
    INNER JOIN returns r ON r.sale_id = s.sale_id
    UNION
    SELECT CAST(NULL AS INT)
);

--Correct version using NOT EXISTS.
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    INNER JOIN returns r ON r.sale_id = s.sale_id
    WHERE s.customer_id = c.customer_id
);

--Stores whose refund total is greater than ANY other store in their region.
WITH StoreRefunds AS (
    SELECT st.store_id, st.store_name, st.region,
           ISNULL(SUM(rf.refund_amount), 0) AS refund_total
    FROM stores st
    LEFT JOIN sales s ON s.store_id = st.store_id
    LEFT JOIN returns r ON r.sale_id = s.sale_id
    LEFT JOIN refunds rf ON rf.return_id = r.return_id
    GROUP BY st.store_id, st.store_name, st.region
)
SELECT sr.store_id, sr.store_name, sr.region, sr.refund_total
FROM StoreRefunds sr
WHERE sr.refund_total > ANY (
    SELECT other.refund_total
    FROM StoreRefunds other
    WHERE other.region = sr.region
      AND other.store_id <> sr.store_id
);

--Stores whose refund total is greater than ALL other stores in their region.
WITH StoreRefunds AS (
    SELECT st.store_id, st.store_name, st.region,
           ISNULL(SUM(rf.refund_amount), 0) AS refund_total
    FROM stores st
    LEFT JOIN sales s ON s.store_id = st.store_id
    LEFT JOIN returns r ON r.sale_id = s.sale_id
    LEFT JOIN refunds rf ON rf.return_id = r.return_id
    GROUP BY st.store_id, st.store_name, st.region
)
SELECT sr.store_id, sr.store_name, sr.region, sr.refund_total
FROM StoreRefunds sr
WHERE sr.refund_total > ALL (
    SELECT other.refund_total
    FROM StoreRefunds other
    WHERE other.region = sr.region
      AND other.store_id <> sr.store_id
);


--Products priced above the average product price in their category.
SELECT p.product_id, p.product_name, p.category, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p2.category = p.category
);

--Stores whose refund total is above the average refund total of all stores.
SELECT st.store_id, st.store_name
FROM stores st
WHERE (
    SELECT ISNULL(SUM(rf.refund_amount), 0)
    FROM sales s
    INNER JOIN returns r ON r.sale_id = s.sale_id
    INNER JOIN refunds rf ON rf.return_id = r.return_id
    WHERE s.store_id = st.store_id
) > (
    SELECT AVG(store_refund)
    FROM (
        SELECT st2.store_id,
               ISNULL(SUM(rf2.refund_amount), 0) AS store_refund
        FROM stores st2
        LEFT JOIN sales s2 ON s2.store_id = st2.store_id
        LEFT JOIN returns r2 ON r2.sale_id = s2.sale_id
        LEFT JOIN refunds rf2 ON rf2.return_id = r2.return_id
        GROUP BY st2.store_id
    ) AS refund_summary
);
