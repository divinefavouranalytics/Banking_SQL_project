# Banking Loan Analysis Project

### Project Overview

In this project, I dove deep into a bank's loan portfolio to understand how loans are performing, how customers are repaying them, and where potential risks might be hiding. It's the kind of analysis that banking professionals actually do to make smarter lending decisions and manage their portfolio more effectively.


💬 Curious about the SQL behind these insights? You can find all my queries here: [project_sql folder](/project_SQL/).

### What I Wanted to Discover:

- Get a clear picture of where loans stand across the entire portfolio
- Measure how well customers are keeping up with their payments
- Spot customers who might be higher risk and understand default patterns
- See if loan size affects repayment behavior
- Track how lending and repayments have changed over time


<p>
<br>


### Tables Used:

<p>
<br>

| **Table**     | **Description**  | **Columns**                                                                 |
| ------------- | ---------------- | --------------------------------------------------------------------------- |
| **customers** | Customer details | `customer_id`, `age`, `income`, `employment_status`, `region`               |
| **loans**     | Loans issued     | `loan_id`, `customer_id`, `amount`, `interest_rate`, `issue_date`, `status` |
| **payments**  | Payments made    | `payment_id`, `loan_id`, `payment_date`, `amount_paid`                      |

<p>
<br>
<br>
<br>


## SQL Skills Demonstrated


| SQL Concept                        | Description / Use Case                                               |
| ---------------------------------- | -------------------------------------------------------------------- |
| **INNER JOIN / LEFT JOIN**         | Combine data from multiple tables based on a related column          |
| **Aggregations (COUNT, SUM, AVG)** | Summarize data to get totals, averages, or counts                    |
| **CASE statements**                | Conditional logic for classification or categorization               |
| **COALESCE**                       | Handle `NULL` values by providing a default                          |
| **GROUP BY / ORDER BY**            | Group data for aggregation and sort results                          |
| **Window functions (optional)**    | Perform calculations across a set of rows related to the current row |
| **Date functions (DATE_TRUNC)**    | Analyze and manipulate time-series data                              |

<p>
<br>


# Analyses Performed
<p>
<br>

### 1. Loan Status Breakdown



**What I wanted to know:** 
How many loans are in good standing versus those that are late or defaulted?


**SQL Query**
```SQL 
SELECT loans.status,
count(*) as total_loans
FROM customers
INNER JOIN loans ON loans.customer_id = customers.customer_id
INNER JOIN payments ON payments.loan_id = loans.loan_id
GROUP BY loans.status
ORDER BY total_loans DESC

```

**What I found :**

Looking at over 77,000+ loans in the bank's records, most are in pretty good shape. The majority (43,911 loans) are current, meaning people are making their payments on time. But there are definitely some areas that need attention - about 15,600 loans are running late, and another 8,100 have already defaulted. On the bright side, 12,300 loans have been completely paid off.

<br>
<br>

![Alt text](/assets/Code_Generated_Image(1).png)

<br>
<br>

### 2. Total Payments vs Loan Amount

**What I wanted to know:**  
Are people keeping up with their loan payments, or falling behind?



<p>
<br>

**SQL Query**
```SQL 

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



```
<p>
<br>

**What I found:**

This was really interesting - most people are still in the process of paying back their loans. About 92% of loans haven't been fully repaid yet. But there's a small group of customers (about 7.6%) who've actually paid more than they originally borrowed, which might mean they're paying early or making extra payments.


<p>
<br>

![Alt text](/assets/Code_Generated_Image(2).png)

<p>
<br>

**Key Takeaway:**

Since most customers are still working on paying down their loans, the bank needs to stay on top of monitoring and follow-ups. The small group that's paying extra might have habits worth studying - maybe we can encourage others to follow their example.



<p>
<br>


### 3. Customer Loan Summary

**What I wanted to know**:  
Who are the bank's biggest borrowers, and should we be concerned about concentration risk?

<br>

**SQL Query**
```SQL 

SELECT 
    customers.customer_id,
    COUNT(loans.loan_id) AS total_loans,
    SUM(loans.amount) AS total_amount_borrowed
FROM customers
LEFT JOIN loans ON loans.customer_id = customers.customer_id
GROUP BY customers.customer_id
ORDER BY total_loans DESC
limit 10
```
<br>

**What I found:**

 Some customers really stand out when you look at their borrowing patterns. One customer has 9 different loans totaling over $200,000! Several others have 6-7 loans each, with amounts ranging from about $98,000 to $200,000.

<p>
<br>

| Customer ID | Total Loans | Total Amount Borrowed |
| ----------- | ----------- | --------------------- |
| 1700        | 9           | $207,540               |
| 9067        | 7           | $200,593               |
| 7606        | 7           | $165,472               |
| 2378        | 7           | $134,363               |
| 390         | 7           | $152,916               |
| 5122        | 7           | $184,573               |
| 6408        | 7           | $192,404               |
| 291         | 6           | $97,939                |
| 5614        | 6           | $119,094               |
| 4503        | 6           | $127,754               |


<p>
<br>

**Why this matters:**

A handful of customers account for a significant chunk of the bank's lending. While this isn't necessarily bad, it does mean the bank should keep a closer eye on these customers. If even one of these big borrowers runs into trouble, it could have a noticeable impact.

<p>
<br>



### 4. Loan Performance by Loan Amount Range

**What I wanted to know:** 
Does the size of the loan affect how likely people are to repay it?


**SQL Query**
```SQL 



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


```


**What I found:**

The results were pretty striking. Large loans (over $5,000) make up the bulk of the portfolio but have a really low repayment rate - only about 3% of what's been borrowed has been paid back. Medium-sized loans do a bit better at around 26% repayment. But the real stars are small loans - not only are they mostly repaid, but some customers have actually paid back more than they borrowed!

<br>

| Loan Size Category     | Total Loans | Total Amount Borrowed | Total Amount Repaid | Repayment Rate (%) | Default Count |
|-----------------------|------------:|--------------------:|------------------:|-----------------:|--------------:|
| Large (5001+)          | 72,551      | $1,989,579,617      | $56,232,053.34    | 2.83             | 72,551        |
| Medium (1001–5000)     | 6,737       | $20,142,853         | $5,194,444.62     | 25.79            | 6,585         |
| Small (0–1000)         | 790         | $583,869            | $628,870.68       | 107.71           | 384           |


<br>

**What this means for the bank:**

Large loans are where most of the risk sits. The bank might want to look at why repayment is so low in this category - are the terms too strict? Are these loans going to people who can't really afford them? Meanwhile, small loans seem to be working really well and might be worth promoting more.

<br>
<br>


### 5 Customer Risk Segmentation

**What I wanted to know:**  
Who are the highest-risk customers that the bank should be most concerned about?

<br>
<br>

**SQL Query**
```SQL 

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


```


**What I found:**

Some patterns here were concerning. I found customers with dozens of loans who had barely made a dent in paying them back. For example, one customer had 52 loans totaling over $1.3 million but had only repaid about 3% of that amount. Several other customers showed similar patterns - lots of borrowing, very little repayment.


<br>

| Customer ID | Total Loans | Total Amount Borrowed | Total Amount Repaid | Repayment Rate (%) | Defaulted Loans |
|------------:|------------:|--------------------:|------------------:|-----------------:|----------------:|
| 5122        | 52          | $1,303,394          | $36,850.53        | 2.83             | 52              |
| 390         | 49          | $1,026,803          | $36,661.72        | 3.57             | 49              |
| 5140        | 46          | $1,395,354          | $38,410.83        | 2.75             | 46              |
| 1572        | 43          | $1,546,379          | $34,606.10        | 2.24             | 43              |
| 9067        | 41          | $1,215,312          | $34,389.08        | 2.83             | 41              |
| 4678        | 41          | $1,054,204          | $31,578.53        | 3.00             | 41              |
| 1820        | 41          | $649,113            | $28,689.77        | 4.42             | 41              |
| 7433        | 40          | $728,830            | $35,332.20        | 4.85             | 40              |
| 7606        | 38          | $1,063,450          | $29,064.83        | 2.73             | 38              |
| 2378        | 38          | $794,886            | $26,607.34        | 3.35             | 38              |




<br>

Customers 5140, 1572, and 9067 also show repayment rates under 3%, despite having dozens of loans.

<br>

**Why this matters:**

These customers represent a significant risk to the bank. They've borrowed a lot and aren't paying it back. Identifying them early gives the bank a chance to intervene - maybe through payment plans, closer monitoring, or adjusting future lending decisions. It's much better to spot these patterns now than wait until these loans become major losses.

<br>

### 6. Loan Trends Over Time

**What I wanted to know:** 
How has the bank's lending activity changed month to month, and are there any seasonal patterns in repayments?



<br>
<br>

**SQL Query**
```SQL 
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

```



**What I found:**

The bank has been pretty consistent in issuing between 1,500 and 1,900 loans each month. What caught my eye was that repayment rates have stayed around 3% month after month, which seems quite low. There were a couple of months where repayments ticked up slightly, but overall the pattern has been stable.


<br>
<br>

| Month     | Total Loans Issued | Total Amount Issued | Total Payments Received | Repayment Rate (%) |
|----------|-----------------:|------------------:|----------------------:|-----------------:|
| 2021-01  | 1,722            | $42,482,827       | $1,327,444.73         | 3.12             |
| 2021-02  | 1,547            | $40,995,453       | $1,170,246.24         | 2.85             |
| 2021-03  | 1,672            | $41,121,930       | $1,296,006.25         | 3.15             |
| 2021-04  | 1,505            | $38,721,604       | $1,194,456.51         | 3.08             |
| 2021-05  | 1,708            | $42,262,360       | $1,318,207.22         | 3.12             |
| 2021-06  | 1,731            | $43,071,031       | $1,357,234.22         | 3.15             |
| 2021-07  | 1,619            | $37,276,733       | $1,239,035.47         | 3.32             |
| 2021-08  | 1,664            | $43,161,060       | $1,309,117.93         | 3.03             |
| 2021-09  | 1,481            | $37,681,969       | $1,173,999.99         | 3.12             |
| 2021-10  | 1,808            | $46,558,946       | $1,404,081.11         | 3.02             |
| 2021-11  | 1,615            | $38,637,604       | $1,261,605.75         | 3.27             |
| 2021-12  | 1,664            | $41,891,461       | $1,275,761.51         | 3.05             |



<br>
<br>

**What this means:**

The steady repayment rate suggests there might be some underlying issues with how loans are structured or who they're being offered to. The bank might want to investigate why repayments aren't improving over time and whether there are ways to encourage better repayment habits.


<br>
<br>


# What I Learned Through This Project

- 📊 **Real Data Analysis:** I learned how to take raw banking data and turn it into actionable insights that could actually help a bank make better decisions

- 🔍 **SQL in Practice:** This wasn't just textbook SQL - I used joins, aggregations, and case statements to solve real business problems

- **💰 Understanding Financial Health:** I now have a much better grasp of what makes a loan portfolio healthy or risky

- **📈 Spotting Patterns:** I learned to identify trends over time and patterns in customer behavior that might not be obvious at first glance

- **🎯 Risk Assessment:** I discovered how to pinpoint which customers and loan types present the highest risk

- **💡 Critical Thinking:** Beyond just running queries, I learned to ask "why" behind the numbers and think about what the data means for business decisions

<br> 
<br>


# Final Thoughts

**After spending time with this data, a few key insights emerged:**

- 📌 **Size Matters:** Large loans might bring in more money, but they also come with much higher risk and lower repayment rates

- 📌 **Customer Concentration:** A small group of customers accounts for a lot of the bank's lending, which could be risky if any of them run into trouble

- 📌 **Repayment Challenges:** The overall repayment rate is lower than you'd hope to see, suggesting there might be opportunities to improve lending criteria or collection processes

- 📌 **Consistent Patterns:** The bank's lending has been steady month to month, but so have the repayment challenges

- 📌 **Actionable Insights:** The analysis points to specific areas where the bank could focus - like monitoring large borrowers more closely, studying why small loans perform so well, and developing strategies to improve repayment rates

<br>
<br>

What surprised me most was how clearly the data told these stories once I knew how to ask the right questions. It really shows the power of using data to understand what's actually happening in a business, rather than just relying on assumptions or gut feelings.