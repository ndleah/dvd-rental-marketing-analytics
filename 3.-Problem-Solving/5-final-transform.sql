/********************* 
PROBLEM SOLVING:

////////////////////////
FINAL TRANSFORMATION
**********************/
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

/*Result:
|customer_id|cat_1   |cat_1_reco_1|cat_1_reco_2|cat_1_reco_3          |cat_2|cat_2_reco_1|cat_2_reco_2|cat_2_reco_3       |actor         |actor_reco_1        |actor_reco_2         |actor_reco_3          |insight_cat_1                                                                                                              |insight_cat_2                                                                 |insight_actor                                                                                                    |
|-----------|--------|------------|------------|----------------------|-----|------------|------------|-------------------|--------------|--------------------|---------------------|----------------------|---------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
|1          |Classics|Timberland Sky|Gilmore Boiled|Voyage Legally        |Comedy|Zorro Ark   |Cat Coneheads|Operation Operation|Val Bolger    |Primary Glass       |Alaska Phantom       |Metropolis Coma       |You've watched 6 Classics films, that's 4 more than the DVD Rental Co average and puts you in the top 1% of Classics gurus!|You've watched 5 Comedy films making up 16% of your entire viewing history!   |You've watched 6 films featuring Val Bolger! Here are some other films Val stars in that might interest you!     |
|2          |Sports  |Gleaming Jawbreaker|Talented Homicide|Roses Treasure        |Classics|Frost Head  |Gilmore Boiled|Voyage Legally     |Gina Degeneres|Goodfellas Salute   |Wife Turn            |Dogma Family          |You've watched 5 Sports films, that's 3 more than the DVD Rental Co average and puts you in the top 2% of Sports gurus!    |You've watched 4 Classics films making up 15% of your entire viewing history! |You've watched 5 films featuring Gina Degeneres! Here are some other films Gina stars in that might interest you!|
|3          |Action  |Rugrats Shakespeare|Suspects Quills|Handicap Boondock     |Sci-Fi|Goodfellas Salute|English Bulworth|Graffiti Love      |Jayne Nolte   |Sweethearts Suspects|Dancing Fever        |Invasion Cyclone      |You've watched 4 Action films, that's 2 more than the DVD Rental Co average and puts you in the top 4% of Action gurus!    |You've watched 3 Sci-Fi films making up 12% of your entire viewing history!   |You've watched 4 films featuring Jayne Nolte! Here are some other films Jayne stars in that might interest you!  |
|4          |Horror  |Pulp Beverly|Family Sweet|Swarm Gold            |Drama|Hobbit Alien|Harry Idaho |Witches Panic      |Walter Torn   |Curtain Videotape   |Lies Treatment       |Nightmare Chill       |You've watched 3 Horror films, that's 2 more than the DVD Rental Co average and puts you in the top 8% of Horror gurus!    |You've watched 2 Drama films making up 9% of your entire viewing history!     |You've watched 4 films featuring Walter Torn! Here are some other films Walter stars in that might interest you! |
|5          |Classics|Timberland Sky|Frost Head  |Gilmore Boiled        |Animation|Juggler Hardly|Dogma Family|Storm Happiness    |Karl Berry    |Virginian Pluto     |Stagecoach Armageddon|Telemark Heartbreakers|You've watched 7 Classics films, that's 5 more than the DVD Rental Co average and puts you in the top 1% of Classics gurus!|You've watched 6 Animation films making up 16% of your entire viewing history!|You've watched 4 films featuring Karl Berry! Here are some other films Karl stars in that might interest you!    |
*/