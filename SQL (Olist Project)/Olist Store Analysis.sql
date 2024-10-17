# Olist_Store_E-Commerce_Analysis.

# KPI'S :
# 1. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics.
# 2. Number of Orders with review score 5 and payment type as credit card.
# 3. Average number of days taken for order_delivered_customer_date for pet_shop.
# 4. Average price and payment values from customers of sao paulo city.
# 5. Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

# KPI-1 :
Use Olist_Store_Analysis;
Select * from olist_store_analysis.olist_orders_dataset;
Select * from olist_store_analysis.olist_order_payments_dataset;

SELECT kpi1.day_end,
	CONCAT(round(kpi1.total_payment / (SELECT SUM(payment_value) FROM olist_order_payments_dataset) * 100, 2)
,'%') AS percentage_payment_values
FROM
(SELECT ord.day_end, SUM(pmt.payment_value) AS total_payment
FROM olist_order_payments_dataset AS pmt
JOIN
(SELECT DISTINCT order_id,
CASE
WHEN weekday(order_purchase_timestamp) IN (5,6) THEN "Weekend"
ELSE "Weekday"
END AS Day_end
FROM olist_orders_dataset) AS ord 
ON ord.order_id = pmt.order_id
GROUP BY ord.day_end) AS kpi1;

# KPI-2 :
SELECT * FROM olist_store_analysis.olist_order_reviews_dataset;
SELECT * FROM olist_store_analysis.olist_order_payments_dataset;

SELECT
COUNT(pmt.order_id) AS Total_Orders
FROM
olist_order_payments_dataset pmt
INNER JOIN olist_order_reviews_dataset rev ON pmt.order_id = rev.order_id
WHERE
rev.review_score = 5
AND pmt.payment_type = 'credit_card';

# KPI-3 :
SELECT * FROM olist_store_analysis.olist_orders_dataset;
SELECT * FROM olist_store_analysis.olist_products_dataset;
SELECT * FROM olist_store_analysis.olist_order_items_dataset;

SELECT
prod.product_category_name,
round(AVG(datediff(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) as Avg_delivery_days
from olist_orders_dataset ord
join
(Select product_id, Order_id, product_category_name
from olist_products_dataset
join olist_order_items_dataset using(product_id)) as prod
on ord.order_id = prod.order_id
where prod.product_category_name = "Pet_Shop"
group by prod.product_category_name;

# KPI-4 :
SELECT * FROM olist_store_analysis.olist_order_items_dataset;
SELECT * FROM olist_store_analysis.olist_orders_dataset;
SELECT * FROM olist_store_analysis.olist_customers_dataset;
SELECT * FROM olist_store_analysis.olist_order_payments_dataset;

with orderitemsavg as (
	select round(avg(item.price)) as avg_order_item_price
	from olist_order_items_dataset item
	join olist_orders_dataset ord on item.order_id = ord.order_id
	join olist_customers_dataset cust on ord.customer_id = cust.customer_id
	where cust.customer_city = "Sao Paulo"
)
select
	(select avg_order_item_price from orderitemsavg) as avg_order_item_price,
	round(avg (pmt.payment_value)) as avg_payment_value
	from olist_order_payments_dataset pmt
	join olist_orders_dataset ord on pmt.order_id = ord.order_id
	join olist_customers_dataset cust on ord.customer_id = cust.customer_id
where
	cust.customer_city = "Sao Paulo";
    
# KPI-5 :
Select * from olist_store_analysis.olist_order_reviews_dataset;
Select * from olist_store_analysis.olist_orders_dataset;

Select
rew.review_score,
round(avg(datediff(ord.order_delivered_customer_date, order_purchase_timestamp)), 0) as "Avg Shipping Days"
from olist_orders_dataset as ord
join olist_order_reviews_dataset as rew on rew.order_id = ord.order_id
group by rew.review_score
order by rew.review_score;
