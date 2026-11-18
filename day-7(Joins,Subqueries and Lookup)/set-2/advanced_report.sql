--creating database
CREATE DATABASE bank_loan_portfolio;
USE bank_loan_portfolio;

--creating tables
CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    branch_id INT NOT NULL REFERENCES branches(branch_id),
    loan_amount DECIMAL(12,2) NOT NULL CHECK (loan_amount > 0),
    interest_rate DECIMAL(5,2) NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_instalments INT NOT NULL CHECK (total_instalments > 0),
    status VARCHAR(30) NOT NULL
);

CREATE TABLE guarantors (
    guarantor_id INT PRIMARY KEY,
    loan_id INT NOT NULL REFERENCES loans(loan_id),
    guarantor_customer_id INT NOT NULL REFERENCES customers(customer_id)
);

CREATE TABLE repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT NOT NULL REFERENCES loans(loan_id),
    repayment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    instalment_number INT NOT NULL
);

--inserting values
INSERT INTO branches VALUES
(1, 'Coimbatore Main', 'Coimbatore'),
(2, 'Chennai Central', 'Chennai'),
(3, 'Bengaluru City', 'Bengaluru'),
(4, 'Madurai Branch', 'Madurai'),
(5, 'Salem Branch', 'Salem');

INSERT INTO customers VALUES
(1, 'Arun Kumar', '9000000001'),
(2, 'Divya Ravi', '9000000002'),
(3, 'Karthik S', '9000000003'),
(4, 'Meena P', '9000000004'),
(5, 'Rahul N', '9000000005'),
(6, 'Priya M', '9000000006'),
(7, 'Vijay K', '9000000007');

INSERT INTO loans VALUES
(101, 1, 1, 500000, 9.50, '2025-01-10', '2026-01-10', 12, 'Active'),
(102, 2, 1, 300000, 8.75, '2025-03-15', '2026-03-15', 12, 'Active'),
(103, 1, 2, 750000, 9.00, '2025-02-01', '2026-02-01', 12, 'Active'),
(104, 3, 2, 250000, 10.00, '2025-04-20', '2026-04-20', 10, 'Active'),
(105, 4, 3, 900000, 8.50, '2025-01-05', '2026-01-05', 12, 'Active'),
(106, 5, 3, 400000, 9.25, '2025-05-10', '2026-05-10', 10, 'Active'),
(107, 6, 1, 150000, 11.00, '2025-06-01', '2026-06-01', 12, 'Active'),
(108, 7, 4, 600000, 9.75, '2025-02-12', '2026-02-12', 12, 'Active');

INSERT INTO guarantors VALUES
(1, 101, 3),
(2, 102, 4),
(3, 103, 2),
(4, 104, 1),
(5, 105, 7),
(6, 106, 2),
(7, 107, 5);

INSERT INTO repayments VALUES
(1, 101, '2026-09-01', 45000, 1),
(2, 101, '2026-09-15', 45000, 2),
(3, 102, '2026-08-10', 28000, 1),
(4, 103, '2026-07-01', 65000, 1),
(5, 104, '2026-10-20', 26000, 1),
(6, 105, '2026-09-10', 80000, 1),
(7, 106, '2026-06-15', 35000, 1),
(8, 107, '2026-10-25', 14000, 1);

--Loans overdue by more than three instalments.
--INNER JOIN combines loans and repayments; count missed instalments from the last paid instalment.
SELECT l.loan_id, c.customer_name, b.branch_name,
       l.total_instalments - ISNULL(MAX(r.instalment_number), 0) AS unpaid_instalments
FROM loans l
INNER JOIN customers c ON c.customer_id = l.customer_id
INNER JOIN branches b ON b.branch_id = l.branch_id
LEFT JOIN repayments r ON r.loan_id = l.loan_id
GROUP BY l.loan_id, c.customer_name, b.branch_name, l.total_instalments
HAVING l.total_instalments - ISNULL(MAX(r.instalment_number), 0) > 3;

--Customers who have loans in more than one branch.
SELECT c.customer_id, c.customer_name, COUNT(DISTINCT l.branch_id) AS branch_count
FROM customers c
INNER JOIN loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT l.branch_id) > 1;

--Guarantors who are also borrowers.
--SELF JOIN: match guarantor customer IDs against customers who have loans.
SELECT DISTINCT g.guarantor_customer_id, c.customer_name, l.loan_id AS borrower_loan_id
FROM guarantors g
INNER JOIN customers c ON c.customer_id = g.guarantor_customer_id
INNER JOIN loans l ON l.customer_id = g.guarantor_customer_id;

--Branches with no loans.
--LEFT JOIN keeps branches even when no loan exists.
SELECT b.branch_id, b.branch_name
FROM branches b
LEFT JOIN loans l ON l.branch_id = b.branch_id
WHERE l.loan_id IS NULL;

--All loans with customer and branch details.
SELECT l.loan_id, c.customer_name, b.branch_name, l.loan_amount, l.status
FROM loans l
INNER JOIN customers c ON c.customer_id = l.customer_id
INNER JOIN branches b ON b.branch_id = l.branch_id;

--Each loan with its repayments, including loans without repayments.
SELECT l.loan_id, c.customer_name, r.repayment_id, r.repayment_date, r.amount
FROM loans l
INNER JOIN customers c ON c.customer_id = l.customer_id
LEFT JOIN repayments r ON r.loan_id = l.loan_id
ORDER BY l.loan_id, r.repayment_date;

--Branch-wise loan count and total loan amount, including empty branches.
SELECT b.branch_id, b.branch_name, COUNT(l.loan_id) AS loan_count,
       ISNULL(SUM(l.loan_amount), 0) AS total_loan_amount
FROM branches b
LEFT JOIN loans l ON l.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name;

--Customers and their total repayments, including customers with none.
SELECT c.customer_id, c.customer_name, ISNULL(SUM(r.amount), 0) AS total_repaid
FROM customers c
LEFT JOIN loans l ON l.customer_id = c.customer_id
LEFT JOIN repayments r ON r.loan_id = l.loan_id
GROUP BY c.customer_id, c.customer_name;

--Loans and their guarantor details, including loans without guarantors.
SELECT l.loan_id, c.customer_name AS borrower_name,
       gc.customer_name AS guarantor_name
FROM loans l
INNER JOIN customers c ON c.customer_id = l.customer_id
LEFT JOIN guarantors g ON g.loan_id = l.loan_id
LEFT JOIN customers gc ON gc.customer_id = g.guarantor_customer_id;

--Pairs of customers who share the same branch through their loans.
--SELF JOIN compares loans in the same branch and avoids duplicate/reversed pairs.
SELECT DISTINCT l1.branch_id, l1.customer_id AS customer_1,
       l2.customer_id AS customer_2
FROM loans l1
INNER JOIN loans l2
  ON l1.branch_id = l2.branch_id
 AND l1.customer_id < l2.customer_id;

--Customers whose total loan exposure exceeds their branch's average customer exposure.
--Correlated subquery: inner query refers to the outer branch_id.
SELECT c.customer_id, c.customer_name, l.branch_id,
       (SELECT SUM(l2.loan_amount)
        FROM loans l2
        WHERE l2.customer_id = c.customer_id) AS total_exposure
FROM customers c
INNER JOIN loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, l.branch_id
HAVING (SELECT SUM(l3.loan_amount)
        FROM loans l3
        WHERE l3.customer_id = c.customer_id)
       >
       (SELECT AVG(customer_exposure)
        FROM (
            SELECT customer_id, SUM(loan_amount) AS customer_exposure
            FROM loans
            WHERE branch_id = l.branch_id
            GROUP BY customer_id
        ) AS branch_exposures);

--Uncorrelated subquery: loans greater than the bank-wide average loan amount.
SELECT loan_id, customer_id, branch_id, loan_amount
FROM loans
WHERE loan_amount > (SELECT AVG(loan_amount) FROM loans);

--Customers with a loan but no repayment in the last 60 days.
--EXISTS confirms a loan; NOT EXISTS confirms no recent repayment for that loan.
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM loans l
    INNER JOIN repayments r ON r.loan_id = l.loan_id
    WHERE l.customer_id = c.customer_id
      AND r.repayment_date >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
);

--Branches whose highest loan exceeds the average of all branch maximum loans.
SELECT b.branch_id, b.branch_name
FROM branches b
WHERE (
    SELECT MAX(l.loan_amount)
    FROM loans l
    WHERE l.branch_id = b.branch_id
) > (
    SELECT AVG(branch_maximum)
    FROM (
        SELECT branch_id, MAX(loan_amount) AS branch_maximum
        FROM loans
        GROUP BY branch_id
    ) AS branch_maxima
);
