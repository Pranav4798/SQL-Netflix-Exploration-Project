DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

-- count of movies and TV shows
select type, count(*) 
from netflix
group by type


-- most common rating for movies and TV shows
with rating_count as (
select type, rating, count(rating) as rating_cnt
from netflix
group by type, rating 
),
ranked_rate as (
select type, rating, rating_cnt, rank () over (partition by type order by rating_cnt desc) as rank
from rating_count
)
select type, rating, rating_cnt
from ranked_rate
where rank = 1

-- Count of titles released each year
select count(*), release_year
from netflix
group by release_year
order by 1 desc

-- Top 5 countries with the most content
select * from (
select unnest(string_to_array(country, ',')) as country, count(*) as total_content
from netflix
group by 1
) as T1
where country is not null
order by total_content desc
limit 6


-- Count of titles released between 2015 and 2020
select count(*)
from netflix
where release_year between '2015' and '2020'


-- Content released in the last 5 years
select count(*)
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'


--Longest title
select title, type, duration
from netflix
order by duration desc
limit 2


-- All movies by director Rajiv Chilaka
select title, type, duration from (
select *,unnest(string_to_array(director,',')) from netflix
) as t
where director = 'Rajiv Chilaka'


--All shows with seasons above 5
select title
from netflix
where type = 'TV Show' and split_part(duration,' ',1)::INT > 5 


--Number of contents in each genre
select count(*) as Total, unnest(string_to_array(listed_in,','))
from netflix
group by 2
order by Total desc


--Content released in India over the years
select count(*), release_year 
from netflix
where country = 'India'
group by release_year
order by 1 desc


--List of all documentaries 
select title
from netflix
where listed_in like '%Documentaries'


--All content wihout a director
select count(*)
from netflix
where director isnull


--Movies in which Salman is present
select title
from netflix
where "cast" like '%Salman Khan%' and release_year > extract(year from current_date) - 10


--Top 10 actors in most content
select count(*), unnest(string_to_array("cast",',')) as Actor
from netflix
where country = 'United States'
group by 2
order by 1 desc
limit 10

--Categorize content based on vulgur content
select count(*) as All_content, category from 
( select
case when description like '%kill%' or description like '%violence%' then 'NSFW'
else 'SFW'
end as category
from netflix
) as categorized_content
group by category

