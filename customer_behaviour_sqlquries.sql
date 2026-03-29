--q1 what is the total revenue genarated by males vs females customer
select gender,SUM(purchase_amount) as revenue
from customer
group by gender
--q2 which customer used a discount but still spent more than average purchase amount
select customer_id,purchase_amount
from customer
where discount_applied='Yes' and purchase_amount >= (select avg(purchase_amount) from customer)
--q3 which are the top 5 products with the heighest average review rating
select  item_purchased,AVG(review_rating) as "Average product rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;
--q4 compare the average purchase amount between standard and express shipping
select shipping_type,ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

--q5 do subscribed customers spend more? compare average spend and total revenue between subscribed and non subscribed customers
select count(customer_id),AVG(purchase_amount),subscription_status,sum(purchase_amount) as total_revenue
from customer
group by subscription_status;

--q6 which 5 products have the heighest percentage of purchases with discounts applied
SELECT item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

--q7 segment customer into new,returning, and loyal based on their total number of previous purchases, and show the count of each segment.
WITH customer_type AS (
    SELECT customer_id, previous_purchases,
    CASE
        WHEN previous_purchases = 1 THEN 'NEW'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment
    FROM customer
)
SELECT customer_segment,
COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;

--q8 what are the top 3 most purche=ased products within each category?
WITH item_counts AS (
    SELECT 
        category, 
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)

SELECT 
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3;

--q9 are customers who are repeat buyers (more than 5 previous purchases)also likely to subscribe?
 select subscription_status, count(customer_id) as repeat_buyers
 from customer
 where previous_purchases >5
 group by subscription_status
 --q10 what is the revenue contribution of each age group
 select age_group,sum(purchase_amount) as revenue
 from customer
 group by age_group
 order by revenue
