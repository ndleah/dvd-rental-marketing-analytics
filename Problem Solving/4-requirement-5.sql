/********************* 
PROBLEM SOLVING:

////////////////////////
Requirement 5: Actor Insights
**********************/
--create actor joint dataset
DROP TABLE IF EXISTS actor_joint_dataset;
CREATE TEMP TABLE actor_joint_dataset AS
SELECT
  rental.customer_id,
  rental.rental_id,
  rental.rental_date,
  film.film_id,
  film.title,
  actor.actor_id,
  actor.first_name,
  actor.last_name
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_actor
  ON film.film_id = film_actor.film_id
INNER JOIN dvd_rentals.actor
  ON film_actor.actor_id = actor.actor_id;

SELECT *
FROM actor_joint_dataset
LIMIT 10;

--Result:
+──────────────+────────────+───────────────────────────+──────────+──────────────────+───────────+─────────────+────────────+
| customer_id  | rental_id  | rental_date               | film_id  | title            | actor_id  | first_name  | last_name  |
+──────────────+────────────+───────────────────────────+──────────+──────────────────+───────────+─────────────+────────────+
| 130          | 1          | 2005-05-24T22:53:30.000Z  | 80       | BLANKET BEVERLY  | 200       | THORA       | TEMPLE     |
| 130          | 1          | 2005-05-24T22:53:30.000Z  | 80       | BLANKET BEVERLY  | 193       | BURT        | TEMPLE     |
| 130          | 1          | 2005-05-24T22:53:30.000Z  | 80       | BLANKET BEVERLY  | 173       | ALAN        | DREYFUSS   |
| 130          | 1          | 2005-05-24T22:53:30.000Z  | 80       | BLANKET BEVERLY  | 16        | FRED        | COSTNER    |
| 459          | 2          | 2005-05-24T22:54:33.000Z  | 333      | FREAKY POCUS     | 147       | FAY         | WINSLET    |
| 459          | 2          | 2005-05-24T22:54:33.000Z  | 333      | FREAKY POCUS     | 127       | KEVIN       | GARLAND    |
| 459          | 2          | 2005-05-24T22:54:33.000Z  | 333      | FREAKY POCUS     | 105       | SIDNEY      | CROWE      |
| 459          | 2          | 2005-05-24T22:54:33.000Z  | 333      | FREAKY POCUS     | 103       | MATTHEW     | LEIGH      |
| 459          | 2          | 2005-05-24T22:54:33.000Z  | 333      | FREAKY POCUS     | 42        | TOM         | MIRANDA    |
| 408          | 3          | 2005-05-24T23:03:39.000Z  | 373      | GRADUATE LORD    | 140       | WHOOPI      | HURT       |
+──────────────+────────────+───────────────────────────+──────────+──────────────────+───────────+─────────────+────────────+

--create Top Actor Counts table
DROP TABLE IF EXISTS top_actor_counts;
CREATE TEMP TABLE top_actor_counts AS
WITH actor_counts AS (
  SELECT
    customer_id,
    actor_id,
    first_name,
    last_name,
    COUNT(*) AS rental_count,
    MAX(rental_date) as latest_rental_date
  FROM actor_joint_dataset
  GROUP BY 
    customer_id,
    actor_id,
    first_name,
    last_name
),
ranked_actor_counts AS (
  SELECT
  actor_counts.*,
  DENSE_RANK() OVER (
    PARTITION BY customer_id
    ORDER BY
      rental_count DESC,
      latest_rental_date DESC,
      first_name,
      last_name
    ) AS actor_rank
  FROM actor_counts
)
SELECT 
  customer_id,
  actor_id,
  first_name,
  last_name,
  rental_count
FROM ranked_actor_counts
WHERE actor_rank = 1;

SELECT *
FROM top_actor_counts
LIMIT 10;

--Result:
+──────────────+───────────+─────────────+────────────+───────────────+
| customer_id  | actor_id  | first_name  | last_name  | rental_count  |
+──────────────+───────────+─────────────+────────────+───────────────+
| 1            | 37        | VAL         | BOLGER     | 6             |
| 2            | 107       | GINA        | DEGENERES  | 5             |
| 3            | 150       | JAYNE       | NOLTE      | 4             |
| 4            | 102       | WALTER      | TORN       | 4             |
| 5            | 12        | KARL        | BERRY      | 4             |
| 6            | 191       | GREGORY     | GOODING    | 4             |
| 7            | 65        | ANGELA      | HUDSON     | 5             |
| 8            | 167       | LAURENCE    | BULLOCK    | 5             |
| 9            | 23        | SANDRA      | KILMER     | 3             |
| 10           | 12        | KARL        | BERRY      | 4             |
+──────────────+───────────+─────────────+────────────+───────────────+

--create Top Actor Film Counts table
DROP TABLE IF EXISTS actor_film_counts;
CREATE TEMP TABLE actor_film_counts AS
WITH film_counts AS (
  SELECT
    film_id,
    COUNT(DISTINCT rental_id) AS rental_count
  FROM actor_joint_dataset
  GROUP BY film_id
)
SELECT DISTINCT
  actor_joint_dataset.film_id,
  actor_joint_dataset.actor_id,
  actor_joint_dataset.title,
  film_counts.rental_count
FROM actor_joint_dataset
LEFT JOIN film_counts
  on actor_joint_dataset.film_id = film_counts.film_id;
  
SELECT *
FROM actor_film_counts
LIMIT 10;

--Result:
+──────────+───────────+───────────────────+───────────────+
| film_id  | actor_id  | title             | rental_count  |
+──────────+───────────+───────────────────+───────────────+
| 1        | 1         | ACADEMY DINOSAUR  | 23            |
| 1        | 10        | ACADEMY DINOSAUR  | 23            |
| 1        | 20        | ACADEMY DINOSAUR  | 23            |
| 1        | 30        | ACADEMY DINOSAUR  | 23            |
| 1        | 40        | ACADEMY DINOSAUR  | 23            |
| 1        | 53        | ACADEMY DINOSAUR  | 23            |
| 1        | 108       | ACADEMY DINOSAUR  | 23            |
| 1        | 162       | ACADEMY DINOSAUR  | 23            |
| 1        | 188       | ACADEMY DINOSAUR  | 23            |
| 1        | 198       | ACADEMY DINOSAUR  | 23            |
+──────────+───────────+───────────────────+───────────────+

--create Actor Film Exclusions table
DROP TABLE IF EXISTS actor_film_exclusions;
CREATE TEMP TABLE actor_film_exclusions AS
(
  SELECT DISTINCT
    customer_id,
    film_id
  FROM complete_joint_dataset_with_rental_date
)
UNION
(
  SELECT DISTINCT
    customer_id,
    film_id
  FROM top_category_recommendations
)
;

SELECT *
FROM category_film_exclusions
LIMIT 10;

--Result:
+──────────────+──────────+
| customer_id  | film_id  |
+──────────────+──────────+
| 493          | 567      |
| 114          | 789      |
| 596          | 103      |
| 176          | 121      |
| 459          | 724      |
| 375          | 641      |
| 153          | 730      |
| 291          | 285      |
| 1            | 480      |
| 144          | 93       |
+──────────────+──────────+

--Final Actor Recommendations
DROP TABLE IF EXISTS actor_recommendations;
CREATE TEMP TABLE actor_recommendations AS
WITH ranked_actor_films_cte AS (
  SELECT
    top_actor_counts.customer_id,
    top_actor_counts.first_name,
    top_actor_counts.last_name,
    top_actor_counts.rental_count,
    actor_film_counts.title,
    actor_film_counts.film_id,
    actor_film_counts.actor_id,
    DENSE_RANK() OVER (
    PARTITION BY 
      top_actor_counts.customer_id
    ORDER BY
      actor_film_counts.rental_count DESC,
      actor_film_counts.title
    ) AS reco_rank
  FROM top_actor_counts
  INNER JOIN actor_film_counts
    ON top_actor_counts.actor_id = actor_film_counts.actor_id
  WHERE NOT EXISTS (
    SELECT customer_id
    FROM actor_film_exclusions
    WHERE
      actor_film_exclusions.customer_id = top_actor_counts.customer_id
      AND
      actor_film_exclusions.film_id = actor_film_counts.film_id
  )
)
SELECT *
FROM ranked_actor_films_cte
WHERE reco_rank <= 3;

SELECT *
FROM actor_recommendations
ORDER BY 
  customer_id, 
  reco_rank
LIMIT 15;

--Result:
+──────────────+─────────────+────────────+───────────────+─────────────────────────+──────────+───────────+────────────+
| customer_id  | first_name  | last_name  | rental_count  | title                   | film_id  | actor_id  | reco_rank  |
+──────────────+─────────────+────────────+───────────────+─────────────────────────+──────────+───────────+────────────+
| 1            | VAL         | BOLGER     | 6             | PRIMARY GLASS           | 697      | 37        | 1          |
| 1            | VAL         | BOLGER     | 6             | ALASKA PHANTOM          | 12       | 37        | 2          |
| 1            | VAL         | BOLGER     | 6             | METROPOLIS COMA         | 572      | 37        | 3          |
| 2            | GINA        | DEGENERES  | 5             | GOODFELLAS SALUTE       | 369      | 107       | 1          |
| 2            | GINA        | DEGENERES  | 5             | WIFE TURN               | 973      | 107       | 2          |
| 2            | GINA        | DEGENERES  | 5             | DOGMA FAMILY            | 239      | 107       | 3          |
| 3            | JAYNE       | NOLTE      | 4             | SWEETHEARTS SUSPECTS    | 873      | 150       | 1          |
| 3            | JAYNE       | NOLTE      | 4             | DANCING FEVER           | 206      | 150       | 2          |
| 3            | JAYNE       | NOLTE      | 4             | INVASION CYCLONE        | 468      | 150       | 3          |
| 4            | WALTER      | TORN       | 4             | CURTAIN VIDEOTAPE       | 200      | 102       | 1          |
| 4            | WALTER      | TORN       | 4             | LIES TREATMENT          | 521      | 102       | 2          |
| 4            | WALTER      | TORN       | 4             | NIGHTMARE CHILL         | 624      | 102       | 3          |
| 5            | KARL        | BERRY      | 4             | VIRGINIAN PLUTO         | 945      | 12        | 1          |
| 5            | KARL        | BERRY      | 4             | STAGECOACH ARMAGEDDON   | 838      | 12        | 2          |
| 5            | KARL        | BERRY      | 4             | TELEMARK HEARTBREAKERS  | 880      | 12        | 3          |
+──────────────+─────────────+────────────+───────────────+─────────────────────────+──────────+───────────+────────────+
