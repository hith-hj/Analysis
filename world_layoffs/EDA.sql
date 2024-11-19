-- EDA

-- Here we are going to explore the data and find trends or patterns or anything 
-- just look around and see what we find!

SELECT * 
FROM ls1;

-- let's begin
SELECT MAX(total_laid_off)
FROM ls1;


-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM ls1
WHERE percentage_laid_off IS NOT NULL;

-- Companies which had 1 which is basically 100 percent of they company laid off
SELECT *
FROM ls1
WHERE  percentage_laid_off = 1;

-- order by funds_raised_millions to see how big these companies were
SELECT *
FROM ls1
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Companies with the biggest single Layoff
SELECT company, total_laid_off
FROM ls1
ORDER BY total_laid_off DESC
LIMIT 5;


-- Total Layoffs by Company 
SELECT company, SUM(total_laid_off) total_sum
FROM ls1
GROUP BY company
ORDER BY total_sum DESC
LIMIT 10;


-- by location
SELECT location, SUM(total_laid_off) total_sum
FROM ls1
GROUP BY location
ORDER BY total_sum DESC
LIMIT 10;

-- by country
SELECT country, SUM(total_laid_off) total_sum
FROM ls1
GROUP BY country
ORDER BY total_sum DESC;

-- by year
SELECT YEAR(date), SUM(total_laid_off) total_sum
FROM ls1
GROUP BY YEAR(date)
ORDER BY total_sum ASC;

-- by industry
SELECT industry, SUM(total_laid_off) total_sum
FROM ls1
GROUP BY industry
ORDER BY total_sum DESC;

-- by stage
SELECT stage, SUM(total_laid_off) total_sum
FROM ls1
GROUP BY stage
ORDER BY total_sum DESC;


-- Companies layoffs per year
WITH Company_Year AS 
(
  SELECT company, YEAR(created_at) AS years, SUM(total_laid_off) AS total_sum
  FROM ls1
  GROUP BY company, YEAR(created_at)
)
, Company_Year_Rank AS (
  SELECT company, years, total_sum, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_sum DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_sum, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_sum DESC;


-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(created_at,1,7) as dates, SUM(total_laid_off) AS total_sum
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(created_at,1,7) as dates, SUM(total_laid_off) AS total_sum
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_sum) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

