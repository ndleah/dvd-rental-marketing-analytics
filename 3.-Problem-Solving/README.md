[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)
[![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Join)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis)

[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/nduongthucanh?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/nduongthucanh)

# **[SERIOUS SQL: MARKETING ANALYTICS CASE STUDY](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis)**

# Problem Solving

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/solving-cover.gif" width=100% height=100%>
</p>

## Table of contents
<!--ts-->
* [Solution plan](#solution-plan)
    * [Requirement 1: Top 2 Categories](#r1-top-2-categories)
    * [Requirement 2: Categories Recommendations](#r2-category-recommendations)
    * [Requirement 3 & 4: Top 2 Categories Insights](#r3-r4-top-2-category-insights)
    * [Requirement 5: Actor Insights](#r5-actor-insights)
* [Final Transformation](#final-transfromation)
* [Next Steps](#next-steps)

---
## Solution Plan
## R1: Top 2 Categories
### **1. Category Counts**
After creating a **```complete_joint_dataset_with_rental_date```** which joins multiple tables together after analysing the relationships between each table, I then created a follow-up table which uses the **```complete_joint_dataset_with_rental_date```** to aggregate our data and generate a rental_count for our ranking purposes downstream.

```sql
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
```
**Result:**
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

### **2. Total Counts**
I will then use this **```category_counts```** table to generate our **```total_counts```** table.
```sql
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
```

**Result:**
|customer_id|sum      |
|-----------|---------|
|1          |32       |
|2          |27       |
|3          |26       |
|4          |22       |
|5          |38       |


### **3. Top Categories**
Finally, with all the data from the above query, I can now generate the table that highlight the top 2 categories each customer based off their past rental history:
```sql
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
```
**Result:**
|customer_id|category_name|rental_count|category_rank|
|-----------|-------------|------------|-------------|
|1          |Classics     |6           |1            |
|1          |Comedy       |5           |2            |
|2          |Sports       |5           |1            |
|2          |Classics     |4           |2            |
|3          |Action       |4           |1            |
|3          |Sci-Fi       |3           |2            |

---

## R2: Category Recommendations
### **1. Film Counts**
We wil first generate another total rental count aggregation from our base table **```complete_joint_dataset_with_rental_date```** - however this time we will use the **```film_id```** and **```title```** instead.

```sql
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
```
**Result:**
|film_id|title   |category_name|rental_count|
|-------|--------|-------------|------------|
|655    |PANTHER REDS|Sci-Fi       |15          |
|285    |ENGLISH BULWORTH|Sci-Fi       |30          |
|258    |DRUMS DYNAMITE|Horror       |13          |
|809    |SLIPPER FIDELITY|Sports       |16          |
|883    |TEQUILA PAST|Children     |6           |


### **2. Category Film Exclusions**
For the next step in our recommendation analysis - we will need to generate a table with all of our customer’s previously watched films so we don’t recommend them something which they’ve already seen before.

```sql
DROP TABLE IF EXISTS category_film_exclusions;
CREATE TEMP TABLE category_film_exclusions AS
SELECT DISTINCT
  customer_id,
  film_id
FROM complete_joint_dataset_with_rental_date;

SELECT *
FROM category_film_exclusions
LIMIT 10;
```

**Result:**
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

### **3. Final Category Recommendations**
In this part, I will perform an **```ANTI JOIN```** using a **```WHERE NOT EXISTS```** SQL implementation for the top 2 categories found in the **```top_categories```** table I had generated a few steps prior so that I can get the necessary information for generating my final category recommendations table.

```sql
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
```
To illustrate the final output, let's take a look at the information generated by customer with **```customer_id = 1```** within this table:
```sql
SELECT *
FROM top_category_recommendations
WHERE customer_id = 1
ORDER BY category_rank, reco_rank;
```

**Result:**
|customer_id|category_name|category_rank|film_id|title              |rental_count|reco_rank|
|-----------|-------------|-------------|-------|-------------------|------------|---------|
|1          |Classics     |1            |891    |TIMBERLAND SKY     |31          |1        |
|1          |Classics     |1            |358    |TIMBERLAND SKY     |28          |2        |
|1          |Classics     |1            |951    |VOYAGE LEGALLY     |28          |3        |
|1          |Comedy       |2            |1000   |ZORRO ARK          |31          |1        |
|1          |Comedy       |2            |127    |CAT CONEHEADS      |30          |2        |
|1          |Comedy       |2            |638    |OPERATION OPERATION|27          |3        |

**FINDING:**

## For customer 1: 

### 1ST CATEGORY: **Classics**

*Your expertly chosen recommendations:*
* ***TIMBERLAND SKY***
* ***TIMBERLAND SKY***
* ***VOYAGE LEGALLY***

### 2ND CATEGORY: **Comedy**

Your expertly chosen recommendations:
* ***ZORRO ARK***
* ***CAT CONEHEADS***  
* ***OPERATION OPERATION***

---

## R3, R4: Top 2 Category Insights
### **1. Average Category Rental Counts**
Next we will need to use the **```category_counts```** table to generate the average aggregated rental count for each category rounded down to the nearest integer using the **```FLOOR```** function

```sql
DROP TABLE IF EXISTS average_category_count;
CREATE TEMP TABLE average_category_count AS
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS avg_rental_count
FROM category_rental_counts
GROUP BY category_name;

SELECT *
FROM average_category_count
ORDER BY category_name;
```

**Result:**
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

### **2. Percentile Values**
Continue with our data problem solving journey, I will continue with the the percentile field's calculation to identify:

> **how does the customer rank in terms of the top X% compared to all other customers in this film category?**


```sql
DROP TABLE IF EXISTS top_category_percentile;
CREATE TEMP TABLE top_category_percentile AS
WITH calculated_cte AS (
SELECT
  top_categories.customer_id,
  top_categories.category_name AS top_category_name,
  top_categories.rental_count,
  category_counts.category_name,
  top_categories.category_rank,
     PERCENT_RANK() OVER (
      PARTITION BY category_counts.category_name
      ORDER BY category_counts.rental_count DESC
  ) AS raw_percentile_value
FROM category_counts
LEFT JOIN top_categories
  ON category_counts.customer_id = top_categories.customer_id
)
SELECT 
  customer_id,
  category_name,
  rental_count,
  category_rank,
  CASE
    WHEN ROUND(100 * raw_percentile_value) = 0 THEN 1
    ELSE ROUND(100 * raw_percentile_value)
  END AS percentile
FROM calculated_cte
WHERE
  top_category_name = category_name;
  
SELECT *
FROM top_category_percentile
ORDER BY 
  customer_id,
  category_rank
LIMIT 10;
```

**Result:**
|customer_id|category_name|rental_count|category_rank|percentile         |
|-----------|-------------|------------|-------------|-------------------|
|1          |Classics     |6           |1            |1                  |
|1          |Comedy       |5           |2            |1                  |
|2          |Sports       |5           |1            |2                  |
|2          |Classics     |4           |2            |2                  |
|3          |Action       |4           |1            |4                  |
|3          |Sci-Fi       |3           |2            |15                 |
|4          |Horror       |3           |1            |8                  |
|4          |Drama        |2           |2            |32                 |
|5          |Classics     |7           |1            |1                  |
|5          |Animation    |6           |2            |1                  |

### **3. Category Joint Table**
To easily extract all the necessary information for my later calculations regarding insights for the top 2 categories, I joined all the query of my previous temp tables above into 1 table only. Note that this table only contains the top 2 categories information and not the rest:
```sql
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
FROM category_counts AS t1
INNER JOIN total_counts AS t2
  ON t1.customer_id = t2.customer_id
INNER JOIN average_category_count AS t3
  ON t1.category_name = t3.category_name
INNER JOIN top_category_percentile AS t4
  ON t1.customer_id = t4.customer_id
  AND t1.category_name = t4.category_name;
  
--inspect customer = 1 rows sorted by percentile
SELECT *
FROM customer_category_joint_table
WHERE customer_id = 1
ORDER BY percentile
LIMIT 5;
```

**Result:**
|customer_id|category_name|rental_count|latest_rental_date|total_rental_count |avg_rental_count|percentile|average_comparison|category_percentage|
|-----------|-------------|------------|------------------|-------------------|----------------|----------|------------------|-------------------|
|1          |Comedy       |5           |2005-08-22T19:41:37.000Z|32                 |1               |1         |4                 |16                 |
|1          |Classics     |6           |2005-08-19T09:55:16.000Z|32                 |2               |1         |4                 |19                 |

### **4. Top 2 Category Insights**
However, I noticed that I were missing two important values, which were: **```average_comparison```** and **```category_percentage```**:
* **```average_comparison```**: How many more films has the customer watched compared to the average DVD Rental Co customer?
* **```category_percentage```**: What proportion of each customer’s total films watched does this count make? 

Therefore, let's update our previous table by adding in Calculated Fields to complete the insights table by running the query below:
```sql
DROP TABLE IF EXISTS top_category_insights;
CREATE TEMP TABLE top_category_insights AS (
WITH ranked_cte AS (
  SELECT
  customer_id,
  ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY 
      rental_count DESC,
      latest_rental_date DESC
    ) AS category_rank,
    category_name,
    rental_count,
    average_comparison,
    percentile,
    category_percentage
  FROM customer_category_joint_table
  )
SELECT *
FROM ranked_cte
WHERE category_rank <= 2
);

-- inspect the result for the first 3 customers
SELECT * 
FROM top_category_insights
ORDER BY 
  customer_id,
  category_rank,
  percentile
LIMIT 10;
```

**Result:**
|customer_id|category_rank|category_name|rental_count|average_comparison |percentile|category_percentage|
|-----------|-------------|-------------|------------|-------------------|----------|-------------------|
|1          |1            |Classics     |6           |4                  |1         |19                 |
|1          |2            |Comedy       |5           |4                  |1         |16                 |
|2          |1            |Sports       |5           |3                  |2         |19                 |
|2          |2            |Classics     |4           |2                  |2         |15                 |
|3          |1            |Action       |4           |2                  |4         |15                 |
|3          |2            |Sci-Fi       |3           |1                  |15        |12                 |
|4          |1            |Horror       |3           |2                  |8         |14                 |
|4          |2            |Drama        |2           |0                  |32        |9                  |
|5          |1            |Classics     |7           |5                  |1         |18                 |
|5          |2            |Animation    |6           |4                  |1         |16                 |


### **5. 1st Category Insights**

```sql
DROP TABLE IF EXISTS first_category_insights;
CREATE TEMP TABLE first_category_insights AS
SELECT
  customer_id,
  category_name,
  rental_count,
  average_comparison,
  percentile
FROM top_category_insights
WHERE category_rank = 1;

SELECT *
FROM first_category_insights
ORDER BY customer_id
LIMIT 10;
```

**Result:**
|customer_id|category_name|rental_count|average_comparison|percentile         |
|-----------|-------------|------------|------------------|-------------------|
|1          |Classics     |6           |4                 |1                  |
|2          |Sports       |5           |3                 |2                  |
|3          |Action       |4           |2                 |4                  |
|4          |Horror       |3           |2                 |8                  |
|5          |Classics     |7           |5                 |1                  |
|6          |Drama        |4           |2                 |3                  |
|7          |Sports       |5           |3                 |2                  |
|8          |Classics     |4           |2                 |2                  |
|9          |Foreign      |4           |2                 |6                  |
|10         |Documentary  |4           |2                 |5                  |

**FINDING:**
## For customer 1: 
### *You’ve watched 6 Classics films, that’s 4 more than the DVD Rental Coaverage and puts you in the top 1%  of Classics gurus!*

### **6. 2nd Category Insights**
```sql
DROP TABLE IF EXISTS second_category_insights;
CREATE TEMP TABLE second_category_insights AS
SELECT
  customer_id,
  category_name,
  rental_count,
  category_percentage
FROM top_category_insights
WHERE category_rank = 2;

SELECT *
FROM second_category_insights
ORDER BY customer_id
LIMIT 10;
```

**Result:**
|customer_id|category_name|rental_count|category_percentage|
|-----------|-------------|------------|-------------------|
|1          |Comedy       |5           |16                 |
|2          |Classics     |4           |15                 |
|3          |Sci-Fi       |3           |12                 |
|4          |Drama        |2           |9                  |
|5          |Animation    |6           |16                 |
|6          |Sci-Fi       |3           |11                 |
|7          |Animation    |5           |15                 |
|8          |Drama        |4           |17                 |
|9          |Travel       |4           |17                 |
|10         |Games        |4           |16                 |

**FINDING:**
## For customer 1: 
### *You’ve watched 5 Classics films, making up 16% of your entiring viewing history!*

---

## R5: Actor Insights
### **1. Actor Joint Table**
For this entire analysis on actors - we will need to create a new base table as we will need to introduce the **```dvd_rentals.film_actor```** and **```dvd_rentals.actor```** tables to extract all the required data points we need for the final output.

```sql 
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
```

**Result:**
|customer_id|rental_id|rental_date|film_id|title          |actor_id|first_name|last_name|
|-----------|---------|-----------|-------|---------------|--------|----------|---------|
|130        |1        |2005-05-24T22:53:30.000Z|80     |BLANKET BEVERLY|200     |THORA     |TEMPLE   |
|130        |1        |2005-05-24T22:53:30.000Z|80     |BLANKET BEVERLY|193     |BURT      |TEMPLE   |
|130        |1        |2005-05-24T22:53:30.000Z|80     |BLANKET BEVERLY|173     |ALAN      |DREYFUSS |
|130        |1        |2005-05-24T22:53:30.000Z|80     |BLANKET BEVERLY|16      |FRED      |COSTNER  |
|459        |2        |2005-05-24T22:54:33.000Z|333    |FREAKY POCUS   |147     |FAY       |WINSLET  |
|459        |2        |2005-05-24T22:54:33.000Z|333    |FREAKY POCUS   |127     |KEVIN     |GARLAND  |
|459        |2        |2005-05-24T22:54:33.000Z|333    |FREAKY POCUS   |105     |SIDNEY    |CROWE    |
|459        |2        |2005-05-24T22:54:33.000Z|333    |FREAKY POCUS   |103     |MATTHEW   |LEIGH    |
|459        |2        |2005-05-24T22:54:33.000Z|333    |FREAKY POCUS   |42      |TOM       |MIRANDA  |
|408        |3        |2005-05-24T23:03:39.000Z|373    |GRADUATE LORD  |140     |WHOOPI    |HURT     |

### **2. Top Actor Counts**
We can now generate our rental counts per actor and since we are only interested in the top actor for each of our customers - we can also perform a filter step to just keep the top actor records and counts for our downstream insights:
```sql
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
```

**Result:**
|customer_id|actor_id|first_name|last_name|rental_count|
|-----------|--------|----------|---------|------------|
|1          |37      |VAL       |BOLGER   |6           |
|2          |107     |GINA      |DEGENERES|5           |
|3          |150     |JAYNE     |NOLTE    |4           |
|4          |102     |WALTER    |TORN     |4           |
|5          |12      |KARL      |BERRY    |4           |
|6          |191     |GREGORY   |GOODING  |4           |
|7          |65      |ANGELA    |HUDSON   |5           |
|8          |167     |LAURENCE  |BULLOCK  |5           |
|9          |23      |SANDRA    |KILMER   |3           |
|10         |12      |KARL      |BERRY    |4           |

### **3. Top Actor Film Counts**
I need to generate aggregated total rental counts across all customers by **```actor_id```** and **```film_id```** so I can join onto our **```top_actor_counts```** table


```sql
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
```

**Result:**
|film_id|actor_id|title|rental_count|
|-------|--------|-----|------------|
|1      |1       |ACADEMY DINOSAUR|23          |
|1      |10      |ACADEMY DINOSAUR|23          |
|1      |20      |ACADEMY DINOSAUR|23          |
|1      |30      |ACADEMY DINOSAUR|23          |
|1      |40      |ACADEMY DINOSAUR|23          |
|1      |53      |ACADEMY DINOSAUR|23          |
|1      |108     |ACADEMY DINOSAUR|23          |
|1      |162     |ACADEMY DINOSAUR|23          |
|1      |188     |ACADEMY DINOSAUR|23          |
|1      |198     |ACADEMY DINOSAUR|23          |

### **4. Actor Film Exclusions**
I can perform the same steps I used to create the **```category_film_exclusions```** table - however I also need to **```UNION```** the exclusions with the relevant category recommendations that I have already given our customers.

The rationale behind this - customers would not want to receive a recommendation for the same film twice in the same email!
```sql
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
```

**Result:**
|customer_id|film_id |
|-----------|--------|
|493        |567     |
|114        |789     |
|596        |103     |
|176        |121     |
|459        |724     |
|375        |641     |
|153        |730     |
|291        |285     |
|1          |480     |
|144        |93      |

### **5. Final Actor Recommendations**
Finally we are up to the last hurdle of our analysis stage!


```sql
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
```

**Result:**
|customer_id|first_name|last_name|rental_count|title                 |film_id|actor_id|reco_rank|
|-----------|----------|---------|------------|----------------------|-------|--------|---------|
|1          |VAL       |BOLGER   |6           |PRIMARY GLASS         |697    |37      |1        |
|1          |VAL       |BOLGER   |6           |ALASKA PHANTOM        |12     |37      |2        |
|1          |VAL       |BOLGER   |6           |METROPOLIS COMA       |572    |37      |3        |
|2          |GINA      |DEGENERES|5           |GOODFELLAS SALUTE     |369    |107     |1        |
|2          |GINA      |DEGENERES|5           |WIFE TURN             |973    |107     |2        |
|2          |GINA      |DEGENERES|5           |DOGMA FAMILY          |239    |107     |3        |
|3          |JAYNE     |NOLTE    |4           |SWEETHEARTS SUSPECTS  |873    |150     |1        |
|3          |JAYNE     |NOLTE    |4           |DANCING FEVER         |206    |150     |2        |
|3          |JAYNE     |NOLTE    |4           |INVASION CYCLONE      |468    |150     |3        |
|4          |WALTER    |TORN     |4           |CURTAIN VIDEOTAPE     |200    |102     |1        |
|4          |WALTER    |TORN     |4           |LIES TREATMENT        |521    |102     |2        |
|4          |WALTER    |TORN     |4           |NIGHTMARE CHILL       |624    |102     |3        |
|5          |KARL      |BERRY    |4           |VIRGINIAN PLUTO       |945    |12      |1        |
|5          |KARL      |BERRY    |4           |STAGECOACH ARMAGEDDON |838    |12      |2        |
|5          |KARL      |BERRY    |4           |TELEMARK HEARTBREAKERS|880    |12      |3        |

---

## Final Transfromation
To package up all our analysis into a single report - I will need to perform some further transformations to finally generate a sample table for the DVD Rental Co Marketing team to consume.

```sql
DROP TABLE IF EXISTS final_data_asset;
CREATE TEMP TABLE final_data_asset AS
WITH first_category AS (
  SELECT
    customer_id,
    category_name,
    CONCAT(
      'You''ve watched ', rental_count, ' ', category_name,
      ' films, that''s ', average_comparison,
      ' more than the DVD Rental Co average and puts you in the top ',
      percentile, '% of ', category_name, ' gurus!'
    ) AS insight
  FROM first_category_insights
),
second_category AS (
  SELECT
    customer_id,
    category_name,
    CONCAT(
      'You''ve watched ', rental_count, ' ', category_name,
      ' films making up ', category_percentage,
      '% of your entire viewing history!'
    ) AS insight
  FROM second_category_insights
),
top_actor AS (
  SELECT
    customer_id,
    -- use INITCAP to transform names into Title case
    CONCAT(INITCAP(first_name), ' ', INITCAP(last_name)) AS actor_name,
    CONCAT(
      'You''ve watched ', rental_count, ' films featuring ',
      INITCAP(first_name), ' ', INITCAP(last_name),
      '! Here are some other films ', INITCAP(first_name),
      ' stars in that might interest you!'
    ) AS insight
  FROM top_actor_counts
),
adjusted_title_case_category_recommendations AS (
  SELECT
    customer_id,
    INITCAP(title) AS title,
    category_rank,
    reco_rank
  FROM top_category_recommendations
),
wide_category_recommendations AS (
  SELECT
    customer_id,
    MAX(CASE WHEN category_rank = 1  AND reco_rank = 1
      THEN title END) AS cat_1_reco_1,
    MAX(CASE WHEN category_rank = 1  AND reco_rank = 2
      THEN title END) AS cat_1_reco_2,
    MAX(CASE WHEN category_rank = 1  AND reco_rank = 3
      THEN title END) AS cat_1_reco_3,
    MAX(CASE WHEN category_rank = 2  AND reco_rank = 1
      THEN title END) AS cat_2_reco_1,
    MAX(CASE WHEN category_rank = 2  AND reco_rank = 2
      THEN title END) AS cat_2_reco_2,
    MAX(CASE WHEN category_rank = 2  AND reco_rank = 3
      THEN title END) AS cat_2_reco_3
  FROM adjusted_title_case_category_recommendations
  GROUP BY customer_id
),
adjusted_title_case_actor_recommendations AS (
  SELECT
    customer_id,
    INITCAP(title) AS title,
    reco_rank
  FROM actor_recommendations
),
wide_actor_recommendations AS (
  SELECT
    customer_id,
    MAX(CASE WHEN reco_rank = 1 THEN title END) AS actor_reco_1,
    MAX(CASE WHEN reco_rank = 2 THEN title END) AS actor_reco_2,
    MAX(CASE WHEN reco_rank = 3 THEN title END) AS actor_reco_3
  FROM adjusted_title_case_actor_recommendations
  GROUP BY customer_id
),
final_output AS (
  SELECT
    t1.customer_id,
    t1.category_name AS cat_1,
    t4.cat_1_reco_1,
    t4.cat_1_reco_2,
    t4.cat_1_reco_3,
    t2.category_name AS cat_2,
    t4.cat_2_reco_1,
    t4.cat_2_reco_2,
    t4.cat_2_reco_3,
    t3.actor_name AS actor,
    t5.actor_reco_1,
    t5.actor_reco_2,
    t5.actor_reco_3,
    t1.insight AS insight_cat_1,
    t2.insight AS insight_cat_2,
    t3.insight AS insight_actor
FROM first_category AS t1
INNER JOIN second_category AS t2
  ON t1.customer_id = t2.customer_id
INNER JOIN top_actor t3
  ON t1.customer_id = t3.customer_id
INNER JOIN wide_category_recommendations AS t4
  ON t1.customer_id = t4.customer_id
INNER JOIN wide_actor_recommendations AS t5
  ON t1.customer_id = t5.customer_id
)
SELECT * FROM final_output;

SELECT *
FROM final_data_asset
LIMIT 5;
```

**Result:**
|customer_id|cat_1   |cat_1_reco_1|cat_1_reco_2|cat_1_reco_3          |cat_2|cat_2_reco_1|cat_2_reco_2|cat_2_reco_3       |actor         |actor_reco_1        |actor_reco_2         |actor_reco_3          |insight_cat_1                                                                                                              |insight_cat_2                                                                 |insight_actor                                                                                                    |
|-----------|--------|------------|------------|----------------------|-----|------------|------------|-------------------|--------------|--------------------|---------------------|----------------------|---------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
|1          |Classics|Timberland Sky|Gilmore Boiled|Voyage Legally        |Comedy|Zorro Ark   |Cat Coneheads|Operation Operation|Val Bolger    |Primary Glass       |Alaska Phantom       |Metropolis Coma       |You've watched 6 Classics films, that's 4 more than the DVD Rental Co average and puts you in the top 1% of Classics gurus!|You've watched 5 Comedy films making up 16% of your entire viewing history!   |You've watched 6 films featuring Val Bolger! Here are some other films Val stars in that might interest you!     |
|2          |Sports  |Gleaming Jawbreaker|Talented Homicide|Roses Treasure        |Classics|Frost Head  |Gilmore Boiled|Voyage Legally     |Gina Degeneres|Goodfellas Salute   |Wife Turn            |Dogma Family          |You've watched 5 Sports films, that's 3 more than the DVD Rental Co average and puts you in the top 2% of Sports gurus!    |You've watched 4 Classics films making up 15% of your entire viewing history! |You've watched 5 films featuring Gina Degeneres! Here are some other films Gina stars in that might interest you!|
|3          |Action  |Rugrats Shakespeare|Suspects Quills|Handicap Boondock     |Sci-Fi|Goodfellas Salute|English Bulworth|Graffiti Love      |Jayne Nolte   |Sweethearts Suspects|Dancing Fever        |Invasion Cyclone      |You've watched 4 Action films, that's 2 more than the DVD Rental Co average and puts you in the top 4% of Action gurus!    |You've watched 3 Sci-Fi films making up 12% of your entire viewing history!   |You've watched 4 films featuring Jayne Nolte! Here are some other films Jayne stars in that might interest you!  |
|4          |Horror  |Pulp Beverly|Family Sweet|Swarm Gold            |Drama|Hobbit Alien|Harry Idaho |Witches Panic      |Walter Torn   |Curtain Videotape   |Lies Treatment       |Nightmare Chill       |You've watched 3 Horror films, that's 2 more than the DVD Rental Co average and puts you in the top 8% of Horror gurus!    |You've watched 2 Drama films making up 9% of your entire viewing history!     |You've watched 4 films featuring Walter Torn! Here are some other films Walter stars in that might interest you! |
|5          |Classics|Timberland Sky|Frost Head  |Gilmore Boiled        |Animation|Juggler Hardly|Dogma Family|Storm Happiness    |Karl Berry    |Virginian Pluto     |Stagecoach Armageddon|Telemark Heartbreakers|You've watched 7 Classics films, that's 5 more than the DVD Rental Co average and puts you in the top 1% of Classics gurus!|You've watched 6 Animation films making up 16% of your entire viewing history!|You've watched 4 films featuring Karl Berry! Here are some other films Karl stars in that might interest you!    |

---

## Next Steps

<br /> 

### **We have completed the final stage of our data analysis in this project, now let's go back to the main folder to see the final otput of the email template (customer_id = 1)**

<br /> 

View The Final Result: [![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis)

View The 1st Part: [![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)

View The 2nd Part: [![View Main FolderData Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/2.-Data-Join)

___________________________________

<p>&copy; 2021 Leah Nguyen</p>

