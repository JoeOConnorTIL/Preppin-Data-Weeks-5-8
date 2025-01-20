--For the Transaction Path table:
--Make sure field naming convention matches the other tables
--i.e. instead of Account_From it should be Account From
--For the Account Information table:
--Make sure there are no null values in the Account Holder ID
--Ensure there is one row per Account Holder ID
--Joint accounts will have 2 Account Holders, we want a row for each of them
--For the Account Holders table:
--Make sure the phone numbers start with 07
--Bring the tables together
--Filter out cancelled transactions 
--Filter to transactions greater than £1,000 in value 
--Filter out Platinum accounts
--Output the data

SELECT * 
FROM PD2023_WK07_ACCOUNT_HOLDERS;
SELECT *
FROM PD2023_WK07_ACCOUNT_INFORMATION;
SELECT *
FROM PD2023_WK07_TRANSACTION_DETAIL;
SELECT *
FROM PD2023_WK07_TRANSACTION_PATH;

WITH Account_Holders AS
(
SELECT
Account_holder_id,
Name,
DATE_OF_BIRTH,
FIRST_LINE_OF_ADDRESS,
CONCAT('0', CAST(CONTACT_NUMBER AS STRING)) AS Contact_number
FROM PD2023_WK07_ACCOUNT_HOLDERS
)
,
Account_Information AS
(
SELECT 
ACCOUNT_NUMBER,
ACCOUNT_TYPE,
VALUE AS ACCOUNT_HOLDER_ID,
BALANCE_DATE,
BALANCE
FROM PD2023_WK07_ACCOUNT_INFORMATION, LATERAL SPLIT_TO_TABLE(account_holder_id, ', ')
WHERE ACCOUNT_HOLDER_ID IS NOT NULL
)
,
ACC AS
(
SELECT
ACCOUNT_NUMBER,
i.ACCOUNT_HOLDER_ID,
NAME,
ACCOUNT_TYPE,
BALANCE,
BALANCE_DATE,
DATE_OF_BIRTH,
CONTACT_NUMBER,
FIRST_LINE_OF_ADDRESS
FROM ACCOUNT_INFORMATION i
INNER JOIN ACCOUNT_HOLDERS h
ON i.ACCOUNT_HOLDER_ID = h.ACCOUNT_HOLDER_ID
)
SELECT
p.TRANSACTION_ID,
ACCOUNT_TO,
TRANSACTION_DATE,
VALUE,
ACCOUNT_NUMBER, 
ACCOUNT_TYPE,
BALANCE_DATE,
BALANCE,
NAME,
DATE_OF_BIRTH,
CONTACT_NUMBER,
FIRST_LINE_OF_ADDRESS
FROM PD2023_WK07_TRANSACTION_PATH p
INNER JOIN PD2023_WK07_TRANSACTION_DETAIL d
ON p.transaction_id = d.transaction_id
INNER JOIN ACC a
ON a.account_number = p.account_from
WHERE cancelled_ != 'Y' AND value > 1000 AND ACCOUNT_TYPE != 'Platinum'