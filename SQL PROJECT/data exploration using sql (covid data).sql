/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT *
FROM Covidvaccination
ORDER BY 3,4

-- SELECT DATA THAT WE USE

SELECT location, date , total_cases , new_cases , total_deaths , population
from CovidDeaths
where continent is not null 
order by location,date

-- Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid with specific country


SELECT  location, date , total_cases , total_deaths ,  (total_cases/total_deaths)*100 as deathpercentage
from CovidDeaths
where continent is not null and total_deaths IS NOT NULL AND total_cases IS NOT NULL and location = 'India'
order by 1,2


-- Total Cases vs Population
-- Shows the percentage of population infected with Covid with specific country

Select location, date, Population, total_cases,  (total_cases/population)*100 as PopulationInfectedPercent
from CovidDeaths
where location like 'I%d_a'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, Population, max(total_cases) as highestinfectedcount , max((total_cases/population))*100 as percentpopulationinfected
from CovidDeaths
--where location like 'I%d_a'
Group by location, Population
order by percentpopulationinfected desc

-- Countries with Highest Death Count per Population

select location , MAX(cast(Total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null 
Group by location
order by totaldeathcount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- showing contintents with the highest death count pr population

Select continent, MAX(cast(Total_deaths as int)) as totaldeathcount
From CovidDeaths
--Where location like '%states%'
where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as deathpercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- TOTAL POPULATION VS VACCINATIONS

---- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as dea
JOIN Covidvaccination as vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths as dea
Join Covidvaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #percentagepopulationvaccinated
Create Table #percentagepopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentagepopulationvaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percentagepopulationvaccinated 

-- Creating View to store data for  visualizations later

Create View percentagepopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
