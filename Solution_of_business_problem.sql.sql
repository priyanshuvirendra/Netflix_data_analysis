-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(208),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);

select * from NETFLIX;

SELECT 
    COUNT(*) AS total_content
FROM netflix;


SELECT
    DISTINCT TYPE
FROM netflix;


SELECT * FROM netflix;


-- 15 business problems

-- 1. Count the number of Movies vs TV Shows
SELECT 
    TYPE,
	COUNT(*) AS total_content
FROM netflix
GROUP BY TYPE

-- 2. Find the most common rating for movies and TV shows

SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

-- filter 2020
-- movies

SELECT * FROM netflix
WHERE 
   TYPE = 'Movie'
   AND
   release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
  new_country,
  COUNT(show_id) AS total_content
FROM
  netflix,
  LATERAL UNNEST(string_to_array(country, ', ')) AS new_country
GROUP BY
  new_country
ORDER BY
  total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE
    TYPE = 'Movie'
	AND
	duration = (SELECT MAX(DURATION) FROM netflix)

-- 6. Find content added in the last 5 years

SELECT *,
  TO_DATE(date_added, 'Month DD, YYYY') AS formatted_date
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * 
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT * 
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

-- 9. Count the number of content items in each genre

SELECT 
    genre,
    COUNT(*) AS total_content
FROM (
    SELECT 
        UNNEST(string_to_array(listed_in, ', ')) AS genre
    FROM netflix
) AS sub
GROUP BY genre
ORDER BY total_content DESC;

-- 10.Find each year and the average numbers of content release in India on netflix.

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	,2)AS avg_content_per_year
FROM netflix
WHERE country ILIKE 'India'
GROUP BY 1

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE
   listed_in ILIKE '%documentaries%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE
    director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE
    castS ILIKE '%Salman Khan%'
    AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;



