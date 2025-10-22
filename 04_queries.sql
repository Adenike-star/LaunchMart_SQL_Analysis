-- 1. Total number of customers who joined in 2023 --

SELECT COUNT(*) AS count_2023_customers
FROM customers
WHERE join_date BETWEEN '2023-01-01' and '2023-12-31';

-- 2. Total Revenue Per customer in descending order. --
SELECT c.customer_id, full_name, SUM(total_amount) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC;


-- 3. TOP 5 Customers By revenue with their Rank --
WITH customer_total_revenue AS (SELECT c.customer_id, full_name, SUM(total_amount) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name)

SELECT customer_id,
		full_name, 
		total_revenue,
		DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_total_revenue
LIMIT 5;


-- 4. Table with year, month, monthly_revenue for all months in 2023 ordered chronologically. -- 
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  EXTRACT(MONTH FROM order_date) AS month,
  SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY year, month
ORDER BY year, month;


-- 5. Customers with no orders in the last 60 days before 2023-12-31
WITH last_orders AS (
    SELECT 
        c.customer_id,
        c.full_name,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.full_name)

SELECT 
    customer_id,
    full_name,
    last_order_date
FROM last_orders
WHERE 
    last_order_date < DATE '2023-11-01'
    OR last_order_date IS NULL
ORDER BY last_order_date;


-- 6. Average order value (AOV) for each customer: return customer_id, full_name, aov (average total_amount of their orders).
SELECT
        c.customer_id,
        c.full_name,
        ROUND(AVG(total_amount), 2) AS AOV
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, full_name
ORDER BY AOV DESC;


-- 7. Calculate total revenue and rank customers by spending
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.full_name,
        SUM(o.total_amount) AS total_revenue
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.full_name)

SELECT
    customer_id,
    full_name,
    total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS spend_rank
FROM customer_revenue
ORDER BY spend_rank;


-- 8. Customers with more than one order
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS order_count,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;


-- 9. Total loyalty points per customer (including Customers  with 0 points)
SELECT
    c.customer_id,
    c.full_name,
    COALESCE(SUM(lp.points_earned), 0) AS total_points
FROM customers c
LEFT JOIN loyalty_points lp
    ON c.customer_id = lp.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_points DESC;

-- 10. Loyalty tiers based on total points:
WITH customer_points AS (
    SELECT
        c.customer_id,
        c.full_name,
        COALESCE(SUM(lp.points_earned), 0) AS total_points
    FROM customers c
    LEFT JOIN loyalty_points lp
        ON c.customer_id = lp.customer_id
    GROUP BY c.customer_id, c.full_name)

SELECT
    CASE
        WHEN total_points < 100 THEN 'Bronze'
        WHEN total_points BETWEEN 100 AND 499 THEN 'Silver'
        ELSE 'Gold'
    END AS tier,
    COUNT(*) AS tier_count,
    SUM(total_points) AS tier_total_points
FROM customer_points
GROUP BY tier
ORDER BY tier_total_points DESC;


-- 11. Customers who spent more than ₦50,000 but have less than 200 loyalty points
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.full_name,
        COALESCE(SUM(o.total_amount), 0) AS total_spend
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.full_name),
customer_points AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(lp.points_earned), 0) AS total_points
    FROM customers c
    LEFT JOIN loyalty_points lp
        ON c.customer_id = lp.customer_id
    GROUP BY c.customer_id)
SELECT
    s.customer_id,
    s.full_name,
    s.total_spend,
    p.total_points
FROM customer_spend s
JOIN customer_points p
    ON s.customer_id = p.customer_id
WHERE s.total_spend > 50000
  AND p.total_points < 200
ORDER BY s.total_spend DESC;



-- 12. Flaging customers as churn risk if not active for 90 days (relative to 2023-12-31) and in Bronze tier
WITH last_orders AS (
    SELECT
        c.customer_id,
        c.full_name,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.full_name),
loyalty_points AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(lp.points_earned), 0) AS total_points
    FROM customers c
    LEFT JOIN loyalty_points lp
        ON c.customer_id = lp.customer_id
    GROUP BY c.customer_id),
loyalty_tiers AS (
    SELECT
        lp.customer_id,
        lp.total_points,
        CASE
            WHEN lp.total_points < 100 THEN 'Bronze'
            WHEN lp.total_points BETWEEN 100 AND 499 THEN 'Silver'
            ELSE 'Gold'
        END AS tier
    FROM loyalty_points lp)
SELECT
    lo.customer_id,
    lo.full_name,
    lo.last_order_date,
    lt.total_points,
    'FLAGGED' AS churn_risk
FROM last_orders lo
JOIN loyalty_tiers lt
    ON lo.customer_id = lt.customer_id
WHERE lt.tier = 'Bronze'
  AND (
        lo.last_order_date < DATE '2023-12-31' - INTERVAL '90 days'
        OR lo.last_order_date IS NULL)
ORDER BY lo.last_order_date NULLS FIRST;
