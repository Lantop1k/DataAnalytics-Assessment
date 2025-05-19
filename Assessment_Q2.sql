-- Analyze average monthly transaction frequency per customer and categorize them

WITH 

-- Step 1: Count transactions per customer per month
monthly_transactions AS (
    SELECT 
        s.owner_id,
        YEAR(s.created_on) AS txn_year,
        MONTH(s.created_on) AS txn_month,
        COUNT(*) AS transaction_count
    FROM savings_savingsaccount s
    WHERE s.created_on IS NOT NULL
    GROUP BY s.owner_id, YEAR(s.created_on), MONTH(s.created_on)
),

-- Step 2: Calculate each customer's average monthly transaction count
avg_transactions AS (
    SELECT 
        owner_id,
        ROUND(AVG(transaction_count), 2) AS avg_transactions_per_month
    FROM monthly_transactions
    GROUP BY owner_id
),

-- Step 3: Categorize each customer based on their average monthly transaction frequency
categorized_customers AS (
    SELECT 
        owner_id,
        avg_transactions_per_month,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM avg_transactions
)

-- Step 4: Aggregate results by category for final output
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
