/********************* 
PROBLEM SOLVING:

////////////////////////
Requirement 3 + 4: 1st + 2nd Category Insights
**********************/

--create Average Category Rental Counts
DROP TABLE IF EXISTS average_category_count;
CREATE TEMP TABLE average_category_count AS
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS avg_rental_count
FROM category_counts
GROUP BY category_name;

SELECT *
FROM average_category_count
ORDER BY category_name;

--Result:
+────────────────+───────────────────+
| category_name  | avg_rental_count  |
+────────────────+───────────────────+
| Action         | 2                 |
| Animation      | 2                 |
| Children       | 1                 |
| Classics       | 2                 |
| Comedy         | 1                 |
| Documentary    | 2                 |
| Drama          | 2                 |
| Family         | 2                 |
| Foreign        | 2                 |
| Games          | 2                 |
| Horror         | 1                 |
| Music          | 1                 |
| New            | 2                 |
| Sci-Fi         | 2                 |
| Sports         | 2                 |
| Travel         | 1                 |
+────────────────+───────────────────+

--calculate the percentile values
DROP TABLE IF EXISTS top_category_percentile;
CREATE TEMP TABLE top_category_percentile AS
WITH calculated_cte AS (
SELECT
  top_categories.customer_id,
  top_categories.category_name AS top_category_name,
  top_categories.rental_count,
  category_counts.category_name,
  top_categories.category_rank,
     PERCENT_RANK() OVER (
      PARTITION BY category_counts.category_name
      ORDER BY category_counts.rental_count DESC
  ) AS raw_percentile_value
FROM category_counts
LEFT JOIN top_categories
  ON category_counts.customer_id = top_categories.customer_id
)
SELECT 
  customer_id,
  category_name,
  rental_count,
  category_rank,
  CASE
    WHEN ROUND(100 * raw_percentile_value) = 0 THEN 1
    ELSE ROUND(100 * raw_percentile_value)
  END AS percentile
FROM calculated_cte
WHERE
  top_category_name = category_name;
  
SELECT *
FROM top_category_percentile
ORDER BY 
  customer_id,
  category_rank
LIMIT 10;

--Result:
+──────────────+────────────────+───────────────+────────────────+─────────────+
| customer_id  | category_name  | rental_count  | category_rank  | percentile  |
+──────────────+────────────────+───────────────+────────────────+─────────────+
| 1            | Classics       | 6             | 1              | 1           |
| 1            | Comedy         | 5             | 2              | 1           |
| 2            | Sports         | 5             | 1              | 2           |
| 2            | Classics       | 4             | 2              | 2           |
| 3            | Action         | 4             | 1              | 4           |
| 3            | Sci-Fi         | 3             | 2              | 15          |
| 4            | Horror         | 3             | 1              | 8           |
| 4            | Drama          | 2             | 2              | 32          |
| 5            | Classics       | 7             | 1              | 1           |
| 5            | Animation      | 6             | 2              | 1           |
+──────────────+────────────────+───────────────+────────────────+─────────────+

--Joining our temporary tables
DROP TABLE IF EXISTS customer_category_joint_table;
CREATE TEMP TABLE customer_category_joint_table AS
SELECT
  t1.customer_id,
  t1.category_name,
  t1.rental_count,
  t1.latest_rental_date,
  t2.total_rental_count,
  t3.avg_rental_count,
  t4.percentile,
  t1.rental_count - t3.avg_rental_count AS average_comparison,
  ROUND(100 * t1.rental_count / t2.total_rental_count) AS category_percentage
FROM category_counts AS t1
INNER JOIN total_counts AS t2
  ON t1.customer_id = t2.customer_id
INNER JOIN average_category_count AS t3
  ON t1.category_name = t3.category_name
INNER JOIN top_category_percentile AS t4
  ON t1.customer_id = t4.customer_id
  AND t1.category_name = t4.category_name;
  
--inspect customer = 1 rows sorted by percentile
SELECT *
FROM customer_category_joint_table
WHERE customer_id = 1
ORDER BY percentile
LIMIT 5;

--Result:
+──────────────+────────────────+───────────────+───────────────────────────+─────────────────────+───────────────────+─────────────+─────────────────────+──────────────────────+
| customer_id  | category_name  | rental_count  | latest_rental_date        | total_rental_count  | avg_rental_count  | percentile  | average_comparison  | category_percentage  |
+──────────────+────────────────+───────────────+───────────────────────────+─────────────────────+───────────────────+─────────────+─────────────────────+──────────────────────+
| 1            | Comedy         | 5             | 2005-08-22T19:41:37.000Z  | 32                  | 1                 | 1           | 4                   | 16                   |
| 1            | Classics       | 6             | 2005-08-19T09:55:16.000Z  | 32                  | 2                 | 1           | 4                   | 19                   |
+──────────────+────────────────+───────────────+───────────────────────────+─────────────────────+───────────────────+─────────────+─────────────────────+──────────────────────+

--create top 2 category insights table
DROP TABLE IF EXISTS top_category_insights;
CREATE TEMP TABLE top_category_insights AS (
WITH ranked_cte AS (
  SELECT
  customer_id,
  ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY 
      rental_count DESC,
      latest_rental_date DESC
    ) AS category_rank,
    category_name,
    rental_count,
    average_comparison,
    percentile,
    category_percentage
  FROM customer_category_joint_table
  )
SELECT *
FROM ranked_cte
WHERE category_rank <= 2
);

-- inspect the result for the first 3 customers
SELECT * 
FROM top_category_insights
ORDER BY 
  customer_id,
  category_rank,
  percentile
LIMIT 10;

--Result:
+──────────────+────────────────+────────────────+───────────────+─────────────────────+─────────────+──────────────────────+
| customer_id  | category_rank  | category_name  | rental_count  | average_comparison  | percentile  | category_percentage  |
+──────────────+────────────────+────────────────+───────────────+─────────────────────+─────────────+──────────────────────+
| 1            | 1              | Classics       | 6             | 4                   | 1           | 19                   |
| 1            | 2              | Comedy         | 5             | 4                   | 1           | 16                   |
| 2            | 1              | Sports         | 5             | 3                   | 2           | 19                   |
| 2            | 2              | Classics       | 4             | 2                   | 2           | 15                   |
| 3            | 1              | Action         | 4             | 2                   | 4           | 15                   |
| 3            | 2              | Sci-Fi         | 3             | 1                   | 15          | 12                   |
| 4            | 1              | Horror         | 3             | 2                   | 8           | 14                   |
| 4            | 2              | Drama          | 2             | 0                   | 32          | 9                    |
| 5            | 1              | Classics       | 7             | 5                   | 1           | 18                   |
| 5            | 2              | Animation      | 6             | 4                   | 1           | 16                   |
+──────────────+────────────────+────────────────+───────────────+─────────────────────+─────────────+──────────────────────+

--1st Category Insights
DROP TABLE IF EXISTS first_category_insights;
CREATE TEMP TABLE first_category_insights AS
SELECT
  customer_id,
  category_name,
  rental_count,
  average_comparison,
  percentile
FROM top_category_insights
WHERE category_rank = 1;

SELECT *
FROM first_category_insights
ORDER BY customer_id
LIMIT 10;

--Result:
+──────────────+────────────────+───────────────+─────────────────────+─────────────+
| customer_id  | category_name  | rental_count  | average_comparison  | percentile  |
+──────────────+────────────────+───────────────+─────────────────────+─────────────+
| 1            | Classics       | 6             | 4                   | 1           |
| 2            | Sports         | 5             | 3                   | 2           |
| 3            | Action         | 4             | 2                   | 4           |
| 4            | Horror         | 3             | 2                   | 8           |
| 5            | Classics       | 7             | 5                   | 1           |
| 6            | Drama          | 4             | 2                   | 3           |
| 7            | Sports         | 5             | 3                   | 2           |
| 8            | Classics       | 4             | 2                   | 2           |
| 9            | Foreign        | 4             | 2                   | 6           |
| 10           | Documentary    | 4             | 2                   | 5           |
+──────────────+────────────────+───────────────+─────────────────────+─────────────+

/*///////////////////////////////////

FINDING:
For customer 1: You’ve watched 6 Classics
films, that’s 4 more than the DVD Rental
Coaverage and puts you in the top 1% 
of Classics gurus!

///////////////////////////////////*/

--2nd Category Insights
DROP TABLE IF EXISTS second_category_insights;
CREATE TEMP TABLE second_category_insights AS
SELECT
  customer_id,
  category_name,
  rental_count,
  category_percentage
FROM top_category_insights
WHERE category_rank = 2;

SELECT *
FROM second_category_insights
ORDER BY customer_id
LIMIT 10;

--Result:
+──────────────+────────────────+───────────────+──────────────────────+
| customer_id  | category_name  | rental_count  | category_percentage  |
+──────────────+────────────────+───────────────+──────────────────────+
| 1            | Comedy         | 5             | 16                   |
| 2            | Classics       | 4             | 15                   |
| 3            | Sci-Fi         | 3             | 12                   |
| 4            | Drama          | 2             | 9                    |
| 5            | Animation      | 6             | 16                   |
| 6            | Sci-Fi         | 3             | 11                   |
| 7            | Animation      | 5             | 15                   |
| 8            | Drama          | 4             | 17                   |
| 9            | Travel         | 4             | 17                   |
| 10           | Games          | 4             | 16                   |
+──────────────+────────────────+───────────────+──────────────────────+

/*///////////////////////////////////

FINDING:
For customer 1: You’ve watched 5 Classics
films, making up 16% of your entiring viewing history!

///////////////////////////////////*/