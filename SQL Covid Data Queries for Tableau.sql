/*
Queries used for Tableau Project
*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidData.dbo.CovidDataDeaths
--Where location like '%ice%'
where continent <> '' 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- Numbers are extremely close so we will keep them

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2

-- 2. 

-- Take these out as they are not inluded in the above queries and want to stay consistent
-- For example, European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidData.dbo.CovidDataDeaths
--Where location like '%ice%'
Where continent = '' 
and location not in ('High income','Upper middle income','Lower middle income','Low income', 'World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)) as PercentPopulationInfected
From CovidData.dbo.CovidDataDeaths
--Where location like '%ice%'
Where continent <> '' 
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.

Select Location, Population,date, Max(total_cases), (Max(total_cases)/population) as PercentPopulationInfected
From CovidData.dbo.CovidDataDeaths
--Where location like '%ice%'
Where continent <> '' 
Group by Location, Population, date
order by PercentPopulationInfected desc

With PopvsInf (Continent, Location, Date, Population, total_cases, RollingPeopleInfection)
as
(
Select dea.continent, dea.location, dea.date, dea.population, dea.total_cases
, SUM(CONVERT(float,dea.total_cases)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleInfection
--, (RollingPeopleVaccinated/population)*100
From CovidData.dbo.CovidDataDeaths dea
Join CovidData.dbo.CovidDataVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
--order by 2,3
)
Select *, (RollingPeopleInfection/Population)*100
From PopvsInf


