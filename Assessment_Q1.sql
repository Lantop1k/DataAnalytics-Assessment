WITH 
-- Aggregate funded savings accounts per user
savings_accounts AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,
        -- Sum confirmed deposits and convert from kobo to naira
        COALESCE(SUM(s.confirmed_amount), 0) / 100.0 AS savings_total  
    FROM 
        plans_plan p
    JOIN 
        savings_savingsaccount s 
        ON s.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1  -- Identify regular savings plans
        AND s.confirmed_amount > 0  -- Only include funded accounts
    GROUP BY 
        p.owner_id
),

-- Aggregate funded investment accounts per user
investment_accounts AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count,
        -- Sum confirmed deposits and convert from kobo to naira
        COALESCE(SUM(s.confirmed_amount), 0) / 100.0 AS investment_total  
    FROM 
        plans_plan p
    JOIN 
        savings_savingsaccount s 
        ON s.plan_id = p.id
    WHERE 
        p.is_a_fund = 1  -- Identify investment plans
        AND s.confirmed_amount > 0  -- Only include funded accounts
    GROUP BY 
        p.owner_id
)

-- Final result combining savings and investment summaries with user info
SELECT 
    u.id AS owner_id,

    -- Build user full name from first and last name, fallback to username or email if missing
    TRIM(
        COALESCE(
            NULLIF(CONCAT(u.first_name, ' ', u.last_name), ' '),
            u.username,
            u.email
        )
    ) AS name,

    s.savings_count,
    i.investment_count,

    -- Total deposits = savings + investments, in naira, rounded to 2 decimal places
    ROUND(s.savings_total + i.investment_total, 2) AS total_deposits

FROM 
    users_customuser u
JOIN 
    savings_accounts s ON u.id = s.owner_id
JOIN 
    investment_accounts i ON u.id = i.owner_id

-- Only include users who have at least one funded savings and investment plan
WHERE 
    s.savings_count >= 1
    AND i.investment_count >= 1

ORDER BY 
    total_deposits DESC;  -- Prioritize high-value customers : sorted by total deposits
