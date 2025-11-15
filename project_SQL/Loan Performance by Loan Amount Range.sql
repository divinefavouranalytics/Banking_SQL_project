-- This query analyzes loan performance based on loan amount ranges.
-- Loans are categorized into three size groups:
--   1. Small: 0–1000
--   2. Medium: 1001–5000
--   3. Large: 5001+
-- For each category:
--   1. total_loans counts the number of loans in that range.
--   2. total_amount_borrowed sums all loan amounts in the category.
--   3. total_amount_repaid sums all payments made for these loans,
--      using COALESCE to handle loans with no payments.
--   4. repayment_rate_percent calculates the percentage of borrowed money that has been repaid.
--   5. default_count counts loans where total payments are less than the loan amount.
-- LEFT JOIN is used to include loans even if they have no payments.
-- The results are ordered by the number of loans per category to highlight the most common loan sizes.




SELECT 
    CASE 
        WHEN amount <= 1000 THEN 'Small (0–1000)'
        WHEN amount BETWEEN 1001 AND 5000 THEN 'Medium (1001–5000)'
        ELSE 'Large (5001+)'
    END AS loan_size_category,

    COUNT(*) AS total_loans,
    SUM(amount) AS total_amount_borrowed,
    SUM(COALESCE(p.amount_paid, 0)) AS total_amount_repaid,

    ROUND(
        SUM(COALESCE(p.amount_paid, 0))::numeric 
        / SUM(amount)::numeric * 100, 
        2
    ) AS repayment_rate_percent,

    SUM(
        CASE 
            WHEN COALESCE(p.amount_paid, 0) < amount THEN 1
            ELSE 0
        END
    ) AS default_count

FROM loans l
LEFT JOIN payments p ON p.loan_id = l.loan_id
GROUP BY loan_size_category
ORDER BY total_loans DESC;

