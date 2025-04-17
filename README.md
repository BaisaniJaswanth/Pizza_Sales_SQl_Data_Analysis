# Pizza_Sales_SQl_Data_Analysis

🍕 Pizza Sales Data Analysis using SQL

📌 Project Overview
This project presents a comprehensive SQL-based analysis of a fictional pizza restaurant’s order and sales data. The dataset includes information about pizza types, prices, order details, and time-based sales patterns. This README outlines the project objectives, business insights, and SQL strategies used to derive actionable intelligence from the data.

📂 Dataset
The analysis is based on four CSV files:

orders.csv

order_details.csv

pizzas.csv

pizza_types.csv

🧱 Schema
sql
Copy
Edit
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

CREATE TABLE pizzas (
    pizza_id VARCHAR(50),
    pizza_type_id VARCHAR(50),
    size VARCHAR(10),
    price NUMERIC(6, 2)
);
🔍 Key Business Insights
✅ Total Orders
Calculate how many total orders were placed to understand volume and demand:

sql
Copy
Edit
SELECT COUNT(*) AS total FROM orders;
💵 Revenue Tracking
Revenue derived from the quantity of pizzas sold and their prices:

sql
Copy
Edit
SELECT SUM(order_details.quantity * pizzas.price) AS total_sales
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;
🏆 Top-Selling Pizzas
Get the top 5 most ordered pizza types:

sql
Copy
Edit
SELECT pizza_types.pizza_type_id, SUM(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;
📏 Most Common Pizza Size
Helps in stock planning:

sql
Copy
Edit
SELECT pizzas.size, COUNT(*)
FROM pizzas
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;
🍽️ Category-wise Sales Volume
Breakdown of quantity sold by pizza category:

sql
Copy
Edit
SELECT pizza_types.category, SUM(order_details.quantity)
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;
🕒 Hourly Order Patterns
Determine busiest hours:

sql
Copy
Edit
SELECT EXTRACT(HOUR FROM order_time) AS order_hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
📆 Daily Average Sales
Evaluate average pizza orders per day:

sql
Copy
Edit
SELECT ROUND(AVG(average_pizzas), 0) AS avg_ordered_pizzas
FROM (
    SELECT order_date, SUM(quantity) AS average_pizzas
    FROM orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY order_date
) AS ordered_quantity;
💰 Cumulative Revenue Over Time
Track sales growth:

sql
Copy
Edit
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY 1
) AS sales;
🥇 Category-wise Top 3 Pizzas by Revenue
sql
Copy
Edit
SELECT category, name, revenue
FROM (
    SELECT category, name, revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 1, 2
    ) AS a
) AS b
WHERE rn <= 3;
🧠 Advanced SQL Techniques Used
Window Functions:
For ranking (RANK()) and cumulative aggregations (SUM() OVER).

Subqueries:
Used for averages, filters, and nested rankings.

Joins & Aggregations:
Crucial to linking orders, pizzas, and pizza types.

Date & Time Functions:
Such as EXTRACT(HOUR FROM order_time) for time-based analysis.

📊 Final Insights & Interpretation
🍕 Highest Revenue Contributors:
Certain pizzas and categories (e.g., "Classic" or "Supreme") generate the most revenue.

⏰ Time Matters:
Majority of orders cluster during lunch and dinner hours — valuable for staffing and prep.

📏 Popular Sizes:
Medium size dominates orders, helping shape future inventory and packaging decisions.

📈 Steady Sales Growth:
Cumulative revenue plots show healthy business trends, with peaks during specific days/times.

📚 Strategic Use of SQL:
This project utilizes advanced SQL constructs, optimizing both performance and insight clarity.
