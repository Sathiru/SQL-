USE CovidPortfolio
GO

/*

Queries for tablaeu reports

*/

-- Report -1
-- Global Number - 

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, 
(sum(cast(total_deaths as int))/sum(total_cases))*100 DeathPercentage
from CovidPortfolio..coviddeath
where continent is not null

-- Report -2
--Breaking things to continent - Continent with highest death count

select continent, max(cast(total_deaths as int)) as MaximumDeath
from CovidPortfolio..coviddeath
where continent is not null
and continent not in ('World', 'International', 'European Union')
group by continent
order by MaximumDeath desc

-- Report -3
-- Countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount , max((total_cases/population)*100) as PercentageInfectionRate
from CovidPortfolio..coviddeath
where continent is not null
group by location, population
order by PercentageInfectionRate desc

-- Report -4
-- Trend/Forecast of infection rate  

select location, date, population, max(total_cases) as HighestInfectionCount , max((total_cases/population)*100) as PercentageInfectionRate
from CovidPortfolio..coviddeath
where continent is not null
group by location, date, population
order by PercentageInfectionRate desc




