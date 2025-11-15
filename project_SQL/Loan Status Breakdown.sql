-- This query summarizes the number of loans by their status.
-- It joins the 'customers' and 'loans' tables to include only loans linked to customers,
-- and joins 'payments' to consider only loans with payment records.
-- For each loan status (e.g., 'current', 'paid', 'late', 'defaulted'):
--   1. total_loans counts the number of loans in that status.
-- The results are grouped by loan status and ordered in descending order to highlight the most common loan status.



SELECT loans.status,
    count(*) as total_loans
FROM customers
INNER JOIN loans ON loans.customer_id = customers.customer_id
INNER JOIN payments ON payments.loan_id = loans.loan_id
GROUP BY loans.status
ORDER BY total_loans DESC


