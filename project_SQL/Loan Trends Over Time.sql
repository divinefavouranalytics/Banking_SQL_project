-- This query analyzes monthly loan issuance and repayment trends.
-- For each month (using DATE_TRUNC on loans.issue_date):
--   1. total_loans_issued counts the number of loans issued in that month.
--   2. total_amount_issued sums the amount of loans issued.
--   3. total_payments_received sums payments made in that month (COALESCE handles loans with no payments).
--   4. repayment_rate_percent calculates the percentage of borrowed money repaid for that month.
-- LEFT JOIN ensures all loans are considered even if they have no payments.
-- Results are grouped by month and ordered chronologically.
-- This analysis helps identify seasonal trends, growth patterns, and repayment behavior over time.



SELECT 
    DATE_TRUNC('month', loans.issue_date) AS month,
    COUNT(loans.loan_id) AS total_loans_issued,
    SUM(loans.amount) AS total_amount_issued,
    SUM(COALESCE(payments.amount_paid, 0)) AS total_payments_received,
    ROUND(
        SUM(COALESCE(payments.amount_paid, 0))::numeric 
        / SUM(loans.amount)::numeric * 100, 2
    ) AS repayment_rate_percent
FROM loans
LEFT JOIN payments 
    ON payments.loan_id = loans.loan_id
GROUP BY month
ORDER BY month;
