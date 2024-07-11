/*

Cleaning Data in SQL Queries

*/

SELECT * FROM netflix;

-- need to edit column names to useable fromat
ALTER TABLE `NetflixSubs`.`netflix` 
CHANGE COLUMN `User ID` `UserID` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Subscription Type` `SubscriptionType` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Monthly Revenue` `MonthlyRevenue` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Join Date` `JoinDate` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Last Payment Date` `LastPaymentDate` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Plan Duration` `PlanDuration` TEXT NULL DEFAULT NULL ;

-- Steps for cleaning the data
-- 1. Create a second table to perform on
-- 2. Remove Duplicates
-- 3. Standardize the data and fix errors
-- 		a. Change JoinDate, and LastPaymentDate to date columns
-- 4. Investigate null values

-- ------------------------------------------------------------------------------------------------------

-- 1. Create a Second Table
-- In case we make a mistake we have the untouched database 
CREATE TABLE netflix_staging
LIKE netflix;

INSERT netflix_staging
SELECT * FROM netflix; 

SELECT * FROM netflix_staging;
-- ------------------------------------------------------------------------------------------------------
-- 2. Remove Duplicates
 
WITH duplicates AS
(
	SELECT * ,
	ROW_NUMBER() OVER(
		PARTITION BY UserID, SubscriptionType, MonthlyRevenue, JoinDate, LastPaymentDate, Country, Age, Gender, Device, PlanDuration
	) AS row_num
	FROM netflix_staging
)
SELECT * FROM duplicates WHERE row_num > 1;

-- The table seems have no duplicates

-- ------------------------------------------------------------------------------------------------------
-- 3. Standardize the data and fix errors
-- a. Change JoinDate, and LastPaymentDate to date columns in proper format

UPDATE netflix_staging
SET JoinDate = DATE_FORMAT(STR_TO_DATE(JoinDate, '%d-%m-%y'), '%Y-%m-%d');

UPDATE netflix_staging
SET LastPaymentDate = DATE_FORMAT(STR_TO_DATE(LastPaymentDate, '%d-%m-%y'), '%Y-%m-%d');

ALTER TABLE `NetflixSubs`.`netflix_staging` 
CHANGE COLUMN `JoinDate` `JoinDate` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `LastPaymentDate` `LastPaymentDate` DATE NULL DEFAULT NULL ;

SELECT * FROM netflix_staging;

-- ------------------------------------------------------------------------------------------------------
-- 3. Investigate null values

SELECT 
  sum(CASE WHEN UserID IS NULL THEN 1 ELSE 0 END) NA_UserID,
  sum(CASE WHEN SubscriptionType IS NULL THEN 1 ELSE 0 END) NA_SubscriptionType,
  sum(CASE WHEN MonthlyRevenue IS NULL THEN 1 ELSE 0 END) NA_MonthlyRevenue,
  sum(CASE WHEN JoinDate IS NULL THEN 1 ELSE 0 END) NA_JoinDate,
  sum(CASE WHEN LastPaymentDate IS NULL THEN 1 ELSE 0 END) NA_LastPaymentDate,
  sum(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) NA_Country,
  sum(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) NA_Age,
  sum(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) NA_Gender,
  sum(CASE WHEN Device IS NULL THEN 1 ELSE 0 END) NA_Device,
  sum(CASE WHEN PlanDuration IS NULL THEN 1 ELSE 0 END) NA_PlanDuration
FROM netflix_staging;

-- There are no nulls in any of the columns
