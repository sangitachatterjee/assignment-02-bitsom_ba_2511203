-- duckdb_queries.sql
-- Cross-format queries using DuckDB.

-- Q1:
SELECT
    c.customer_id,
    c.name            AS customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders
FROM read_csv_auto('datasets/customers.csv')  c
LEFT JOIN read_json_auto('datasets/orders.json') o
       ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY total_orders DESC, c.name;


-- Q2:
SELECT
    c.customer_id,
    c.name            AS customer_name,
    c.city,
    SUM(o.total_amount) AS total_order_value
FROM read_csv_auto('datasets/customers.csv')  c
JOIN read_json_auto('datasets/orders.json') o
  ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY total_order_value DESC
LIMIT 3;


-- Q3:
SELECT DISTINCT
    c.customer_id,
    c.name         AS customer_name,
    p.product_id,
    p.product_name,
    p.category
FROM read_csv_auto('datasets/customers.csv')    c
JOIN read_json_auto('datasets/orders.json')     o  ON c.customer_id = o.customer_id
JOIN read_parquet('datasets/products.parquet')  p  ON o.order_id    = p.order_id
WHERE c.city = 'Bangalore'
ORDER BY c.name, p.product_name;


-- Q4:
SELECT
    c.name         AS customer_name,
    o.order_date,
    p.product_name,
    p.quantity
FROM read_csv_auto('datasets/customers.csv')   c
JOIN read_json_auto('datasets/orders.json')    o  ON c.customer_id = o.customer_id
JOIN read_parquet('datasets/products.parquet') p  ON o.order_id    = p.order_id
ORDER BY o.order_date, c.name, p.product_name;
