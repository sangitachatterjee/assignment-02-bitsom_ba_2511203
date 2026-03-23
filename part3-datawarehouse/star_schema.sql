-- star_schema.sql
-- Star schema for retail BI reporting, built from retail_transactions.csv.
--
-- Three data quality issues found and fixed:
--   1. Dates in three formats (YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY) -> all ISO 8601
--   2. store_city NULL in several rows -> inferred from store_name
--   3. category casing and Grocery/Groceries inconsistency -> canonical values used

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- date dimension: one row per unique calendar date in the fact table
-- date_key is YYYYMMDD integer so it sorts naturally without a join
CREATE TABLE dim_date (
    date_key     INT         NOT NULL,
    full_date    DATE        NOT NULL,
    day_of_month SMALLINT    NOT NULL,
    month        SMALLINT    NOT NULL,
    month_name   VARCHAR(12) NOT NULL,
    quarter      SMALLINT    NOT NULL,
    year         SMALLINT    NOT NULL,
    day_of_week  VARCHAR(10) NOT NULL,
    is_weekend   BOOLEAN     NOT NULL,
    PRIMARY KEY (date_key)
);

-- store dimension: city stored here once, so NULL city rows in the source never enter the warehouse
CREATE TABLE dim_store (
    store_key  INT          NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(50)  NOT NULL,
    PRIMARY KEY (store_key)
);

-- product dimension: category is standardized here (see etl_notes.md)
CREATE TABLE dim_product (
    product_key  INT          NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50)  NOT NULL,
    PRIMARY KEY (product_key)
);

-- fact table: one row per retail transaction line
-- total_amount is pre-computed (units_sold * unit_price) so aggregates don't repeat the multiply
CREATE TABLE fact_sales (
    sale_key       INT            NOT NULL,
    transaction_id VARCHAR(10)    NOT NULL,
    date_key       INT            NOT NULL,
    store_key      INT            NOT NULL,
    product_key    INT            NOT NULL,
    customer_id    VARCHAR(10)    NOT NULL,
    units_sold     INT            NOT NULL,
    unit_price     DECIMAL(12, 2) NOT NULL,
    total_amount   DECIMAL(14, 2) NOT NULL,
    PRIMARY KEY (sale_key),
    FOREIGN KEY (date_key)    REFERENCES dim_date    (date_key),
    FOREIGN KEY (store_key)   REFERENCES dim_store   (store_key),
    FOREIGN KEY (product_key) REFERENCES dim_product (product_key)
);


-- 19 date rows, one per unique transaction date; day_of_week and is_weekend verified against calendar
INSERT INTO dim_date
    (date_key, full_date, day_of_month, month, month_name, quarter, year, day_of_week, is_weekend)
VALUES
    (20230115, '2023-01-15',  15,  1, 'January',    1, 2023, 'Sunday',    TRUE),
    (20230118, '2023-01-18',  18,  1, 'January',    1, 2023, 'Wednesday', FALSE),
    (20230208, '2023-02-08',   8,  2, 'February',   1, 2023, 'Wednesday', FALSE),
    (20230220, '2023-02-20',  20,  2, 'February',   1, 2023, 'Monday',    FALSE),
    (20230331, '2023-03-31',  31,  3, 'March',      1, 2023, 'Friday',    FALSE),
    (20230428, '2023-04-28',  28,  4, 'April',      2, 2023, 'Friday',    FALSE),
    (20230512, '2023-05-12',  12,  5, 'May',        2, 2023, 'Friday',    FALSE),
    (20230521, '2023-05-21',  21,  5, 'May',        2, 2023, 'Sunday',    TRUE),
    (20230604, '2023-06-04',   4,  6, 'June',       2, 2023, 'Sunday',    TRUE),
    (20230722, '2023-07-22',  22,  7, 'July',       3, 2023, 'Saturday',  TRUE),
    (20230801, '2023-08-01',   1,  8, 'August',     3, 2023, 'Tuesday',   FALSE),
    (20230815, '2023-08-15',  15,  8, 'August',     3, 2023, 'Tuesday',   FALSE),
    (20230829, '2023-08-29',  29,  8, 'August',     3, 2023, 'Tuesday',   FALSE),
    (20230912, '2023-09-12',  12,  9, 'September',  3, 2023, 'Tuesday',   FALSE),
    (20231020, '2023-10-20',  20, 10, 'October',    4, 2023, 'Friday',    FALSE),
    (20231026, '2023-10-26',  26, 10, 'October',    4, 2023, 'Thursday',  FALSE),
    (20231118, '2023-11-18',  18, 11, 'November',   4, 2023, 'Saturday',  TRUE),
    (20231208, '2023-12-08',   8, 12, 'December',   4, 2023, 'Friday',    FALSE),
    (20231212, '2023-12-12',  12, 12, 'December',   4, 2023, 'Tuesday',   FALSE);


-- NULL city rows resolved by deriving city from store_name
INSERT INTO dim_store (store_key, store_name, store_city)
VALUES
    (1, 'Chennai Anna',    'Chennai'),
    (2, 'Mumbai Central',  'Mumbai'),
    (3, 'Bangalore MG',    'Bangalore'),
    (4, 'Pune FC Road',    'Pune'),
    (5, 'Delhi South',     'Delhi');


-- canonical categories applied: "electronics" -> "Electronics", "Groceries" -> "Grocery"
INSERT INTO dim_product (product_key, product_name, category)
VALUES
    ( 1, 'Smartwatch', 'Electronics'),
    ( 2, 'Saree',      'Clothing'),
    ( 3, 'Headphones', 'Electronics'),
    ( 4, 'Tablet',     'Electronics'),
    ( 5, 'Milk 1L',    'Grocery'),
    ( 6, 'Laptop',     'Electronics'),
    ( 7, 'Jacket',     'Clothing'),
    ( 8, 'Atta 10kg',  'Grocery'),
    ( 9, 'Speaker',    'Electronics'),
    (10, 'Jeans',      'Clothing'),
    (11, 'Biscuits',   'Grocery'),
    (12, 'Phone',      'Electronics');


-- 19 fact rows spanning all 12 months of 2023
INSERT INTO fact_sales
    (sale_key, transaction_id, date_key, store_key, product_key,
     customer_id, units_sold, unit_price, total_amount)
VALUES
    (1,  'TXN5004', 20230115, 1,  1,  'CUST004', 10, 58851.01,  588510.10),
    (2,  'TXN5015', 20230118, 2,  2,  'CUST009', 15, 35451.81,  531777.15),
    (3,  'TXN5018', 20230208, 3,  3,  'CUST015', 15, 39854.96,  597824.40),
    (4,  'TXN5003', 20230220, 5,  4,  'CUST007', 14, 23226.12,  325165.68),
    (5,  'TXN5006', 20230331, 4,  1,  'CUST025',  6, 58851.01,  353106.06),
    (6,  'TXN5013', 20230428, 2,  5,  'CUST015', 10, 43374.39,  433743.90),
    (7,  'TXN5012', 20230521, 3,  6,  'CUST044', 13, 42343.15,  550460.95),
    (8,  'TXN5017', 20230512, 3,  7,  'CUST019',  6, 30187.24,  181123.44),
    (9,  'TXN5010', 20230604, 1,  7,  'CUST031', 15, 30187.24,  452808.60),
    (10, 'TXN5019', 20230722, 1,  8,  'CUST008',  3, 52464.00,  157392.00),
    (11, 'TXN5016', 20230801, 2,  2,  'CUST035', 11, 35451.81,  389969.91),
    (12, 'TXN5009', 20230815, 3,  1,  'CUST020',  3, 58851.01,  176553.03),
    (13, 'TXN5000', 20230829, 1,  9,  'CUST045',  3, 49262.78,  147788.34),
    (14, 'TXN5059', 20230912, 3,  3,  'CUST009',  1, 39854.96,   39854.96),
    (15, 'TXN5011', 20231020, 2, 10,  'CUST045', 13,  2317.47,   30127.11),
    (16, 'TXN5007', 20231026, 4, 10,  'CUST041', 16,  2317.47,   37079.52),
    (17, 'TXN5014', 20231118, 5,  7,  'CUST042',  5, 30187.24,  150936.20),
    (18, 'TXN5008', 20231208, 3, 11,  'CUST030',  9, 27469.99,  247229.91),
    (19, 'TXN5001', 20231212, 1,  4,  'CUST021', 11, 23226.12,  255487.32);
