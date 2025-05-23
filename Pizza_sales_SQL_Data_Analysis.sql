CREATE TABLE order_details (
    order_details_id VARCHAR(50),
    order_id VARCHAR(50),
    pizza_id VARCHAR(50),
    quantity INT,
	PRIMARY KEY(order_details_id)
);

CREATE TABLE orders (
    order_id VARCHAR(50),
    order_date DATE,
    order_time TIME,
	PRIMARY KEY(order_id)
);

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50),
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients VARCHAR(100)
);

DROP TABLE IF EXISTS
pizza_types;

CREATE TABLE pizzas (
    pizza_id VARCHAR(50),
    pizza_type_id VARCHAR(50),
    size VARCHAR(10),
    price NUMERIC(6, 2)
);

SELECT *
FROM order_details;

SELECT *
FROM orders;

SELECT *
FROM pizza_types;

SELECT *
FROM pizzas;

-- Basic:

-- 1. Retrieve the total number of orders placed.
SELECT
	COUNT(*) AS total
FROM
	ORDERS;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT
	SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS TOTAL_SALES
FROM
	ORDER_DETAILS
	JOIN PIZZAS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID;

-- or

SELECT
	SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS TOTAL_SALES
FROM
	PIZZAS
	JOIN ORDER_DETAILS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID;

-- 3. Identify the highest-priced pizza.
SELECT
	PRICE AS HIGHEST_PRICE_PIZZA
FROM
	PIZZAS
ORDER BY PRICE DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT
	PIZZAS.SIZE,
	COUNT(*)
FROM
	PIZZAS
	JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 1
ORDER BY 2 DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT
	PIZZA_TYPES.PIZZA_TYPE_ID,
	SUM(ORDER_DETAILS.QUANTITY) AS TOTAL_QUANTITY
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
	JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;

-- Intermediate:
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT
	PIZZA_TYPES.CATEGORY,
	SUM(ORDER_DETAILS.QUANTITY)
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
	JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Determine the distribution of orders by hour of the day.
SELECT
	EXTRACT(HOUR FROM ORDERS.ORDER_TIME) AS ORDER_HOUR,
	COUNT(DISTINCT ORDERS.ORDER_ID) AS ORDER_COUNT -- this is combining orders from both table so we have to conside the the unique orders using order id so we use DISTINCT
FROM
	ORDERS
	INNER JOIN ORDER_DETAILS ON ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
GROUP BY 1
ORDER BY 2 DESC;

-- or

SELECT
	EXTRACT(HOUR FROM ORDER_TIME) AS ORDER_HOUR,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT
	CATEGORY,
	COUNT(NAME) AS PIZZA_COUNT
FROM
	PIZZA_TYPES
GROUP BY 1;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT
	ROUND(AVG(AVERAGE_PIZZAS), 0) AS AVG_ORDERED_PIZZAS
FROM
	(SELECT ORDER_DATE, SUM(QUANTITY) AS AVERAGE_PIZZAS
	 FROM ORDERS
	 JOIN ORDER_DETAILS ON ORDER_DETAILS.ORDER_ID = ORDERS.ORDER_ID
	 GROUP BY ORDER_DATE
	)AS ORDERED_QUANTITY;

-- 5.Determine the top 3 most ordered pizza types(name, category and size) based on revenue.
SELECT
	NAME, CATEGORY, SIZE, SUM(PRICE * QUANTITY) AS PIZZA_REVENUE
FROM
	PIZZA_TYPES
	INNER JOIN PIZZAS ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
	INNER JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 1, 2, 3
ORDER BY 4 DESC
LIMIT 3;

-- Advanced:

-- 1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT
	PIZZA_TYPES.CATEGORY,
	ROUND((SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE)) / (SELECT SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS TOTAL_SALES
	FROM ORDER_DETAILS
	JOIN PIZZAS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
	),2) * 100 AS REVENUE
FROM
	PIZZA_TYPES
	JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
	JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Analyze the cumulative revenue generated over time.
SELECT
	ORDER_DATE, SUM(REVENUE) OVER (ORDER BY ORDER_DATE) AS CUM_REVENUE
FROM
	(SELECT ORDERS.ORDER_DATE, SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
	FROM ORDER_DETAILS
	JOIN PIZZAS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
	JOIN ORDERS ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
GROUP BY 1) AS SALES;

-- 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT CATEGORY, NAME, REVENUE
FROM
	(SELECT CATEGORY, NAME, REVENUE, RANK() OVER (PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RN
	FROM
	(SELECT PIZZA_TYPES.CATEGORY, PIZZA_TYPES.NAME, SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
	FROM PIZZA_TYPES
	JOIN PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
	JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
	GROUP BY 1, 2) AS A) AS B -- we are using another subquery AS b beacuse we cannot use WHERE clause directly to check the value of rn
WHERE RN <= 3;