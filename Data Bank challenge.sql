1. A. Customer Nodes Exploration

-- 1.1 How many unique nodes are there on the Data Bank system?
SELECT COUNT( DISTINCT node_id) as count_node
FROM customer_nodes;
  
-- 1.2. What is the number of nodes per region?
SELECT 
        r.region_name,  
        COUNT(cn.node_id) AS num_node
FROM regions AS r
RIGHT JOIN customer_nodes AS cn ON r.region_id=cn.region_id
GROUP BY r.region_name 
ORDER BY num_node;
          
-- 1.3. How many customers are allocated to each region?
SELECT 
        region_name,
        COUNT(DISTINCT customer_id) AS num_customer
FROM customer_nodes
LEFT JOIN regions ON customer_nodes.region_id=regions.region_id
GROUP BY region_name 
ORDER BY num_customer;
 
-- 1.4.How many days on average are customers reallocated to a different node?
SELECT AVG(DATEDIFF(DAY,start_date,end_date)) AS avg_date_rellocate
FROM customer_nodes
WHERE end_date != '9999-12-31';
 
-	I exclude end_date='9999-12-31’ cause it’s abnormal date, maybe this was a typo when input data
5.	What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

-- 1.5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH cte AS(
        SELECT 
                cn.region_id,
                r.region_name,   
                DATEDIFF(DAY,start_date,end_date) AS date_rellocate
        FROM customer_nodes AS cn 
        LEFT JOIN regions AS r ON cn.region_id=r.region_id
        WHERE end_date != '9999-12-31'
)
SELECT  DISTINCT
            region_id,
            region_name,
            PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY date_rellocate) OVER(PARTITION BY region_name) AS medium,
            PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY date_rellocate) OVER(PARTITION BY region_name) AS [80%],
            PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY date_rellocate) OVER(PARTITION BY region_name) AS [95%]
FROM cte;
 
2. B. Customer Transactions
2.1 What is the unique count and total amount for each transaction type?
-- 2.1 What is the unique count and total amount for each transaction type?
SELECT 
        txn_type,
        COUNT(*) AS num_transaction,
        SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;
 

2.2 What is the average total historical deposit counts and amounts for all customers?
2.3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
-- 2.3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH customer_transaction_month_cte AS (
        SELECT 
                MONTH(txn_date) AS month_transaction,
                DATENAME(MONTH, txn_date) AS month_name,
                customer_id,
                SUM(IIF(txn_type='deposit',1,0)) AS deposit_count,
                SUM(IIF(txn_type='purchase',1,0)) AS purchase_count,
                SUM(IIF(txn_type='withdrawal',1,0)) AS withdrawal_count,
                SUM(txn_amount) AS total_amount
        FROM customer_transactions
        GROUP BY                
                 MONTH(txn_date),
                 DATENAME(MONTH, txn_date),
                 customer_id
)
SELECT 
        month_transaction,
        month_name,
        COUNT( customer_id) AS count_customer
        
FROM customer_transaction_month_cte
WHERE 
        deposit_count > 1 
        AND (purchase_count > 0 OR withdrawal_count > 0)
GROUP BY 
        month_transaction,
        month_name
ORDER BY month_transaction;

 
2.4 What is the closing balance for each customer at the end of the month?
-- 2.4 What is the closing balance for each customer at the end of the month?
WITH customer_closing_balance_cte AS (
        SELECT 
                MONTH(txn_date) AS month_transaction,
                DATENAME(MONTH, txn_date) AS month_name,
                customer_id,      
                SUM(
                        CASE WHEN txn_type='deposit' THEN txn_amount 
                        ELSE -1*txn_amount 
                        END
                ) AS end_month_balance
        FROM customer_transactions
        GROUP BY 
                customer_id,
                MONTH(txn_date),
                DATENAME(MONTH, txn_date)
)
SELECT
        month_name,
        customer_id,
        SUM(end_month_balance) OVER(PARTITION BY customer_id ORDER BY month_transaction) AS closing_balance
FROM customer_closing_balance_cte;

 
2.5 What is the percentage of customers who increase their closing balance by more than 5%?

-- 2.5 What is the percentage of customers who increase their closing balance by more than 5%?

--CTE 1: Monthly transactions of each customer
WITH monthly_balance AS(
        SELECT 
                EOMONTH(txn_date) AS month_end_date,
                DATENAME(MONTH, txn_date) AS month_name,
                customer_id,      
                SUM(
                        CASE WHEN txn_type='deposit' THEN txn_amount 
                        ELSE -1*txn_amount 
                        END
                ) AS end_month_balance
        FROM customer_transactions
        GROUP BY 
                EOMONTH(txn_date),
                DATENAME(MONTH, txn_date),
                customer_id
)
-- CTE 2: Closing balance of each customer each month
, closing_balance_cte AS(
        SELECT
                month_name,
                month_end_date,
                customer_id,
                SUM(end_month_balance) OVER(PARTITION BY customer_id ORDER BY month_end_date ASC) AS closing_balance
        FROM monthly_balance
)
-- CTE 3: Calculate the increase in percentage of each customer's balance
,pct_increase AS (
SELECT 
        *,
        LAG(closing_balance, 1) OVER(PARTITION BY customer_id ORDER BY month_end_date) AS prev_closing_balance,
        100*(closing_balance-LAG(closing_balance, 1) OVER(PARTITION BY customer_id ORDER BY month_end_date))
                /NULLIF( LAG(closing_balance, 1) OVER(PARTITION BY customer_id ORDER BY month_end_date),0) AS pct_inc
              
FROM closing_balance_cte
)
-- Calculate the percentage of customers who have increased their balance more than 5%
SELECT 
        CAST(COUNT(distinct customer_id)*1.0/(SELECT COUNT(DISTINCT customer_id)*1.0 FROM customer_transactions)*100 AS DECIMAL(10,2)) AS pct_customer
FROM pct_increase 
WHERE pct_inc >5;


 
•	running customer balance column that includes the impact each transaction
Running balance is the sum of present debit and credit amounts after the previous day's balance have been deducted. Running balance is used to manage individual accounts in a business.
WITH trans_amount AS(
        SELECT 
                customer_id,
                txn_date,
                txn_type,
                SUM(
                CASE WHEN txn_type='deposit' THEN txn_amount 
                ELSE (-1*txn_amount)
                END
                )  AS remain_balance
        FROM customer_transactions
        GROUP by customer_id,
                txn_date,
                txn_type
)
SELECT  customer_id, 
        remain_balance,
        SUM(remain_balance) OVER(PARTITION by customer_id order by txn_date) as running_balance
FROM trans_amount;

 

•	customer balance at the end of each month

-- customer balance at the end of each month
SELECT 
    customer_id,
    -- MONTH(txn_date) AS month_trans,
    DATENAME(MONTH, txn_date) AS month_name,
    SUM(X
        CASE WHEN txn_type='deposit' THEN txn_amount 
        ELSE (-1*txn_amount)
        END
        )  AS remain_balance
FROM customer_transactions
GROUP BY  
    customer_id,
    MONTH(txn_date),
    DATENAME(MONTH, txn_date);
 
-- minimum, average and maximum values of the running balance for each customer
WITH running_balance AS(
    SELECT
        customer_id, 
        txn_date,
        txn_type, 
        SUM(
            CASE WHEN txn_type='deposit' THEN txn_amount
            ELSE (-1*txn_amount)
            END
        ) OVER(PARTITION by customer_id order by txn_date) as running_balance
    FROM customer_transactions  
)
SELECT  
    customer_id,
    MIN(running_balance) AS min_running_balance,
    AVG(running_balance) AS avg_running_balance,
    MAX(running_balance) AS max_running_balance
FROM running_balance
GROUP BY customer_id
ORDER BY customer_id;
 
-- Option 1: data is allocated based off the amount of money at the end of the previous month     
WITH trans_amount_cte AS(
    SELECT 
        customer_id,
        txn_date,
        DATENAME(MONTH,txn_date) AS txn_month,
         SUM(
            CASE WHEN txn_type='deposit' THEN txn_amount
            ELSE (-1*txn_amount)
            END) AS trans_m
    FROM customer_transactions
    grOUp by customer_id,txn_date
    )
,running_balance_cte AS(
    SELECT 
        *,
        SUM(trans_m) OVER(PARTITION BY customer_id,txn_month ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_trans
    FROM trans_amount_cte
)
, end_month_amount_cte AS(
    SELECT 
        customer_id,
        txn_date, 
        txn_month,
        SUM(month_trans) AS end_month_amount
    FROM running_balance_cte
    GROUP BY customer_id,txn_date ,txn_month
    -- ORDER BY customer_id
)
, data_needed_month AS(
    SELECT 
        customer_id ,
        txn_month, 
        MAX(end_month_amount) AS max_data_needed
    FROM end_month_amount_cte 
    GROUP BY  customer_id, txn_month 
) 
SELECT txn_month, 
    SUM(max_data_needed) as FGG
FROM data_needed_month
GROUP BY txn_month;

 

  -- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
WITH trans_amount_cte AS(
    SELECT 
        customer_id,
        txn_date,
        MONTH(txn_date) AS txn_month,
         SUM(
            CASE WHEN txn_type='deposit' THEN txn_amount
            ELSE (-1*txn_amount)
            END) AS trans_m
    FROM customer_transactions
    GROUP by customer_id,txn_date
    )
,running_balance_cte AS(
    SELECT 
        *,
        SUM(trans_m) OVER(PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_trans
    FROM trans_amount_cte
)
, end_month_amount_cte AS(
    SELECT 
        customer_id,
        -- txn_date, 
        txn_month,
        AVG(month_trans) over(PARTITION BY customer_id,txn_month  Order by customer_id) AS end_month_amount
    FROM running_balance_cte
)
-- , 
SELECT
    txn_month,
    SUM(end_month_amount) AS data_required
FROM end_month_amount_cte
GROUP BY txn_month
ORDER BY txn_month;
 
-- Option 3: data is updated real-time   

WITH trans_amount_cte AS(
    SELECT 
        customer_id,
        txn_date,
        MONTH(txn_date) AS txn_month,
         SUM(
            CASE WHEN txn_type='deposit' THEN txn_amount
            ELSE (-1*txn_amount)
            END) AS trans_m
    FROM customer_transactions
    GROUP by customer_id,txn_date
    )
,running_balance_cte AS(
    SELECT 
        *,
        SUM(trans_m) OVER(PARTITION BY customer_id ORDER BY txn_date) AS month_trans
    FROM trans_amount_cte
)
SELECT  
    txn_month, 
    SUM(month_trans) AS data_required
FROM running_balance_cte
GROUP BY txn_month
ORDER BY txn_month;
 


