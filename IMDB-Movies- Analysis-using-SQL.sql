-- Using the Movies database

use movies;

-- Reading All the Data from all the Tables
select * from actors;
select* from directors;
select * from genre;
select * from keywords;
select * from movies;
select * from ratings;

-- What are all Directors Names and total count of unique directors in directors table and some additional questions also
select * from directors;
select Directors from directors;
select distinct(Directors) from directors;
select count(distinct(Directors)) from directors;

-- what are all the actor names and total count of unique Actors in actors table?
select * from actors;
select actor from actors;
select distinct(actor) from actors;
select count(distinct(actor)) as Total_no_of_Actors from actors;

-- What are the colour, langauge, country, titile_year distribution of movies in movies table
select * from movies;
select color, count(color) as no_of_movies_by_color 
from movies
group by color;

select * from movies;
select languages, sum(gross) as total_gross_of_movies_by_langauge  from movies 
group by languages
order by 2 desc;

select * from movies;
select country, max(budget) as Max_budget_spentby_country from movies
group by country
order by Max_budget_spentby_country desc;

select * from movies;
select country, sum(budget) as total_budget_spentby_country from movies
group by country
order by total_budget_spentby_country desc;

select * from movies;
select languages, count(Movie_id) as no_of_movies_by_langauge 
from movies
group by languages
order by 2 desc;

select country, count(Movie_id) as no_of_movies_by_country 
from movies
group by country
order by 2 desc;

-- What is the Highest and lowest grossing, highest and lowest budget movies in the Data base
select * from movies;

----- Gross of all movies 
select movie_title, max(gross) as max_groos_movie 
from movies 
group by movie_title
order by 2 desc;

----- or using sub queries method 
----- highest grossing movie
select max(gross)
from movies;

select * from movies
where gross = (select max(gross) from movies);

----- lowest grossing movie 
select min(gross)
from movies;

select * from movies
where gross = (select min(gross) from movies);

----- highest budget movie 
select max(budget)
from movies;

select * from movies
where budget = (select max(budget) from movies);

----- lowest budget movie 
select min(budget)
from movies
where budget>0;

select * from movies
where budget= (select min(budget) from movies where budget>0);



-- Retrieving a list of movie titles along with a column indicating  whether the duration is above 120 minutes or not 
select * from movies;


select movie_title, duration,
	case 
    when duration >120 then 'above 120 Minutes'
    else 'Below 120 Minutes'
    end as Duration_category
from movies;


-- Finding the top 5 geners based on the number of movies released in last 5 years 
select * from movies;

select max(title_year) from movies;

select genres, count(Movie_id) as Total_no_movies_genre
from movies 
where title_year > 2011
group by genres
order by 2 desc
limit 5;


-- Retrieve the movie titles movie titles directed by a director whose average movie duration is above the overall average duration
select * from directors;

select * from movies;

select avg(duration) as avg_movie_duration
from movies;

select Director_ID, avg(duration) from movies 
group by Director_ID
having avg(duration)> (select avg(duration) as avg_movie_duration from movies);

select movie_title from movies
where Director_ID in
 (
select Director_ID from movies 
group by Director_ID
having avg(duration)> (select avg(duration) from movies)
);


-- Calcullate the average budget of movies over the last 3 years, including avg budget for each movie
select * from movies;

select max(title_year) from movies;

select movie_title, avg(budget) as avg_budget
from movies
WHERE title_year in (2014, 2015,2016)
group by movie_title
order by 2;

select movie_title, title_year, avg(budget) 
over (partition by title_year) as Avg_budget
from movies
where title_year is NOT NULL;


-- Retriveing a lit of movies with thier genres , including only those genres that have more than 5 movies
select * from movies;

select genres, count(genres) as count
from movies
group by genres
having count >5
order by 2 asc;

select movie_title, genres
from movies
where genres in
(
select genres
from movies
group by genres
having count(genres) > 5
);


-- Finding the directors who have directed atleast 3 movies and have an average IMDB score above 7 

select * from movies;
select * from directors;

select  t2.Directors, count(*) as no_movies , avg(imdb_score) as avg_imdb_score
from movies as t1
inner join
directors as t2 
on 
t1.Director_ID = t2.D_ID  
group by t2.Directors
having  (avg_imdb_score >7) and no_movies >=3
order by 3 desc;

-- Listing the top 3 actors who have appeared in the most movies , for each other , provide an average IMDB score of the movies they appeared in 
select * from movies;

select * from actors ;	

select  a.actor,  count(*) as movie_count , avg(imdb_score) as avg_imdb_score
from 
actors as a
left join
movies as m
on 
concat('|', m.actors, '|') like concat('%|', a.actor,'|%')
group by a.actor
order by movie_count desc
limit 3;


-- For each year, findinng the movie with the highest gross, also retrieving the secondd highest gross the same result test

select * from movies;

with my_cte as (
select movie_title, gross, title_year,
row_number() over(partition by title_year order by gross desc) as new_rank
from movies
)

select title_year, 
max(case when new_rank=1 then movie_title end) as Highest_grossing_movie,
max(case when new_rank=2 then movie_title end) as Second_highest_grossing_movie
from my_cte
where new_rank<=2
group by title_year
order by  title_year desc;


-- creating a stored procedure that takes a directorts IDs and returns the average IMDB score of the movies directed by that director 

DELIMITER //
create procedure Avg_IMBD_score(in D_ID varchar(255))
begin
     select	avg(imdb_score)
     from movies 
     where Director_ID = D_ID;
end	//

CALL Avg_IMBD_score('D1003') ;


-- Retrieving the top 3 movies based on IMbd score, and include their ranking

select * from movies;

select movie_title, imdb_score,
       rank() over (order by imdb_score desc) as ranking
from movies
where imdb_score is NOT NULL,
order by imdb_score desc;


-- Finding each directors, listing their movies along with the imdb score and the ranking of each movie based on Imdb score 


select Director_ID, movie_title, imdb_score,
       rank() over (partition by Director_ID order by imdb_score desc) as Ranking
from movies
where imdb_score is NOT NULL,
order by  Director_ID, imdb_score desc;




















































