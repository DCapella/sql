-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
--
-- SELECT t3.name AS name, t2.region AS region, t2.total_usd AS total_usd
-- FROM (SELECT region, MAX(total_usd) AS total_usd
--   FROM (SELECT s.name AS name, r.name AS region, SUM(o.total_amt_usd) AS total_usd
--     FROM sales_reps AS s
--     JOIN region AS r
--     ON r.id = s.region_id
--     JOIN accounts AS a
--     ON a.sales_rep_id = s.id
--     JOIN orders AS o
--     ON o.account_id = a.id
--     GROUP BY 1,2) AS t1
--   GROUP BY 1) AS t2
-- JOIN (SELECT s.name AS name, SUM(o.total_amt_usd) AS total_usd
--   FROM sales_reps AS s
--   JOIN accounts AS a
--   ON a.sales_rep_id = s.id
--   JOIN orders AS o
--   ON o.account_id = a.id
--   GROUP BY 1) AS t3
-- ON t3.total_usd = t2.total_usd

WITH t1 AS (
  SELECT s.name AS name, r.name AS region, SUM(o.total_amt_usd) AS total_usd
  FROM sales_reps AS s
  JOIN region AS r
  ON r.id = s.region_id
  JOIN accounts AS a
  ON a.sales_rep_id = s.id
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1,2),
t2 AS (
  SELECT region, MAX(total_usd) AS total_usd
  FROM t1
  GROUP BY 1),
t3 AS (
  SELECT s.name AS name, SUM(o.total_amt_usd) AS total_usd
  FROM sales_reps AS s
  JOIN accounts AS a
  ON a.sales_rep_id = s.id
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1
)

SELECT t3.name AS name, t2.region AS region, t2.total_usd AS total_usd
FROM t2
JOIN t3
ON t3.total_usd = t2.total_usd
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
=============================================================================
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

-- For the region with the largest sales total_amt_usd, how many total orders were placed?
--
-- SELECT *
-- FROM (SELECT r.name AS region, COUNT(*) AS total_orders
--   FROM region AS r
--   JOIN sales_reps AS s
--   ON s.region_id = r.id
--   JOIN accounts AS a
--   ON a.sales_rep_id = s.id
--   JOIN orders AS o
--   ON o.account_id = a.id
--   GROUP BY 1) AS t1
-- JOIN (SELECT r.name AS region, SUM(o.total_amt_usd) AS total_usd
--   FROM region AS r
--   JOIN sales_reps AS s
--   ON s.region_id = r.id
--   JOIN accounts AS a
--   ON a.sales_rep_id = s.id
--   JOIN orders AS o
--   ON o.account_id = a.id
--   GROUP BY 1
--   ORDER BY 2 DESC
--   LIMIT 1) AS t2
-- ON t1.region = t2.region


WITH t1 AS (
  SELECT r.name AS region, COUNT(*) AS total_orders
  FROM region AS r
  JOIN sales_reps AS s
  ON s.region_id = r.id
  JOIN accounts AS a
  ON a.sales_rep_id = s.id
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1),
t2 AS (
  SELECT r.name AS region, SUM(o.total_amt_usd) AS total_usd
  FROM region AS r
  JOIN sales_reps AS s
  ON s.region_id = r.id
  JOIN accounts AS a
  ON a.sales_rep_id = s.id
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1
)

SELECT *
FROM t1
JOIN t2
ON t1.region = t2.region

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
=============================================================================
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- For the name of the account that purchased the most (in total over their lifetime as a customer)
-- standard_qty paper, how many accounts still had more in total purchases?
--
SELECT COUNT(*)
FROM (SELECT a.name AS name, SUM(o.total) AS total_amt
  FROM accounts AS a
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT MAX(total_amt)
    FROM (SELECT a.name AS name, SUM(o.standard_qty) AS total_standard, SUM(o.total) AS total_amt
      FROM accounts AS a
      JOIN orders AS o
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1) AS t1)) AS t2

WITH t1 AS (
  SELECT a.name AS name, SUM(o.standard_qty) AS total_standard, SUM(o.total) AS total_amt
  FROM accounts AS a
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1),
t2 AS (
  SELECT a.name AS name, SUM(o.total) AS total_amt
  FROM accounts AS a
  JOIN orders AS o
  ON o.account_id = a.id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT MAX(total_amt)
    FROM t1))

SELECT COUNT(*)
FROM t2


–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
=============================================================================
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
--
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
=============================================================================
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
--
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
=============================================================================
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- What is the lifetime average amount spent in terms of total_amt_usd for only the companies that spent more than the average of all accounts.
