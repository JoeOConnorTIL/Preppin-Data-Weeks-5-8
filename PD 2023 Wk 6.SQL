--Requirements
--Input the data
--Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
--Clean the question categories so they don't have the platform in from of them
--e.g. Mobile App - Ease of Use should be simply Ease of Use
--Exclude the Overall Ratings, these were incorrectly calculated by the system
--Calculate the Average Ratings for each platform for each customer 
--Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
--Catergorise customers as being:
--Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
--Mobile App Fans if difference >= 1
--Online Interface Fan
--Online Interface Superfan
--Neutral if difference is between 0 and 1
--Calculate the Percent of Total customers in each category, rounded to 1 decimal place
--Output the data
WITH MAIN AS (
  SELECT 
    CUSTOMER_ID, 
    RESPONSE, 
    SPLIT_PART(CATEGORY, '___', 1) AS Online_or_Mobile, 
    SPLIT_PART(CATEGORY, '___', 2) AS Category 
  FROM 
    PD2023_WK06_DSB_CUSTOMER_SURVEY UNPIVOT (
      Response FOR Category IN (
        MOBILE_APP___EASE_OF_USE, MOBILE_APP___EASE_OF_ACCESS, 
        MOBILE_APP___NAVIGATION, MOBILE_APP___LIKELIHOOD_TO_RECOMMEND, 
        MOBILE_APP___OVERALL_RATING, ONLINE_INTERFACE___EASE_OF_USE, 
        ONLINE_INTERFACE___EASE_OF_ACCESS, 
        ONLINE_INTERFACE___NAVIGATION, 
        ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND, 
        ONLINE_INTERFACE___OVERALL_RATING
      )
    ) 
  ORDER BY 
    CUSTOMER_ID
), 
Online AS (
  SELECT 
    CUSTOMER_ID, 
    CATEGORY, 
    RESPONSE AS ONLINE 
  FROM 
    MAIN 
  WHERE 
    ONLINE_OR_MOBILE = 'ONLINE_INTERFACE'
), 
Mobile AS (
  SELECT 
    CUSTOMER_ID, 
    CATEGORY, 
    RESPONSE AS MOBILE 
  FROM 
    MAIN 
  WHERE 
    ONLINE_OR_MOBILE = 'MOBILE_APP'
), 
Pivoted AS (
  SELECT 
    m.customer_id, 
    m.category, 
    mobile, 
    online 
  FROM 
    MOBILE m 
    JOIN ONLINE o ON m.customer_id = o.customer_id 
    AND m.category = o.category 
  WHERE 
    m.category != 'OVERALL_RATING'
), 
Categorised AS (
  SELECT 
    CUSTOMER_ID, 
    AVG(MOBILE) AS MOBILE, 
    AVG(ONLINE) AS ONLINE, 
    AVG(MOBILE) - AVG(ONLINE) AS DIFFERENCE, 
    CASE WHEN DIFFERENCE >= 2 THEN 'Mobile App Superfan' WHEN DIFFERENCE >= 1 THEN 'Mobile App Fan' WHEN DIFFERENCE <= -2 THEN 'Online Interface Superfan' WHEN DIFFERENCE <= -1 THEN 'Online Interface Fan' ELSE 'Neutral' END AS Category, 
    'Link' AS Link 
  FROM 
    PIVOTED 
  GROUP BY 
    CUSTOMER_ID
), 
total_customers AS (
  SELECT 
    COUNT(DISTINCT CUSTOMER_ID) AS total, 
    'Link' AS Link 
  FROM 
    PD2023_WK06_DSB_CUSTOMER_SURVEY
) 
SELECT 
  category, 
  ROUND(
    (
      COUNT(CUSTOMER_ID)/ MAX(total)
    )* 100, 
    1
  ) AS Percentage, 
FROM 
  CATEGORISED c 
  JOIN total_customers t ON c.link = t.link 
GROUP BY 
  category