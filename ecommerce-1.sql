---------------------------------- Ecommerce Fraud Analysis -----------------------------------
----------------------------**********************************************---------------------
---------------------------------- 1. Create Realtionships ------------------------------------
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM payments LIMIT 5;
SELECT * FROM reviews LIMIT 5;

SELECT *
FROM customers
LIMIT 5;

-- Check table structure (checks column and data type)
SELECT
column_name,
data_type
FROM information_schema.columns
WHERE table_name='customers';


SELECT
column_name,
data_type
FROM information_schema.columns
WHERE table_name='orders';

SELECT
column_name,
data_type
FROM information_schema.columns
WHERE table_name='payments';

SELECT
column_name,
data_type
FROM information_schema.columns
WHERE table_name='reviews';

-- Verify all tables exist.
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM reviews;

-- check if PK is clean (customer_id & order_id)
SELECT order_id, 
COUNT(*) as duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--Check for missing(null) values if 0 then ok (for customers & orders)
SELECT COUNT(*) as missing_values
FROM orders
WHERE order_id IS NULL 
   OR order_id = '';
   
-- 1) Check if FK: orders.customer_id → customers.customer_id is valid
-- Find orders whose customer does not exist (result- 0)
SELECT COUNT(*) AS invalid_customers
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check matching percentage(result- 100%)
SELECT
COUNT(*) AS total_orders,
COUNT(c.customer_id) AS matched_customers,
ROUND(
100.0 * COUNT(c.customer_id) / COUNT(*),
2
) AS match_percent
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id;

--2) Check if FK: payments.order_id → orders.order_id is valid
-- Find payments with missing orders
SELECT COUNT(*) AS invalid_orders
FROM payments p
LEFT JOIN orders o
ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS invalid_customers -- for orders
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--Check matching percentage
SELECT
COUNT(*) AS total_payments,
COUNT(o.order_id) AS matched_orders,
ROUND(
100.0 * COUNT(o.order_id) / COUNT(*),
2
) AS match_percent
FROM payments p
LEFT JOIN orders o
ON p.order_id = o.order_id;

-- 3) Check Null Values(customers)
SELECT
COUNT(*) total_rows,
COUNT(customer_id) customer_id,
COUNT(customer_city) customer_city,
COUNT(customer_state) customer_state
FROM customers;

-- Check Null Values(orders)
SELECT
COUNT(*) total_rows,
COUNT(order_id) order_id,
COUNT(customer_id) customer_id,
COUNT(order_status) order_status,
COUNT(order_purchase_timestamp) purchase_time
FROM orders;

-- Check Null Values(payments)
SELECT
COUNT(*) total_rows,
COUNT(order_id) order_id,
COUNT(payment_type) payment_type,
COUNT(payment_value) payment_value
FROM payments;

-- Check Null Values(reviews)
SELECT
COUNT(*) total_rows,
COUNT(order_id) order_id,
COUNT(review_score) review_score
FROM reviews;

----------------------------------------------------------------------------------------------
----------------- 2. Business Questions (queries- sql analysis) ------------------------------
-- 1) Total Revenue
select 
round(sum(payment_value)::numeric,2) as total_revenue
from payments;

-- 2) Total orders
select count(*) as total_orders
from orders;

--3) Revenue by payment type
select payment_type,
round(sum(payment_value)::numeric,2) revenue
from payments
group by payment_type
order by revenue desc;

-- 4) Monthly revenue trend
select purchase_year, purchase_month,
round(sum(payment_value)::numeric,2) as revenue
from ecommerce_master 
group by purchase_year, purchase_month
order by purchase_year, purchase_month asc;

--5) Delayed orders
select 
round(100.0 * sum(is_delayed) / count(*),2) as delayed_percentage
from orders;

--6) Average Delivery Time
select
ROUND(AVG(delivery_days)::numeric,2) as avg_delivery_days
FROM orders;

--7) Starts with Highest Revenue
SELECT
customer_state,
ROUND(SUM(payment_value)::numeric,2) as revenue
FROM ecommerce_master
GROUP BY customer_state
ORDER BY revenue DESC;

--8) Cities with Most Orders
SELECT customer_city,
COUNT(order_id) total_orders
FROM ecommerce_master
GROUP BY customer_city
ORDER BY total_orders DESC
LIMIT 10;

--9) Review Score Distribution
SELECT review_score,
COUNT(*) reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score;

-- 10) Revenue vs Review Score
SELECT review_score,
ROUND(SUM(payment_value)::numeric,2) as revenue
FROM ecommerce_master
GROUP BY review_score
ORDER BY review_score;

----------------------------------------------------------------------------------------------
-------------------------------- 3. Advanced SQL Queries -----------------------------------
-- 1) Top 10 Customers by Spending
SELECT
customer_id,
ROUND(SUM(payment_value)::numeric,2) total_spent
FROM ecommerce_master
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

--2) Customer Segmentation
SELECT customer_id,
CASE
WHEN SUM(payment_value) > 1000 THEN 'VIP'
WHEN SUM(payment_value) > 500 THEN 'Regular'
ELSE 'Low Value' END customer_segment
FROM ecommerce_master
GROUP BY customer_id;

--3) Monthly Growth Rate
WITH monthly_sales AS (
SELECT purchase_year, purchase_month,
SUM(payment_value) as revenue
FROM ecommerce_master
GROUP BY purchase_year, purchase_month)
SELECT *,
LAG(revenue) OVER() previous_month,
ROUND(((revenue - LAG(revenue) OVER()) / LAG(revenue) OVER()*100)::numeric,2)
AS growth_percent
FROM monthly_sales;
