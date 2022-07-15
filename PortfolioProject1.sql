select * from dbo.covid_deaths where continent is not null order by 3,4 

select * from dbo.covid_deaths

--Select Data that we are going to be using

select location, date, total_cases, total_deaths, population
from dbo.covid_deaths
order by 1,2

--Looking at Total Cases vs Total Deaths (Shows Likelihood of Dying if you contract covid in your country)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.covid_deaths
order by 1,2

--Looking at a specific country's death percentage (Shows Likelihood of Dying if you contract covid in  the US)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.covid_deaths
where location like '%states%'
order by 1,2

--Looking at total cases versus population

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopInfected
From dbo.covid_deaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopInfected
From dbo.covid_deaths
--where location like '%states%'
group by population, location
order by PercentPopInfected desc

--Showing countries with Highest Death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
From dbo.covid_deaths 
where continent is not null
--where location like '%states%'
group by population, location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From dbo.covid_deaths 
where continent is not null
--where location like '%states%'
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.covid_deaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--Global Death Percentage (world)
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.covid_deaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Explore Vaccination Table
select * from dbo.covid_vaccinations

--Joining death and vaccinations table
 select * from dbo.covid_deaths as dea
 join dbo.covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at the total population v vaccinations (Total amount of people in the world that have been vaccinated) with CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 
 from dbo.covid_deaths as dea
 join dbo.covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated from PopvsVac

--Temp Table % Population Vaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 
 from dbo.covid_deaths as dea
 join dbo.covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Temp Table % Population Vaccinated second time with Drop Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 
 from dbo.covid_deaths as dea
 join dbo.covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 
 from dbo.covid_deaths as dea
 join dbo.covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--now we can query the view
Select *
from dbo.PercentPopulationVaccinated