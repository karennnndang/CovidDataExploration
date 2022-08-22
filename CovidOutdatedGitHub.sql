--Initial selection
SELECT *
From CovidPortfolioProjectOutdated.dbo.CovidDeathsOutdated
Where continent is not null
Order by 3,4

--Select working data set
Select location, date, new_cases, total_cases, total_deaths, population
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
Where continent is not null
Order by 1,2

--Total cases VS Total deaths & the likelihood of dying from Covid US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
Where location like '%states%'
Order by 1,2

--Total Cases VS Population & shows percentage of United States infected by day
Select location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfection 
From CovidPortfolioProjectOutdated.dbo.CovidDeathsOutdated
Where location like '%states%'
Order by 1,2

--Total Cases VS Population & shows percentage of each location that has gotten COVID
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRatePercent
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
GROUP BY location, population
ORDER BY InfectionRatePercent DESC

--Total Cases VS Population & shows percentage of population that has gotten COVID
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
WHERE continent is not null
GROUP BY location
Order by TotalDeathCount DESC

--Looking at each continents highest death rate per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
WHERE continent is not null
GROUP BY continent
Order by TotalDeathCount DESC

--Break down by continent with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCountByPopulation
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
Where continent is not null
Group By continent
Order by TotalDeathCountByPopulation DESC

--GLOBAL NUMBERS COMPARED TO POPULATION
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolioProjectOutdated..CovidDeathsOutdated
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total Population VS Vaccination
--Shows the pecentage of population that has received at least 1 covid shot
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectOutdated..CovidDeathsOutdated dea
JOIN CovidPortfolioProjectOutdated..CovidVaccinationsOutdated vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectOutdated..CovidDeathsOutdated dea
JOIN CovidPortfolioProjectOutdated..CovidVaccinationsOutdated vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVSVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
--DROP Table if exists #PercentPopulationVaccinated
--Drop View PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectOutdated..CovidDeathsOutdated dea
JOIN CovidPortfolioProjectOutdated..CovidVaccinationsOutdated vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectOutdated..CovidDeathsOutdated dea
JOIN CovidPortfolioProjectOutdated..CovidVaccinationsOutdated vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 