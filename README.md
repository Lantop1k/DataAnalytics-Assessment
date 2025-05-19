# Olanrewaju Faboyin's Solution to the Data Analyst Assessment

## Project Overview

This repository contains solution to the Data Analyst Assessment. Each file contains a single SQL query that answers each question. 

---

## Questions and Explanations

### **Assessment Q1: High-Value Customers with Multiple Products**

* **Task**: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits..
* **Explanation**:

  * The query joins `savings_savingsaccount` and `plans_plan` to calculate the number of savings and investment plans each customer has, and it sums up the deposits across those plans.
  * The deposit amounts are converted from Kobo to Naira.
  * The results show customers who have both savings and investment accounts, ordered by total deposits in Naira.

  **Challenges**:

  * **Handling NULL or Missing Data**: Some customers may not have their full name available (missing first name or last name). The query handles this by using `COALESCE` to provide fallback options such as username or email.
  * **Summing Deposits**: Ensuring the deposits are summed correctly across different types of accounts (savings and investment), especially with the conversion from Kobo to Naira.

### **Assessment Q2: Transaction Frequency Analysis**

* **Task**: Calculate the average number of transactions per customer per month and categorize them: 
    "High Frequency - ≥10 transactions/month" 
	"Medium Frequency - 3-9 transactions/month" 
	"Low Frequency - ≤2 transactions/month".
	
* **Explanation**:

  * The query counts transactions per customer per month and calculates the average number of transactions each customer makes per month.
  * Based on the average transaction frequency, customers are categorized:

    * **High Frequency**: 10 or more transactions per month
    * **Medium Frequency**: Between 3 and 9 transactions per month
    * **Low Frequency**: 2 or fewer transactions per month

  **Challenges**:

  * **Handling Different Transaction Periods**: Transactions are aggregated by month, and the challenge is ensuring correct monthly categorization, even when a user might have inconsistent transaction activity across months.
  * **Edge Cases**: Dealing with customers who have no transactions or very few transactions over time (avoiding NULL values and divisions by zero).

### **Assessment Q3: Account Inactivity Alert**

* **Task**: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .
* **Explanation**:

  * The query identifies the most recent transaction date for each account.
  * If the account has no inflow transactions or if the last inflow was more than a year ago, it will be flagged as inactive.
  * This helps identify accounts that have not been actively funded or used for a long time.

  **Challenges**:

  * **Missing Transaction Records**: Some plans might have never had any transactions. This requires the use of a `LEFT JOIN` to handle missing transaction dates for plans that have no inflow.
  * **Date Calculation**: The challenge of correctly calculating the date difference between the current date and the last transaction date, ensuring proper filtering for inactivity.

### **Assessment Q4: Customer Lifetime Value (CLV) Estimation**

* **Task**:  For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate.
              - Account tenure (months since signup)
			  - Total transactions
			  -	Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
			  -	Order by estimated CLV from highest to lowest

* **Explanation**:

  * This query calculates the customer’s tenure (in months) and sums the total transactions across all accounts.
  * CLV is calculated using the formula:

    $$
    \text{CLV} = \left(\frac{\text{total transactions}}{\text{tenure in months}}\right) \times 12 \times 0.1\% \text{ of avg transaction value}
    $$
  * This formula assumes a 0.1% profit margin per transaction.

  **Challenges**:

  * **Division by Zero**: Handling cases where the tenure might be zero (e.g., customers who have just signed up) to avoid division by zero errors.
  * **Transaction Data**: Accurately summing the total transactions and determining the average transaction value, especially when some transactions might be low or very high in value.

---

## How to Run the Queries

1. **Load the Database:**
   First, ensure that the `adashi_staging` database is loaded onto your MySQL or MariaDB server. To do this, execute the `adashi_assessment.sql` script. This script contains all the necessary commands to set up the `adashi_staging` database with the relevant schema and data.

   * **Command to execute**:

     ```sql
     SOURCE adashi_assessment.sql;
     ```

2. **Use the Database:**
   After the database is loaded, switch to the `adashi_staging` database by executing the following SQL command:

   ```sql
   USE adashi_staging;
   ```

3. **Running the SQL Queries:**
   The SQL queries for each assessment (Q1 to Q4) are stored in separate `.sql` files. To run a query, execute the corresponding SQL file for each question.

   Example:

   ```sql
   SOURCE Assessment_Q1.sql;
   ```

---

## File Structure

The project contains the following files:

```
- README.md                # This file
- adashi_assessment.sql     # Script to load the database schema and data into 'adashi_staging'
- Assessment_Q1.sql         # Query for analyzing funded accounts summary (Savings and Investments)
- Assessment_Q2.sql         # Query for analyzing transaction frequency per customer
- Assessment_Q3.sql         # Query for inactivity alert (no inflow in the past 365 days)
- Assessment_Q4.sql         # Query for estimating Customer Lifetime Value (CLV)
```

Each SQL file corresponds to a specific assessment question:

* **Assessment\_Q1.sql**: Retrieves and analyzes the number of funded savings and investment accounts, including total deposits.
* **Assessment\_Q2.sql**: Categorizes customers based on their monthly transaction frequency.
* **Assessment\_Q3.sql**: Identifies accounts with no inflow transactions in the past year (365 days).
* **Assessment\_Q4.sql**: Estimates the Customer Lifetime Value (CLV) based on account tenure and transaction volume.

---

## Software Requirements

To run the queries, you can use any SQL client that supports MySQL. Below are some recommended software tools:

* **MySQL Workbench** 
* **phpMyAdmin** (Web-based MySQL interface)
* **Command Line Interface (CLI)** (Direct SQL execution via terminal)
