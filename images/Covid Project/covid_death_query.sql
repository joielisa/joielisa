SELECT *
FROM covid_data..CovidDeaths$
--Lets me view all the columns in the dataset

--How many unique countires are in the dataset
SELECT Count (DISTINCT location)
FROM covid_data..CovidDeaths$
--Returns 219 


--What coutries are in the dataset
SELECT DISTINCT location
FROM covid_data..CovidDeaths$
ORDER BY location
--Returns unique locations in ABC order

--What unique continents do we hav
SELECT DISTINCT (continent)
FROM covid_data..CovidDeaths$
ORDER BY 1
--There is an issue. There are 7 returns when there should only be 6. Need to clean the "Null"

--How many unique dates do we have?
SELECT DISTINCT ("date")
FROM covid_data..CovidDeaths$
--This returned 486 rows which comes to 1 year 4 months and 1 day


--Select data that we are going to be using
SELECT location, "date", total_cases, new_cases, total_deaths, population
FROM covid_data..CovidDeaths$
Order By 1,2

--Looking at the total cases vs total deaths for the United Sates
SELECT location, "date", total_cases,  total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_data..CovidDeaths$
WHERE location LIKE '%state%'
Order By 1,2
--returns a table that shows the likelihood of dying if you contract covid in your country

--Looking at total cases vs populaton 
--Shows what percentage of population got Covid
SELECT location, "date", total_cases,  population, (total_cases/population)*100 AS infected_of_pop
FROM covid_data..CovidDeaths$
WHERE location LIKE '%state%'
Order By 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_infection_COunt, MAX((total_cases/population)*100) AS Percent_Pop_Infected
FROM covid_data..CovidDeaths$
--WHERE location LIKE '%state%'
Group By location, population
Order By population, Percent_Pop_Infected
--Very interested to see the percentage of infection in countries that have a low population

--Looking at Countries with Highest Death count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS Totaldeathcount
FROM covid_data..CovidDeaths$
WHERE continent is not null
Group By location
Order By  Totaldeathcount desc


--break it down by continent

--shows continent with highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS Totaldeathcount
FROM covid_data..CovidDeaths$
WHERE continent is not null
Group By continent
Order By  Totaldeathcount desc


--global numbers

SELECT  SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/ SUM(new_cases) ) * 100AS Death_Percentage
FROM covid_data..CovidDeaths$
--WHERE location LIKE '%state%'
where continent is not null
--Group By date
Order By 1,2

--Let's Join the Covid_Deaths and COvid_Vaccine Tables

SELECT *
FROM covid_data..CovidDeaths$ dea
JOIN covid_data..CovidVaccinations$ vac
	ON dea.location = vac.location AND
		dea.date = vac.date


--Looking at the total Population vs Vaccinations of people in the world




SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
	--,(rollingpeoplevaccinated/population)*100
FROM covid_data..CovidDeaths$ dea
JOIN covid_data..CovidVaccinations$ vac
	ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL
order BY 2,3 


--use cte
WITH POPvsVAC (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
	--,(rollingpeoplevaccinated/population)*100
FROM covid_data..CovidDeaths$ dea
JOIN covid_data..CovidVaccinations$ vac
	ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100 AS PERCENTVAC
FROM POPvsVAC


--TEMP TABLE


DROP TABLE IF EXISTS  #PERCENTPOPULATIONVACCINATED
CREATE TABLE  #PERCENTPOPULATIONVACCINATED
(
CONTINENT NVARCHAR(255), 
LOCATION NVARCHAR(255), 
DATE DATETIME, 
POPULATION NUMERIC, 
NEW_VACCINATIONS NUMERIC,
rollingpeoplevaccinated NUMERIC
)

INSERT INTO  #PERCENTPOPULATIONVACCINATED

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
	--,(rollingpeoplevaccinated/population)*100
FROM covid_data..CovidDeaths$ dea
JOIN covid_data..CovidVaccinations$ vac
	ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rollingpeoplevaccinated/population)*100 AS PERCENTVAC
FROM #PERCENTPOPULATIONVACCINATED



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW  PERCENTPOPULATIONVACCINATED as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
	--,(rollingpeoplevaccinated/population)*100
FROM covid_data..CovidDeaths$ dea
JOIN covid_data..CovidVaccinations$ vac
	ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL