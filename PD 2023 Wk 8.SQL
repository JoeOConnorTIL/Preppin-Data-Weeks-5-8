--Input each of the 12 monthly files
--Create a 'file date' using the month found in the file name
--The Null value should be replaced as 1
--Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
--Remove any rows with 'n/a'
--Categorise the Purchase Price into groupings
--0 to 24,999.99 as 'Low'
--25,000 to 49,999.99 as 'Medium'
--50,000 to 74,999.99 as 'High'
--75,000 to 100,000 as 'Very High'
--Categorise the Market Cap into groupings
--Below $100M as 'Small'
--Between $100M and below $1B as 'Medium'
--Between $1B and below $100B as 'Large' 
--$100B and above as 'Huge'
--CURRENT_DATERank the highest 5 purchases per combination of: file date, Purchase Price Categorisation and Market Capitalisation Categorisation.
--Output only records with a rank of 1 to 5

WITH MAIN AS
(
SELECT *, 
01 AS File_Date
FROM PD2023_WK08_01
UNION
SELECT *,
02 AS File_Date
FROM PD2023_WK08_02
UNION 
SELECT *,
03 AS File_Date
FROM PD2023_WK08_03
UNION
SELECT *, 
04 AS File_Date
FROM PD2023_WK08_04
UNION
SELECT *,
05 AS File_Date
FROM PD2023_WK08_05
UNION 
SELECT *,
06 AS File_Date
FROM PD2023_WK08_06
UNION
SELECT *, 
07 AS File_Date
FROM PD2023_WK08_07
UNION
SELECT *,
08 AS File_Date
FROM PD2023_WK08_08
UNION 
SELECT *,
09 AS File_Date
FROM PD2023_WK08_09
UNION
SELECT *, 
10 AS File_Date
FROM PD2023_WK08_10
UNION
SELECT *,
11 AS File_Date
FROM PD2023_WK08_11
UNION 
SELECT *,
12 AS File_Date
FROM PD2023_WK08_12
)
,
Stage1 AS
(
SELECT *,
LEFT(SPLIT_PART(MARKET_CAP, '$', 2), (LENGTH (SPLIT_PART(MARKET_CAP, '$', 2)))-1) AS MC,
RIGHT(SPLIT_PART(MARKET_CAP, '$', 2), 1) AS multiplier,
CASE
WHEN MULTIPLIER = 'M' THEN CAST(MC AS DOUBLE)*1000000
WHEN MULTIPLIER = 'B' THEN CAST(MC AS DOUBLE)*1000000000
WHEN MULTIPLIER != 'M' AND MULTIPLIER != 'B' THEN CAST(SPLIT_PART(MARKET_CAP, '$', 2) AS DOUBLE)
END AS Market_Capitalisation,
CAST(SPLIT_PART(PURCHASE_PRICE, '$', 2) AS DOUBLE) AS PPRICE
FROM MAIN
WHERE Market_Cap != 'n/a'
)
,
Stage2 AS
(
SELECT *, 
CASE
WHEN PPRICE < 25000 THEN 'Low'
WHEN PPRICE < 50000 THEN 'Medium'
WHEN PPRICE < 75000 THEN 'High'
WHEN PPRICE < 100001 THEN 'Very High'
END AS PPRICE_GROUP,
CASE
WHEN MARKET_CAPITALISATION < 100000000 THEN 'Small'
WHEN MARKET_CAPITALISATION < 1000000000 THEN 'Medium'
ELSE 'Huge'
END AS MCAP_GROUP
FROM STAGE1
)
,
Stage3 AS
(
SELECT 
ROW_NUMBER() OVER ( PARTITION BY FILE_DATE, PPRICE_GROUP, MCAP_GROUP ORDER BY PPRICE ) AS Rank_,
MCAP_GROUP,
PPRICE_GROUP,
FILE_DATE, 
TICKER,
SECTOR
MARKET,
STOCK_NAME,
MARKET_CAPITALISATION,
PPRICE
FROM STAGE2
)
SELECT *
FROM STAGE3
WHERE Rank_ < 6