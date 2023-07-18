select * from PortfolioProject..CovidDeaths
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4


--Select data I will be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Total Cases vs Total Deaths - shows likelihood of death if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) as DeathtoCasesRatio, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2


--Total Cases vs Population - shows % of Population that has contracted Covid 19 

select location, date, population, total_cases, (total_cases/population) as CasestoPopRatio, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
order by 1,2


--Countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%States%'
Group by location, population
order by PopulationInfected desc


--Countried with Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as HighestDeath
from PortfolioProject..CovidDeaths
where continent is not null 
Group by location
order by HighestDeath desc


--Total Death count by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc


--Global Numbers by date
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
Group by date
order by 1,2

--Global Numbers - Total
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
--Group by date
order by 1,2




--Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--sum(convert(int, vac.new_vaccinations))
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Use Common Table Expression, CTE

With PopvsVac (continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
select * , (RollingPeopleVaccinated/population)*100 as RollingPercentVaccinated
from PopvsVac


-- Use Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select * , (RollingPeopleVaccinated/population)*100 as RollingPercentVaccinated
from #PercentPopulationVaccinated



--Create view for visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * 
from PercentPopulationVaccinated