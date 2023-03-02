SELECT *
FROM PortfolioProject..CovidDeaths
where continent IS NOT Null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVacinations
--ORDER BY 3,4

SELECT location,date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
where continent IS NOT Null
ORDER BY 1,2


-- Total cases vs Total Deaths in Nigeria
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%nigeria' AND continent IS NOT Null
ORDER BY 1,2

-- Total Cases vs Population 
SELECT location,date,population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%nigeria' AND continent IS NOT Null
ORDER BY 1,2

-- Looking for country with highest infection rate compared to population 
SELECT location,population, Max(total_cases) as HigestinfectionCount, Max((total_cases/population))*100 as PopulationPercentageInfection
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PopulationPercentageInfection desc

-- Showing Countries with high death rate 
SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing by Continent
SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers
SELECT date, SUM(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

-- showing world death percentage

SELECT SUM(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 1,2

--CTE
With PopVsVac (continent,location,date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date)as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated / population)*100
FROM PopVsVac

-- Temp table
DROP TABLE if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date)as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
Select *, (RollingPeopleVaccinated / population)*100
FROM #PercentPopulationVaccinated

-- creating view to store data for later visualization 
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date)as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated