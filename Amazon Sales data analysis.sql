create database amazondb;
use amazondb;
select * from customers;
select * from order_items;
select * from orders;
select * from payments;
select * from products;
select * from reviews;
-- 1.Find active customers who signed up during 2025 and belong to the Loyal or Regular customer segment.

select customer_id, first_name, last_name, signup_date, customer_segment
from customers
where is_active ='yes'
	  and signup_date>= '2025-01-01'
      and signup_date<='2025-12-31'
	  and customer_segment in ('loyal','regular')
order by signup_date asc;
-- 2.Find active products with fewer than 50 units in stock and a unit price above ₹5,000. Sort by stock quantity from lowest to highest.
select * from products;

select product_id, product_name, stock_quantity, unit_price
from products
where product_status= 'active'
      	  and stock_quantity>50
             and unit_price> 5000
order by stock_quantity asc;

-- 3.For each sales channel, calculate the total number of orders, delivered orders, cancelled orders, and delivery rate as a percentage of all orders in that channel.

select * from orders;

select sales_channel, 
       count(order_id) as total_orders, 
       sum(case when order_status ='delivered' then 1 else 0 end) as delivered_orders,
       sum(case when order_status='cancelled' then 1 else 0 end) as cancelled_orders,
       round(sum(case when order_status ='delivered' then 1 else 0 end)/count(order_id),2)*100 as delivery_rate
from orders
group by sales_channel
order by delivery_rate desc;

-- 4.Product Review Analysis 
-- Business scenario: The e-commerce team wants to understand customer satisfaction across product categories before deciding which categories need improvement.
-- Using the products and reviews tables, write a SQL query to calculate the following for each product category:
-- 1. Total number of reviews.
-- 2. Average product rating, rounded to 2 decimal places.
-- 3. Number of positive reviews, where the rating is 4 or 5.
-- 4. Number of negative reviews, where the rating is 1 or 2.
-- 5. Percentage of positive reviews out of all reviews in that category.

select * from products;
select * from reviews;
select distinct p.category,count(r.review_id) as total_review
from reviews r
join products p on p.product_id=r.product_id
group by p.category;

select avg(rating) as avg_product_rating
from reviews;

select p.category, count(*) as total_ratings, sum(case when rating in (4,5) then 1 else 0 end) as positive_reviews 
from reviews r
join products p on p.product_id=r.product_id
group by p.category
order by positive_reviews desc;

select p.category, count(review_id) as total_rating, sum(case when rating in (1,2) then 1 else 0 end) as negetive_review
from reviews r
join products p on p.product_id=r.product_id
group by p.category
order by negetive_review desc;

select p.category, count(*) as total_review, 
	   round(sum(case when rating in (4,5) then 1 else 0 end) /nullif(count(review_id),0)*100,2) as review_rate_percent
from reviews r
join products p on p.product_id=r.product_id
group by p.category
order by review_rate_percent;


select p.category,
	   count(*) as total_count,
        avg(rating) as avg_product_rating,
       count(r.review_id) as total_rating, sum(case when r.rating in (1,2) then 1 else 0 end) as negetive_review,
       count(review_id) as total_rating, sum(case when rating in (1,2) then 1 else 0 end) as negetive_review,
       round(sum(case when rating in (4,5) then 1 else 0 end) /nullif(count(review_id),0)*100,2) as review_rate_percent
from reviews r
join products p on p.product_id=r.product_id
group by p.category
HAVING COUNT(r.review_id) >= 10
order by avg_product_rating;

-- 5. Calculate monthly revenue for successfully paid orders using payments.
select * from payments;

select date_format(payment_date, "%Y-%m") ,
	  sum(amount) as total_revenue
from payments
where payment_status= "successful"
group by date_format(payment_date, "%Y-%m")
order by date_format(payment_date, "%Y-%m") desc ;

-- 6.Find the top 10 customers by total successful payment amount. Show each customer's name, state, total amount spent, and number of successful payments.

select * from customers;
select * from orders;
select * from payments;

select c.customer_id, 
	   c.first_name, 
       c.last_name, 
       c.state, 
       sum(p.amount) as total_amount,
       count(p.payment_id) as total_successful_payment
from customers c
join orders o on o.customer_id= o.customer_id
join payments p on p.order_id=o.order_id
where p.payment_status= "successful"
group by c.customer_id, 
	   c.first_name, 
       c.last_name,
       c.state
order by total_amount desc
limit 10;

-- 7. write a SQL query to calculate monthly revenue and compare it with the previous month.
select * from payments;

with monnthly_revenue as (select date_format(payment_date, "%Y-%M") as monthly, 
								 sum(amount) as this_month_revenue
						  from payments
                          group by date_format(payment_date, "%Y-%M") 
                          ),
revenue_comparision as ( select monthly,
                                this_month_revenue,
                                lag(this_month_revenue) over(order by monthly) as previous_month_revenue
						from monnthly_revenue)
select monthly,
	   this_month_revenue,
       previous_month_revenue
from revenue_comparision
order by monthly;

-- 8.Top 3 Customers in Each State (Intermediate–Advanced)
-- Business scenario: The sales team wants to identify the highest-value customers in each state to plan regional marketing campaigns and customer-retention strategies.

select * from customers;
select * from orders;
select * from payments;


with product_revenue as (select c.customer_id,
								c.first_name,
                                c.last_name,
                                c.state,
                                sum(p.amount) as total_spent
						from customers c
                        join orders o on o.customer_id=c.customer_id
                        join payments p on p.order_id= o.order_id
                        group by c.customer_id,
								c.first_name,
                                c.last_name,
                                c.state
						),
product_rank as (select customer_id,
						first_name, 
                        last_name,
                        state,
                        dense_rank() over(partition by state order by total_spent) as rnk
				from product_revenue
                )
select customer_id,
       first_name,
	   last_name,
       state,
       rnk
from product_rank
where rnk<=3;

-- The e-commerce finance team wants to identify which products generate the highest profit after accounting for product costs and discounts.

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.line_total) AS total_revenue,
        SUM(p.cost_price * oi.quantity) AS total_cost
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
    HAVING SUM(oi.quantity) >= 10
),
product_profitability AS (
    SELECT
        product_id,
        product_name,
        category,
        total_units_sold,
        total_revenue,
        total_cost,
        total_revenue - total_cost AS total_profit,
        ROUND(
            100.0 * (total_revenue - total_cost)
            / NULLIF(total_revenue, 0),
            2
        ) AS profit_margin_pct
    FROM product_sales
)
SELECT
    product_id,
    product_name,
    category,
    total_units_sold,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_cost, 2) AS total_cost,
    ROUND(total_profit, 2) AS total_profit,
    profit_margin_pct
FROM product_profitability
ORDER BY total_profit DESC;