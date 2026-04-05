-- -- BEGINNING OF SCRIPT

-- LAYOFFS DATA CLEANING PROJECT

-- 🔹 STEP 1: Database Setup
-- Reset environment
DROP DATABASE IF EXISTS layoffs_db;

CREATE DATABASE layoffs_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE layoffs_db;

-- STEP 2: Create Raw Table
CREATE TABLE layoffs_raw_tb (
    company VARCHAR(255),
    location VARCHAR(255),
    industry VARCHAR(255),
    total_laid_off INT,
    percentage_laid_off VARCHAR(20),
    date VARCHAR(20),
    stage VARCHAR(100),
    country VARCHAR(100),
    funds_raised_millions VARCHAR(50)
);

-- STEP 3: Import CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\PERSONAL PROJECT\\layoffs.csv'
INTO TABLE layoffs_raw_tb
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- STEP 4: Create Staging Table
DROP TABLE IF EXISTS layoffs_staging_tb;

CREATE TABLE layoffs_staging_tb AS
SELECT *
FROM layoffs_raw_tb;

-- STEP 5: Data Cleaning BEFORE Deduplication
-- 5A: Trim + Standardize NULLs

UPDATE layoffs_staging_tb
SET 
    company = NULLIF(TRIM(company), ''),
    location = NULLIF(TRIM(location), ''),
    industry = NULLIF(TRIM(industry), ''),
    percentage_laid_off = NULLIF(TRIM(REPLACE(percentage_laid_off, '%', '')), ''),
    date = NULLIF(TRIM(date), ''),
    stage = NULLIF(TRIM(stage), ''),
    country = NULLIF(TRIM(country), ''),
    funds_raised_millions = NULLIF(TRIM(REPLACE(funds_raised_millions, ',', '')), '');

-- 5B: Normalize Placeholder Values

UPDATE layoffs_staging_tb
SET 
    company = NULLIF(UPPER(company), 'NULL'),
    industry = NULLIF(UPPER(industry), 'N/A'),
    location = NULLIF(UPPER(location), 'N/A'),
    stage = NULLIF(UPPER(stage), 'N/A'),
    country = NULLIF(UPPER(country), 'N/A');

-- STEP 6: Deduplication
-- Using Window Functions

DROP TABLE IF EXISTS layoffs_dedup_tb;

CREATE TABLE layoffs_dedup_tb AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, date
               ORDER BY company
           ) AS rn
    FROM layoffs_staging_tb
) t
WHERE rn = 1;

-- Add Primary Key
ALTER TABLE layoffs_dedup_tb DROP COLUMN rn;

ALTER TABLE layoffs_dedup_tb
ADD id INT AUTO_INCREMENT PRIMARY KEY FIRST;

SELECT *
FROM layoffs_dedup_tb;

-- STEP 7: Data Type Conversion
-- 7A: Convert Percentage to decimal
ALTER TABLE layoffs_dedup_tb
MODIFY percentage_laid_off DECIMAL(5,2);

-- 7B: Convert Fund raised to decimal
-- Clean formatting
UPDATE layoffs_dedup_tb
SET funds_raised_millions = TRIM(REPLACE(funds_raised_millions, ',', ''));

-- Empty strings to NULL
UPDATE layoffs_dedup_tb
SET funds_raised_millions = NULL
WHERE funds_raised_millions = '';

-- Remove invalid values
UPDATE layoffs_dedup_tb
SET funds_raised_millions = NULL
WHERE funds_raised_millions IS NOT NULL
AND funds_raised_millions NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';

-- Convert type to Decimal
ALTER TABLE layoffs_dedup_tb
MODIFY funds_raised_millions DECIMAL(20,2);

-- Convert date to DATE type
UPDATE layoffs_dedup_tb
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_dedup_tb
MODIFY date DATE;

-- STEP 8: Final Cleaning & Standardization
UPDATE layoffs_dedup_tb
SET 
    company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    stage = TRIM(stage),
    country = TRIM(country);

-- STEP 9: Create Clean Table
   DROP TABLE IF EXISTS layoffs_clean_tb;

CREATE TABLE layoffs_clean_tb AS
SELECT *
FROM layoffs_dedup_tb;

ALTER TABLE layoffs_clean_tb
MODIFY id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- STEP 10: EXPLORATORY DATA ANALYSIS
-- 10A: Layoffs by Industry
SELECT industry, 
       SUM(total_laid_off) AS total_layoffs,
       ROUND(AVG(total_laid_off),2) AS avg_layoffs
FROM layoffs_clean_tb
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 10B: Layoffs by Country
SELECT country, 
       SUM(total_laid_off) AS total_layoffs,
       COUNT(DISTINCT company) AS companies
FROM layoffs_clean_tb
GROUP BY country
ORDER BY total_layoffs DESC;

-- 10C: Layoffs Over Time (Monthly Trend)
SELECT DATE_FORMAT(date, '%Y-%m') AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY month
ORDER BY month;

-- 10D: Top Companies by Layoffs
SELECT company, 
       SUM(total_laid_off) AS total_layoffs,
       MAX(funds_raised_millions) AS funding
FROM layoffs_clean_tb
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- 10E: Layoffs by Company Stage
SELECT stage, 
       COUNT(*) AS num_companies, 
       SUM(total_laid_off) AS total_layoffs,
       AVG(total_laid_off) AS avg_layoffs_per_company
FROM layoffs_clean_tb
GROUP BY stage
ORDER BY total_layoffs DESC;

-- STEP 11: Export Clean Dataset
SELECT 'company','location','industry','total_laid_off',
       'percentage_laid_off','date','stage','country','funds_raised_millions'
UNION ALL
SELECT  
  IFNULL(company, '-'),
  IFNULL(location, '-'),
  IFNULL(industry, '-'),
  IFNULL(total_laid_off, '-'),
  IFNULL(percentage_laid_off, '-'),
  IFNULL(date, '-'),
  IFNULL(stage, '-'),
  IFNULL(country, '-'),
  IFNULL(funds_raised_millions, '-')
FROM layoffs_clean_tb
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\PERSONAL PROJECT\\layoffs_cleaned_dataset.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n';

-- STEP 12: ADVANCED KPIs
-- 12A: Layoff Intensity (Per Company)
SELECT company,
       COUNT(*) AS layoff_events,
       SUM(total_laid_off) AS total_laid_off,
       ROUND(SUM(total_laid_off) / COUNT(*), 2) AS layoff_intensity
FROM layoffs_clean_tb
GROUP BY company
ORDER BY total_laid_off DESC;

-- 12B: Company Risk Classification
SELECT company,
       SUM(total_laid_off) AS total_laid_off,
       MAX(funds_raised_millions) AS funding,
       CASE 
           WHEN SUM(total_laid_off) >= 5000 THEN 'High Risk'
           WHEN SUM(total_laid_off) >= 1000 THEN 'Moderate Risk'
           ELSE 'Low Risk'
       END AS risk_level
FROM layoffs_clean_tb
GROUP BY company
ORDER BY total_laid_off DESC;

-- 12C: Layoff-to-Funding Ratio
SELECT company,
       SUM(total_laid_off) AS total_laid_off,
       MAX(funds_raised_millions) AS funding,
       ROUND(SUM(total_laid_off) / NULLIF(MAX(funds_raised_millions), 0), 4) AS layoff_funding_ratio
FROM layoffs_clean_tb
GROUP BY company
ORDER BY layoff_funding_ratio DESC;

-- 12D: Monthly Layoff Growth Trend
SELECT month,
       total_layoffs,
       LAG(total_layoffs) OVER (ORDER BY month) AS prev_month,
       ROUND(
           (total_layoffs - LAG(total_layoffs) OVER (ORDER BY month)) 
           / NULLIF(LAG(total_layoffs) OVER (ORDER BY month), 0), 2
       ) AS growth_rate
FROM (
    SELECT DATE_FORMAT(date, '%Y-%m') AS month,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs_clean_tb
    GROUP BY month
) t;

-- 12E: Industry Risk Score
SELECT industry,
       SUM(total_laid_off) AS total_layoffs,
       COUNT(DISTINCT company) AS companies,
       ROUND(SUM(total_laid_off) / COUNT(DISTINCT company), 2) AS risk_score
FROM layoffs_clean_tb
GROUP BY industry
ORDER BY risk_score DESC;

-- 12F: Layoff Concentration (Top Contributors)
SELECT company,
       SUM(total_laid_off) AS total_laid_off,
       ROUND(
           SUM(total_laid_off) / 
           (SELECT SUM(total_laid_off) FROM layoffs_clean_tb) * 100, 2
       ) AS contribution_percent
FROM layoffs_clean_tb
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- END OF SCRIPT