/********************* 
DATA EXPLORATION PART 3: 

////////////////////////
Film and Film_category Tables
**********************/

-- I. FOREIGN KEY DISTRINUTION & INSPECTING THE HYPOTHESES
-- H1:There should be 1-to-1 relationship for film_id and the rows of the dvd_rentals.film_category table
WITH base_counts AS (
SELECT
  film_id,
  COUNT(*) AS record_count
FROM dvd_rentals.film_category
GROUP BY film_id
)
SELECT
  record_count,
  COUNT(DISTINCT film_id) AS unique_film_id_values
FROM base_counts
GROUP BY record_count
ORDER BY record_count;

--Result:
+───────────────+────────────────────────+
| record_count  | unique_film_id_values  |
+───────────────+────────────────────────+
| 1             | 1000                   |
+───────────────+────────────────────────+


--> **FINDING**: VALID HYPOTHESIS (TRUE)


--H2: There should be 1-to-1 relationship for film_id and the rows of the dvd_rentals.film table 
WITH base_counts AS (
SELECT
  film_id,
  COUNT(*) AS record_count
FROM dvd_rentals.film
GROUP BY film_id
)
SELECT
  record_count,
  COUNT(DISTINCT film_id) AS unique_film_id_values
FROM base_counts
GROUP BY record_count
ORDER BY record_count;

--Result:
+───────────────+────────────────────────+
| record_count  | unique_film_id_values  |
+───────────────+────────────────────────+
| 1             | 1000                   |
+───────────────+────────────────────────+


--> **FINDING**: VALID HYPOTHESIS (TRUE)

-- II. UNIQUE FOREIGN KEYS 
-- film_category table to film table
SELECT 
  COUNT(DISTINCT film_category.film_id)
FROM dvd_rentals.film_category
WHERE NOT EXISTS (
  SELECT film_id
  FROM dvd_rentals.film
  WHERE film_category.film_id = film.film_id
);

--OR

SELECT 
  COUNT(DISTINCT film_category.film_id)
FROM dvd_rentals.film_category AS film_category
LEFT JOIN dvd_rentals.film AS film
ON film_category.film_id = film.film_id
WHERE film.film_id IS NULL;

--Result:
+────────+
| count  |
+────────+
| 0      |
+────────+

-- **FINDING**: There are no overlap foreign keys in the film_category table to the film table

-- film table to film_category table
SELECT 
  COUNT(DISTINCT film.film_id)
FROM dvd_rentals.film
WHERE NOT EXISTS (
  SELECT film_id
  FROM dvd_rentals.film_category
  WHERE film_category.film_id = film.film_id
);

--OR

SELECT 
  COUNT(DISTINCT film.film_id)
FROM dvd_rentals.film AS film
LEFT JOIN dvd_rentals.film_category AS film_category 
ON film_category.film_id = film.film_id
WHERE film_category.film_id IS NULL;

--Result:
+────────+
| count  |
+────────+
| 0      |
+────────+

--> **FINDING**: There are no overlap foreign keys in the film table to the film_category table.

--> There is no difference between an inner join or left join for these datasets
