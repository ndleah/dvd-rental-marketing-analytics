![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/ndleah)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/ndleah?tab=repositories)

# DVD Rental Marketing Analytics <img src="https://media3.giphy.com/media/w85OYSOzXQaiVzZswl/200.gif" align="right" width="120" />

> This case study is contained within the [Serious SQL](https://www.datawithdanny.com) by [Danny Ma](https://www.linkedin.com/in/datawithdanny/). With this **Marketing Analytics Case Study**, I was asked to support the customer analytics team at **DVD Rental Co** who have been tasked with generating the necessary data points required to populate specific parts of this first-ever customer email campaign.


# 📕 Table of contents
<!--ts-->
   * 🛠️ [Requirements](#️-requirements)
   * 📂 [Data Overview](#-data-overview)
   * 🚀 [Solution](#-solutions)
   * 🧙‍♂️ [Result](#️-result)
   * 🐋 [Bonus Section](#-bonus-section)
<!--te-->

# 🛠️ Requirements
The marketing team have shared with me a draft of the email they wish to send to their customers:

<p align="center">
<img src="/IMG/email-template.png" width=40% height=40%>

## 📋 Requirement 1: Top 2 Categories

<details>
<summary>
Click to view
</summary>

For each customer, I need to identify the top 2 categories each customer based off their past rental history. 

<p align="center">
<img src="/IMG/requirement-1.gif" width=40% height=40%>

</details>

## 📋 Requirement 2: Category Film Recommendations

<details>
<summary>
Click to view
</summary>

The marketing team has also requested for the 3 most popular films for each customer’s top 2 categories.

<p align="center">
<img src="/IMG/requirement-2.gif" width=40% height=40%

</details>
</details>

## 📋 Requirement 3 & 4: Individual Customer Insights

<details>
<summary>
Click to view
</summary>
 
The number of films watched by each customer in their **top 2 categories** is required as well as some specific insights.

For the 1st category, the marketing requires the following insights **```(requirement 3)```**:

1. How many total films have they watched in their top category?
2. How many more films has the customer watched compared to the average DVD Rental Co customer?
3. How does the customer rank in terms of the top X% compared to all other customers in this film category?

For the second ranking category **```(requirement 4)```**:
   
1. How many total films has the customer watched in this category?
2. What proportion of each customer’s total films watched does this count make?

<p align="center">
<img src="/IMG/requirement-3-4.gif" width=40% height=40%>

</details>

## 📋 Requirement 5: Favorite Actor Recommendations

<details>
<summary>
Click to view
</summary>

Along with the top 2 categories, marketing has also requested top actor film recommendations where **up to 3 more films are included in the recommendations list as well as the count of films by the top actor.**

<p align="center">
<img src="/IMG/requirement-5.gif" width=40% height=40%>

</details>

# 📂 Data Overview
## Data Exploration
In this project, I have a total of 7 tables in our ERD (Entity Relationship Diagram), highlighting the important columns which I should use to join my tables for the data analysis task. 

Therefore, the first section will cover the data inspection process of these tables in order to find out the best JOIN type that will be the most suitable for the later problem solving stage.

[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-b11226?style=for-the-badge&logo=GITHUB)](/Data%20Exploration)

## Data Join

Now that I’ve identified the key columns and highlighted some things I need to keep in mind when performing some table joins for my data analysis - next exciting step is to join them together.

[![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-b11226?style=for-the-badge&logo=GITHUB)](/Data%20Join)

# 🚀 Solutions
> Finally, after I’ve combined all of different datasets together into a single base table which I can use for our insights, this section will aim to cover those core calculated fields which I broke down in the first [Key Business Requirements](#Key-Business-Requirements) section of this case study.
## View the entire solution for this part [**here**]

[![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-b11226?style=for-the-badge&logo=GITHUB)](/Problem%20Solving)

# 🧙‍♂️ Result

Assume this email template will be sent to a customer with **```customer_id = 1```**, I will first go back to the requirements of the marketing team and by that, answer each question one by one regarding this customer's scenario.

<details>
<summary>
Requirement 1: Top 2 Categories
</summary>

|customer_id|category_name|rental_count|category_rank|
|-----------|-------------|------------|-------------|
|1          |Classics     |6           |1            |
|1          |Comedy       |5           |2            |

</details>

<details>
<summary>
Requirement 2: Category Film Recommendations
</summary>

|customer_id|category_name|category_rank|film_id|title              |rental_count|reco_rank|
|-----------|-------------|-------------|-------|-------------------|------------|---------|
|1          |Classics     |1            |891    |TIMBERLAND SKY     |31          |1        |
|1          |Classics     |1            |358    |TIMBERLAND SKY     |28          |2        |
|1          |Classics     |1            |951    |VOYAGE LEGALLY     |28          |3        |
|1          |Comedy       |2            |1000   |ZORRO ARK          |31          |1        |
|1          |Comedy       |2            |127    |CAT CONEHEADS      |30          |2        |
|1          |Comedy       |2            |638    |OPERATION OPERATION|27          |3        |

</details>

<details>
<summary>
Requirement 3 & 4: Individual Customer Insights
</summary>

**```FIRST CATEGORY INSIGHTS```**

|customer_id|category_name|rental_count|average_comparison|percentile         |
|-----------|-------------|------------|------------------|-------------------|
|1          |Classics     |6           |4                 |1                  |

**```SECOND CATEGORY INSIGHTS```**
|customer_id|category_name|rental_count|category_percentage|
|-----------|-------------|------------|-------------------|
|1          |Comedy       |5           |16                 |
 
 </details>

<details>
<summary>
Requirement 5: Favorite Actor Recommendations
</summary>

**Result:**

|customer_id|first_name|last_name|rental_count|title                 |film_id|actor_id|reco_rank|
|-----------|----------|---------|------------|----------------------|-------|--------|---------|
|1          |VAL       |BOLGER   |6           |PRIMARY GLASS         |697    |37      |1        |
|1          |VAL       |BOLGER   |6           |ALASKA PHANTOM        |12     |37      |2        |
|1          |VAL       |BOLGER   |6           |METROPOLIS COMA       |572    |37      |3        |

</details>

 ## Final Output
Hooray! Finally, this is what out final input looks like:

<p align="center">
<img src="/IMG/final-output.png" width=50% height=50%>


# ✨ Contribution

Contributions, issues, and feature requests are welcome!

To contribute to this project, see the GitHub documentation on **[creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request)**.

# 👏 Support

Give a ⭐️ if you like this project!
___________________________________

<p>&copy; 2021 Leah Nguyen</p>

