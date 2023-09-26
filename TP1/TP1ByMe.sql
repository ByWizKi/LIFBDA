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


select name_reviewer 
    from Reviewers 
        where id_reviewer = 205;

select distinct 
    title_movie 
        from Movies;

select distinct 
    title_movie 
        from Movies 
            order by title_movie ASC;

select distinct 
    title_movie 
        from Movies 
            where (director_movie = 'Steven Spielberg');

select distinct 
    title_movie 
        from Movies 
            where (director_movie is null);

create view v_detail_evaluations 
    (id_movie, id_reviewer, title_movie, stars_rating,director_movie)
        as 
            select t1.id_movie, id_reviewer, title_movie,stars_rating, director_movie
                from Movies t1, Ratings t2
                    where t1.id_movie = t2.id_movie 
                        order by (title_movie) ASC;

select distinct year_movie 
    from Movies t1 
        inner join v_detail_evaluations t2 
            on (stars_rating = 4 or stars_rating = 5)
                order by (year_movie) DESC;

select distinct name_reviewer 
    from Reviewers t1 
        natural join v_detail_evaluations t2 
            where (title_movie = 'Gone with the Wind');

select 
    name_reviewer as nom_examinateur, 
    title_movie as titre_film, 
    stars_rating as nombre_etoiles
        from Reviewers t1 
            natural join v_detail_evaluations t2
                order by (name_reviewer, title_movie, stars_rating);

select 
    name_reviewer as nom_examinateur,
    title_movie as titre_film,
    stars_rating as nombre_etoiles
        from Reviewers t1 
            natural join v_detail_evaluations t2 
                natural join Movies t3
                    where (t1.name_reviewer = t3.director_movie);

select title_movie
    from v_detail_evaluations
        except 
select title_movie 
    from v_detail_evaluations
        natural join Reviewers t2
            where (t2.name_reviewer = 'Chris Jackson');