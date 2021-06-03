/********************* 
DATA JOINING: 
**********************/
--I. JOINING TABLES
--create complete joint dataset
DROP TABLE IF EXISTS complete_joint_dataset;
CREATE TEMP TABLE complete_joint_dataset AS
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  film_category.category_id,
  category.name AS category_name
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_category
  ON film.film_id = film_category.film_id
INNER JOIN dvd_rentals.category
  ON film_category.category_id = category.category_id;

SELECT * FROM complete_joint_dataset limit 10;

/*Result:
|customer_id|film_id|title          |category_id|category_name|
|-----------|-------|---------------|-----------|-------------|
|130        |80     |BLANKET BEVERLY|8          |Family       |
|459        |333    |FREAKY POCUS   |12         |Music        |
|408        |373    |GRADUATE LORD  |3          |Children     |
|333        |535    |LOVE SUICIDES  |11         |Horror       |
|222        |450    |IDOLS SNATCHERS|3          |Children     |
|549        |613    |MYSTIC TRUMAN  |5          |Comedy       |
|269        |870    |SWARM GOLD     |11         |Horror       |
|239        |510    |LAWLESS VISION |2          |Animation    |
|126        |565    |MATRIX SNOWMAN |9          |Foreign      |
|399        |396    |HANGING DEEP   |7          |Drama        |
*/


--II. DEALING WITH TIES 
--create complete joint dataset with additional "rental_date" column
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
  ON film_category.category_id = category.category_id

--perform group by aggregations on category_name and customer_id
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

 /*Result: 
|customer_id|category_name|rental_count|latest_rental_date      |
|-----------|-------------|------------|------------------------|
|1          |Classics     |6           |2005-08-19T09:55:16.000Z|
|1          |Comedy       |5           |2005-08-22T19:41:37.000Z|
|1          |Drama        |4           |2005-08-18T03:57:29.000Z|
|1          |Animation    |2           |2005-08-22T20:03:46.000Z|
|1          |Sci-Fi       |2           |2005-08-21T23:33:57.000Z|
|1          |New          |2           |2005-08-19T13:56:54.000Z|
|1          |Action       |2           |2005-08-17T12:37:54.000Z|
|1          |Music        |2           |2005-07-09T16:38:01.000Z|
|1          |Sports       |2           |2005-07-08T07:33:56.000Z|
|1          |Family       |1           |2005-08-02T18:01:38.000Z|
 */