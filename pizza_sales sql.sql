-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id)
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    Round(SUM(order_details.quantity * pizzas.price),2) 
    AS total_sales
FROM
     order_details
        JOIN pizzas 
    ON order_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.


SELECT 
    pizza_type.name, pizzas.price
FROM
    pizza_type
    join pizzas
    On pizza_type.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.


SELECT 
    pizzas.size, COUNT(order_details.order_details_id)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.order_details_id) DESC
LIMIT 1;



-- List the top 5 most ordered pizza types 
-- along with their quantities.


SELECT 
    pizzas.size, COUNT(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY pizzas.size
LIMIT 5;
 
 
--  Join the necessary tables to find the
--  total quantity of each pizza category ordered.
 

SELECT 
    pizza_type.category, SUM(order_details.quantity)
    as total_quantity
FROM
    pizza_type
        JOIN
    pizzas ON pizza_type.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_type.category
ORDER BY SUM(order_details.quantity);
 

-- Determine the distribution of orders 
-- by hour of the day.


SELECT 
    HOUR(time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(time);


-- Join relevant tables to find the category-wise distribution of pizzas.-- 


SELECT 
    category, COUNT(name)
FROM
    pizza_type
GROUP BY category;



-- Group the orders by date and 
-- calculate the average number of pizzas ordered per day.


SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity ;
    
    
    
 -- Determine the top 3 most ordered pizza types
 -- based on revenue.   


SELECT 
    pizza_type.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_type
        JOIN
    pizzas ON pizza_type.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.name
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to 
-- total revenue.


SELECT 
    pizza_type.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                    AS total_sales
                FROM
                    order_details
                        JOIN
		pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_type
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_type.pizza_type_id
        JOIN
        order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_type.category;



-- Analyze the cumulative revenue generated over time.



SELECT 
    orders.date,
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.date;

-- Determine the top 3 most ordered pizza types based on 
-- revenue for each pizza category


SELECT category, name, revenue
FROM (
    SELECT 
        pizza_type.category,
        pizza_type.name,
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (PARTITION BY pizza_type.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rn
    FROM pizzas
    JOIN pizza_type ON pizza_type.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_type.category, pizza_type.name
) AS ranked_pizzas
WHERE rn <= 3;







