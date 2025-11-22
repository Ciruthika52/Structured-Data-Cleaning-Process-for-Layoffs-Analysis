# Structured-Data-Cleaning-Process-for-Layoffs-Analysis
Welcome to the documentation site for the Layoffs Dataset Data Cleaning Project.
This guide explains how the data was transformed from raw format into a clean, structured, analysis-ready dataset using MySQL.

## Project Overview
This project focuses on cleaning a dataset of company layoffs, improving data quality and consistency for future analytics and reporting.

Key problems addressed:  
1.Duplicate records  
2.Inconsistent text formatting  
3.Mixed date formats  
4.Missing and blank values   
5.Unnecessary temporary columns  

The result is a curated database table suitable for dashboards, reports, and advanced analysis.

## Tools & Technology

Database:MySQL  
SQL Concepts:	Window Functions, Joins, Data Standardization

## Data Cleaning Pipeline
### 1. Create a Staging Table
To protect original data, a staging table is created and populated with all source records:

```sql
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;
```
### 2. Detect and Remove Duplicates

Duplicates are detected using ROW_NUMBER():

```
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off,
               percentage_laid_off, date, stage, country,
               funds_raised_millions
)
```
Records with row_num > 1 are deleted, leaving only unique values.

### 3. Standardize Text Fields
#### Remove leading/trailing whitespace

```
UPDATE layoffs_staging2
SET company = TRIM(company);
```
#### Unify industry categorization

```
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```


