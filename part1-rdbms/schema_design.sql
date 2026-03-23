-- 3NF schema normalized from orders_flat.csv
-- drop in FK-safe order

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales_reps;

CREATE TABLE customers (
    customer_id   VARCHAR(10) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100),
    customer_city  VARCHAR(50),
    PRIMARY KEY (customer_id)
);

-- unit_price lives here, not on orders -- a price is a property of the product
CREATE TABLE products (
    product_id   VARCHAR(10) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    unit_price   DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id)
);

-- one row per rep; single office_address here fixes the update anomaly from normalization.md
CREATE TABLE sales_reps (
    sales_rep_id   VARCHAR(10) NOT NULL,
    sales_rep_name VARCHAR(100) NOT NULL,
    sales_rep_email VARCHAR(100),
    office_address VARCHAR(200),
    PRIMARY KEY (sales_rep_id)
);

-- FK constraints mean deleting a customer/product/rep is blocked while orders exist
CREATE TABLE orders (
    order_id     VARCHAR(10) NOT NULL,
    customer_id  VARCHAR(10) NOT NULL,
    product_id   VARCHAR(10) NOT NULL,
    sales_rep_id VARCHAR(10) NOT NULL,
    quantity     INT NOT NULL,
    order_date   DATE NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(sales_rep_id)
);


INSERT INTO customers VALUES
    ('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
    ('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
    ('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
    ('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
    ('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
    ('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
    ('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
    ('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');

INSERT INTO products VALUES
    ('P001', 'Laptop',        'Electronics', 55000.00),
    ('P002', 'Mouse',         'Electronics', 800.00),
    ('P003', 'Desk Chair',    'Furniture',   8500.00),
    ('P004', 'Notebook',      'Stationery',  120.00),
    ('P005', 'Headphones',    'Electronics', 3200.00),
    ('P006', 'Standing Desk', 'Furniture',   22000.00),
    ('P007', 'Pen Set',       'Stationery',  250.00),
    ('P008', 'Webcam',        'Electronics', 2100.00);

INSERT INTO sales_reps VALUES
    ('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
    ('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
    ('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001');

INSERT INTO orders VALUES
    ('ORD1027', 'C002', 'P004', 'SR02', 4, '2023-11-02'),
    ('ORD1114', 'C001', 'P007', 'SR01', 2, '2023-08-06'),
    ('ORD1002', 'C002', 'P005', 'SR02', 1, '2023-01-17'),
    ('ORD1075', 'C005', 'P003', 'SR03', 3, '2023-04-18'),
    ('ORD1091', 'C001', 'P006', 'SR01', 3, '2023-07-24'),
    ('ORD1076', 'C004', 'P006', 'SR03', 5, '2023-05-16'),
    ('ORD1061', 'C006', 'P001', 'SR01', 4, '2023-10-27'),
    ('ORD1098', 'C007', 'P001', 'SR03', 2, '2023-10-03'),
    ('ORD1131', 'C008', 'P001', 'SR02', 4, '2023-06-22'),
    ('ORD1022', 'C005', 'P002', 'SR01', 5, '2023-10-15'),
    ('ORD1054', 'C002', 'P001', 'SR03', 1, '2023-10-04'),
    ('ORD1095', 'C001', 'P001', 'SR03', 3, '2023-08-11'),
    ('ORD1166', 'C003', 'P002', 'SR01', 3, '2023-09-05'),
    ('ORD1033', 'C004', 'P002', 'SR02', 5, '2023-03-24'),
    ('ORD1025', 'C008', 'P001', 'SR01', 2, '2023-02-26'),
    ('ORD1093', 'C007', 'P006', 'SR03', 1, '2023-06-19'),
    ('ORD1143', 'C003', 'P005', 'SR03', 2, '2023-02-28'),
    ('ORD1043', 'C004', 'P005', 'SR01', 1, '2023-01-04'),
    ('ORD1169', 'C003', 'P003', 'SR01', 5, '2023-01-28'),
    ('ORD1021', 'C008', 'P004', 'SR03', 2, '2023-08-23'),
    ('ORD1049', 'C007', 'P004', 'SR02', 1, '2023-01-28'),
    ('ORD1094', 'C002', 'P003', 'SR01', 3, '2023-10-25'),
    ('ORD1155', 'C007', 'P003', 'SR01', 3, '2023-09-11'),
    ('ORD1007', 'C006', 'P003', 'SR01', 3, '2023-04-21'),
    ('ORD1009', 'C006', 'P005', 'SR02', 4, '2023-01-23');
