-- ANALYZING AND CLEANING DATASET
SELECT *
FROM BikeStores

SELECT distinct order_id, customers
FROM BikeStores
ORDER BY order_id, customers

-- Finding wrongly written names in the list to check whether there's more
SELECT order_id, customers
FROM BikeStores
WHERE customers IN('ARLA Ellis', 'CARMAN HARDY', 'Ai FORBES', 'LYNNE Anderson', 'Boyd Irwin', 'Brittni GreeN', 'Lyndsey Bean', 'Lindsey Bean', 'LyndseyBean') 

-- Finding all wrongly written names and their unique order_id numbers
SELECT order_id, customers
FROM BikeStores
WHERE order_id IN (5, 237, 263, 1059, 827, 346, 372, 1592, 1611)

-- Creating temporary table for testing purpose
DROP Table if exists #TempTable
CREATE TABLE #TempTable
(
order_id varchar(255),
customers varchar(255),
city varchar(255),
state varchar(255),
order_date date,
[total units] varchar(255),
revenue varchar(255),
product_name varchar(255),
category_name varchar(255),
store_name varchar(255),
sales_rep varchar(255)
)

INSERT INTO #TempTable
SELECT *
FROM BikeStores

UPDATE #TempTable
SET customers =
	(CASE when order_id = 5 then 'Arla Ellis'
		when order_id = 237 then 'Carman Hardy'
		when order_id = 263 then 'Ai Forbes'
		when order_id = 827 then 'Brittni Green'
		when order_id = 346 then 'Lynne Anderson'
		when order_id = 372 then 'Boyd Irwin'
		when order_id IN (1059, 1592, 1611) then 'Lyndsey Bean'
		else customers
	END)

-- Updating customers column
UPDATE BikeStores
SET customers =
	(CASE when order_id = 5 then 'Arla Ellis'
		when order_id = 237 then 'Carman Hardy'
		when order_id = 263 then 'Ai Forbes'
		when order_id = 827 then 'Brittni Green'
		when order_id = 346 then 'Lynne Anderson'
		when order_id = 372 then 'Boyd Irwin'
		when order_id IN (1059, 1592, 1611) then 'Lyndsey Bean'
		else customers
	END)


-- Spliting order_date column into YEAR, MONTH columns

SELECT YEAR(order_date) as order_year, 
CASE
	WHEN MONTH(order_date) = 1 THEN 'January'
	WHEN MONTH(order_date) = 2 THEN 'February'
	WHEN MONTH(order_date) = 3 THEN 'March'
	WHEN MONTH(order_date) = 4 THEN 'April'
	WHEN MONTH(order_date) = 5 THEN 'May'
	WHEN MONTH(order_date) = 6 THEN 'June'
	WHEN MONTH(order_date) = 7 THEN 'July'
	WHEN MONTH(order_date) = 8 THEN 'August'
	WHEN MONTH(order_date) = 9 THEN 'September'
	WHEN MONTH(order_date) = 10 THEN 'October'
	WHEN MONTH(order_date) = 11 THEN 'November'
	WHEN MONTH(order_date) = 12 THEN 'December'
END as order_month
FROM BikeStores

ALTER TABLE BikeStores
ADD order_year varchar(5)
UPDATE BikeStores
SET order_year = YEAR(order_date)

ALTER TABLE BikeStores
ADD order_month varchar(10)
UPDATE BikeStores
SET order_month = CASE
	WHEN MONTH(order_date) = 1 THEN 'January'
	WHEN MONTH(order_date) = 2 THEN 'February'
	WHEN MONTH(order_date) = 3 THEN 'March'
	WHEN MONTH(order_date) = 4 THEN 'April'
	WHEN MONTH(order_date) = 5 THEN 'May'
	WHEN MONTH(order_date) = 6 THEN 'June'
	WHEN MONTH(order_date) = 7 THEN 'July'
	WHEN MONTH(order_date) = 8 THEN 'August'
	WHEN MONTH(order_date) = 9 THEN 'September'
	WHEN MONTH(order_date) = 10 THEN 'October'
	WHEN MONTH(order_date) = 11 THEN 'November'
	WHEN MONTH(order_date) = 12 THEN 'December'
END



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA TO BE USED FOR ANALYSIS
-- This data will be used for Tableu

-- (1) Total Revenue per YEAR
SELECT order_year, ROUND(SUM(revenue), 0) as total_revenue
FROM BikeStores
GROUP BY order_year
ORDER BY order_year

-- (2) Total Revenue per MONTH
SELECT order_year, order_month, ROUND(SUM(revenue), 0) as total_revenue
FROM BikeStores
GROUP BY order_year, order_month
ORDER BY order_year

-- (3) Total Revenue per Store (in percentage)
SELECT store_name, CAST(COUNT(revenue) * 100.0 / SUM(COUNT(revenue)) over() as DECIMAL(18, 0)) as revenue_percentage
FROM BikeStores
GROUP BY store_name

-- (4) Total Revenue per Product Category
SELECT category_name, ROUND(SUM(revenue), 0) as total_revenue
FROM BikeStores
GROUP BY category_name
ORDER BY total_revenue DESC

-- (5) TOP 10 customers based on Revenue
SELECT TOP 10 customers, ROUND(SUM(revenue), 0) as total_revenue
FROM BikeStores
GROUP BY customers
ORDER BY total_revenue DESC

-- (6) Revenue per Sales Rep
SELECT sales_rep, ROUND(SUM(revenue), 0) as total_revenue
FROM BikeStores
GROUP BY sales_rep
ORDER BY total_revenue DESC