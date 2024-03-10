Use HR_data


--What is the gender breakdown of employees in the company?
--What is the race/ethnicity breakdown of employees in the company?
--What is the age distribution of employees in the company?
--How many employees work at headquarters versus remote locations?
--What is the average length of employment for employees who have been terminated?
--How does the gender distribution vary across departments and job titles?
--What is the distribution of job titles across the company?
--Which department has the highest turnover rate?
--What is the distribution of employees across locations by state?
--How has the company's employee count changed over time based on hire and term dates?
--What is the tenure distribution for each department?

select * from dbo.hr
order by department

EXEC sp_rename 'dbo.hr.id', 'employee_id', 'COLUMN'; --changing column name


--select
--PARSENAME(REPLACE(termdate, ' ','.'),3) as Date
--from hr

ALter table hr
Add termdateclean Nvarchar(255)

Update hr
SET termdateclean = PARSENAME(REPLACE(termdate, ' ','.'),3)

select termdateclean
from hr

alter table hr
alter column [termdateclean] date

------
ALter table hr
Add Age int

update hr
set Age = DATEDIFF(YEAR,birthdate, GETDATE()) - 
    CASE 
        WHEN MONTH(birthdate) > MONTH(GETDATE()) OR 
             (MONTH(birthdate) = MONTH(GETDATE()) AND DAY(birthdate) > DAY(GETDATE()))
        THEN 1
        ELSE 0
    END

select gender, COUNT(*) as count
from hr
where termdateclean is null and Age > 18
group by gender

 ----

select race, COUNT(race) as count
from hr
where termdateclean is null and Age > 18
group by race
order by count(race) desc


----

With AgeData AS(
select case
	when age >=18 and age <= 24 then '18-24'
	when age >=25 and age <= 34 then '25-34'
	when age >=35 and age <= 44 then '35-44'
	when age >=45 and age <= 54 then '45-54'
	when age >=55 and age <= 64 then '55-64'
	else '65+'
	end as age_group, gender
from hr
where termdateclean is null and Age > 18)

select age_group,gender, COUNT(*) as count
from AgeData
group by age_group, gender
order by age_group, gender

----

select location, COUNT(location) as count
from hr
where termdateclean is null and Age > 18
group by location

---

select avg(datediff(year,hire_date,termdateclean)) as avg_length_emplyoment
from hr
where termdateclean is not null and termdateclean <= GETDATE()

----


select department, gender, COUNT(*) as count
from hr
where termdateclean is null and Age > 18
group by department, gender
order by department

-----

select department,total_count, terminated_count,terminated_count/cast(total_count as float) as termination_rate
from( select department,count(*) as total_count, sum(case when termdateclean is not null and termdateclean <= getdate() then 1 else 0 end) as terminated_count
	from hr
	where age >=18
	group by department) as subquery
	order by termination_rate desc

---

select location_state, count(*) as count
from hr
where termdateclean is null and Age > 18
group by location_state
order by count desc

----

select location_city, count(*) as count
from hr
where termdateclean is null and Age > 18
group by location_city
order by count desc


-----

select 
year, hires, terminations, hires - terminations as net_change,
(hires - terminations)/cast(hires as float) * 100 as net_change_percent
from(select year(hire_date) as year, count(*) as hires, sum(case when termdateclean is not null and termdateclean <= getdate() then 1 else 0 end) as terminations
from hr
where age >= 18
group by year(hire_date)) as subquery
order by year Asc;

-----

select department, avg(DATEDIFF(year,hire_date,termdateclean)) as avg_tenure
from hr 
where termdateclean is not null and Age > 18
group  by department