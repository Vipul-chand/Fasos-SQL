use gdb023;
-- 1.How many wraps were ordered?

SELECT 
    COUNT(*)
FROM
    customer_orders;
    
    -- 2.How many unique customer orders were made?
    
SELECT 
    COUNT(DISTINCT customer_id)
FROM
    customer_orders;
    
-- 3.How many successful orders were delivered by each driver?

SELECT 
    driver_id, COUNT(order_id)
FROM
    driver_order
WHERE
    cancellation NOT LIKE ('%cancellation%')
GROUP BY driver_id;

-- 4.How many of each type of wraps were delivered?


SELECT 
    roll_id, COUNT(order_id) order_count
FROM
    customer_orders
WHERE
    order_id IN (SELECT order_id FROM
            (SELECT                                                           -- Null values were removed from order delivery status column 
                *, CASE                                                            
                        WHEN cancellation NOT LIKE ('%cancellation%') THEN 'nc'
                        WHEN cancellation IS NULL THEN 'nc'
                        ELSE 'c'
                    END AS order_cancel_details
            FROM
                driver_order) a
        WHERE
            order_cancel_details = 'nc')
GROUP BY roll_id;

-- 5. How many Veg and Non Veg wraps ordered by each customer ?

SELECT 
    a.customer_id,
    count(case when b.roll_name = "Non Veg Roll" then 1 else null end) as non_veg_orders,
    count(case when b.roll_name = "Veg Roll" then 1 else null end) as veg_orders
FROM
    customer_orders a
        LEFT JOIN
    rolls b ON a.roll_id = b.roll_id
    group by a.customer_id;
    

-- 6. What was the maximum number of wraps delivered in a single order?

select * from 
(SELECT *, rank() over(order by count desc) rnk
from (
SELECT 
    order_id, COUNT(roll_id) count
FROM
    customer_orders
WHERE
    order_id IN (SELECT 
            order_id
        FROM
            (SELECT 
                *,
                    CASE
                        WHEN cancellation NOT LIKE ('%cancellation%') THEN 'nc'
                        WHEN cancellation IS NULL THEN 'nc'
                        ELSE 'c'
                    END AS order_cancel_details
            FROM
                driver_order) a
        WHERE
            order_cancel_details = 'nc') 
GROUP BY order_id) q ) x
where rnk = 1 ;

-- 7. For each customer, how many delivered wraps had at least 1 change (request to add or remove some of the standard ingredients used in wraps) 
-- and how many had no changes?

-- Created temporary table for removing null and blank values

drop table temp_customer_orders;

create temporary table temp_customer_orders as 
select order_id, customer_id, roll_id, 
case when not_include_items is null or not_include_items = '' then 0 else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included= '' or extra_items_included ='NaN' then 0 else extra_items_included end as new_extra_items_included
from customer_orders;

create temporary table temp_driver_order as 
select order_id, driver_id, pickup_time, distance, duration,
CASE WHEN cancellation LIKE ('%cancellation%') THEN 0 else 1 end as new_cancellation
from driver_order;


with CTE AS (
select * ,
case when new_not_include_items = 0 and new_extra_items_included = 0 then "no change" else "change" end as change_no_change
from temp_customer_orders where order_id IN (
select order_id from temp_driver_order
where new_cancellation != 0))

select customer_id, change_no_change, count(order_id) atleast_1_chng
from CTE
group by customer_id, change_no_change;


-- 8. How many wraps were delivered that had both exclusions and extras?

create temporary table temp_customer_orders as 
select order_id, customer_id, roll_id, 
case when not_include_items is null or not_include_items = '' then 0 else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included= '' or extra_items_included ='NaN' then 0 else extra_items_included end as new_extra_items_included
from customer_orders;

create temporary table temp_driver_order as 
select order_id, driver_id, pickup_time, distance, duration,
CASE WHEN cancellation LIKE ('%cancellation%') THEN 0 else 1 end as new_cancellation
from driver_order;


select change_no_change, count(change_no_change)
from (
select * ,
case when new_not_include_items != 0 and new_extra_items_included != 0 then "included and exculded" else "either one" end as change_no_change
from temp_customer_orders where order_id IN (
select order_id from temp_driver_order
where new_cancellation != 0)) a
group by change_no_change;

-- 9.What was the total number of wraps ordered for each hour of the day?

select
hour_bucket, count(hour_bucket)
from (
select  CONCAT(cast(hour(order_date) AS CHAR),'-', cast(hour(order_date)+ 1 AS CHAR)) hour_bucket
from customer_orders) a
group by 1
order by 1;

-- 10. What was the number of orders for each day of the week?

select DAYNAME(order_date) day, count(distinct order_id)
from customer_orders
group by 1;

-- 11. What is the average time in minutes it took for each driver to arrive at the fasos counter to pick up the order?

with CTE1 AS (
select a.order_id, a.customer_id, a.order_date, b.driver_id, b.pickup_time, 
TIMESTAMPDIFF(MINUTE, a.order_date, b.pickup_time) diff
from customer_orders a
join driver_order b ON a.order_id = b.order_id
where b.pickup_time is not null),

CTE2 AS (
    select 
    order_id, driver_id, diff, row_number () over(partition by order_id order by diff) rnk
    from CTE1)

select driver_id, ROUND(sum(diff)/count(order_id),2) avg_min
from CTE2
where rnk = 1
group by driver_id;

-- 12. Is there ny relationship between the number of wraps ordered and how long the order takes to prepare?


with CTE AS (
select a.order_id, a.customer_id, a.order_date, b.driver_id, b.pickup_time, 
TIMESTAMPDIFF(MINUTE, a.order_date, b.pickup_time) diff
from customer_orders a
join driver_order b ON a.order_id = b.order_id
where b.pickup_time is not null)

select order_id, count(order_id) cnt, sum(diff)/count(order_id) Time
from CTE
group by order_id;

-- 13. What was the average distance travelled for each customer to deliver the order ?

SELECT 
    customer_id, SUM(distance) / COUNT(customer_id) Avg_distance
FROM
    (SELECT 
        a.order_id,
            a.customer_id,
            a.roll_id,
            a.order_date,
            b.driver_id,
            b.pickup_time,
            b.distance
    FROM
        customer_orders a
    JOIN driver_order b ON a.order_id = b.order_id
    WHERE
        b.pickup_time IS NOT NULL) a
GROUP BY customer_id;

-- 14. What is the difference between the highest and shortest delivery times for all oreders?

select  MAX(duration) - MIN(duration)
from driver_order;

-- 15. What is the successful delivery percentage for each driver?

SELECT 
    driver_id,
    SUM(order_status) / COUNT(order_status) * 100 AS successful_delivery_perage
FROM
    (SELECT 
        driver_id,
            CASE
                WHEN cancellation LIKE '%cancel%' THEN 0
                ELSE 1
            END AS order_status
    FROM
        driver_order) a
GROUP BY driver_id;


















