/********************* 
DATA JOINING: 
**********************/

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