--Requirements
--Input data
--Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
--Change transaction date to the just be the month of the transaction
--Total up the transaction values so you have one row for each bank and month combination
--Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
--Without losing all of the other data fields, find:
--The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
--The average transaction value per rank, call this field 'Avg Transaction Value per Rank'
--Output the data

WITH Main_table AS
(
SELECT 
SPLIT_PART(TRANSACTION_CODE, '-', 1) AS Bank,
MONTH(TO_DATE(TRANSACTION_DATE, 'dd/MM/YYYY hh:mi:ss')) AS transaction_month,
ROW_NUMBER() OVER(PARTITION BY TRANSACTION_MONTH ORDER BY SUM(VALUE) DESC) AS monthly_rank,
SUM(value) AS total_value
FROM PD2023_WK01
GROUP BY BANK, transaction_month
ORDER BY TRANSACTION_MONTH, BANK
)
,
Bank_Avg_monthly_ranks AS
(
SELECT BANK,
AVG(Monthly_rank) AS Avg_Rank_per_Bank
FROM main_table
GROUP BY bank
)
,
Montly_rank_avg_value AS
(
SELECT MONTHLY_RANK, 
AVG(Total_value) AS Average_value_per_rank
FROM main_table
GROUP BY Monthly_rank
)
SELECT *
FROM MAIN_TABLE m
JOIN BANK_AVG_MONTHLY_RANKS b 
ON b.bank = m.bank
JOIN montly_rank_avg_value r
ON m.Monthly_rank = r.Monthly_rank