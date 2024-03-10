Select *
From PortfolioProject..covid_vaccination
order by 3,4
--Select *
--From PortfolioProject..covid_vaccination
--order by 3,4

-- Select data that we are gonna use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths

order by 1,2

-- Looking total cases vs Total deaths from int to float

Select location, date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float)*100 as DeathPercentage
From PortfolioProject..covid_deaths
where location like 'Hungary'
order by 1,2

-- total cases vs population

Select location, date, population, total_cases,  (CAST(total_cases as float)  / CAST(population as float))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
where location like 'Hungary'
order by 1,2

--  Looking at countries with highest infection rate compared to poplutation

Select location, population, MAX(total_cases) as HIghestInfectionCount,  MAX((CAST(total_cases as float))  / CAST(population as float))*100 as HighestInfectionRate
From PortfolioProject..covid_deaths
--where location like 'Hungary'
Group by location, population
order by HighestInfectionRate desc

-- Showing countries with the highest deathCount/population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--where location like 'Hungary'
where continent is  null
group by location
order by TotalDeathCount desc

-- GOLBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(New_cases as float))*100 as DeathPercentage
from portfolioproject.. covid_deaths
where continent is not null
order by 1,2

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as  RollingPplVaccinated
--RollingPplVaccinated/population*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

-- USE CTE

with PopVsVac (Continent, location, date, population, new_vaccinations, RollingPplVaccinated)
as
(
    select 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVaccinated
        -- RollingPplVaccinated/population*100
    from 
        PortfolioProject..covid_deaths dea
    join 
        PortfolioProject..covid_vaccination vac
        on dea.location = vac.location
        and dea.date = vac.date
    where 
        dea.continent is not null
    -- order by 2,3
)
select *
from PopVsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as  RollingPplVaccinated
--RollingPplVaccinated/population*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as  RollingPplVaccinated
--RollingPplVaccinated/population*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3