#What is Data Cleaning?

#1 Data cleaning is the process of identifying and correcting or removing invalid, incorrect, or incomplete data from a dataset

#2 THere are several techniques including removing deuplicated data, normalization, standardization, pupulating values, and more

#START Removing Duplicates

#Suggested to make duplicate of data set because it is difficulat to get data back

USE bakery;

SELECT *
FROM bakery.customer_sweepstakes;

#Changing Name of column

ALTER TABLE customer_sweepstakes
	RENAME COLUMN `ï»¿sweepstake_id` TO `sweepstakes_id`
    ;
    
SELECT *
FROM bakery.customer_sweepstakes;

#When looking at data for removing duplicates, we see that there are 2 doubles in the 101s and the 106s

SELECT customer_id, COUNT(customer_id)
FROM customer_sweepstakes
GROUP BY customer_id
HAVING COUNT(customer_id) > 1
;

#Another way of finding the duplicates with window function and subquery
SELECT *
FROM( SELECT customer_id,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS row_num
FROM customer_sweepstakes) AS table_row
WHERE row_num > 1
;

DELETE FROM customer_sweepstakes
WHERE sweepstakes_id IN (

	SELECT sweepstakes_id
	FROM( 
		SELECT sweepstakes_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS row_num
		FROM bakery.customer_sweepstakes) AS table_row
		WHERE row_num > 1)
;


#END Removing Duplicates

#START Standaradize Data

SELECT *
FROM customer_sweepstakes
;

SELECT phone
FROM customer_sweepstakes
;

SELECT phone, REGEXP_REPLACE(phone, '[()-/+]','') #Don't forget to add the brackets
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET phone = REGEXP_REPLACE(phone, '[()-/+]','')
;

SELECT phone, SUBSTRING(phone,1,3),
			SUBSTRING(phone,4,3),
            SUBSTRING(phone,7,4)
FROM customer_sweepstakes
;

SELECT phone, CONCAT(SUBSTRING(phone,1,3),
			'-',
			SUBSTRING(phone,4,3),
            '-',
            SUBSTRING(phone,7,4))
FROM customer_sweepstakes
WHERE phone <> ''
;

UPDATE customer_sweepstakes
SET phone = CONCAT(SUBSTRING(phone,1,3),
			'-',
			SUBSTRING(phone,4,3),
            '-',
            SUBSTRING(phone,7,4))
WHERE phone <> ''
;

SELECT phone
FROM bakery.customer_sweepstakes
;

USE bakery;

SELECT birth_date
FROM customer_sweepstakes
;

#In original table schema, birth_date is a text column and will need to be converted

SELECT birth_date, STR_TO_DATE(birth_date, '%m/%d/%Y') #In one of the inputs, the date is '1978/30/05' and shows Null, so need to fix that
FROM customer_sweepstakes
;

SELECT birth_date, 
	STR_TO_DATE(birth_date, '%m/%d/%Y'),
    STR_TO_DATE(birth_date, '%Y/%d/%m')
FROM customer_sweepstakes
;

#Now that able to get the format, but needing it in one column, may need to use an IF statement to combine

SELECT birth_date, 
	IF(STR_TO_DATE(birth_date, '%m/%d/%Y') IS NOT NULL, STR_TO_DATE(birth_date, '%m/%d/%Y'),STR_TO_DATE(birth_date, '%Y/%d/%m')) AS updated_date,
    STR_TO_DATE(birth_date, '%Y/%d/%m')
FROM customer_sweepstakes
;

#IF statement does not work with the UPDATE statement, so will need to use a CASE statement

SELECT birth_date, 
	CASE
	WHEN STR_TO_DATE(birth_date, '%m/%d/%Y') IS NOT NULL THEN STR_TO_DATE(birth_date, '%m/%d/%Y')
    WHEN STR_TO_DATE(birth_date, '%m/%d/%Y') IS NULL THEN STR_TO_DATE(birth_date, '%Y/%d/%m') 
    END AS updated_date
FROM customer_sweepstakes
;

#CASE statement still came out with an error and may need to use SUBSTRING to pick out the 2 entries that are formated incorrectly

SELECT birth_date, CONCAT(SUBSTRING(birth_date, 9,2),'/',
					SUBSTRING(birth_date, 6,2),'/',
                    SUBSTRING(birth_date, 1,4))
FROM bakery.customer_sweepstakes
;

UPDATE customer_sweepstakes
SET birth_date = CONCAT(SUBSTRING(birth_date, 9,2),'/',
					SUBSTRING(birth_date, 6,2),'/',
                    SUBSTRING(birth_date, 1,4))
WHERE sweepstakes_id IN(9,11)
;


SELECT *
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET birth_date = STR_TO_DATE(birth_date, '%m/%d/%Y')
;

SELECT `Are you over 18?`
FROM customer_sweepstakes
;

SELECT 'Are you over 18?',
CASE 
	WHEN `Are you over 18?` = 'Yes' THEN 'Y'
    WHEN `Are you over 18?` = 'No' THEN 'N'
    ELSE `Are you over 18?`
END
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET `Are you over 18?` = CASE 
	WHEN `Are you over 18?` = 'Yes' THEN 'Y'
    WHEN `Are you over 18?` = 'No' THEN 'N'
    ELSE `Are you over 18?`
END
;

#END Standaradize Data

#START Breaking One Column into Multiple Columns

SELECT *
FROM customer_sweepstakes
;

#Wanting to break out things like the address so that we can make KPIs from the data like city or state

SELECT address
FROM customer_sweepstakes
;

SELECT address, SUBSTRING_INDEX(address,',',1) AS street,
                SUBSTRING_INDEX(SUBSTRING_INDEX(address,',',2),',',-1) AS city,
				SUBSTRING_INDEX(address,',',-1) AS state
FROM customer_sweepstakes
;

#Now that we're able to seperate the column, we need to add columns with an 'ALTER TABLE'

ALTER TABLE customer_sweepstakes
ADD COLUMN street VARCHAR(50) AFTER address #Placing the column where you'd like using the AFTER
;

ALTER TABLE customer_sweepstakes
ADD COLUMN city VARCHAR(50) AFTER street,
ADD COLUMN state VARCHAR(50) AFTER city
;

SELECT address, SUBSTRING_INDEX(address,',',1) AS street,
                SUBSTRING_INDEX(SUBSTRING_INDEX(address,',',2),',',-1) AS city,
				SUBSTRING_INDEX(address,',',-1) AS state
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET street = SUBSTRING_INDEX(address,',',1)
;

UPDATE customer_sweepstakes
SET city = SUBSTRING_INDEX(SUBSTRING_INDEX(address,',',2),',',-1)
;

UPDATE customer_sweepstakes
SET state = SUBSTRING_INDEX(address,',',-1)
;

SELECT state, UPPER(state)
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET state = UPPER(state)
;

UPDATE customer_sweepstakes
SET city = TRIM(city)
;

UPDATE customer_sweepstakes
SET city = TRIM(state)
;

#END Breaking One Column into Multiple Columns


#START Working with Null Values

SELECT *
FROM bakery.customers
;

SELECT COUNT(phone)
FROM customers
;


SELECT COUNT(customer_id), COUNT(phone)
FROM customers
;

SELECT COUNT(sweepstakes_id), COUNT(phone)
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET phone = NULL
WHERE phone = ''
;


UPDATE customer_sweepstakes
SET income = NULL
WHERE income = ''
;

SELECT COUNT(income)
FROM customer_sweepstakes
;

#NULL removes the value from the data so that it does not count towards future calculations

SELECT income
FROM customer_sweepstakes
;

SELECT AVG(income)
FROM customer_sweepstakes
WHERE income IS NOT NULL
;


SELECT AVG(COALESCE(income,0))
FROM customer_sweepstakes
;

# Better to have NULL values because you can control when to use with statements like COALESCE

SELECT birth_date, `Are you over 18?`
FROM customer_sweepstakes
WHERE (YEAR(NOW()) - 18) > YEAR(birth_date)
;

UPDATE customer_sweepstakes
SET `Are you over 18?` = 'Y'
WHERE (YEAR(NOW()) - 18) > YEAR(birth_date)
;

#For null values in income column, you can either populate with something, make it a 0 or replace with an average

#END Working with Null Values

#START Deleting Columns

SELECT *
FROM customer_sweepstakes
;

ALTER TABLE customer_sweepstakes
DROP COLUMN address
;


ALTER TABLE customer_sweepstakes
DROP COLUMN favorite_color
;

#Last resort situation, but if really do not need it, then do it. Sometimes help with speeding up queries

#END Deleting Columns
