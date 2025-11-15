-- This query provides a detailed risk and repayment profile for each customer.
-- For every customer in the 'customers' table:
--   1. COUNT(loans.loan_id) calculates the total number of loans taken by the customer.
--   2. SUM(loans.amount) calculates the total amount borrowed by that customer.
--   3. SUM(COALESCE(payments.amount_paid, 0)) calculates the total payments made by the customer,
--      using COALESCE to treat customers with no payments as 0.
--   4. repayment_rate_percent calculates the percentage of borrowed amount that has been repaid.
--   5. defaulted_loans counts the number of loans where total payments are less than the loan amount.
-- LEFT JOINs are used to ensure all customers are included, even if they have no loans or payments.
-- The results are grouped by customer_id and ordered to show the highest-risk customers first,
-- i.e., those with the most defaults and lowest repayment rates.



SELECT 
    customers.customer_id,
    COUNT(loans.loan_id) AS total_loans,
    SUM(loans.amount) AS total_amount_borrowed,
    SUM(COALESCE(payments.amount_paid, 0)) AS total_amount_repaid,
    ROUND(
        SUM(COALESCE(payments.amount_paid, 0))::numeric 
        / SUM(loans.amount)::numeric * 100, 2
    ) AS repayment_rate_percent,
    SUM(
        CASE 
            WHEN COALESCE(payments.amount_paid, 0) < loans.amount THEN 1
            ELSE 0
        END
    ) AS defaulted_loans
FROM customers
LEFT JOIN loans 
    ON loans.customer_id = customers.customer_id
LEFT JOIN payments 
    ON payments.loan_id = loans.loan_id
GROUP BY 
    customers.customer_id
ORDER BY defaulted_loans DESC, repayment_rate_percent ASC;




-- This query provides a detailed risk and repayment profile for top 10 customer.

--   1. COUNT(loans.loan_id) calculates the total number of loans taken by the customer.
--   2. SUM(loans.amount) calculates the total amount borrowed by that customer.
--   3. SUM(COALESCE(payments.amount_paid, 0)) calculates the total payments made by the customer,
--      using COALESCE to treat customers with no payments as 0.
--   4. repayment_rate_percent calculates the percentage of borrowed amount that has been repaid.
--   5. defaulted_loans counts the number of loans where total payments are less than the loan amount.
-- LEFT JOINs are used to ensure all customers are included, even if they have no loans or payments.
-- The results are grouped by customer_id and ordered to show the highest-risk customers first,
-- i.e., those with the most defaults and lowest repayment rates.





SELECT 
    customers.customer_id,
    COUNT(loans.loan_id) AS total_loans,
    SUM(loans.amount) AS total_amount_borrowed,
    SUM(COALESCE(payments.amount_paid, 0)) AS total_amount_repaid,
    ROUND(
        SUM(COALESCE(payments.amount_paid, 0))::numeric / SUM(loans.amount)::numeric * 100, 
        2
    ) AS repayment_rate_percent,
    SUM(
        CASE 
            WHEN COALESCE(payments.amount_paid, 0) < loans.amount THEN 1
            ELSE 0
        END
    ) AS defaulted_loans
FROM customers
LEFT JOIN loans ON loans.customer_id = customers.customer_id
LEFT JOIN payments ON payments.loan_id = loans.loan_id
GROUP BY customers.customer_id
ORDER BY defaulted_loans DESC, repayment_rate_percent ASC
LIMIT 10; 

