[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)
[![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis)

[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/ndleah?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/ndleah)

# **[SERIOUS SQL: MARKETING ANALYTICS CASE STUDY](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis)**

# Data Overview - Data Join

<p align="center">
<img src="https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/table-join.gif" width=60% height=60%>
</p>

## **Table of contents**
<!--ts-->
1. [Joining Tables](#joining-tables)
2. [Dealing With Ties](#dealing-with-ties)
3. [Next Steps](#next-steps)

 <br /> 

## **JOINING TABLES**

Now that we’ve done with the data exploration part of the joining journey - I will start to join all the data table for getting insights for our campaign objective as the query below:

```sql
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
```
 <br /> 

⚡ **Result:**
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

<br /> 

## **DEALING WITH TIES**

In order to avoid matching **```rental_count```** values, which often refered as "ties", in the same top category ranking, it is neccessary to include 1 more column into our joint dataset as an additional condition for ties dealing.

In this case study, I will use the latest **```rental date```** as a additional determination if there is any tie that happened in our analysis.

To add on this column to my previous joint table, I simply generated the following query as replacement:
```sql
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
```
<br /> 

⚡ **Result:** 
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

<br /> 

**Conclusion:** 

The result look just great for me now, which mean that we can end this part here (Wow, thanks to the super long session we have covered in the **[Data Exploration](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)** section previously, I can save up a lot of time in the Data Joining part. That's great!).

<br /> 

## **Next Steps**

### **In the next stage of this project, let's proceed to discover all of our core questions related to the data for the email marketing template that the Marketing team had requested**

<br /> 

View The Next Part: [![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)

Have you viewed the 1st part yet? Take a look here: [![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)

Come back to main folder: [![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main)

___________________________________

<p>&copy; 2021 Leah Nguyen</p>