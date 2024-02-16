/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (cast(total_deaths as int) / cast(total_cases as int))*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
And continent is not null
Order By 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, population, (cast(total_cases as int) / population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Order By 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) As HighestInfectionCount, Max(cast(total_cases as int) / population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Group By location, population
Order By PercentPopulationInfected Desc


-- Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group By location
Order By HighestDeathCount Desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group By continent
Order By HighestDeathCount Desc


-- GLOBAL NUMBERS

Select Sum(new_cases) As total_cases, Sum(cast(new_deaths as int)) As total_deaths, Sum(cast(new_deaths as int)) / Sum(new_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
--Group By date
Order By 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select *
From PortfolioProject..CovidVaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as Bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as Bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinations
Create Table #PercentPopulationVaccinations
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as Bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinations


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as Bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinations

