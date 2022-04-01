--Select *
--from PortfolioP..CovidDeath$
--order by 3,4

--Select *
--from PortfolioP..CovidVax$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioP..CovidDeath$
order by 1,2

-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioP..CovidDeath$
--where location like  '%states%'
where continent is not null
order by 1,2

--Looking at total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopulationInfected
from PortfolioP..CovidDeath$
--where location like  '%states%'
where continent is not null
order by 1,2

-- looking at counttries with highest infection rate
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioP..CovidDeath$
--where location like  '%states%'
where continent is not null
Group by location, population
order by PercentOfPopulationInfected desc

-- showing countries with highest death count per pop
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioP..CovidDeath$
--where location like  '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- break down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioP..CovidDeath$
--where location like  '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global
Select date, sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as totaldeath, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioP..CovidDeath$
--where location like  '%states%'
where continent is not null
group by date
order by 1,2

-- total pop vs vac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax

From PortfolioP..CovidDeath$ dea
join PortfolioP..CovidVax$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
order by 2,3

--CTE
with popvvac(continent, location, date, population,New_Vaccinations, RollingPeopleVax)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax

From PortfolioP..CovidDeath$ dea
join PortfolioP..CovidVax$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3
)
select *, (RollingPeopleVax/population)*100
From popvvac 

--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVax numeric)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax

From PortfolioP..CovidDeath$ dea
join PortfolioP..CovidVax$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3
select *, (RollingPeopleVax/population)*100
From #PercentPopulationVaccinated

-- Createing View to store data for later

create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVax

From PortfolioP..CovidDeath$ dea
join PortfolioP..CovidVax$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3

select *
from PercentPopulationVaccinated

--Queries for Microsoft power bi
--1
create View DeathPercent as 
select Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioP..CovidDeath$
where continent is not null
--order by 1,2
--2
create View DeathCount as
Select Location, Sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioP..CovidDeath$
Where continent is null
and Location not in ('World', 'European Union', 'International')
Group by location
--order by TotalDeathCount desc
--3
create View PercentPopInfected as
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioP..CovidDeath$ 
Group by location,population
--order by PercentPopulationInfected desc
--4
create View PercentPopInfectedworld as
select location , population , date , MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioP..CovidDeath$
group by location, population,date
--order by PercentPopulationInfected desc