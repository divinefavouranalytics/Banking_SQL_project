-- This query calculates the total payments per loan and compares them to the loan amount.
-- For each loan:
--   1. total_paid sums all payments made for the loan (COALESCE handles loans with no payments as 0).
--   2. payment_status classifies the loan as 'Underpaid', 'Fully Paid', or 'Overpaid'.
-- LEFT JOIN ensures all loans are included even if no payments exist.
-- The results are grouped by loan_id and loan amount and ordered by loan_id.
-- This analysis shows repayment performance for individual loans.



SELECT 
    loans.loan_id,
    loans.amount AS loan_amount,
    COALESCE(SUM(payments.amount_paid), 0) AS total_paid,
    CASE 
        WHEN COALESCE(SUM(payments.amount_paid), 0) < loans.amount THEN 'Underpaid'
        WHEN COALESCE(SUM(payments.amount_paid), 0) = loans.amount THEN 'Fully Paid'
        WHEN COALESCE(SUM(payments.amount_paid), 0) > loans.amount THEN 'Overpaid'
    END AS payment_status
FROM loans
LEFT JOIN payments 
    ON payments.loan_id = loans.loan_id
GROUP BY 
    loans.loan_id, 
    loans.amount
ORDER BY 
    loans.loan_id;







/*
	This is a common analysis for understanding the health of a loan portfolio.

	The first part (the 'loan_payments' CTE) is crucial: it calculates the 
	*total amount paid* against the *original loan amount* for every single loan, 
	making sure to count zero payments for loans that haven't received anything yet (thanks to COALESCE and the LEFT JOIN).

	The final SELECT statement then aggregates these results. It essentially bins 
	all our loans into one of three buckets: 'Underpaid', 'Fully Paid', or 'Overpaid', 
	and then tells us the total count and percentage of loans in each category.

	In short: It gives us a quick, high-level view of repayment performance across the whole book.
*/




-- Calculate total paid per loan

WITH loan_payments AS (
    SELECT
        loans.loan_id,
        loans.amount AS loan_amount,
        COALESCE(SUM(payments.amount_paid), 0) AS total_paid
    FROM loans
    LEFT JOIN payments ON payments.loan_id = loans.loan_id
    GROUP BY loans.loan_id, loans.amount
)

-- Aggregate by payment status

SELECT
    CASE 
        WHEN total_paid < loan_amount THEN 'Underpaid'
        WHEN total_paid = loan_amount THEN 'Fully Paid'
        ELSE 'Overpaid'
    END AS payment_status,
    COUNT(*) AS num_loans,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM loans), 2) AS pct_of_total
FROM loan_payments
GROUP BY payment_status
ORDER BY num_loans DESC;