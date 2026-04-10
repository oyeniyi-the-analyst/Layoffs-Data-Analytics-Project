

#Layoffs Data Analytics Project

[Project Banner]![reports/Dashboard_Overview.png]



## Project Overview
The **Layoffs Data Analytics Project** transforms raw global layoffs data from tech startups into **clean, structured datasets** with actionable insights. Leveraging **MySQL, advanced KPIs, and Power BI**, the project highlights workforce trends, company risk profiles, and funding-related layoffs, enabling **data-driven decision-making**.


## Key Features
- **ETL Pipeline** in MySQL:
  - Create database & staging tables  
  - Deduplication, cleaning, standardization  
  - Automated export of cleaned datasets
  - 
- **Advanced KPIs**:
  - Layoff intensity per company  
  - Company risk classification  
  - Layoff-to-funding ratios  
  - Industry risk scoring  
  - Monthly and quarterly layoff trends  
- **Power BI Dashboard**:
  - Visualizations by industry, country, stage  
  - Top contributors and risk analysis  
  - Interactive slicers for dynamic exploration  
- **Automation**:
  - Fully automated `.bat` script for MySQL pipeline execution  
  - Exports clean CSV and computes KPIs automatically  


## Installation & Setup

mysql -u <username> -p < sql/01_create_db.sql

Run Full Pipeline Automatically
automation/run_pipeline.bat

Explore Advanced KPIs
mysql> source sql/04_kpis.sql;
Open Power BI Dashboard
Open reports/powerbi_dashboard.pbix for interactive visualization.

Advanced KPIs Explained*
| KPI                         | Description                                                                         |
| --------------------------- | ----------------------------------------------------------------------------------- |
| **Layoff Intensity**        | Average layoffs per event for each company                                          |
| **Company Risk Level**      | Classifies companies as High, Medium, Low risk based on total layoffs               |
| **Layoff-to-Funding Ratio** | Shows layoffs relative to funding received, highlighting potential financial stress |
| **Industry Risk Score**     | Average layoffs per company within each industry                                    |
| **Monthly Layoff Growth**   | Measures the growth or decline in layoffs over time                                 |
| **Top Contributors**        | Identifies companies responsible for the highest layoffs                            |


Power BI Dashboard Insights
Layoffs by Industry, Country, Stage
Comparison of funding vs layoffs for companies
Seasonal trends: quarterly & monthly layoffs
High-risk companies & sectors highlighted


