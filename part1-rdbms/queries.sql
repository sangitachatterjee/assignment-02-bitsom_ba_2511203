-- queries.sql
-- All queries run against the 3NF schema defined in schema_design.sql.

-- Q1:
SELECT
    c.customer_id,
    c.customer_name,
    SUM(p.unit_price * o.quantity) AS total_order_value
FROM customers c
JOIN orders   o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id  = p.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_order_value DESC;

-- Q2:
SELECT
    p.product_id,
    p.product_name,
    SUM(o.quantity) AS total_quantity_sold
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3:
SELECT
    sr.sales_rep_id,
    sr.sales_rep_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers_handled
FROM sales_reps sr
LEFT JOIN orders o ON sr.sales_rep_id = o.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name
ORDER BY unique_customers_handled DESC;

-- Q4:
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    o.quantity,
    p.unit_price,
    (o.quantity * p.unit_price) AS total_value
FROM orders   o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE (o.quantity * p.unit_price) > 10000
ORDER BY total_value DESC;

-- Q5:
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;
