---------------------------------- Ecommerce Sales & Customer Analytics-----------------------------------
----------------------------**********************************************---------------------
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM payments LIMIT 5;
SELECT * FROM reviews LIMIT 5;

----------------------------------------------------------------------------------------------
----------------- 1. Business Questions (queries- sql analysis) ------------------------------
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
-------------------------------- 2. Advanced SQL Queries -----------------------------------
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
