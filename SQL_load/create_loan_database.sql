-- The customers table stores basic demographic and financial information 
-- about each client. This allows us to analyze how factors like age, 
-- income, employment status, and region relate to loan risk and repayment behavior.



CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    age INT,
    income INT,
    employment_status VARCHAR(50),
    region VARCHAR(50)
);


-- The loans table records every loan issued to customers. 
-- It connects borrowers to their loans and includes key financial attributes 
-- such as loan amount, interest rate, issue date, and current status. 
-- This helps in analyzing approval patterns, risk levels, and default trends.




CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    amount INT,
    interest_rate DECIMAL,
    issue_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- The payments table tracks all repayments made toward each loan. 
-- Linking payments to loans allows us to evaluate repayment behavior, 
-- detect late or missed payments, and calculate total amounts repaid over time.
-- This is essential for understanding borrower performance and loan risk.



CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);



