/********************* 
PROBLEM SOLVING:

////////////////////////
Requirement 2: Category Recommendations
**********************/
--create Film Counts table
DROP TABLE IF EXISTS film_counts;
CREATE TEMP TABLE film_counts AS
SELECT DISTINCT
  film_id,
  title,
  category_name,
  COUNT(*) OVER (
  PARTITION BY film_id
  ) AS rental_count
FROM complete_joint_dataset_with_rental_date;

SELECT *
FROM film_counts
LIMIT 5;

/*Result:
|film_id|title   |category_name|rental_count|
|-------|--------|-------------|------------|
|655    |PANTHER REDS|Sci-Fi       |15          |
|285    |ENGLISH BULWORTH|Sci-Fi       |30          |
|258    |DRUMS DYNAMITE|Horror       |13          |
|809    |SLIPPER FIDELITY|Sports       |16          |
|883    |TEQUILA PAST|Children     |6           |
*/

--create Category Film Exclusions table
DROP TABLE IF EXISTS category_film_exclusions;
CREATE TEMP TABLE category_film_exclusions AS
SELECT DISTINCT
  customer_id,
  film_id
FROM complete_joint_dataset_with_rental_date;

SELECT *
FROM category_film_exclusions
LIMIT 10;

/*Result:
|customer_id|film_id |
|-----------|--------|
|596        |103     |
|176        |121     |
|459        |724     |
|375        |641     |
|153        |730     |
|1          |480     |
|291        |285     |
|144        |93      |
|158        |786     |
|211        |962     |
*/

--create 3 top category film recommendations for the top 2 categories
DROP TABLE IF EXISTS top_category_recommendations;
CREATE TEMP TABLE top_category_recommendations AS
WITH ranked_cte AS (
  SELECT
    top_categories.customer_id,
    top_categories.category_name,
    top_categories.category_rank,
    film_counts.film_id,
    film_counts.title,
    film_counts.rental_count,
    DENSE_RANK() OVER (
    PARTITION BY 
      customer_id,
      category_rank
    ORDER BY
      film_counts.rental_count DESC,
      film_counts.title
    ) AS reco_rank
  FROM top_categories
  INNER JOIN film_counts
    ON top_categories.category_name = film_counts.category_name
  WHERE NOT EXISTS (
    SELECT customer_id
    FROM category_film_exclusions
    WHERE
      category_film_exclusions.customer_id = top_categories.customer_id
      AND
      category_film_exclusions.film_id = film_counts.film_id
  )
)
SELECT *
FROM ranked_cte
WHERE reco_rank <= 3;

SELECT *
FROM top_category_recommendations
WHERE customer_id = 1
ORDER BY category_rank, reco_rank;

/*Result:
|customer_id|category_name|category_rank|film_id|title              |rental_count|reco_rank|
|-----------|-------------|-------------|-------|-------------------|------------|---------|
|1          |Classics     |1            |891    |TIMBERLAND SKY     |31          |1        |
|1          |Classics     |1            |358    |TIMBERLAND SKY     |28          |2        |
|1          |Classics     |1            |951    |VOYAGE LEGALLY     |28          |3        |
|1          |Comedy       |2            |1000   |ZORRO ARK          |31          |1        |
|1          |Comedy       |2            |127    |CAT CONEHEADS      |30          |2        |
|1          |Comedy       |2            |638    |OPERATION OPERATION|27          |3        |
*/

/*///////////////////////////////////

FINDING:
For customer 1: 
//1ST CATEGORY: Classics//
Your expertly chosen recommendations:
* TIMBERLAND SKY
* TIMBERLAND SKY
* VOYAGE LEGALLY

//2ND CATEGORY: Comedy//
Your expertly chosen recommendations:
* ZORRO ARK
* CAT CONEHEADS  
* OPERATION OPERATION
///////////////////////////////////*/