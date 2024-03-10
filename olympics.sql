-- How many olympics games have been held?

select count(distinct games) as Numbers_of_Olympics 
from Olympics_History..athlete_events

--List down all Olympics games held so far

select distinct year, Season, City
from Olympics_History..athlete_events
order by year

--Mention the total number of nations who participated in each olympics game?

with all_regions as (
	select games, region
	from Olympics_History..athlete_events ath
	join Olympics_History..noc_regions noc ON ath.NOC  = noc.NOC
	group by Games, region
)
select games, COUNT(games) as total_countries
from all_regions
group by Games


-- Which year saw the highest and lowest no of countries participating in olympics


with all_countries as
              (select games, nr.region
              from Olympics_History..athlete_events oh
              join Olympics_History..noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;

--Which nation has participated in all of the olympic games

with  
	all_games as(
select count(distinct games) as Numbers_of_Olympics 
from Olympics_History..athlete_events
), 
countries as (
	select games, region as country
	from Olympics_History..athlete_events ath
	join Olympics_History..noc_regions noc ON ath.NOC  = noc.NOC
	group by Games, region
	),
	countries_participated as(
	select country, count(country) as total_participated_games
	from countries
	group by country
)
select country,total_participated_games
from countries_participated 
join all_games on all_games.Numbers_of_Olympics =  countries_participated.total_participated_games


--Identify the sport which was played in all summer olympics.

-- 1. find total no of summer olympic games
--2. find for each sport, hwo many games where they played in

with t1 as(
	select count(distinct Games) as total_sumer_games 
	from Olympics_History..athlete_events
	where Season = 'Summer'
),
	t2 as(
	select distinct Sport, Games
	from Olympics_History..athlete_events
	where Season = 'Summer'

	),
	t3 as(
	select sport, count(games) as no_of_games
	from t2
	group by sport
	)
	select *
	from t3
	join t1 on t1.total_sumer_games = t3.no_of_games

--Which Sports were just played only once in the olympics.

with t1 as(
select distinct  games, sport
from Olympics_History..athlete_events),
t2 as( select sport, count(sport) as no_of_sport
from t1
group by sport)
select t1.sport, no_of_sport, games
from t2
join t1 on t1.sport = t2.sport
where no_of_sport = 1

----Fetch the total no of sports played in each olympic games.

with t1 as(
select distinct  games, sport
from Olympics_History..athlete_events),
t2 as( select games, count(games) as no_of_sport
from t1
group by games)
select *
from t2
order by no_of_sport desc


--Fetch oldest athletes to win a gold medal

SELECT name, sex, age,team,games,city,sport,event,medal
FROM Olympics_History..athlete_events
WHERE Medal = 'Gold' AND age = (SELECT MAX(age) FROM Olympics_History..athlete_events WHERE Medal = 'Gold');

--Find the Ratio of male and female athletes participated in all olympic games.

create table #gender_ratio(sex varchar(50))
insert into #gender_ratio
select sex
from Olympics_History..athlete_events

Alter table #gender_ratio add male_athletes int, female_athletes int, ratio int

with t1 as(select  sum(case when sex = 'M' then 1 else 0 end) as male_athletes,
		sum(case when sex = 'F' then 1 else 0 end) as female_athletes
	from #gender_ratio)
	select CONCAT(male_athletes/male_athletes, ' ', ':',' ' ,Round(male_athletes/cast(female_athletes as float), 2)) as ratio
	from t1

--Fetch the top 5 athletes who have won the most gold medals.

    with t1 as
            (select name, team, count(1) as total_gold_medals
            from Olympics_History..athlete_events
            where medal = 'Gold'
            group by name, team
            ),
        t2 as
            (select *, dense_rank() over (order by total_gold_medals desc) as rnk
            from t1)
    select name, team, total_gold_medals
    from t2
    where rnk <= 5;

---Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

with t1 as
            (select name, team, count(1) as total_medals
            from Olympics_History..athlete_events
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team
            ),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select name, team, total_medals
    from t2
    where rnk <= 5;



--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with t1 as (
select distinct region as country, count(medal) as total_medals
	from Olympics_History..athlete_events ath
	join Olympics_History.dbo.noc_regions noc ON ath.NOC  = noc.NOC
	where medal != 'NA'
	group by region
	
	),
	t2 as ( select *, rank() over (order by total_medals desc) as rnk
            from t1)
    select country, total_medals, rnk
    from t2
    where rnk <= 5;
	
--List down total gold, silver and bronze medals won by each country.	
	
with t1 as(	select distinct region, sum(case when medal = 'Gold' then 1 else 0 end) as gold,
			sum(case when medal = 'Silver' then 1 else 0 end) as silver,
			sum(case when medal = 'Bronze' then 1 else 0 end) as bronze
	from Olympics_History..athlete_events ath
	join Olympics_History.dbo.noc_regions noc ON ath.NOC  = noc.NOC
	where medal != 'NA'
	group by  region)
	select *,gold+silver+bronze as total
	from t1
	order by (gold+silver+bronze) desc
	


--Identify which country won the most gold, most silver and most bronze medals in each olympic games



with t1 as (
    select
        SUBSTRING(games, 1, CHARINDEX(' - ', games) - 1) as games,
        SUBSTRING(games, CHARINDEX(' - ', games) + 3, LEN(games)) as country,
        COALESCE(gold, 0) as gold,
        COALESCE(silver, 0) as silver,
        COALESCE(bronze, 0) as bronze
    from (select CONCAT(games, ' - ', nr.region) as games, medal, COUNT(1) as total_medals
         from Olympics_History..athlete_events oh
              JOIN olympics_history..noc_regions nr on nr.noc = oh.noc
            where medal <> 'NA'
            group by games, nr.region, medal
        ) as Source
        pivot (
            SUM(total_medals)
            for medal IN ([Gold], [Silver], [Bronze])
        ) as PivotTable
)
, t2 as (
    select
        games, country, gold, silver, bronze,
        ROW_NUMBER() over (partition by games order by gold desc) as GoldRank,
        ROW_NUMBER() over (partition by games order by silver desc) as SilverRank,
        ROW_NUMBER() over (partition by games order by bronze desc) as BronzeRank
    from t1
)
select games,
    CONCAT(MAX(case when GoldRank = 1 then country end), ' - ', MAX(case when GoldRank = 1 then gold end)) as Max_Gold,
    CONCAT(MAX(case when SilverRank = 1 then country end), ' - ', MAX(case when SilverRank = 1 then silver end)) as Max_Silver,
    CONCAT(MAX(case when BronzeRank = 1 then country end), ' - ', MAX(case when BronzeRank = 1 then bronze end)) as Max_Bronze
from t2
group by games
order by games;


--Which countries have never won gold medal but have won silver/bronze medals?

with t4 as(select distinct Games,region, sum(case when medal = 'Gold' then 1 else 0 end) as gold,
				sum(case when medal = 'Silver' then 1 else 0 end) as silver,
				sum(case when medal = 'Bronze' then 1 else 0 end) as bronze
		from Olympics_History..athlete_events ath
		join Olympics_History.dbo.noc_regions noc ON ath.NOC  = noc.NOC
		where medal != 'NA'
		group by  Games, region)
		select region, gold, silver, bronze
		from t4
		where gold = 0 and (silver > 0 or bronze > 0)

--In which Sport/event, Hungary has won highest medals.

with t1 as(	select distinct region,Sport, sum(case when medal = 'Gold' then 1 else 0 end) as gold,
			sum(case when medal = 'Silver' then 1 else 0 end) as silver,
			sum(case when medal = 'Bronze' then 1 else 0 end) as bronze
	from Olympics_History..athlete_events ath
	join Olympics_History.dbo.noc_regions noc ON ath.NOC  = noc.NOC
	where medal != 'NA'
	group by  region,Sport)
	select TOP 1 Sport, gold+silver+bronze as total
	from t1
	where region = 'Hungary'
	order by (gold+silver+bronze) desc

--Break down all olympic games where Hungary won medal for Fencing and how many medals in each olympic games

with t1 as(	select distinct team, Games,Sport, sum(case when medal = 'Gold' then 1 else 0 end) as gold,
			sum(case when medal = 'Silver' then 1 else 0 end) as silver,
			sum(case when medal = 'Bronze' then 1 else 0 end) as bronze, region
	from Olympics_History..athlete_events ath
	join Olympics_History.dbo.noc_regions noc ON ath.NOC  = noc.NOC
	where medal != 'NA'
	group by  team,Games,Sport,region)
	select team,Sport,games, gold+silver+bronze as total
	from t1
	where region = 'Hungary' and Sport = 'Fencing'
	order by (gold+silver+bronze) desc
	
