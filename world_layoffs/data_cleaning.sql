
-- First lets copy the data to another table to make sure we don't mess with the raw data
-- and let's add row count to it at the same time
CREATE TABLE ls1 SELECT * , 
ROW_NUMBER() OVER( PARTITION BY company, industry, location, total_laid_off, 
	percentage_laid_off,stage,`date`,country,funds_raised_millions) as row_count
FROM layoffs;

-- new check for duplicated rows and delete them
SELECT * FROM ls1 WHERE row_count > 1;
DELETE FROM ls1 WHERE row_count > 1;

-- now remove row_count 
ALTER TABLE ls1 DROP COLUMN row_count;

-- look for empty cells and replace empty with null
UPDATE ls1 set industry = null where industry = '';
UPDATE ls1 set total_laid_off = null where total_laid_off = '';
UPDATE ls1 set percentage_laid_off = null where percentage_laid_off = '';
UPDATE ls1 set funds_raised_millions = null where funds_raised_millions = '';

-- standardize the columns 

-- remove white spaces from company column
UPDATE ls1 SET company = trim(company) ;

-- formalize country values
UPDATE ls1 SET country = trim(TRAILING '.' FROM country);


-- try to repopulate industry null value for companies that have another row with industry value
UPDATE ls1 AS a 
join ls1 AS b on a.company = b.company 
SET a.industry = b.industry
WHERE a.industry IS null && b.industry IS NOT null;

-- there are multiple rows having crypto industry with different values , unify them to all have crypto
UPDATE ls1 SET industry = 'Crypto' WHERE industry LIKE '%Crypto%';

-- now let's fix the date column 
-- first remove any white spaces from date column
UPDATE ls3 set `date` = trim(`date`);

-- then change the values from text to date
UPDATE ls3 set `date` = str_to_date(`date`, '%m/%d/%Y');

-- change its name to created_at and change its type to date 
ALTER TABLE ls1 CHANGE `date` created_at date ;

-- now remove rows that have null values for both total_laid_off and percentage_laid_off because it is useless 
-- as a precaution we will create a table for them just in case;
SELECT * FROM ls1 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

CREATE TABLE deleted_rows SELECT * FROM ls1 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM ls1 WHERE total_laid_off  IS NULL AND percentage_laid_off IS NULL;




