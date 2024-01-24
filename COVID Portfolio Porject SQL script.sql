SELECT *
FROM COVID..COVIDVaccinations$
order by 3,4


SELECT *
FROM COVID..COVIDDeaths$
order by 3,4

-- Select Data that to use 


Select location, date, total_cases, new_cases, total_deaths, population
FROM COVIDDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM COVIDDeaths$
Where location like '%states%' AND total_cases IS NOT NULL
order by 1,2


-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
Select location, date, total_cases, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as infectedPercentage
FROM COVIDDeaths$
Where location like '%states%' AND total_cases IS NOT NULL
order by 1,2

-- Country with the highest infection rates compared to population**************
Select location, population, MAX(total_cases) as highestInfectionCount, (cast(MAX(total_cases) as float)/population)*100 as infectedPopulationPercentage
FROM COVIDDeaths$
Group By location, population
order by infectedPopulationPercentage desc




-- countries with highest deat count per population

Select location, MAX(cast(total_deaths as int)) as totalDeathCount
FROM COVIDDeaths$
WHERE continent is not null
Group by location
order by totalDeathCount desc


--Data broken down by continent

Select continent, MAX(cast(total_deaths as int)) as totalDeathCount
FROM COVIDDeaths$
WHERE continent is not null
Group by continent
order by totalDeathCount desc



-- Global Numbers

Select SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
FROM COVIDDeaths$
WHERE continent is not null

order by 1,2


-- Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as rollingPeopleVaccinated
FROM COVIDVaccinations$ vac
JOIN COVIDDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null AND dea.location = 'Albania'
order by 2,3

-- USE CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as rollingPeopleVaccinated
FROM COVIDVaccinations$ vac
JOIN COVIDDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null AND dea.location = 'Albania'
--order by 2,3
)
Select*, (rollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPOpulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as rollingPeopleVaccinated
FROM COVIDVaccinations$ vac
JOIN COVIDDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*, (rollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View for Visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as rollingPeopleVaccinated
FROM COVIDVaccinations$ vac
JOIN COVIDDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


