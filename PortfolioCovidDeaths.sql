SELECT * 
FROM portfolio_project.coviddeathstable
;

DROP TABLE portfolio_project.coviddeathstable;

SELECT * 
FROM portfolio_project.coviddeathstable
#WHERE continent = ''
ORDER BY 3, 4
;

SELECT * 
FROM portfolio_project.coviddeathsvaccinationstable
ORDER BY 3, 4
;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.coviddeathstable
ORDER BY 1,2
;

#Looking at Total Cases Vs Total Deaths
#Shows likelihood of dying in your country

SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS Death_Percentage
FROM portfolio_project.coviddeathstable
WHERE location LIKE '%states%'
ORDER BY 1,2
;

#Looking at Total Cases Vs Population
#Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS Infected_Percentage
FROM portfolio_project.coviddeathstable
WHERE location LIKE '%states%'
ORDER BY 1,2
;

#Looking at countries with heighest infection rate compared to population
SELECT Location, population, 
		MAX(total_cases) AS HighestInfectionCount,
        ROUND(MAX((total_cases/population)*100),2) AS PercentagePopulationInfected
FROM portfolio_project.coviddeathstable
GROUP BY location, population
#WHERE location LIKE '%states%'
ORDER BY PercentagePopulationInfected DESC
;

#Showing the countries with the highest death count per population
SELECT Location, 
		MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM portfolio_project.coviddeathstable
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
;

#Breaking things down by continent
SELECT continent, 
		MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM portfolio_project.coviddeathstable
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
;

#Showing continents with the highest death count per population
SELECT continent, 
		MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM portfolio_project.coviddeathstable
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
;

# Global Numbers
SELECT date, 
		SUM(new_cases) AS TotalCases,
        SUM(new_deaths) AS TotalDeaths,
        ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) AS DeathPercentages
FROM portfolio_project.coviddeathstable
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
;

# Global Numbers
SELECT #date, 
		SUM(new_cases) AS TotalCases,
        SUM(new_deaths) AS TotalDeaths,
        ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) AS DeathPercentages
FROM portfolio_project.coviddeathstable
WHERE continent IS NOT NULL
#GROUP BY date
ORDER BY 1,2
;

SELECT * 
FROM portfolio_project.coviddeathstable AS dea
JOIN portfolio_project.coviddeathsvaccinationstable AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
;

#Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathstable AS dea
JOIN portfolio_project.coviddeathsvaccinationstable AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
;

# Using a CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathstable AS dea
JOIN portfolio_project.coviddeathsvaccinationstable AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
#ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 AS RollingPercentage
FROM PopvsVac
;

# Using a Temp Table

Create Table PercentPopulationVaccinated
(
continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
;

SELECT *
FROM PercentPopulationVaccinated
;

DROP TABLE IF EXISTS PercentPopulationVaccinated
;

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathstable AS dea
JOIN portfolio_project.coviddeathsvaccinationstable AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
#ORDER BY 2, 3
;

SELECT *, (RollingPeopleVaccinated/population) * 100 AS RollingPercentage
FROM PercentPopulationVaccinated
;

#Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio_project.coviddeathstable AS dea
JOIN portfolio_project.coviddeathsvaccinationstable AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
#ORDER BY 2, 3
;

SELECT *
FROM PercentPopulationVaccinated
;

#TABLES FOR VISUALIZATION

#1 Table for Visualization 'Global Numbers'
SELECT SUM(new_cases) AS total_cases,
		SUM(cast(new_deaths AS SIGNED)) AS total_deaths,
        SUM(CAST(new_deaths AS SIGNED))/SUM(New_Cases)*100  AS Death_Percentage
FROM portfolio_project.coviddeathstable
WHERE continent IS NOT NULL
ORDER BY 1,2
;

#2 Table for Visualization 'Total Deaths per Continent'

SELECT location, SUM(cast(new_deaths as signed)) AS TotalDeathCount
FROM portfolio_project.coviddeathstable
WHERE continent is NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC
;

# 3 Table for Visualization ' Percent Population Infected Per Country'
SELECT Location, Population,
		MAX(total_cases) AS HighestInfectionCount,
        MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM portfolio_project.coviddeathstable
GROUP BY Location, Population
ORDER BY PercentPopulationInfected
;

# 4 Table for Visualization ' Percent Population Infected

SELECT Location, Population, Date,
		MAX(total_cases) AS HighestInfectionCount,
		MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM portfolio_project.coviddeathstable
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC
;