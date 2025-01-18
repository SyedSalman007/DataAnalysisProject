USE [MyPortfolio]

Select *
From CovidDeaths$
Order by 3, 4

--Select *
--From CovidVaccinations$
--order by 3, 4

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths$';

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$ 
order by 1, 2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100, 2) as DeathPercentage
From CovidDeaths$ 
--Where location like '%Pak%'
order by 1, 2

-- Total Cases vs Population

Select location, date, population, total_cases, Round((total_cases/population)*100, 5) as CasePercentage
From CovidDeaths$ 
--Where location like '%Pak%'
order by 1, 2

-- Total Deaths vs Population

Select location, date, population, total_deaths, Round((total_deaths/population)*100, 5) as DeathPercentage
From CovidDeaths$ 
order by 1, 2

-- Countries Highesh Infection Count

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
From CovidDeaths$ 
Group by location, population
order by PercentPopulationInfected desc

-- Countries Highest Death Count

Select location, population, MAX(CAST(total_deaths as int)) as HighestInfectionCount, Max((CAST(total_deaths as int)/population)*100) as PercentPopulationDied
From CovidDeaths$ 
Group by location, population
order by PercentPopulationDied desc

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where Continent is not null
Group by location
order by TotalDeathCount desc


Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where Continent is null
Group by location
order by TotalDeathCount desc

-- Continents with highest death count per population

Select Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where Continent is not null
Group by Continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as NewCases, SUM(CAST(new_deaths as int)) as NewDeaths, ROUND((SUM(CAST(new_deaths as int))/SUM(new_cases)), 3)*100 as DeathPercentage
From CovidDeaths$
Where Continent is not null
Group by date
order by 1, 2
 

 Select *
 From CovidVaccinations$


 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order 
 By dea.location, dea.date) as RollingPeopleVaccinated
 From CovidDeaths$ dea
 Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and vac.new_vaccinations is not null
order by 2, 3

-- With ETC

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order 
 By dea.location, dea.date) as RollingPeopleVaccinated
 From CovidDeaths$ dea
 Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and vac.new_vaccinations is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DateTime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order 
 By dea.location, dea.date) as RollingPeopleVaccinated
 From CovidDeaths$ dea
 Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
and vac.new_vaccinations is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated


 
Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order 
 By dea.location, dea.date) as RollingPeopleVaccinated
 From CovidDeaths$ dea
 Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
and vac.new_vaccinations is not null

Select *
From PercentPopulationVaccinated