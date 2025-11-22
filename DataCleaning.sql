-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Remove Null or Blank
-- 4. Remove any columns

-- First create staging table 

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_staging;
-- REMOVE DUPLICATES
-- Assigning Row number to the table is the easiest way to remove duplicates

WITH duplicate_cte AS
(
SELECT * ,ROW_NUMBER() 
OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)

SELECT * 
FROM duplicate_cte
WHERE row_num >1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT * ,ROW_NUMBER() 
OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- Standardizing the data

-- Remove Whitespaces
SELECT company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct country
FROM layoffs_staging2
Order by 1;

UPDATE layoffs_staging2
SET country= TRIM(Trailing '.' from country)
where country like 'United States%';

-- TRIM(Trailing '.' from country) trailing means remove whitespace from given charecter

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`=str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Remove blanks and nulls

Select * 
from layoffs_staging2
where industry is null or industry ='';

UPDATE layoffs_staging2
SET industry = null
WHERE industry ='';

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
    WHERE t1.industry is null AND t2.industry is not null;
    
Update layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry is null AND t2.industry is not null;   


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

DELETE FROM layoffs_staging2
 WHERE total_laid_off is null
AND percentage_laid_off is null;


SELECT * 
FROM layoffs_staging2;

-- Remove unnecessary columns

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

