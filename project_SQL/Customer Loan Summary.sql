-- This query summarizes each customer's borrowing activity.
-- For every customer in the 'customers' table:
--   1. COUNT(loans.loan_id) calculates the total number of loans the customer has taken.
--   2. SUM(loans.amount) calculates the total amount borrowed by that customer.
-- We use a LEFT JOIN to include all customers, even if they have no loans.
-- The results are grouped by customer_id and ordered by the number of loans in descending order,
-- so the customers with the most loans appear at the top.



SELECT 
    customers.customer_id,
    COUNT(loans.loan_id) AS total_loans,
    SUM(loans.amount) AS total_amount_borrowed
FROM customers
LEFT JOIN loans ON loans.customer_id = customers.customer_id
GROUP BY customers.customer_id
ORDER BY total_loans DESC;



-- This query summarizes the top 10 customer's borrowing activity.
-- For every customer in the 'customers' table:
--   1. COUNT(loans.loan_id) calculates the total number of loans the customer has taken.
--   2. SUM(loans.amount) calculates the total amount borrowed by that customer.
-- We use a LEFT JOIN to include all customers, even if they have no loans.
-- The results are grouped by customer_id and ordered by the number of loans in descending order,
-- so the customers with the most loans appear at the top.




SELECT 
    customers.customer_id,
    COUNT(loans.loan_id) AS total_loans,
    SUM(loans.amount) AS total_amount_borrowed
FROM customers
LEFT JOIN loans ON loans.customer_id = customers.customer_id
GROUP BY customers.customer_id
ORDER BY total_loans DESC
limit 10