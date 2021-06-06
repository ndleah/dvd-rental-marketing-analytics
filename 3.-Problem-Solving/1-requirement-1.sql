/********************* 
PROBLEM SOLVING:

////////////////////////
Requirement 1: Calculate on Top 2 Categories for each customer
**********************/

/* ///// Note /////: 
In order to properly run all the query in this data,
we will need the "complete_joint_dataset_with_rental_date"
as in previous stage.

If you are using this file from the start without
viewing the previous parts, I encourage you to first
run this following query to avoid running into error:

---- (this querycan also be found in the Data Joining 
phase of this project) ----

---> (**BEGINNING OF THE QUERY**)

DROP TABLE IF EXISTS complete_joint_dataset_with_rental_date;
CREATE TEMP TABLE complete_joint_dataset_with_rental_date AS
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  category.name AS category_name,
  rental.rental_date
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_category
  ON film.film_id = film_category.film_id
INNER JOIN dvd_rentals.category
  ON film_category.category_id = category.category_id;
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset_with_rental_date
GROUP BY 
  customer_id,
  category_name
ORDER BY
  customer_id,
  rental_count DESC,
  latest_rental_date DESC
LIMIT 10;

<--- (**THE END OF THE QUERY**) 
*/

--create Customer Rental Count table (for customer 1 as an example)
DROP TABLE IF EXISTS category_rental_counts;
CREATE TEMP TABLE category_rental_counts AS
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset_with_rental_date
GROUP BY
  customer_id,
  category_name;
--profile just customer_id = 1 values sorted by desc rental_count
SELECT *
FROM category_rental_counts
WHERE customer_id = 1
ORDER BY rental_count DESC;

/*Result:
|customer_id|category_name|rental_count|latest_rental_date      |
|-----------|-------------|------------|------------------------|
|1          |Classics     |6           |2005-08-19T09:55:16.000Z|
|1          |Comedy       |5           |2005-08-22T19:41:37.000Z|
|1          |Drama        |4           |2005-08-18T03:57:29.000Z|
|1          |Sci-Fi       |2           |2005-08-21T23:33:57.000Z|
|1          |Animation    |2           |2005-08-22T20:03:46.000Z|
|1          |Sports       |2           |2005-07-08T07:33:56.000Z|
|1          |Music        |2           |2005-07-09T16:38:01.000Z|
|1          |Action       |2           |2005-08-17T12:37:54.000Z|
|1          |New          |2           |2005-08-19T13:56:54.000Z|
|1          |Travel       |1           |2005-07-11T10:13:46.000Z|
|1          |Family       |1           |2005-08-02T18:01:38.000Z|
|1          |Documentary  |1           |2005-08-01T08:51:04.000Z|
|1          |Games        |1           |2005-07-08T03:17:05.000Z|
|1          |Foreign      |1           |2005-07-28T16:18:23.000Z|
*/

--create TOTAL Customer Rentals table
DROP TABLE IF EXISTS customer_total_rentals;
CREATE TEMP TABLE customer_total_rentals AS
SELECT
  customer_id,
  SUM(rental_count) AS total_rental_count
FROM category_rental_counts
GROUP BY customer_id;
---- profile just first 5 customers sorted by ID as an illustration
SELECT *
FROM customer_total_rentals
WHERE customer_id <= 5
ORDER BY customer_id;

/*Result:
|customer_id|sum      |
|-----------|---------|
|1          |32       |
|2          |27       |
|3          |26       |
|4          |22       |
|5          |38       |
*/

--create Average Category Rental Counts
DROP TABLE IF EXISTS average_category_rental_counts;
CREATE TEMP TABLE average_category_rental_counts AS
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS avg_rental_count
FROM category_rental_counts
GROUP BY category_name;

SELECT *
FROM average_category_rental_counts
ORDER BY category_name;

/* Result:
|category_name|avg_rental_count|
|-------------|----------------|
|Action       |2               |
|Animation    |2               |
|Children     |1               |
|Classics     |2               |
|Comedy       |1               |
|Documentary  |2               |
|Drama        |2               |
|Family       |2               |
|Foreign      |2               |
|Games        |2               |
|Horror       |1               |
|Music        |1               |
|New          |2               |
|Sci-Fi       |2               |
|Sports       |2               |
|Travel       |1               |


*/
--calculate the percentile values
DROP TABLE IF EXISTS customer_category_percentiles;
CREATE TEMP TABLE customer_category_percentiles AS
SELECT
  customer_id,
  category_name,
      CEILING(
      100 * PERCENT_RANK() OVER (
      PARTITION BY category_name
      ORDER BY rental_count DESC
      )
  ) AS percentile
FROM category_rental_counts;
--profile just customer_id = 1 values with the top 2 categories sorted as an result illustration
SELECT *
FROM customer_category_percentiles
WHERE customer_id = 1
ORDER BY percentile
LIMIT 2;

/*Result:
|customer_id|category_name|percentile|
|-----------|-------------|----------|
|1          |Classics     |1         |
|1          |Comedy       |1         |
*/

/*///////////////////////////////////

FINDING:
For customer 1: You’ve watched 6 Classics
films, that’s 4 more than the DVD Rental
Coaverage and puts you in the top 1% 
of Classics gurus!

///////////////////////////////////*/

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
FROM category_rental_counts AS t1
INNER JOIN customer_total_rentals AS t2
  ON t1.customer_id = t2.customer_id
INNER JOIN average_category_rental_counts AS t3
  ON t1.category_name = t3.category_name
INNER JOIN customer_category_percentiles AS t4
  ON t1.customer_id = t4.customer_id
  AND t1.category_name = t4.category_name;
  
--inspect customer = 1 rows sorted by percentile
SELECT *
FROM customer_category_joint_table
WHERE customer_id = 1
ORDER BY percentile
LIMIT 5;

/*Result:
|customer_id|category_name|rental_count|latest_rental_date|total_rental_count|avg_rental_count|percentile|average_comparison|category_percentage|
|-----------|-------------|------------|------------------|------------------|----------------|----------|------------------|-------------------|
|1          |Comedy       |5           |2005-08-22T19:41:37.000Z|32                |1               |1         |4                 |16                 |
|1          |Classics     |6           |2005-08-19T09:55:16.000Z|32                |2               |1         |4                 |19                 |
|1          |Drama        |4           |2005-08-18T03:57:29.000Z|32                |2               |3         |2                 |13                 |
|1          |Music        |2           |2005-07-09T16:38:01.000Z|32                |1               |21        |1                 |6                  |
|1          |New          |2           |2005-08-19T13:56:54.000Z|32                |2               |27        |0                 |6                  |
*/

--create top 2 category table
DROP TABLE IF EXISTS top_categories_information;
CREATE TEMP TABLE top_categories_information AS (
WITH ordered_customer_category_joint_table AS (
  SELECT
  customer_id,
  ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY 
      rental_count DESC,
      latest_rental_date DESC
    ) AS category_ranking,
    category_name,
    rental_count,
    average_comparison,
    percentile,
    category_percentage
  FROM customer_category_joint_table
  )
-- filter out top 2 rows from the CTE for final output  
SELECT *
FROM ordered_customer_category_joint_table
WHERE category_ranking <= 2
);

-- inspect the result for the first 3 customers
SELECT * FROM top_categories_information
WHERE customer_id IN (1, 2, 3)
ORDER BY 
  customer_id, 
  category_ranking;
  
/* Result:
|customer_id|category_ranking|category_name|rental_count|average_comparison|percentile|category_percentage|
|-----------|----------------|-------------|------------|------------------|----------|-------------------|
|1          |1               |Classics     |6           |4                 |1         |19                 |
|1          |2               |Comedy       |5           |4                 |1         |16                 |
|2          |1               |Sports       |5           |3                 |3         |19                 |
|2          |2               |Classics     |4           |2                 |2         |15                 |
|3          |1               |Action       |4           |2                 |5         |15                 |
|3          |2               |Sci-Fi       |3           |1                 |15        |12                 |
*/