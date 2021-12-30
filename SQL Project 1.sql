Select *
From PortfolioPtoject..['covid vaccination]
WHERE continent is not null
order by 3,4

--select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioPtoject..['covid deaths]
order by 1,2


-- Looking at the total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in my country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioPtoject..['covid deaths]
where location like '%India%'
order by 1,2


-- looking at total cases vs Population
-- shows what percentage of population got covid 
Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfected
From PortfolioPtoject..['covid deaths]
--where location like '%India%'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to population 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAx((total_cases/population))*100 as PopulationInfected
From PortfolioPtoject..['covid deaths]
--where location like '%India%'
Group by location, population
order by PopulationInfected desc

--showing countries with HIghest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioPtoject..['covid deaths]
--where location like '%India%'
where continent is not null
Group by location, population
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with Highest Death Counts per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioPtoject..['covid deaths]
--where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPtoject..['covid deaths]
--where location like '%India%'
where continent is not null
--Group by date
order by 1,2

 
 --Looking at total population vs vaccination
with popVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPtoject..['covid deaths] dea
join PortfolioPtoject..['covid vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*,(RollingPeopleVaccinated/Population)*100
from popVac

-- Temp Table

Drop table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPtoject..['covid deaths] dea
join PortfolioPtoject..['covid vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*,(RollingPeopleVaccinated/Population)*100
from #percentpopulationvaccinated

-- Creating view to stoere data for later visualization




Create View percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPtoject..['covid deaths] dea
join PortfolioPtoject..['covid vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select * 
From percentpopulationvaccinated