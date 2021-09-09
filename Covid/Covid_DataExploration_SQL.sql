USE CovidPortfolio
GO

/*

Data Exploration

SQL statement includes where, group by, order by, joins, CTE, aggregation, temp table and views

*/

select * 
from CovidPortfolio..coviddeath
where continent is not null
order by 3,4

-- Select data that is in main focus.

select location, date, population, total_cases, total_deaths
from CovidPortfolio..coviddeath
where continent is not null
order by 1,2

-- Number of death from total cases

select location, date, population, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as Percentageofdeath
from CovidPortfolio..coviddeath
where continent is not null
and location like '%states%'
order by 1,2

-- Total number of cases from the population

select location, date, population, total_cases, (total_cases/population)*100 as PeopleAffectedCount
from CovidPortfolio..coviddeath
where continent is not null
order by 1,2

-- Countries with maximum death count 

select location, population, max(cast(total_deaths as int)) as HighestDeath
from CovidPortfolio..coviddeath
where continent is not null
group by location, population
order by HighestDeath desc

-- Countries with highest infection rate compared to population

select location, population, max(total_cases), max((total_cases/population)*100) as HighestInfectionRate
from CovidPortfolio..coviddeath
where continent is not null
group by location, population
order by HighestInfectionRate desc

--Breaking things to continent - Continent with highest death count

select continent, max(cast(total_deaths as int)) as MaximumDeath
from CovidPortfolio..coviddeath
where continent is not null
group by continent
order by MaximumDeath desc

-- Global Number

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(total_deaths as int))/sum(total_cases))*100 PercentageDeath
from CovidPortfolio..coviddeath
where continent is not null

-- Number of people vaccinated compared to the population

select vac.location, vac.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as RollingPeopleVaccinated
from CovidPortfolio..covidvacc as vac
join CovidPortfolio..coviddeath as dea
	 on vac.location = dea.location and
	    vac.date = dea.date
where dea.continent is not null
order by 1,2


-- use CTE to perform calculation for percentage of people vaccinated compared to the population

with popvac (location, date, people_vaccinated, population, RollingPeopleVaccinated)
as
(
select vac.location, vac.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as RollingPeopleVaccinated
from CovidPortfolio..covidvacc as vac
join CovidPortfolio..coviddeath as dea
	 on vac.location = dea.location and
	    vac.date = dea.date
where dea.continent is not null
--order by 1,2
)
select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from popvac

-- Use temp table to perform same calculations as above to get percentage of population vaccinated.

Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
( 
location nvarchar(255),
date datetime,
new_vaccinations numeric,
population numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
select vac.location, vac.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as RollingPeopleVaccinated
from CovidPortfolio..covidvacc as vac
join CovidPortfolio..coviddeath as dea
	 on vac.location = dea.location and
	    vac.date = dea.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from #percentpopulationvaccinated

-- Create view for reports
GO

CREATE VIEW percentpopulationvaccinated as
select vac.location, vac.date, vac.new_vaccinations, dea.population, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as RollingPeopleVaccinated
from CovidPortfolio..covidvacc as vac
join CovidPortfolio..coviddeath as dea
	 on vac.location = dea.location and
	    vac.date = dea.date
where dea.continent is not null
--order by 1,2

GO
















