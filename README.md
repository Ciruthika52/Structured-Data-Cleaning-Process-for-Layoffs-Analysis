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

```sql
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off,
               percentage_laid_off, date, stage, country,
               funds_raised_millions
)
```
Records with row_num > 1 are deleted, leaving only unique values.

### 3. Standardize Text Fields
#### Remove leading/trailing whitespace

```sql
UPDATE layoffs_staging2
SET company = TRIM(company);
```
#### Unify industry categorization

```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```
#### Clean up country formatting

```sql
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);
```
### 4. Convert Date Formats
Convert text-based dates into actual SQL DATE values:

```sql
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');
```
Then modify the column:

```sql
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;
```
### 5. Fix Null and Missing Values
#### Convert empty strings to NULL

```sql
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
```
#### Fill missing industry values

```sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL;
```
#### Remove fully non-informative rows
```sql
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
```
### 6. Remove Temporary Columns
Once cleaning is complete:

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```
### Final Output
After completing all steps, the dataset:  
1. Has no duplicates
2. Contains standardized text values
3. Has properly formatted dates
4. Handles missing data consistently
5. Includes only meaningful records
6. Is ready for analysis, visualization, dashboards, and ETL pipelines

### File Included
DataCleaning.sql – Full cleaning script used to process the dataset.






