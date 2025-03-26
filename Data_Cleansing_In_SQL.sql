SELECT 
    *
FROM
    layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null value or blank values fix
-- 4. Remove unnecessary  columns
CREATE TABLE lay_cpy LIKE layoffs;-- It create other table lay_copy with same structure like layoffs

SELECT 
    *
FROM
    lay_cpy;

insert lay_cpy
select * from layoffs ;  -- It is basically adding the table value from layoffs to lay_cpy


WITH duplicate_cte AS (
SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
    `date`, stage, country, funds_raised_millions) AS row_num
	FROM lay_cpy
    ) 
    select * from duplicate_cte where row_num=1;
    
CREATE TABLE `lay_cpy2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;




insert into  lay_cpy2 
SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
    `date`, stage, country, funds_raised_millions) AS row_num
	FROM lay_cpy;
    

set sql_safe_updates = 0;-- We did this so that sql allow us to delete from tables

DELETE FROM lay_cpy2 
WHERE
    row_num > 1;-- deleted duplicate rows from table

SELECT 
    *
FROM
    lay_cpy2;

-- Standardizing the data (Removing issues from data like unnecsary space and all)

SELECT 
    company, TRIM(company)
FROM
    lay_cpy2;-- trimming space from company and displaying trimmed company name column and raw company column

UPDATE lay_cpy2 
SET 
    company = TRIM(company);-- company column value updated with space removed company name

SELECT 
    *
FROM
    lay_cpy2;

-- In industry column lot of same industry with little mess written like crypto/ crypto currency/ cryptocurrency all are same

UPDATE lay_cpy2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';-- fixed all rypto/ crypto currency/ cryptocurrency with crypto value

UPDATE lay_cpy2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country = 'united states%'; -- fixed country name united states by removing dot from ending of united states through trailing


-- fixed date column 

alter table lay_cpy2 add column new_d DATE ;

UPDATE lay_cpy2 
SET 
    new_d = STR_TO_DATE(`date`, '%m/%d/%Y'); -- converted text datatype to date and inserted in new column new_d (as it wasnt allowing to change datatype of existing column date

alter table lay_cpy2 drop column `date`; -- drop the text type column date

alter table lay_cpy2 change column new_d `date` DATE ;-- modified name of new_d to date

SELECT 
    *
FROM
    lay_cpy2;

-- removing null values from industry and populating(inserting) it with industry name when there is 2 row with same company and location name except belly as oit was single company name present in data

UPDATE lay_cpy2 
SET 
    industry = NULL
WHERE
    industry = '';-- replace blank row of industry with null

UPDATE lay_cpy2 t1
        JOIN
    lay_cpy2 t2 ON (t1.company = t2.company
        AND t1.location = t2.location) 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;-- replaced value of null in industry column to industry name with same company name's industry name


DELETE FROM lay_cpy2 
WHERE
    percentage_laid_off IS NULL
    AND total_laid_off IS NULL; -- deleted rows where percentage laid and total laid is null

ALTER TABLE lay_cpy2
  DROP COLUMN row_num;  -- removed unnecesary column

SELECT 
    *
FROM
    lay_cpy2;