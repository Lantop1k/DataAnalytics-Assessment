-- Estimate Customer Lifetime Value (CLV) based on account tenure and average transaction value

WITH 

-- Step 1: Calculate the account tenure in months for each customer
customer_tenure AS (
    SELECT 
        u.id AS customer_id,  -- Unique identifier for the customer
        CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the customer
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months  -- Calculate the number of months since account creation
    FROM 
        users_customuser u  -- Get data from the users table
),

-- Step 2: Calculate the total number of transactions and the average transaction value for each customer
customer_transactions AS (
    SELECT 
        s.owner_id,  -- Reference to the customer ID
        COUNT(*) AS total_transactions,  -- Total number of successful transactions
        AVG(s.confirmed_amount / 100.0) AS avg_transaction_value  -- Average transaction value, converted from kobo to Naira
    FROM 
        savings_savingsaccount s  -- Get data from the savings account table
    WHERE 
        s.confirmed_amount > 0  -- Filter for successful transactions (inflow transactions)
    GROUP BY 
        s.owner_id  -- Group by customer ID to get totals per customer
)

-- Step 3: Final CLV calculation based on tenure and transaction details
SELECT 
    ct.customer_id,  -- Customer ID
    ct.name,  -- Customer full name
    ct.tenure_months,  -- Account tenure in months
    tr.total_transactions,  -- Total number of transactions made by the customer

    -- Step 4: CLV = (total transactions / tenure in months) * 12 (annualized) * 0.1% of avg transaction value
    ROUND(
        (tr.total_transactions / NULLIF(ct.tenure_months, 0)) * 12 *  -- Avoid division by zero (NULLIF checks if tenure is 0)
        (tr.avg_transaction_value * 0.001),  -- 0.1% profit margin assumed per transaction
        2  -- Round to 2 decimal places for clarity
    ) AS estimated_clv  -- Calculated Customer Lifetime Value (CLV)

FROM 
    customer_tenure ct  -- Join customer tenure data
JOIN 
    customer_transactions tr  -- Join customer transaction data
    ON ct.customer_id = tr.owner_id  -- Match the customer ID

-- Step 5: Filter out customers with zero tenure to avoid division errors and ensure meaningful CLV calculation
WHERE 
    ct.tenure_months > 0  -- Ensure the customer has been active for at least one month

-- Step 6: Order by the estimated CLV from highest to lowest to prioritize high-value customers
ORDER BY 
    estimated_clv DESC;
