-- Inactivity alert for savings and investment plans with no inflow in the past 365 days

WITH latest_transactions AS (
    -- Step 1: Find the most recent inflow transaction for each plan (based on confirmed_amount > 0)
    SELECT 
        s.plan_id,  -- Plan ID
        MAX(s.transaction_date) AS last_transaction_date  -- Find the most recent transaction date for each plan
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0  -- Only consider inflow transactions (positive confirmed amounts)
    GROUP BY s.plan_id  -- Group by plan_id to get one row per plan (latest inflow transaction)
)

-- Step 2: Combine the plans with the latest transaction data
SELECT 
    p.id AS plan_id,  -- Plan ID from plans_plan table
    p.owner_id,  -- Owner ID of the plan
    -- Step 3: Determine the type of the plan based on flags (Savings or Investment)
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'  -- If it's a regular savings plan
        WHEN p.is_a_fund = 1 THEN 'Investment'  -- If it's an investment plan
        ELSE 'Other'  -- For any other plan types (if applicable)
    END AS type,

    lt.last_transaction_date,  -- The date of the last inflow transaction
    -- Step 4: Calculate the number of days since the last inflow transaction
    DATEDIFF(CURRENT_DATE, lt.last_transaction_date) AS inactivity_days  -- Inactivity days since last inflow transaction

FROM 
    plans_plan p  -- From the plans_plan table
LEFT JOIN 
    latest_transactions lt ON p.id = lt.plan_id  -- Join with the latest_transactions CTE to get the last inflow date for each plan

-- Step 5: Filter the results
WHERE 
    p.is_deleted = 0  -- Exclude deleted plans (only active plans should be considered)
    AND p.is_archived = 0  -- Exclude archived plans
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)  -- Only consider savings or investment plans (exclude other types)
    AND (
        lt.last_transaction_date IS NULL  -- Plans that have never had an inflow (no transaction date recorded)
        OR DATEDIFF(CURRENT_DATE, lt.last_transaction_date) > 365  -- Plans where the last transaction was over a year ago
    )

-- Step 6: Sort the results by the most inactive plans first (highest inactivity days)
ORDER BY inactivity_days DESC;  -- Orders by inactivity days in descending order (most inactive first)
