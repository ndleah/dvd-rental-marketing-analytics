[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)
[![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Join)
[![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis)

[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/ndleah?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/ndleah)

# **[SERIOUS SQL: MARKETING ANALYTICS CASE STUDY](https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis)**

# Bonus Section
<p align="center">
<img src="https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/The_Office_GIF.gif" width=60% height=60%>

## Overview

The following questions are part of this case study - these are example questions the Marketing team might be interested in as a bonus section which cover more in-depth insights of the email template!

## Solutions

### **Q1: Which film title was the most recommended for all customers?**
```sql
SELECT 
  title,
  film_id,
  COUNT(*) AS film_count
FROM top_category_recommendations
GROUP BY 
  title,
  film_id
  ORDER BY film_count DESC;
```
**Result:**
|title            |film_id|film_count|
|-----------------|-------|----------|
|DOGMA FAMILY     |239    |102       |
|JUGGLER HARDLY   |489    |100       |
|STORM HAPPINESS  |849    |100       |
|TALENTED HOMICIDE|875    |92        |
|ROSES TREASURE   |745    |91        |

**Answer:** DOGMA FAMILY 

---

### **Q2: How many customers were included in the email campaign?**
```sql
SELECT
  COUNT(DISTINCT customer_id)
FROM dvd_rentals.rental;
```
**Result:**
|count            |
|-----------------|
|599              |

**Answer:** 599

---

### **Q3: Out of all the possible films - what percentage coverage do we have in our recommendations?**
*Updating*

---

### **Q4: What is the most popular top category?**
```sql
WITH cte_top_categories_count AS (
  SELECT
    category_name,
    SUM(rental_count) AS category_rental_count
  FROM category_counts
  GROUP BY category_name
)
SELECT
  category_name,
  category_rental_count,
  DENSE_RANK() OVER (
    ORDER BY category_rental_count DESC
  ) AS rank
FROM cte_top_categories_count;
```
**Result:**
|category_name|category_rental_count|rank|
|-------------|---------------------|----|
|Sports       |1179                 |1   |
|Animation    |1166                 |2   |
|Action       |1112                 |3   |
|Sci-Fi       |1101                 |4   |
|Family       |1096                 |5   |
|Drama        |1060                 |6   |
|Documentary  |1050                 |7   |
|Foreign      |1033                 |8   |
|Games        |969                  |9   |
|Children     |945                  |10  |
|Comedy       |941                  |11  |
|New          |940                  |12  |
|Classics     |939                  |13  |
|Horror       |846                  |14  |
|Travel       |837                  |15  |
|Music        |830                  |16  |

**Answer:** Sports

---

### **Q5: What is the 4th most popular top category?**
From the query above:

**Result:**
|category_name|category_rental_count|rank|
|-------------|---------------------|----|
|Sports       |1179                 |1   |
|Animation    |1166                 |2   |
|Action       |1112                 |3   |
|Sci-Fi       |1101                 |4   |
|Family       |1096                 |5   |
|Drama        |1060                 |6   |
|Documentary  |1050                 |7   |
|Foreign      |1033                 |8   |
|Games        |969                  |9   |
|Children     |945                  |10  |
|Comedy       |941                  |11  |
|New          |940                  |12  |
|Classics     |939                  |13  |
|Horror       |846                  |14  |
|Travel       |837                  |15  |
|Music        |830                  |16  |

**Answer:** Sci-Fi

---

### **Q6: What is the average percentile ranking for each customer in their top category rounded to the nearest 2 decimal places?**
*Updating*

---

### **Q7: What is the cumulative distribution of the top 5 percentile values for the top category from the ```first_category_insights``` table rounded to the nearest round percentage?**
*Updating*

---

### **Q8: What is the median of the second category percentage of entire viewing history?**
```sql
SELECT
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY category_percentage)
        AS MedianCont
FROM second_category_insights;
```

**Result:**
|mediancont|
|----------|
|13        |

**Answer:** 13

---

### **Q9: What is the 80th percentile of films watched featuring each customer’s favourite actor?**
*Updating*

---

### **Q10: What was the average number of films watched by each customer?**
```sql
SELECT
ROUND(AVG(total_rental_count)) AS avg_rental_count
FROM total_counts;
```

**Result:**
|avg_rental_count|
|----------------|
|27              |

**Answer:** 27

---

### **Q11: What is the top combination of top 2 categories and how many customers if the order is relevant (e.g. Horror and Drama is a different combination to Drama and Horror)**
*Updating*

--- 

### **Q12: Which actor was the most popular for all customers?**
*Updating*

---

### **Q13: How many films on average had customers already seen that feature their favourite actor rounded to closest integer?**
*Updating*

---

### **Q14: What is the most common top categories combination if order was irrelevant and how many customers have this combination? (e.g. Horror and Drama is a the same as Drama and Horror)**
*Updating*
___________________________________

<p>&copy; 2021 Leah Nguyen</p>