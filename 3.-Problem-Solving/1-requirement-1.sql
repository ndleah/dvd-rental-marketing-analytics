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

--create Category Counts table (for customer 1 as an example)
DROP TABLE IF EXISTS category_counts;
CREATE TEMP TABLE category_counts AS
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
FROM category_counts
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
DROP TABLE IF EXISTS total_counts;
CREATE TEMP TABLE total_counts AS
SELECT
  customer_id,
  SUM(rental_count) AS total_rental_count
FROM category_counts
GROUP BY customer_id;
---- profile just first 5 customers sorted by ID as an illustration
SELECT *
FROM total_counts
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

--create Top Categories table
DROP TABLE IF EXISTS top_categories;
CREATE TEMP TABLE top_categories AS
WITH ranked_cte AS (
  SELECT
    customer_id,
    category_name,
    rental_count,
    DENSE_RANK() OVER (
    PARTITION BY customer_id
    ORDER BY 
      rental_count DESC,
      latest_rental_date DESC,
      category_name
    ) AS category_rank
  FROM category_counts
)
SELECT *
FROM ranked_cte
WHERE category_rank <= 2;
--inspect the first 3 customer_id
SELECT *
FROM top_categories
LIMIT 6;

/*Result:
|customer_id|category_name|rental_count|category_rank|
|-----------|-------------|------------|-------------|
|1          |Classics     |6           |1            |
|1          |Comedy       |5           |2            |
|2          |Sports       |5           |1            |
|2          |Classics     |4           |2            |
|3          |Action       |4           |1            |
|3          |Sci-Fi       |3           |2            |
*/
