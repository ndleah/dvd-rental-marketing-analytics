/********************* 
DATA EXPLORATION PART 4: 

////////////////////////
Film_category and Category Tables
**********************/

-- I. FOREIGN KEY DISTRINUTION & INSPECTING THE HYPOTHESES
-- H1:There should be 1-to-many relationship for film_id and the rows of the dvd_rentals.film_category table
WITH base_counts AS (
SELECT
  category_id,
  COUNT(*) AS record_count
FROM dvd_rentals.film_category
GROUP BY category_id
)
SELECT
  record_count,
  COUNT(DISTINCT category_id) AS unique_category_id_values
FROM base_counts
GROUP BY record_count
ORDER BY record_count;

/* Result:
|record_count|unique_category_id_values|
|------------|-------------------------|
|51          |1                        |
|56          |1                        |
|57          |2                        |
|58          |1                        |
|60          |1                        |
|61          |2                        |
|62          |1                        |
|63          |1                        |
|64          |1                        |
|66          |1                        |
|68          |1                        |
|69          |1                        |
|73          |1                        |
|74          |1                        |

*/

--> **FINDING**: VALID HYPOTHESIS (TRUE)


--H2: There should be 1-to-1 relationship for film_id and the rows of the dvd_rentals.film table 
WITH base_counts AS (
SELECT
  category_id,
  COUNT(*) AS record_count
FROM dvd_rentals.category
GROUP BY category_id
)
SELECT
  record_count,
  COUNT(DISTINCT category_id) AS unique_category_id_values
FROM base_counts
GROUP BY record_count
ORDER BY record_count;

/* Result:
|record_count|unique_category_id_values|
|------------|-------------------------|
|1           |16                       |
*/

--> **FINDING**: VALID HYPOTHESIS (TRUE)

-- II. UNIQUE FOREIGN KEYS 
-- film_category table to film table
SELECT 
  COUNT(DISTINCT film_category.category_id)
FROM dvd_rentals.film_category
WHERE NOT EXISTS (
  SELECT category_id
  FROM dvd_rentals.category
  WHERE film_category.category_id = category.category_id
);

--OR

SELECT 
  COUNT(DISTINCT film_category.category_id)
FROM dvd_rentals.film_category AS film_category
LEFT JOIN dvd_rentals.category AS category
ON film_category.category_id = category.category_id
WHERE category.category_id IS NULL;

/*Result:
|count|
|-----|
|0    |
*/  

-- **FINDING**: There are no overlap foreign keys in the film_category table to the film table

-- category table to film_category table
SELECT 
  COUNT(DISTINCT category.category_id)
FROM dvd_rentals.category
WHERE NOT EXISTS (
  SELECT category_id
  FROM dvd_rentals.film_category
  WHERE film_category.category_id = category.category_id
);

--OR

SELECT 
  COUNT(DISTINCT category.category_id)
FROM dvd_rentals.category AS category
LEFT JOIN dvd_rentals.film_category AS film_category 
ON film_category.category_id = category.category_id
WHERE film_category.film_id IS NULL;

/*Result:
|count|
|-----|
|0    |
*/  

--> **FINDING**: There are no overlap foreign keys in the film table to the film_category table.


--> There is no difference between an inner join or left join for these datasets
