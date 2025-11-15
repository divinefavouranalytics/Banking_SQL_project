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
