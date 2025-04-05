SELECT * FROM walmart_db;

SELECT COUNT(*) FROM walmart_db;

SELECT DISTINCT payment_method
FROM walmart_db;

SELECT payment_method, COUNT(*) AS total_count
FROM walmart_db
GROUP BY 1;

SELECT * FROM walmart_db;

SELECT Branch FROM walmart_db;

DROP TABLE walmart_db;

SELECT DISTINCT branch 
FROM walmart_db;

SELECT MAX(quantity) FROM walmart_db;

SELECT MIN(quantity) FROM walmart_db;
-----------------------------------------------------------------------------------------------------------------
--Q.1 Find the different payment method and number of transactions, number of quantity sold.

SELECT * FROM walmart_db;

SELECT payment_method,
       COUNT(*) AS total_transaction,
	   ROUND(SUM(quantity)::numeric,0) AS total_quantity_sold
FROM walmart_db
GROUP BY 1;
--------------------------------------------------------------------------------------------------------------------

--Q 2 Identify the highest rated category in each branch, displaying the branch, category, average rating.

SELECT * FROM walmart_db;

SELECT * 
FROM
(
SELECT branch,
       category,
	   AVG(rating) AS avg_rating,
	   RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart_db
GROUP BY 1,2
)
WHERE rank = 1;
------------------------------------------------------------------------------------------------------------------

--Q 3 Identify the busiest day for each branch based on the number of transactions.

SELECT
    date,
	TO_DATE(date,'DD/MM/YY') AS formated_date
FROM walmart_db;
-----------------

SELECT
    date,
	TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS day_name
FROM walmart_db;
----------------

SELECT *
FROM
(SELECT
    branch,
	TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS day_name,
	COUNT(*) AS total_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart_db
GROUP BY 1,2)
WHERE rank=1;
-----------------------------------------------------------------------------------------------------------------

--Q 4 Calculate the total quantity of items sold per payment method. List payment_method and total quantity.

SELECT * FROM walmart_db;

SELECT 
    payment_method,
	SUM(quantity) AS total_quantity
FROM walmart_db
GROUP BY 1
ORDER BY 2 DESC;
-------------------------------------------------------------------------------------------------------------------

--Q 5 Determine the average, minimum, and maximum rating of category for each city.
------List the city, average rating, min rating, and max rating.

SELECT * FROM walmart_db;

SELECT 
    city,
	category,
	AVG(rating) AS avg_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM walmart_db
GROUP BY 1,2;
----------------------------------------------------------------------------------------------------------------------

--Q 6 Calculate the total profit for each category by considering total_profit as (unit_price*quantity*profit_margin).
------List category and total_profit, ordered from highest to lowest profit.

SELECT * FROM walmart_db;

SELECT 
    category,
	ROUND(SUM(total_revenue)::numeric,0) AS total_revenue,
	ROUND(SUM(total_revenue*profit_margin)::numeric,0) AS total_profit
FROM walmart_db
GROUP BY 1
ORDER BY 3 DESC;
-------------------------------------------------------------------------------------------------------------------

--Q 7 Determine the most common payment method for each branch. Display branch and the preffered payment method.

SELECT * FROM walmart_db;

SELECT *
FROM
(SELECT 
     branch,
	 payment_method,
	 COUNT(*) AS total_transaction,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart_db
GROUP BY 1,2)
WHERE rank=1;
------------------OR------------------
--it is same when use cte

WITH cte
AS
(SELECT 
     branch,
	 payment_method,
	 COUNT(*) AS total_transaction,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart_db
GROUP BY 1,2)
SELECT * FROM cte
WHERE rank=1;
------------------------------------------------------------------------------------------------------------------

--Q 8 Categorize sales into 3 group Morning, Afternoon, Evening. Find out which of the shift and the number of invoices.
--first convert text to time format
SELECT * FROM walmart_db;

SELECT *,
       time::time
FROM walmart_db;
-----------------------

SELECT *,
       CASE
	       WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
		   WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		   ELSE 'Evening'
		END AS shift
FROM walmart_db;
------------------------

SELECT
       CASE
	       WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
		   WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		   ELSE 'Evening'
		END AS shift,
		COUNT(*) AS total_sales
FROM walmart_db
GROUP BY 1;
---------------------------------------------------------------------------------------------------------------------

--Q 9 Identify 5 branch with highest decrease ratio in revenue compare to last year(current year 2023 and last year 2022).
SELECT *,
       TO_DATE(date, 'DD/MM/YY') AS formated_date
FROM walmart_db;
------------------

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart_db;

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total_revenue) as revenue
	FROM walmart_db
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total_revenue) as revenue
	FROM walmart_db
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,      --ls=last year sale, cs=current year sale
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;






































