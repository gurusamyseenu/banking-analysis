use banking_db;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    city VARCHAR(50),
    contact_no VARCHAR(15)
);
INSERT INTO customers
(customer_id, name, dob, city, contact_no)

WITH RECURSIVE seq AS
(
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM seq
    WHERE n < 100
)

SELECT
    1000 + n,
    CONCAT('Customer_', n),

    DATE_ADD(
        '1970-01-01',
        INTERVAL FLOOR(RAND() * 15000) DAY
    ),

    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'Mumbai'
        WHEN 1 THEN 'Delhi'
        WHEN 2 THEN 'Bangalore'
        WHEN 3 THEN 'Chennai'
        ELSE 'Ahmedabad'
    END,

    CONCAT(
        '9',
        LPAD(FLOOR(RAND() * 1000000000), 9, '0')
    )

FROM seq;
select * from customers; 
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    balance DECIMAL(12,2),
    opened_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO accounts (
    account_id,
    customer_id,
    account_type,
    balance
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 100
)
SELECT
    2000 + n,
    1000 + n,  -- matches 1001–1100 in customers
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'Savings'
        WHEN 1 THEN 'Current'
        ELSE 'Fixed Deposit'
    END,
    ROUND(RAND() * 100000, 2)
FROM seq;
CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    account_id INT,
    txn_date DATE,
    txn_type VARCHAR(10), -- Debit / Credit
    amount DECIMAL(12,2),
    channel VARCHAR(30),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
INSERT INTO transactions (
    txn_id,
    account_id,
    txn_date,
    txn_type,
    amount,
    channel
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 100
)
SELECT
    3000 + n,  -- txn_id

    2000 + ((n - 1) % 100) + 1, -- account_id

    DATE_ADD(
        '2015-01-01',
        INTERVAL FLOOR(RAND() * 3650) DAY
    ), -- random date between 2015–2025

    CASE FLOOR(RAND() * 2)
        WHEN 0 THEN 'Debit'
        ELSE 'Credit'
    END,

    ROUND(RAND() * 50000, 2), -- random amount up to 50k

    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Online Banking'
        WHEN 1 THEN 'ATM'
        WHEN 2 THEN 'Branch'
        ELSE 'Mobile App'
    END
FROM seq;
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(30),
    amount DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO loans (
    loan_id,
    customer_id,
    loan_type,
    amount,
    start_date,
    end_date,
    status
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 100
)
SELECT
    4000 + n,  -- loan_id

    1000 + n,  -- customer_id (1001–1100)

    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Home Loan'
        WHEN 1 THEN 'Personal Loan'
        WHEN 2 THEN 'Car Loan'
        ELSE 'Education Loan'
    END,

    ROUND(RAND() * 1000000, 2), -- random loan amount up to 10L

    DATE_ADD(
        '2015-01-01',
        INTERVAL FLOOR(RAND() * 3650) DAY
    ), -- random start date between 2015–2025

    DATE_ADD(
        '2025-01-01',
        INTERVAL FLOOR(RAND() * 3650) DAY
    ), -- random end date after 2025

    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'Active'
        WHEN 1 THEN 'Closed'
        ELSE 'Defaulted'
    END
FROM seq;