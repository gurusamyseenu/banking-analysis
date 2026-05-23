
-- 1. List all customers
SELECT * FROM customers;

-- 2. Find customers living in "Mumbai"
SELECT name, city FROM customers WHERE city = 'Mumbai';

-- 3. Count total accounts by account type
SELECT account_type, COUNT(*) AS total_accounts
FROM accounts
GROUP BY account_type;

-- 4. Find accounts with balance greater than ?50,000
SELECT account_id, balance 
FROM accounts
WHERE balance > 50000;

-- 5. Get total deposits and withdrawals per account
SELECT account_id,
       SUM(CASE WHEN txn_type = 'Credit' THEN amount ELSE 0 END) AS total_credit,
       SUM(CASE WHEN txn_type = 'Debit' THEN amount ELSE 0 END) AS total_debit
FROM transactions
GROUP BY account_id;

-- 6. Find customers with active loans
SELECT DISTINCT c.customer_id, c.name
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
WHERE l.status = 'Active';

-- 7. Find loan amount per loan type
SELECT loan_type, SUM(amount) AS total_amount
FROM loans
GROUP BY loan_type;

-- 8. Find top 5 highest loan amounts
SELECT TOP 5 loan_id, customer_id, amount
FROM loans
ORDER BY amount DESC;

-- 9. Monthly transaction volume (credits + debits)
SELECT YEAR(txn_date) AS yr, MONTH(txn_date) AS mn,
       SUM(amount) AS total_volume
FROM transactions
GROUP BY YEAR(txn_date), MONTH(txn_date)
ORDER BY yr, mn;

-- 10. Find suspicious transactions (> ?1,00,000)
SELECT t.txn_id, c.name, t.amount, t.channel
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.amount > 100000;

-- 11. Find customers with more than 1 loan
SELECT customer_id, COUNT(*) AS loan_count
FROM loans
GROUP BY customer_id
HAVING COUNT(*) >= 1;

-- 12. Average loan duration (in days)
SELECT AVG(DATEDIFF(DAY, start_date, end_date)) AS avg_loan_duration
FROM loans;

-- 13. Find customers who never did a transaction
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.txn_id IS NULL;

-- 14. Find top 3 customers with highest total balance
SELECT TOP 3 c.customer_id, c.name, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_balance DESC;

-- 15. Find customers who took loans but have < ?5,000 balance
SELECT c.customer_id, c.name, a.balance, l.amount AS loan_amount
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN loans l ON c.customer_id = l.customer_id
WHERE a.balance < 5000 AND l.status = 'Active';

-- ===============================================
-- 5. Create View
-- ===============================================
CREATE VIEW active_loans_view AS
SELECT l.loan_id, c.name, l.loan_type, l.amount, l.start_date, l.end_date
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
WHERE l.status = 'Active';

-- ===============================================
-- 6. Stored Procedure
-- ===============================================
CREATE PROCEDURE sp_fraud_detection
AS
BEGIN
    SELECT t.txn_id, c.name, a.account_type, t.amount, t.channel, t.txn_date
    FROM transactions t
    JOIN accounts a ON t.account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.amount > 100000;
END;

EXEC sp_fraud_detection;

-- ===============================================
-- 7. Trigger
-- ===============================================
CREATE TRIGGER trg_auto_update_loan_status
ON loans
AFTER UPDATE
AS
BEGIN
    UPDATE loans
    SET status = 'Completed'
    WHERE end_date < GETDATE() AND status = 'Active';
END;