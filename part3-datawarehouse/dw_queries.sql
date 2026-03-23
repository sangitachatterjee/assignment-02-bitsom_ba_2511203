-- dw_queries.sql
-- Analytical queries against the star schema defined in star_schema.sql.

-- Q1:
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    dp.category,
    SUM(fs.total_amount)   AS total_revenue,
    SUM(fs.units_sold)     AS total_units
FROM fact_sales  fs
JOIN dim_date    dd ON fs.date_key    = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY
    dd.year,
    dd.month,
    dd.month_name,
    dp.category
ORDER BY
    dd.year,
    dd.month,
    dp.category;


-- Q2:
SELECT
    ds.store_name,
    ds.store_city,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.units_sold)   AS total_units_sold,
    COUNT(*)             AS total_transactions
FROM fact_sales fs
JOIN dim_store  ds ON fs.store_key = ds.store_key
GROUP BY
    ds.store_key,
    ds.store_name,
    ds.store_city
ORDER BY total_revenue DESC
LIMIT 2;


-- Q3:
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    SUM(fs.total_amount)  AS monthly_revenue,
    LAG(SUM(fs.total_amount)) OVER (
        ORDER BY dd.year, dd.month
    )                     AS prev_month_revenue,
    ROUND(
        (
            SUM(fs.total_amount)
            - LAG(SUM(fs.total_amount)) OVER (ORDER BY dd.year, dd.month)
        )
        / LAG(SUM(fs.total_amount)) OVER (ORDER BY dd.year, dd.month)
        * 100,
        2
    )                     AS mom_change_percent
FROM fact_sales fs
JOIN dim_date   dd ON fs.date_key = dd.date_key
GROUP BY
    dd.year,
    dd.month,
    dd.month_name
ORDER BY
    dd.year,
    dd.month;
