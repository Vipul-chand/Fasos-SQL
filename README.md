 # Project Description     

 In this SQL project exploratory data analysis and data cleaning has been performed. We have data for an online food delivery service.
 Which has its own cloud kitchen, and specialises in wraps(rolls).Data set contains the following tables

1.	Customer_orders – It contains details of orders mapped to each customer ids, product they ordered and also if they prefer any particular ingredients in their wraps.
2.	Driver – id of delivery person and their date of registration with the company.
3.	Driver_order – details of the deliveries done by the delivery person.
4.	Rolls – assigned unique id of each wrap and their names.
5.	Ingredients – assigned unique id of each ingredient and their names.
6.	Rolls_reciepe – ingredients which are added to each wrap.

### Exploratory Analysis has been conducted to gain insights related to two metrics

#### 1.	Product Metrics 
*	How many wraps were ordered?
*	How many unique customer orders were made?
*	How many successful orders were delivered by each driver?
*	How many of each type of wraps were delivered?
*	How many Veg and Non-Veg wraps ordered by each customer?
*	What was the maximum number of wraps delivered in a single order?
* For each customer, how many delivered wraps had at least 1 change (request to add or remove some of the standard ingredients used in wraps) 
  and how many had no changes?
* How many wraps were delivered that had both exclusions and extras?
*	What was the total number of wraps ordered for each hour of the day?
*	What was the number of orders for each day of the week?

#### 2.	Driver and customer experience
*	What is the average time in minutes it took for each driver to arrive at the Faasos counter to pick up the order?
*	Is there any relationship between the number of wraps ordered and how long the order takes to prepare?
*	What was the average distance travelled for each customer to deliver the order?
*	What is the difference between the highest and shortest delivery times for all orders?
*	What is the successful delivery percentage for each driver?

### To achieve desired output following SQL functions were used. 
Aggregate functions, Joins, Case statement, Subqueries, Window functions, Temporary Tables, Common Table Expressions (CTE).

![image](https://user-images.githubusercontent.com/119819006/223269481-ce959155-b012-455a-aa89-9c30dd692fa6.png)

