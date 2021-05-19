SELECT * 
FROM PortfolioProject..Coviddeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..Covidvaccination
ORDER BY 3,4

-- SELECT DATA that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Coviddeaths
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelidhood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..Coviddeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as percentofpopulationinfected
FROM PortfolioProject..Coviddeaths
--WHERE location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentofpopulationinfected
FROM PortfolioProject..Coviddeaths
GROUP by Location, Population
ORDER BY percentofpopulationinfected desc

-- Showing Countries with Highest Death Count per Population
SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP by Location
ORDER bY TotalDeathCount desc

--Breaking Things Down By Continent

--Showing continents with the highest death count per population
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP by continent
ORDER bY TotalDeathCount desc

-- Global Numbers

-- Total cases, deaths and death percentage by date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..Coviddeaths
WHERE continent is not null
--Group By date
order by 1,2

--Total cases, deaths and deathpercentage worldwide
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..Coviddeaths
WHERE continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVAC

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exist #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into#PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea,location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccination vac
		On dea.location = vac.location
		and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visulaizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccination vac
		ON dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null