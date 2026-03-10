CREATE DATABASE financial_analysis;

USE financial_analysis;

SELECT COUNT(*) FROM transactions;

CREATE TABLE transactions_cleaned (
    trans_date_trans_time DATETIME,
    cc_num BIGINT,
    merchant VARCHAR(255),
    category VARCHAR(100),
    amt DECIMAL(10,2),
    first VARCHAR(100),
    last VARCHAR(100),
    gender VARCHAR(10),
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip INT,
    lat DOUBLE,
    longitude DOUBLE,
    city_pop INT,
    job VARCHAR(255),
    dob DATE,
    trans_num VARCHAR(50) PRIMARY KEY,
    unix_time BIGINT,
    merch_lat DOUBLE,
    merch_long DOUBLE,
    is_fraud TINYINT,
    merch_zipcode INT
);

INSERT INTO transactions_cleaned (
    trans_date_trans_time,
    cc_num,
    merchant,
    category,
    amt,
    first,
    last,
    gender,
    street,
    city,
    state,
    zip,
    lat,
    longitude,
    city_pop,
    job,
    dob,
    trans_num,
    unix_time,
    merch_lat,
    merch_long,
    is_fraud,
    merch_zipcode
)
SELECT
    CASE 
        WHEN trans_date_trans_time = 'NaT' OR trans_date_trans_time = '' 
        THEN NULL
        ELSE STR_TO_DATE(trans_date_trans_time, '%Y-%m-%d %H:%i:%s')
    END,
    cc_num + 0,
    merchant,
    category,
    NULLIF(amt,'') + 0,
    first,
    last,
    gender,
    street,
    city,
    state,
    NULLIF(zip,'') + 0,
    NULLIF(lat,'') + 0,
    NULLIF(longitude,'') + 0,
    NULLIF(city_pop,'') + 0,
    job,
    dob,
    trans_num,
    NULLIF(unix_time,'') + 0,
    NULLIF(merch_lat,'') + 0,
    NULLIF(merch_long,'') + 0,
    NULLIF(is_fraud,'') + 0,
    NULLIF(merch_zipcode,'') + 0
FROM transactions;

SELECT COUNT(*) FROM transactions_cleaned;
describe transactions_cleaned;

SELECT COUNT(*) FROM transactions;

#Fraud transactions
SELECT COUNT(*) 
FROM transactions_cleaned
WHERE is_fraud = 1;

#Fraud percentage
SELECT 
COUNT(*) AS total,
SUM(is_fraud) AS fraud_count,
(SUM(is_fraud)/COUNT(*))*100 AS fraud_percentage
FROM transactions_cleaned;

#Biggest Transactions
SELECT MAX(amt) 
FROM transactions_cleaned;

#Average Transaction
SELECT AVG(amt)
FROM transactions_cleaned;

#Highest Fraud Amount
SELECT MAX(amt)
FROM transactions_cleaned
WHERE is_fraud = 1;

#Fraud by Category
SELECT category, COUNT(*) AS fraud_count
FROM transactions_cleaned
WHERE is_fraud = 1
GROUP BY category
ORDER BY fraud_count DESC;

#Fraud by Merchant
SELECT 
merchant,
COUNT(*) AS total_transactions,
SUM(is_fraud) AS fraud_transactions,
ROUND(SUM(is_fraud)/COUNT(*)*100,2) AS fraud_percentage
FROM transactions_cleaned
GROUP BY merchant
HAVING fraud_transactions > 20
ORDER BY fraud_percentage DESC
LIMIT 10;

#Fraud by Time of Day
SELECT 
HOUR(trans_date_trans_time) AS hour,
COUNT(*) AS total_transactions,
SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
GROUP BY hour
ORDER BY hour;

#Fraud by Transaction Amount
SELECT 
CASE
WHEN amt < 50 THEN 'Below 50'
WHEN amt BETWEEN 50 AND 100 THEN '50-100'
WHEN amt BETWEEN 100 AND 500 THEN '100-500'
WHEN amt BETWEEN 500 AND 1000 THEN '500-1000'
ELSE 'Above 1000'
END AS amount_range,
COUNT(*) AS total_transactions,
SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
GROUP BY amount_range
ORDER BY fraud_transactions DESC;

#Fraud by gender
SELECT 
gender,
COUNT(*) AS total_transactions,
SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
GROUP BY gender;

#Fraud by State
SELECT 
state,
COUNT(*) AS total_transactions,
SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
GROUP BY state
ORDER BY fraud_transactions DESC
LIMIT 10;

#Fraud by Age Group
SELECT 
FLOOR(DATEDIFF(CURDATE(), dob)/365/10)*10 AS age_group,
COUNT(*) AS total_transactions,
SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
GROUP BY age_group
ORDER BY age_group;

SELECT 
    YEAR(trans_date_trans_time) AS year,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
GROUP BY YEAR(trans_date_trans_time)
ORDER BY year;

#fraud_by_month
SELECT 
    MONTHNAME(trans_date_trans_time) AS month,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
WHERE trans_date_trans_time IS NOT NULL
GROUP BY MONTHNAME(trans_date_trans_time), MONTH(trans_date_trans_time)
ORDER BY MONTH(trans_date_trans_time);

SELECT 
    DAYNAME(trans_date_trans_time) AS weekday,
    SUM(is_fraud) AS fraud_transactions
FROM transactions_cleaned
WHERE trans_date_trans_time IS NOT NULL
GROUP BY weekday
ORDER BY FIELD(weekday,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');