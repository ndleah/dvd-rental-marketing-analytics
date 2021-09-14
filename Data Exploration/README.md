[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/ndleah?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/ndleah)

# # DVD Rental Marketing Analytics: Data Exploration

## Table of contents
<!--ts-->
1. [Identifying table relationships](#Identifying-Table-Relationships)
   
2. [Idetifying key columns](#Idetifying-Key-Columns)

3. [Identifying Start & End Points](#identifying-start--end-points)

4. [Start With The First](#start-with-the-first)
   * [Inspecting The Table Values](#inspecting-the-table-values)
      
      a. [Validating Hypotheses](#a-validating-hypotheses)
      
      b. [Hypotheses Summary](#b-hypotheses-summary)
      
      c. [Foreign Keys Distribution Analysis](#c-foreign-keys-distribution-analysis)
      
      d. [Foreign Key Overlap Analysis](#d-foreign-key-overlap-analysis)

      e. [Joint Foreign Keys](#e-joint-foreign-keys)
      
      f. [Implemening The Joins](#f-implementing-the-joins)
   * [Summary](#Summary)

5. [Returning To The Data Exploration Journey](#returning-to-the-data-exploration-journey)

6. [Next Steps](#next-steps)

---
## Identifying Table Relationships
Before diving straight into solution mode for the business requirements, I need to take a look at the data with **EDR (Entity-Relationship Diagrams)** to identify different data relationships between tables. The EDR of these datasets can be viewed as below:

<p align="center">
<img src="/IMG/ERD-full.png" width=100% height=100%>
</p>

<br /> 

Next, I named each step of the travel journey starting from **```dvd_rentals.rental```** to **```dvd_rentals.actor```** table labeled as 1 to 7 to have a better view of the data connection, as the image below:

<p align="center">
<img src="/IMG/EDR.png" width=70% height=70%>
</p>

---

## Idetifying Key Columns
In order to generate each customer insight for answering questions, I found out that the following inputs was needed: 

  * **```category_name```**: The name of the top 2 ranking categories
  * **```rental_count```**: How many total films have they watched in this category?
  * **```average_comparison```**: How many more films has the customer watched compared to the average DVD Rental Co customer?
  * **```percentile```**: How does the customer rank in terms of the top X% compared to all other customers in this film category?
* **```category_percentage```**: What proportion of each customer’s total films watched does this count make?

 <br /> 

**FINDING**: 

With the **```category_name```**, **```average_comparison```**, **```percentile```** and **```category_percentage```** are going to need some intense SQL calculations to generate these outputs, in that **```rental_count```** is going to be the key for my analysis.

Therefore, I would focus on the columns that needed to generate this all important value.

---

 ## Identifying Start & End Points

In order to generate datasets required to calculate **```rental_count```** at a **```customer_id```** level, the following information was needed:
  * **```customer_id```**
  * **```category_name```**

 <br /> 
 
  <p align="center">
<img src="/IMG/EDR.png" width=70% height=70%>
</p>

 However, if going back to the EDR review, I also noticed that the **```dvd_rentals.rental```** table was the only place where my **```customer_id```** field exists and the **```dvd_rentals.category```** table was the only table which I can get values of **```category_name```** field.

Thus, I need to somehow connect all the data dots from tables starting from **```dvd_rentals.rental```** labeled as **number 1** all the way through to table **number 5** - **```dvd_rentals.category```**. 

 <p align="center">
<img src="/IMG/EDR(2).png" width=70% height=70%>
</p>

<br /> 

In order to do that, identifying the **foreign keys** as the common ground for table joining, or in other words, the route from the start **(rental table)** to our final destination **(inventory table)**, is a must!

So here is the final version of my 4 part table joining journey itinerary:

|Join Journey Part|Start              |End                |Foreign Key       |
|-----------------|-------------------|-------------------|------------------|
|**Part 1**       |```rental```       |```inventory```    |```inventory_id```|
|**Part 2**       |```inventory```    |```film```         |```film_id```     |
|**Part 3**       |```film```         |```film_category```|```film_id```     |
|**Part 4**       |```film_category```|```category```     |```category_id``` |

<br /> 

In short, let's imagine my data exploration journey broken down into different parts as illustrated below: 

<p align="center">
<img src="/IMG/DE-P1.png" width=70% height=70%>
</p>

<p align="center">
<img src="/IMG/DE-P2.png" width=70% height=70%>
</p>

<p align="center">
<img src="/IMG/DE-P3.png" width=70% height=70%>
</p>

<p align="center">
<img src="/IMG/DE-P4.png" width=70% height=70%>
</p>

With those information - the start and end points of my data joining journey are defined. The next important step is to figure out how to combine our data to get these two fields together in the same SQL table output!

---

## Start With The First

As can be seen from the data journey within the [4 part table above](#identifying-start--end-points), my data journey first started with the **Part 1** - which will be between the **```rental```** and the **```inventory```** tables:

<p align="center">
<img src="/IMG/DE-P1.png" width=70% height=70%>

Therefore, I will focus on the data exploration process in these two tables in this part.

For this question, I actually needed to answer 3 additional ones:
1. [What is **the purpose** of joining these two tables?](#question-1)
2. [What is **the distribution of foreign keys** within each table?](#question-2)
3. [How many **unique foreign key values** exist in each table?](#question-3)

 <br /> 

## Question 1

If going back to the insights found in the [Identify Key Columns](#idetifying-key-columns), the important thing needed was to **generate the **```rental_count```** calculation** - the number of films that a customer has watched in a specific category.

In order to do this, I would need to: 

> Keep all of the customer rental records from **rental table** and match up each record with its equivalent **```film_id```** value from the **inventory table**.

Ok, so now that I got the purpose for joining data tables. However, there were a few unknowns that needed to address as I was going to match the **```inventory_id```** foreign key between the rental and inventory tables:
1. **How many records exist per **```inventory_id```** value in rental or inventory tables?** 
2. **How many **overlapping** and **missing unique foreign** key values are there between the two tables?**

Therefore, the next important steps was to take a deeper look at two tables values in order to answer the above questions.

---
## Inspecting the table values

> 1. **How many records exist per **```inventory_id```** value in rental or inventory tables?**

There are 3 possible hypotheses for this question:
* [**Hypothesis 1:** The number of unique **```inventory_id```** records will be equal in both **```dvd_rentals.rental```** and **```dvd_rentals.inventory```** tables](#h1-the-number-of-unique-inventory_id-records-will-be-equal-in-both-dvd_rentalsrental-and-dvd_rentalsinventory-tables)

* [**Hypothesis 2:** There will be a multiple records per unique **```inventory_id```** in the **```dvd_rentals.rental```** table](#h2-there-will-be-a-multiple-records-per-unique-inventory_id-in-the-dvd_rentalsrental-table)

* [**Hypothesis 3:** There will be multiple **```inventory_id```** records per unique **```film_id```** value in the **```dvd_rentals.inventory```** table](#h3-there-will-be-multiple-inventory_id-records-per-unique-film_id-value-in-the-dvd_rentalsinventory-table)

Thus, I will conduct tests on these assumptions to verify the results.

---
 ### a. Validating Hypotheses 

#### **H1:** The number of unique **```inventory_id```** records will be equal in both **```dvd_rentals.rental```** and **```dvd_rentals.inventory```** tables 
 <br /> 

```sql
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
```
⚡ **Result:**
|table_name|count|
|----------|-----|
|inventory table|4581 |
|rental table|4580 |
 
 <br /> 

**FINDING**: 

There seems to be 1 additional **```inventory_id```** value in the **```dvd_rentals.inventory```** table compared to the **```dvd_rentals.rental```** table

---

#### **H2:** There will be a multiple records per unique **```inventory_id```** in the **```dvd_rentals.rental```** table

 <br /> 

```sql
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
```

⚡ **Result:**
|row_counts|count_of_target_values|
|----------|----------------------|
|1         |4                     |
|2         |1126                  |
|3         |1151                  |
|4         |1160                  |
|5         |1139                  |

 <br /> 

**FINDING**: 

I can indeed confirm that there are multiple rows per **```inventory_id```** value in **```dvd_rentals.rental```** table

---

#### **H3:** There will be multiple **```inventory_id```** records per unique **```film_id```** value in the **```dvd_rentals.inventory```** table

<br /> 

```sql
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
```

⚡ **Result:**
|row_counts|count_of_target_values|
|----------|----------------------|
|2         |133                   |
|3         |131                   |
|4         |183                   |
|5         |136                   |
|6         |187                   |
|7         |116                   |
|8         |72                    |

<br /> 

**FINDING**: 

I can confirm that there are indeed multiple unique **```inventory_id```** per **```film_id```** value in the **```dvd_rentals.inventory```** table.

<br /> 

### b. Hypotheses Summary
<br /> 

> **1. Hypothesis 1:** The number of unique **```inventory_id```** records will be equal in both **```dvd_rentals.rental```** and **```dvd_rentals.inventory```** tables

**1.1 RESULT:** 
|table_name|count|
|----------|-----|
|inventory table|4581 |
|rental table|4580 |

**1.2 CONCLUSION**: ```INVALID HYPOTHESIS [FALSE]```

<br /> 

> **2. Hypothesis 2:** There will be a multiple records per unique **```inventory_id```** in the **```dvd_rentals.rental```** table

**2.1 RESULT:** 
|row_counts|count_of_target_values|
|----------|----------------------|
|1         |4                     |
|2         |1126                  |
|3         |1151                  |
|4         |1160                  |
|5         |1139                  |

**2.2 CONCLUSION**: ```VALID HYPOTHESIS [TRUE]```

<br /> 

> **3. Hypothesis 3:** There will be multiple **```inventory_id```** records per unique **```film_id```** value in the **```dvd_rentals.inventory```** table

**3.1 RESULT:**
|row_counts|count_of_target_values|
|----------|----------------------|
|2         |133                   |
|3         |131                   |
|4         |183                   |
|5         |136                   |
|6         |187                   |
|7         |116                   |
|8         |72                    |

**3.2 CONCLUSION**: ```VALID HYPOTHESIS [TRUE]```
<br /> 

As I had inspected the two tables in question to validate 3 hypotheses about the data, the key next step was to see how foreign key values are distributed in order to have a further investigation into the raw datasets.

### c. Foreign Keys Distribution Analysis
## Question 2

One of the first places to start inspecting my datasets is to look at **the distribution of foreign key values** in each rental and inventory table used for my join.

* **TABLE 1:** **```dvd_rentals.rental```**
```sql
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
```

⚡ **Result:**
|row_counts|count_of_fk_values|
|----------|------------------|
|1         |4                 |
|2         |1126              |
|3         |1151              |
|4         |1160              |
|5         |1139              |

 <br /> 

* **TABLE 2:** **```dvd_rentals.inventory```**
```sql
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
```

⚡ **Result:**
|row_counts|count_of_fk_values|
|----------|------------------|
|1         |4581              |

 <br /> 

**FINDING**:   
* **Rental table**: There may exist 1 or more record for each unique **```inventory_id```** value in this table - **"a 1-to-many relationship"** for the **```inventory_id```**
* **Inventory table**: For every single unique **```inventory_id```** value in the inventory table - there exists only 1 table row record - **"a 1-to-1 relationship"**

 <br /> 

### d. Foreign Key Overlap Analysis
 

## Question 3

> 2. How many **overlapping** and **missing unique foreign** key values are there between the two tables?

 <br /> 

**How many foreign keys only exist in the left table and not in the right?**
```sql
SELECT 
  COUNT(DISTINCT rental.inventory_id)
FROM dvd_rentals.rental
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);
```

OR

```sql
SELECT 
  COUNT(DISTINCT rental.inventory_id)
FROM dvd_rentals.rental AS rental
LEFT JOIN dvd_rentals.inventory AS inventory
ON inventory.inventory_id = rental.inventory_id
WHERE inventory.inventory_id IS NULL;
```
⚡ **Result:**
|count|
|-----|
|0    |

**FINDING:** 

There are no **```inventory_id```** records which appear in the **```dvd_rentals.rental```** table which does not appear in the **```dvd_rentals.inventory```** table.

 <br /> 

**How many foreign keys only exist in the right table and not in the left?**

```sql
SELECT 
  COUNT(DISTINCT inventory.inventory_id)
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);
```

OR

```sql
SELECT 
  COUNT(DISTINCT inventory.inventory_id)
FROM dvd_rentals.inventory AS inventory
LEFT JOIN dvd_rentals.rental AS rental
ON inventory.inventory_id = rental.inventory_id
WHERE rental.inventory_id IS NULL;
```

⚡ **Result:**
|count|
|-----|
|1    |  

 <br /> 

**FINDING:** 

There are **1 foreign key record** that only exists in the right table

 <br /> 

Now that I had identified 1 foreign key value that contained only in the **```dvd_rentals.inventory```** table. Let's take a more detailed look on this value by generating the following query:
* **Further inspection:**
```sql
SELECT *
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);
```

⚡ **Result:**
|inventory_id|film_id|store_id|last_update             |
|------------|-------|--------|------------------------|
|5           |1      |2       |2006-02-15T05:09:17.000Z|

<br /> 

### e. Joint Foreign Keys

Since I already identified that all of the **```inventory_id```** values which exist in **```dvd_rentals.rental```** table also exists in the **```dvd_rentals.inventory```** dataset - I can now redraw our venn diagram from before with a representation of what my exact data looks like.

<p align="center">
<img src="https://github.com/ndleah/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/Venn-Diagram.png" width=70% height=70%>
</p>

Then I can quickly perfom a **```LEFT SEMI JOIN```** with **```WHERE EXIST```** function to get the count of **unique foreign key values**:

```sql
SELECT
  COUNT(DISTINCT rental.inventory_id)
FROM dvd_rentals.rental
WHERE EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);
```

OR

```sql
SELECT
  COUNT(DISTINCT r.inventory_id)
FROM dvd_rentals.rental AS rental
LEFT JOIN dvd_rentals.inventory AS inventory
ON rental.inventory_id = inventory.inventory_id
WHERE i.inventory_id IS NOT NULL;
```

⚡ **Result:**
|count|
|-----|
|4580 |  

**FINDING:**

I noticed that this number was actually the same with what I had calculated for the distinct counts for the **```dvd_rentals.rental```** table from above!

Therefore, one possible hypothesis could be: There are no difference between **```INNER JOIN```** and **```LEFT JOIN```** in this case example. Let's find out the truth for our hypothesis that will be covered in next steps.

 <br /> 

### f. Implementing The Join(s)

Inspect if the **```INNER JOIN```** is the same with **```LEFT JOIN```** or not in this case example:

```sql  
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
```

**Result:**
|join_type|record_count|unique_key_values|
|---------|------------|-----------------|
|inner join|16044       |4580             |
|left join|16044       |4580             |

**FINDING:** 

There is no difference between an **```INNER JOIN```** or **```LEFT JOIN```** for these datasets.

---

# Summary

In summary, I have now successfully answered all 3 questions for table join:

**1. What is the purpose of joining these two tables?**

> I need to keep all of the customer rental records from **```dvd_rentals.rental```** and match up each record with its equivalent **```film_id```** value from the **```dvd_rentals.inventory```** table.

**2. What is the distribution of foreign keys within each table?**
> There is a **1-to-many relationship** between the **```inventory_id```** and the rows of the **```dvd_rentals.rental```** table

|row_counts|count_of_fk_values|
|----------|------------------|
|1         |4                 |
|2         |1126              |
|3         |1151              |
|4         |1160              |
|5         |1139              |

 <br /> 

> There is a **1-to-1 relationship** between the **```inventory_id```** and the rows of the **```dvd_rentals.inventory```** table

|row_counts|count_of_fk_values|
|----------|------------------|
|1         |4581              |

 <br /> 

**3. How many unique foreign key values exist in each table?**

All of the foreign key values in **```dvd_rentals.rental```** exist in **```dvd_rentals.inventory```** and only 1 record **```inventory_id```** = 5 exists only in the **```dvd_rentals.inventory```** table.

There is an overlap of **4,580 unique** **```inventory_id```** **foreign key values** which will exist after the join is complete.

---

## Returning To The Data Exploration Journey

<p align="center">
<img src="/IMG/done-DE-P1.png" width=70% height=70%>
</p>

Now that I've covered **part 1** of the data exploration before joining table. Phew! We nailed it guys. This was a super long process and it just feel like forever. But hold up, **there will more to come** :D ```*screaming in SQL*```

For **part 2, 3** and **4**, I repeated each steps of the data exploration journey from **part 1**. However, in this document, let's end the section here because it's gonna be super long if I decided to list all the repeated steps here (Also because I'm lazy...)

However, you can find all the code and answers for part 2, 3 and 4 within this folder as well:

**Part 2**
<p align="center">
<img src="/main/IMG/DE-P2.png" width=70% height=70%>
</p>

[![View P2](https://img.shields.io/badge/view%20P2-here-blue?style=for-the-badge&logo=GITHUB)](/DE-P2.sql)


**Part 3**
<p align="center">
<img src="/main/IMG/DE-P3.png" width=70% height=70%>
</p>

[![View P3](https://img.shields.io/badge/view%20P3-here-brightgreen?style=for-the-badge&logo=GITHUB)](/DE-P3.sql)


**Part 4**
<p align="center">
<img src="/IMG/DE-P4.png" width=70% height=70%>
</p>

[![View P4](https://img.shields.io/badge/view%20P4-here-yellow?style=for-the-badge&logo=GITHUB)](/DE-P4.sql)


___________________________________

<p>&copy; 2021 Leah Nguyen</p>