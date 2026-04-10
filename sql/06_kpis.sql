-- 10 — KPI QUERIES

-- KPI 1 — TOTAL LAYOFFS
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb;

-- KPI 2 — TOTAL COMPANIES

SELECT COUNT(DISTINCT company) AS total_companies
FROM layoffs_clean_tb;

-- KPI 3 — TOP COMPANIES BY LAYOFFS

SELECT 
    company, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;


-- KPI 4 — LAYOFF TREND OVER TIME

SELECT 
    date,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY date
ORDER BY date;

-- KPI 5 — MONTHLY TREND
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY year, month
ORDER BY year, month;

-- KPI 6 — INDUSTRY IMPACT
SELECT 
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY industry
ORDER BY total_layoffs DESC;

-- KPI 7 — COUNTRY ANALYSIS
SELECT 
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY country
ORDER BY total_layoffs DESC;

-- KPI 8 — FUNDING VS LAYOFFS
SELECT 
    company,
    SUM(total_laid_off) AS total_layoffs,
    AVG(funds_raised_millions) AS avg_funding
FROM layoffs_clean_tb
GROUP BY company
ORDER BY total_layoffs DESC;

-- KPI 9 — COMPANY STAGE ANALYSIS

SELECT 
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean_tb
GROUP BY stage
ORDER BY total_layoffs DESC;