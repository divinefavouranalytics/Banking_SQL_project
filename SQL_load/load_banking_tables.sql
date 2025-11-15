-- Banking SQL Project - Data Import Script


-- Import customers data from CSV file
-- This table contains customer demographic information
\copy customers 
FROM 'C:\Users\tayod\OneDrive\Desktop\Banking_SQL_project\customers.csv' 
WITH (
    FORMAT csv,      
    HEADER true    
);

-- Import loans data from CSV file  
-- This table contains loan details and customer borrowing information
\copy loans 
FROM 'C:\Users\tayod\OneDrive\Desktop\Banking_SQL_project\loans.csv' 
WITH (
    FORMAT csv,      
    HEADER true      
);

-- Import payments data from CSV file
-- This table contains payment transactions and loan repayment history
\copy payments 
FROM 'C:\Users\tayod\OneDrive\Desktop\Banking_SQL_project\payments.csv' 
WITH (
    FORMAT csv,      
    HEADER true      
);


-- Script Purpose:
-- This script imports three core banking datasets:
-- 1. customers: Master customer information
-- 2. loans: Loan portfolio data  
-- 3. payments: Payment transaction records

-- These tables form the foundation for banking analytics
-- including customer segmentation, loan performance analysis,
-- and payment behavior tracking.
