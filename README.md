
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/nduongthucanh)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/nduongthucanh?tab=repositories)


# Serious SQL - Marketing Analytics Case Study
[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)
[![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/2.-Data-Join)
[![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/intro-cover.gif" width=100% height=100%>

This case study is contained within the [Serious SQL](https://www.datawithdanny.com) by [Danny Ma](https://www.linkedin.com/in/datawithdanny/). With this **Marketing Analytics Case Study**, I was asked to support the customer analytics team at **DVD Rental Co** who have been tasked with generating the necessary data points required to populate specific parts of this first-ever customer email campaign.


<p align="center">
  <img src="https://forthebadge.com/images/badges/built-with-love.svg">
  <img src="https://forthebadge.com/images/badges/powered-by-coffee.svg">
</p>

<p align="center">
  <img src="https://forthebadge.com/images/badges/check-it-out.svg">
</p>

 <br /> 



# 📕 Table of contents
<!--ts-->
   * 🛠️ [Requirements](#️-requirements)
   * 📂 [Data Overview](#-data-overview)
     * [Data Exploration](#data-exploration)
     * [Data Join](#data-join)
   * 🚀 [Solution](#-solutions)
   * 🧙‍♂️ [Result](#️-result)
   * 🐋 [Bonus Section](#-bonus-section)
<!--te-->


 <br /> 


# 🛠️ Requirements
The marketing team have shared with me a draft of the email they wish to send to their customers:

 <br /> 


<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/email-template.png" width=50% height=50%>

 <br /> 

## Requirement #1
* **Top 2 Categories**

For each customer, I need to identify the top 2 categories each customer based off their past rental history. 

 <br /> 

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/requirement-1.gif" width=50% height=50%>

 <br /> 

## Requirement #2
* **Category Film Recommendations**

The marketing team has also requested for the 3 most popular films for each customer’s top 2 categories.

 <br /> 

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/requirement-2.gif" width=50% height=50%>

 <br /> 

## Requirement #3 & #4
* **Individual Customer Insights**

The number of films watched by each customer in their **top 2 categories** is required as well as some specific insights.

For the 1st category, the marketing requires the following insights **```(requirement 3)```**:

> 1. How many total films have they watched in their top category?
> 2. How many more films has the customer watched compared to the average DVD Rental Co customer?
> 3. How does the customer rank in terms of the top X% compared to all other customers in this film category?

For the second ranking category **```(requirement 4)```**:
   
1. How many total films has the customer watched in this category?
2. What proportion of each customer’s total films watched does this count make?

 <br /> 

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/requirement-3-4.gif" width=50% height=50%>

 <br /> 

## Requirement #5
* **Favorite Actor Recommendations**

Along with the top 2 categories, marketing has also requested top actor film recommendations where **up to 3 more films are included in the recommendations list as well as the count of films by the top actor.**

 <br /> 

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/requirement-5.gif" width=50% height=50%>

 <br /> 

# 📂 Data Overview
## **Data Exploration**
> In this project, I have a total of 7 tables in our ERD (Entity Relationship Diagram), highlighting the important columns which I should use to join my tables for the data analysis task. 
> 
> Therefore, the first section will cover the data inspection process of these tables in order to find out the best JOIN type that will be the most suitable for the later problem solving stage.

## View the entire solution for this part [**here**](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration) or
[![View Data Exploration Folder](https://img.shields.io/badge/View-Data_Exploration_Folder-red?style=for-the-badge&logo=GITHUB)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/1.-Data-Exploration)

**Preview:**

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/sc-dep1.gif" width=100% height=100%>

 <br /> 

---

## **Data Join**

> Now that I’ve identified the key columns and highlighted some things I need to keep in mind when performing some table joins for my data analysis - next exciting step is to join them together.

## View the entire solution for this part [**here**](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/2.-Data-Join) or
[![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?style=for-the-badge&logo=GITHUB)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/2.-Data-Join)

 <br /> 

**Preview:**

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/sc-dep2.gif" width=100% height=100%>


# 🚀 Solutions
> Finally, after I’ve combined all of different datasets together into a single base table which I can use for our insights, this section will aim to cover those core calculated fields which I broke down in the first [Key Business Requirements](#Key-Business-Requirements) section of this case study.
## View the entire solution for this part [**here**](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving) or
[![View Data Join Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?style=for-the-badge&logo=GITHUB)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)

 <br /> 

**Preview:**

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/sc-dep3.gif" width=100% height=100%>

# 🧙‍♂️ Result
okay so now I've successfully generated all the insights needed for this email template, let's go on to the final step to inspect the final output appearance of the actual email when sending it to the end customers. To do this, I'm gonna craft together the [draft template](#key-business-requirements) the marketing team has already provided with our valuable data found in previous parts.

Let's assume this email template will be sent to a customer with **```customer_id = 1```**. Therefore, I will first go back to the requirements of the marketing team and by that, answer each question one by one regarding this customer's scenario.
 <br /> 

## Requirement #1
* **Top 2 Categories**

**Result:**
|customer_id|category_name|rental_count|category_rank|
|-----------|-------------|------------|-------------|
|1          |Classics     |6           |1            |
|1          |Comedy       |5           |2            |

 <br /> 

**Email Mock-up**:
<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/template_r1.png" width=50% height=50%>

 <br /> 

## Requirement #2
* **Category Film Recommendations**

**Result:**
|customer_id|category_name|category_rank|film_id|title              |rental_count|reco_rank|
|-----------|-------------|-------------|-------|-------------------|------------|---------|
|1          |Classics     |1            |891    |TIMBERLAND SKY     |31          |1        |
|1          |Classics     |1            |358    |TIMBERLAND SKY     |28          |2        |
|1          |Classics     |1            |951    |VOYAGE LEGALLY     |28          |3        |
|1          |Comedy       |2            |1000   |ZORRO ARK          |31          |1        |
|1          |Comedy       |2            |127    |CAT CONEHEADS      |30          |2        |
|1          |Comedy       |2            |638    |OPERATION OPERATION|27          |3        |

 <br /> 

**Email Mock-up**:
<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/template_r2.png" width=50% height=50%>

 <br /> 

## Requirement #3 & #4
* **Individual Customer Insights**

**Result:**

**```FIRST CATEGORY INSIGHTS```**

|customer_id|category_name|rental_count|average_comparison|percentile         |
|-----------|-------------|------------|------------------|-------------------|
|1          |Classics     |6           |4                 |1                  |

**```SECOND CATEGORY INSIGHTS```**
|customer_id|category_name|rental_count|category_percentage|
|-----------|-------------|------------|-------------------|
|1          |Comedy       |5           |16                 |
 
 <br /> 

**Email Mock-up**:

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/template_r3-4.png" width=50% height=50%>

 <br /> 

## Requirement #5
* **Favorite Actor Recommendations**

**Result:**

|customer_id|first_name|last_name|rental_count|title                 |film_id|actor_id|reco_rank|
|-----------|----------|---------|------------|----------------------|-------|--------|---------|
|1          |VAL       |BOLGER   |6           |PRIMARY GLASS         |697    |37      |1        |
|1          |VAL       |BOLGER   |6           |ALASKA PHANTOM        |12     |37      |2        |
|1          |VAL       |BOLGER   |6           |METROPOLIS COMA       |572    |37      |3        |

 <br /> 

**Email Mock-up**:

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/template_r5.png" width=50% height=50%>

 <br /> 

 ## Final Output
Hooray! Finally, this is what out final input looks like:

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/final-output.png" width=50% height=50%>

# 🐋 Bonus Section

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/The_Office_GIF.gif" width=60% height=60%>

The following questions are part of this case study - these are example questions the Marketing team might be interested in as a bonus section which cover more in-depth insights of the email template!

1. Which film title was the most recommended for all customers?
2. How many customers were included in the email campaign?
3. Out of all the possible films - what percentage coverage do we have in our recommendations?
4. What is the most popular top category?
5. What is the 4th most popular top category?
6. What is the average percentile ranking for each customer in their top category rounded to the nearest 2 decimal places?
7. What is the cumulative distribution of the top 5 percentile values for the top category from the **```first_category_insights```** table rounded to the nearest round percentage?
8. What is the median of the second category percentage of entire viewing history?
9. What is the 80th percentile of films watched featuring each customer’s favourite actor?
10. What was the average number of films watched by each customer?
11. What is the top combination of top 2 categories and how many customers if the order is relevant (e.g. Horror and Drama is a different combination to Drama and Horror)
12. Which actor was the most popular for all customers?
13. How many films on average had customers already seen that feature their favourite actor rounded to closest integer?
14. What is the most common top categories combination if order was irrelevant and how many customers have this combination? (e.g. Horror and Drama is a the same as Drama and Horror)

## View the entire solution for this part [**here**](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving) or
[![View Data Join Folder](https://img.shields.io/badge/View-Bonus_Section_Folder-green?style=for-the-badge&logo=GITHUB)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/4.-Bonus-Section)

 <br /> 

# ✨ Contribution

Contributions, issues, and feature requests are welcome!

To contribute to Patronify, see the GitHub documentation on **[creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request)**.

# 👏 Support

Give a ⭐️ if you like this project!
___________________________________

<p>&copy; 2021 Leah Nguyen</p>