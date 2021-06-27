/********************* 
DATA EXPLORATION PART 1: 

////////////////////////
Rental and Inventory Tables
**********************/

-- I. INSPECTING THE HYPOTHESES
-- H1: The number of unique inventory_id records will be equal in both dvd_rentals.rental and dvd_rentals.inventory tables
(
SELECT
  'rental table' AS table_name,
  COUNT(DISTINCT inventory_id)
FROM dvd_rentals.rental
)
UNION
(
SELECT
  'inventory table' AS table_name,
  COUNT(DISTINCT inventory_id)
FROM dvd_rentals.inventory
);

--Result:
+──────────────────+────────+
| table_name       | count  |
+──────────────────+────────+
| inventory table  | 4581   |
| rental table     | 4580   |
+──────────────────+────────+


--> **FINDING**: INVALID HYPOTHESIS (FALSE)

-- H2: There will be a multiple records per unique inventory_id in the dvd_rentals.rental table
  -- first generate group by counts on the target_column_values column
WITH counts_base AS (
SELECT
  inventory_id AS target_column_values,
  COUNT(*) AS row_counts
FROM dvd_rentals.rental
GROUP BY target_column_values
)
  -- summarize the group by counts above by grouping again on the row_counts from counts_base CTE part
SELECT
  row_counts,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_counts
ORDER BY row_counts;

--*Result:
+─────────────+─────────────────────────+
| row_counts  | count_of_target_values  |
+─────────────+─────────────────────────+
| 1           | 4                       |
| 2           | 1126                    |
| 3           | 1151                    |
| 4           | 1160                    |
| 5           | 1139                    |
+─────────────+─────────────────────────+

--> **FINDING**: VALID HYPOTHESIS (TRUE)

-- H3: There will be multiple inventory_id records per unique film_id value in the dvd_rentals.inventory table
WITH counts_base AS (
SELECT
  film_id AS target_column_values,
  COUNT(DISTINCT inventory_id) AS row_counts 
FROM dvd_rentals.inventory
GROUP BY 
  target_column_values
ORDER BY row_counts DESC
)
SELECT 
  row_counts,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_counts
ORDER BY row_counts;

--> **FINDING**: VALID HYPOTHESIS (TRUE)

-- II. RETURNING KEY QUESTIONS
-- Q1: How many records exist per inventory_id value in rental or inventory tables?
  -- a. dvd_rentals.rental
  -- first generate group by counts on the foreign_key_values column
WITH counts_base AS (
SELECT
  inventory_id AS foreign_key_values,
  COUNT(*) AS row_counts
FROM dvd_rentals.rental  
GROUP BY foreign_key_values
)
  -- -- summarize the group by counts above by grouping again on the row_counts from counts_base CTE part
SELECT 
  row_counts,
  COUNT(foreign_key_values) AS count_of_fk_values
FROM counts_base
GROUP BY row_counts
ORDER BY row_counts;

--Result:
+─────────────+─────────────────────+
| row_counts  | count_of_fk_values  |
+─────────────+─────────────────────+
| 1           | 4                   |
| 2           | 1126                |
| 3           | 1151                |
| 4           | 1160                |
| 5           | 1139                |
+─────────────+─────────────────────+


-- b. dvd_rentals.inventory
  -- first generate group by counts on the foreign_key_values column
WITH counts_base AS (
SELECT
  inventory_id AS foreign_key_values,
  COUNT(DISTINCT inventory_id) AS row_counts
FROM dvd_rentals.inventory
GROUP BY foreign_key_values
)
  -- summarize the group by counts above by grouping again on the row_counts from counts_base CTE part
SELECT 
  row_counts,
  COUNT(foreign_key_values) AS count_of_fk_values
FROM counts_base
GROUP BY row_counts
ORDER BY row_counts;

--Result:
+─────────────+─────────────────────+
| row_counts  | count_of_fk_values  |
+─────────────+─────────────────────+
| 1           | 4581                |
+─────────────+─────────────────────+

/* **FINDING**:   
  **Rental table**: There may exist 1 or more record for each unique inventory_id value in this table - "a 1-to-many relationship" for the inventory_id
  ** Inventory table**: For every single unique inventory_id value in the inventory table - there exists only 1 table row record - "a 1-to-1 relationship"
*/

-- Q2: How many overlapping and missing unique foreign key values are there between the two tables?

-- how many foreign keys only exist in the left table and not in the right?
SELECT 
  COUNT(DISTINCT rental.inventory_id)
FROM dvd_rentals.rental
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);

-- OR

SELECT 
  COUNT(DISTINCT rental.inventory_id)
FROM dvd_rentals.rental AS rental
LEFT JOIN dvd_rentals.inventory AS inventory
ON inventory.inventory_id = rental.inventory_id
WHERE inventory.inventory_id IS NULL;

--Result:
+────────+
| count  |
+────────+
| 0      |
+────────+  

-- **FINDING**: There are no inventory_id records which appear in the dvd_rentals.rental table which does not appear in the dvd_rentals.inventory table.
-- how many foreign keys only exist in the right table and not in the left?

SELECT 
  COUNT(DISTINCT inventory.inventory_id)
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);

--OR

SELECT 
  COUNT(DISTINCT inventory.inventory_id)
FROM dvd_rentals.inventory AS inventory
LEFT JOIN dvd_rentals.rental AS rental
ON inventory.inventory_id = rental.inventory_id
WHERE rental.inventory_id IS NULL;

--Result:
+────────+
| count  |
+────────+
| 1      |
+────────+

-- **FINDING**: There are 1 foreign key record that only exist in the right table

--further inspection:
SELECT *
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);

--Result:
+───────────────+──────────+───────────+───────────────────────────+
| inventory_id  | film_id  | store_id  | last_update               |
+───────────────+──────────+───────────+───────────────────────────+
| 5             | 1        | 2         | 2006-02-15T05:09:17.000Z  |
+───────────────+──────────+───────────+───────────────────────────+

-- Perfom a LEFT SEMI JOIN with WHERE EXIST function to get the count of unique foreign key values:
SELECT
  COUNT(DISTINCT rental.inventory_id)
FROM dvd_rentals.rental
WHERE EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);

--OR

SELECT
  COUNT(DISTINCT r.inventory_id)
FROM dvd_rentals.rental AS rental
LEFT JOIN dvd_rentals.inventory AS inventory
ON rental.inventory_id = inventory.inventory_id
WHERE inventory.inventory_id IS NOT NULL;

--Result:
+────────+
| count  |
+────────+
| 4580   |
+────────+

-- III. IMPLEMENTING THE JOIN(S)
-- Inspect if the INNER JOIN is the same with LEFT JOIN or not in this case example:
  
  -- Create LEFT JOIN table
DROP TABLE IF EXISTS left_rental_join;
CREATE TEMP TABLE left_rental_join AS
SELECT
   rental.customer_id,
   rental.inventory_id,
   inventory.film_id
FROM dvd_rentals.rental
LEFT JOIN dvd_rentals.inventory
ON rental.inventory_id = inventory.inventory_id;
  -- Create INNER JOIN table
DROP TABLE IF EXISTS inner_rental_join;
CREATE TEMP TABLE inner_rental_join AS
SELECT
   rental.customer_id,
   rental.inventory_id,
   inventory.film_id
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
ON rental.inventory_id = inventory.inventory_id;

  -- Check the counts for each output
(
SELECT
  'left join' AS join_type,
  COUNT(*) AS record_count,
  COUNT (DISTINCT inventory_id) AS unique_key_values
FROM left_rental_join
)
UNION
(
SELECT
  'inner join' AS join_type,
  COUNT(*) AS record_count,
  COUNT (DISTINCT inventory_id) AS unique_key_values
FROM inner_rental_join
);

-- Result:
+────────────+───────────────+────────────────────+
| join_type  | record_count  | unique_key_values  |
+────────────+───────────────+────────────────────+
| inner join | 16044         | 4580               |
| left join  | 16044         | 4580               |
+────────────+───────────────+────────────────────+

-- **FINDING**: There is no difference between an inner join or left join for these datasets