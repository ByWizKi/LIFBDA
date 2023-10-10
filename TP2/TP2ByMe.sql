drop table if exists Ratings;
drop table if exists Movies;
drop table if exists Reviewers;


create table Movies (
    id_movie integer,
    title_movie text,
    year_movie integer check (
        year_movie >= 1900 
        and 
        year_movie <= extract(
            year from current_date
        )
    ),
    director_movie text,
    primary key (id_movie)
);

create table Reviewers (
    id_reviewer integer,
    name_reviewer text,
    primary key (id_reviewer)
);

create table Ratings(
    id_reviewer integer,
    id_movie integer,
    date_rating date, 
    stars_rating integer,
    foreign key 
        (id_reviewer) 
    references 
        Reviewers(id_reviewer),
    foreign key 
        (id_movie)
    references
        Movies(id_movie),
    primary key (
        id_reviewer,
        id_movie,
        date_rating
    )
);

insert into movies(id_movie, title_movie, year_movie, director_movie) values
    (101, 'Gone with the Wind', 1939, 'Victor Fleming'),
    (102, 'Star Wars', 1977, 'George Lucas'),
    (103, 'The Sound of Music', 1965, 'Robert Wise'),
    (104, 'E.T.', 1982, 'Steven Spielberg'),
    (105, 'Titanic', 1997, 'James Cameron'),
    (106, 'Snow White', 1937, null),
    (107, 'Avatar', 2009, 'James Cameron'),
    (108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg')
;

insert into reviewers(id_reviewer, name_reviewer) values
    (201, 'Sarah Martinez'),
    (202, 'Daniel Lewis'),
    (203, 'Brittany Harris'),
    (204, 'Mike Anderson'),
    (205, 'Chris Jackson'),
    (206, 'Elizabeth Thomas'),
    (207, 'James Cameron'),
    (208, 'Ashley White')
;

INSERT INTO ratings(id_reviewer, id_movie, stars_rating, date_rating) values
    (201, 101, 2, '2011-01-22'),
    (201, 101, 4, '2015-01-27'),
    (202, 106, 4, '2021-02-04'),
    (203, 103, 2, '2011-01-20'),
    (203, 108, 4, '2011-01-12'),
    (203, 108, 2, '2016-01-30'),
    (204, 101, 3, '2020-01-09'),
    (205, 103, 3, '2011-01-27'),
    (205, 104, 2, '2011-01-22'),
    (205, 108, 4, '2020-01-27'),
    (206, 107, 3, '2015-01-15'),
    (206, 106, 5, '2021-01-19'),
    (207, 107, 5, '2014-01-20'),
    (208, 104, 3, '2021-01-02'),
    (203, 102, 3, '2011-01-27'),
    (203, 101, 2, '2011-02-27'),
    (203, 104, 2, '2011-03-27'),
    (203, 105, 2, '2011-04-27'),
    (203, 106, 4, '2011-05-27'),
    (203, 107, 5, '2011-06-27')

select 
    distinct
    name_reviewer,
    title_movie,
    stars_rating
    from v_detail_evaluations as t
    natural join movies natural join reviewers
    where stars_rating in 
        (select min(stars_rating) from ratings)
    group by title_movie, t.id_reviewer,name_reviewer, stars_rating;

select
    title_movie,
    Max(stars_rating) as rating_max
    from ratings 
    natural join movies
    group by title_movie
    order by title_movie;

select name_reviewer 
    from reviewers natural join ratings 
    where id_movie in 
    (select distinct id_movie 
        from movies)
    group by name_reviewer
    having COUNT(id_movie) = 
    (select COUNT(distinct id_movie) 
        from movies);

select 
    title_movie, 
    avg(stars_rating), 
    max(stars_rating), 
    min(stars_rating)
    from ratings
    natural join movies
    group by id_movie, title_movie
    order by title_movie;

select 
    t.id_reviewer, 
    name_reviewer, 
    COUNT(*) as nombre_eval
    from ratings t
    join reviewers using (id_reviewer)
    group by name_reviewer, t.id_reviewer
    having COUNT(t.id_reviewer) >= 3
    order by nombre_eval desc;



select 
    title_movie,
    avg(stars_rating) as moy
    from Ratings
    join movies using(id_movie)
    group by title_movie, id_movie
    having avg(stars_rating) = (

select
    max(t.moy_plus_haute)
    from (
        select
        title_movie,
        avg(stars_rating) as moy_plus_haute
        from ratings
        join movies using(id_movie)
        group by title_movie, id_movie
        order by moy_plus_haute desc
    ) as t);  


with moymaxf as (
    select
        id_movie,
        title_movie,
        max(stars_rating) as max_note
    from movies 
    join ratings using(id_movie)
    group by title_movie, id_movie
    order by max_note desc
)

select 
    
    name_reviewer,
    title_movie,
    max_note
    from moymaxf
    natural join ratings natural join reviewers
    where max_note = ratings.stars_rating
    group by title_movie, name_reviewer, max_note
    order by max_note desc, title_movie asc;

with mf as (
    select
        id_movie,
        title_movie,
        year_movie,
        avg(stars_rating) as moyenne
    from movies as t
    join ratings using(id_movie)
    group by title_movie, id_movie, year_movie
),

avant_80 as (
    select avg(moyenne) as m from mf where year_movie <= 1980),

apres_80 as (
    select avg(moyenne) as m from mf where year_movie >= 1980
)

select avant_80.m - apres_80.m 
    from avant_80 
    cross join apres_80;


with mmf as (
    select
        id_movie,
        title_movie,
        max(stars_rating) as max_note,
        min(stars_rating) as min_note
    from movies as t
    join ratings using(id_movie)
    group by title_movie, id_movie
)

select 
    id_movie,
    title_movie,
    max_note - min_note as diff_note
    from mmf
    order by diff_note desc, title_movie asc;


