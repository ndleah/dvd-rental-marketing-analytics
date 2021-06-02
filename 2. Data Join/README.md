[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)
[![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/nduongthucanh?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/nduongthucanh)

# **[SERIOUS SQL: MARKETING ANALYTICS CASE STUDY](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis)**

# Data Overview - Data Join

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/table-join.gif" width=100% height=100%>
</p>

## **JOIN TABLE**

Now that we’ve done with the data exploration part of the joining journey - I will start to join all the data table for getting insights for our campaign objective as the query below:

 <br /> 

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

**Conclusion:** Hmm this result table actually seems good enough to me, which mean that we can end this part here (Wow, thanks to the super long session we have covered in the **[Data Exploration](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)** section previously, I can save up a lot of time in the Data Joining part). Great!

<br /> 

## **Next Steps**

### **In the next stage of this project, let's proceed to discover all of our core questions related to the data for the email marketing template that the Marketing team had requested**

<br /> 

View The Next Part: [![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)

Have you viewed the 1st part yet? Take a look here: [![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/2.-Data-Join)

Come back to main folder: [![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main)

___________________________________

<p>&copy; 2021 Leah Nguyen</p>