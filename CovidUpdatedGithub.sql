--Inital Selection
Select *
From CovidPortfolioProjectUpdated.dbo.CovidDeathsUpdated
Order by 3,4

--Select working data set
Select location, date, population, new_cases, total_cases, total_deaths
From CovidPortfolioProjectUpdated.dbo.CovidDeathsUpdated
Order by 1,2

--Total cases VS Total deaths & the likelihood of dying from Covid US
Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentInUS
From CovidPortfolioProjectUpdated.dbo.CovidDeathsUpdated
Where location like '%states'
Order by 1,2

--Total Cases VS Population & shows percentage of United States infected by day
Select location, date, total_cases, population, (total_cases/population)*100 as USPopulationInfection
From CovidPortfolioProjectUpdated..CovidDeathsUpdated
Where location like '%states%'
Order by 1,2

--Total Cases VS Population & shows percentage of each location that has gotten COVID
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionRatePercent
From CovidPortfolioProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Group By location, population
Order by InfectionRatePercent DESC

--Total Cases VS Population & shows percentage of population that has gotten COVID
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProjectUpdated..CovidDeathsUpdated
WHERE continent is not null
GROUP BY location
Order by TotalDeathCount DESC

--Looking at each continents highest death rate per population
Select continent, MAX(CONVERT(int,total_deaths)) as TotalDeathCount
From CovidPortfolioProjectUpdated..CovidDeathsUpdated
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Break down by continent with highest death count per population
Select continent, MAX(CONVERT(int,total_deaths)) as TotalDeathCount
From CovidPortfolioProjectUpdated..CovidDeathsUpdated
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--GLOBAL NUMBERS COMPARED TO POPULATION
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolioProjectUpdated..CovidDeathsUpdated
where continent is not null 
order by 1,2

--Total Population VS Vaccination
--Shows the pecentage of population that has received at least 1 covid shot
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectUpdated..CovidDeathsUpdated dea
JOIN CovidPortfolioProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopulationVSVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectUpdated..CovidDeathsUpdated dea
JOIN CovidPortfolioProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationVSVaccination;

-- Using Temp Table to perform Calculation on Partition By in previous query
--DROP Table if exists #PercentPopulationVaccinated
--Drop View PercentPopulationVaccinated
Create Table #PercentageofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentageofPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectUpdated..CovidDeathsUpdated dea
JOIN CovidPortfolioProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentageofPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentageofPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortfolioProjectUpdated..CovidDeathsUpdated dea
JOIN CovidPortfolioProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 