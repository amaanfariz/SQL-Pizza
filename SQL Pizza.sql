create database pizza;
use pizza;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

-- Retrive the total numbers of order placed
SELECT 
    COUNT(*) AS Total_orders
FROM
    orders;
    
-- calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest price pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most ordered pizza size
SELECT 
    pizzas.size,
    SUM(order_details.quantity) AS most_ordered_pizza
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY most_ordered_pizza DESC
LIMIT 1;

-- List the top 5 most ordered type of pizza with quantities
SELECT 
    pizza_types.name AS Pizza_Name,
    sum(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Pizza_Name
ORDER BY total_quantity DESC
LIMIT 5;

-- Find the total quantity of each pizza category ordered
SELECT 
    pizza_types.category AS Pizza_category,
    sum(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Pizza_category
ORDER BY total_quantity DESC;

-- Determine the distributiion of orders by hour of the day
SELECT 
    HOUR(orders.order_time) AS Hour,
    COUNT(order_details.order_id) AS order_count
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY Hour
ORDER BY Hour;

-- Find category wise distribution of pizzas
SELECT 
    category, COUNT(name) AS Distribution
FROM
    pizza_types
GROUP BY category
ORDER BY Distribution;

-- Group Orders by Date and calculate the avg no. of pizzas ordered/day
SELECT 
    ROUND(AVG(quantity), 0) AS per_day_order
FROM
    (SELECT 
        orders.order_date AS Order_date,
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY Order_date) AS b;
    
-- Determine the top 3 most ordered pizza based on revenue
SELECT 
    pizza_types.name AS name_pizza,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name_pizza
ORDER BY revenue DESC
LIMIT 3;

-- Claculate the percentage contribution of each pizza category to total revenue
SELECT 
    pizza_types.category AS caytegory_pizza,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            SUM(order_details.quantity * pizzas.price)
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY caytegory_pizza;

-- Analyze the cumulative revenue generated over time
select order_date, sum(revenue) over (order by order_date) as Cumulative_revenue
from
(select orders.order_date as order_date, 
sum(order_details.quantity*pizzas.price) as revenue
from order_details 
join orders on orders.order_id=order_details.order_id
join pizzas on pizzas.pizza_id=order_details.pizza_id
group by order_date) as b;

-- determine the top 3 pizza types in each pizza category based on revenue
select Category_name,Pizza_name,revenue,revenue_rank
from
(select Category_name,Pizza_name,revenue,
rank() over(partition by Category_name order by revenue desc) as revenue_rank
from
(select pizza_types.category as Category_name,pizza_types.name as Pizza_name, 
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types 
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by Category_name,Pizza_name
order by Category_name,revenue desc) as b) as a
where revenue_rank <4 ;
