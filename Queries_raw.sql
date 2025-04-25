SELECT * FROM pizzas;

SELECT * FROM pizza_types;

SELECT * FROM orders;

SELECT * FROM order_details;


--Count the total number of orders?
SELECT COUNT(DISTINCT orders.order_id) AS Total_Orders FROM orders;

--Calculate the total revenue?
SELECT ROUND(SUM(pizzas.price*order_details.quantity),2) as Total_revenue 
FROM pizzas 
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
;

--Identify the highyest priced Pizza?
SELECT TOP 1 pizza_types. name, pizzas.price FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
;

--Identify the most common pizza ordered?
SELECT TOP 1 pizza_types.name, COUNT (quantity) AS Quantities 
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantities DESC;


--Identify the most common pizza size ordered?
SELECT pizzas.size, COUNT(order_details.quantity) AS Pizza_count FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Pizza_count DESC;


--Identify the most common pizza types along with quantity?
SELECT TOP 5 pizza_types.name, SUM(order_details.quantity) AS Most_common 
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Most_common DESC;


--Find the total quantity of each pizza?
SELECT pizza_types.category, SUM(order_details.quantity) AS Total_Quantity 
FROM pizza_types
JOIN pizzas
On pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY Total_Quantity DESC;


--Determine the distribution of orders by hour of the day?
SELECT DATEPART(HOUR, orders.time) AS Order_hour, COUNT (orders.order_id) AS Count_of_order 
FROM orders
GROUP BY DATEPART(HOUR, orders.time)
ORDER BY DATEPART(HOUR, orders.time) DESC
;

--Find the category wise distribution of pizzas?
 SELECT pizza_types.category AS Category, COUNT(pizza_types.category) AS Count
FROM pizza_types
GROUP BY Category
ORDER BY COUNT(pizza_types.category) DESC
;


--Group the orders by date and calculate the average number of pizzas ordered per day?
SELECT AVG(Quantity) AS Average_count FROM
(SELECT orders.date, SUM(order_details.quantity) AS Quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS Order_quantity;


--Determine the top 3 most ordered piza based on Revenue?
SELECT TOP 3 pizza_types.name, SUM(pizzas.price*order_details.quantity) AS Summation 
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Summation DESC;


--Calculate the percentage distribution of each pizza type to total revenue?
SELECT pizza_types.category,
ROUND((SUM(pizzas.price*order_details.quantity)/
(SELECT SUM(pizzas.price*order_details.quantity) FROM
pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id))*100,2) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP by category
ORDER by Revenue;


--Analyze the cumulative revenue generated over time?
SELECT date, SUM(Revenue) OVER (ORDER BY date) AS Cum_Revenue
FROM
(SELECT orders.date, SUM(pizzas.price*order_details.quantity) AS Revenue FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
JOIN orders
ON order_details.order_id = orders.order_id
GROUP BY orders.date) AS totals
;


--Determine the top 3 most ordered pizza types based on revenue for each pizza?
SELECT category, name, Revenue
FROM
(SELECT category, name, REVENUE, RANK () over (PARTITION BY category ORDER BY REVENUE DESC) AS Ranks 
FROM
(SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity*pizzas.price) AS REVENUE 
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category, name) AS Table_1) AS Table_2
WHERE Ranks<=3;
