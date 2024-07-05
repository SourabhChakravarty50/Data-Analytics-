CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    date DATE,
    product_id INT,
    sales_amount DECIMAL(10, 2)
);

INSERT INTO sales (sale_id, date, product_id, sales_amount) VALUES
(1, '2023-01-01', 1, 100.00),
(2, '2023-01-01', 2, 150.00),
(3, '2023-01-02', 1, 200.00),
(4, '2023-01-02', 2, 250.00),
(5, '2023-01-03', 1, 300.00),
(6, '2023-01-03', 2, 350.00),
(7, '2023-01-04', 1, 400.00),
(8, '2023-01-04', 2, 450.00),
(9, '2023-01-05', 1, 500.00),
(10, '2023-01-05', 2, 550.00);


Select * from sales
	
-- 1. Running Total of Sales for Each Product

SELECT 
    date,
    product_id,
    sales_amount,
    SUM(sales_amount) OVER (PARTITION BY product_id ORDER BY date) AS running_total
FROM 
    sales;

-- 2. Row Number for Each Sale by Product

SELECT
	sale_id,
    date,
    product_id,
    sales_amount,
ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY date) AS row_num
FROM sales;

-- 3. Average Sales Amount Over All Sales

SELECT 
    date,
    product_id,
    sales_amount,
    AVG(sales_amount) OVER (PARTITION BY product_id ORDER BY date) AS avg_sales_amount
FROM 
    sales;

-- 4. Sales Rank for Each Product

SELECT 
    sale_id,
    date,
    product_id,
    sales_amount,
    RANK() OVER (PARTITION BY product_id ORDER BY sales_amount DESC) AS sales_rank
FROM 
    sales;

-- 5. Cumulative Distribution of Sales Amounts

SELECT 
    sale_id,
    date,
    product_id,
    sales_amount,
    CUME_DIST() OVER (PARTITION BY product_id ORDER BY sales_amount) AS cum_dist
FROM 
    sales;
