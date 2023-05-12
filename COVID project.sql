SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--Selecting data which will be used for analysis

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Lithuania' AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs population
-- Shows what percentage of population got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM CovidDeaths
WHERE location = 'Lithuania' AND continent is not null
ORDER BY 1,2

--Countries that has highest infection rate compareds to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM CovidDeaths
WHERE continent is not null
--WHERE location = 'Lithuania'
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--Countries with highest death count per population
--breaking down by continent

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
	--AND location <> 'High income'
	--AND location <> 'Upper middle income'
	--AND location <> 'Lower middle income'
	--AND location <> 'Low income'
--WHERE location = 'Lithuania'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing continents with highest death count

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--WHERE location = 'Lithuania'
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
-- Joining tables based on location and date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE

WITH PopvsVac (Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for visualizations

CREATE View PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated