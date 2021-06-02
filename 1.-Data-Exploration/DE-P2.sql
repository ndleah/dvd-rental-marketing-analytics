/********************* 
DATA EXPLORATION PART 2: 

////////////////////////
Inventory and Film Tables
**********************/

-- I. FOREIGN KEY DISTRINUTION & INSPECTING THE HYPOTHESES
-- H1:There be 1-to-many relationship for film_id and the rows of the dvd_rentals.inventory table as one specific film might have multiple copies to be purchased at the rental store 
WITH base_counts AS (
SELECT
  film_id,
  COUNT(*) AS record_count
FROM dvd_rentals.inventory
GROUP BY film_id
)
SELECT
  record_count,
  COUNT(DISTINCT film_id) AS unique_film_id_values
FROM base_counts
GROUP BY record_count
ORDER BY record_count;

/* Result:
|record_count|unique_film_id_values|
|------------|---------------------|
|2           |133                  |
|3           |131                  |
|4           |183                  |
|5           |136                  |
|6           |187                  |
|7           |116                  |
|8           |72                   |
*/

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

/* Result:
|record_count|unique_film_id_values|
|------------|---------------------|
|1           |1000                 |
*/

--> **FINDING**: VALID HYPOTHESIS (TRUE)

-- II. UNIQUE FOREIGN KEYS 
-- inventory table to film table
SELECT 
  COUNT(DISTINCT inventory.film_id)
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT film_id
  FROM dvd_rentals.film
  WHERE inventory.film_id = film.film_id
);

--OR

SELECT 
  COUNT(DISTINCT inventory.film_id)
FROM dvd_rentals.inventory AS inventory
LEFT JOIN dvd_rentals.film AS film
ON inventory.film_id = film.film_id
WHERE film.film_id IS NULL;

/*Result:
|count|
|-----|
|0    |
*/  

-- **FINDING**: There are no overlap foreign keys in the inventory table to the film table

-- film table to inventory table
SELECT 
  COUNT(DISTINCT film.film_id)
FROM dvd_rentals.film
WHERE NOT EXISTS (
  SELECT film_id
  FROM dvd_rentals.inventory
  WHERE inventory.film_id = film.film_id
);

--OR

SELECT 
  COUNT(DISTINCT film.film_id)
FROM dvd_rentals.film AS film
LEFT JOIN dvd_rentals.inventory AS inventory 
ON inventory.film_id = film.film_id
WHERE inventory.film_id IS NULL;

/*Result:
|count|
|-----|
|42   |
*/  

--> **FINDING**: There were 42 foreign keys which exist in the dvd_rentals.film table than in the dvd_rentals.inventory table.


-- Perfom a LEFT SEMI JOIN with WHERE EXIST function to get the count of unique foreign key values:
SELECT
  COUNT(DISTINCT film_id)
FROM dvd_rentals.inventory
WHERE EXISTS (
  SELECT film_id
  FROM dvd_rentals.film
  WHERE film.film_id = inventory.film_id
);
/*Result:
|count|
|-----|
|958  |
*/  


--> **FINDING**: We will be expecting a total distinct count of film_id values of 958 once we perform the final join between our 2 tables.

-- IV. IMPLEMENT THE JOIN(S)

DROP TABLE IF EXISTS left_join_part_2;
CREATE TEMP TABLE left_join_part_2 AS
SELECT
  inventory.inventory_id,
  inventory.film_id,
  film.title
FROM dvd_rentals.inventory
LEFT JOIN dvd_rentals.film
  ON film.film_id = inventory.film_id;

DROP TABLE IF EXISTS inner_join_part_2;
CREATE TEMP TABLE inner_join_part_2 AS
SELECT
  inventory.inventory_id,
  inventory.film_id,
  film.title
FROM dvd_rentals.inventory
LEFT JOIN dvd_rentals.film
  ON film.film_id = inventory.film_id;

-- check the counts for each output (bonus UNION usage)
-- note that these parantheses are not really required but it makes
-- the code look and read a bit nicer!
(
  SELECT
    'left join' AS join_type,
    COUNT(*) AS record_count,
    COUNT(DISTINCT film_id) AS unique_key_values
  FROM left_join_part_2
)
UNION
(
  SELECT
    'inner join' AS join_type,
    COUNT(*) AS record_count,
    COUNT(DISTINCT film_id) AS unique_key_values
  FROM inner_join_part_2
);

/* Result:
|join_type|record_count|unique_key_values|
|---------|------------|-----------------|
|inner join|4581       |958             |
|left join|4581       |958             |
*/

-- **FINDING**: There is no difference between an inner join or left join for these datasets