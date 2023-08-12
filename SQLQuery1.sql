create database covid19
use covid19

select * from dbo.CovidDeaths$


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2


--looking at total cases vs total deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs population 
--shows whar percentage of population got covid 

select location, date,  population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
--where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compare to populatiion 

select location, population,max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as  PercentPopulationInfected
from CovidDeaths$
group by location, population  
order by  PercentPopulationInfected desc

-- showing coutries with highest death count per population

select location, population, max(cast(total_deaths as int)) as HighestDeath , max((total_deaths/population))*100 as  PercentPopulationDeath
from CovidDeaths$
where continent is not null          -- explaination is below 
group by location, population  
order by  HighestDeath desc
 
 -- note here location world, asia, south america are not countries but continent

 select * from dbo.CovidDeaths$
  -- here as we scroll down continent become null so we eliminate it


  -- showing continent with highest death count  per population 
  select continent, max(cast(total_deaths as int)) as TotalDeathCount
  from CovidDeaths$
  where continent is not null 
  group by continent
  order by TotalDeathCount desc

  
  --  global number 
  select sum(new_cases) as Totalcases, 
		 sum(cast(new_deaths as int)) as totalDeath,
		 sum(cast(new_deaths as int)) /sum(new_cases)*100 deathPercentage
  from CovidDeaths$
  where continent is not null 
  
  -- join two table coviddeath and covidvaccination 

  select *	
  from	CovidDeaths$ join CovidVaccinations$
  on CovidDeaths$.location = CovidVaccinations$.location
  and CovidDeaths$.date = CovidVaccinations$.date

  -- looking at total population vs vaccination 

   select d.continent, d.location, d.date, d.population, 
			sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated 
	from CovidDeaths$ as d join CovidVaccinations$ as v                          --note above is not a rank function but rolling functioon
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null 
	order by 1,2,3

	-- use of cte

	with	popvsvac (continent, locatioon, date, popuation, rolling_people_vaccinated) 
	as
	(
	 select d.continent, d.location, d.date, d.population, 
			sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated 
	from CovidDeaths$ as d join CovidVaccinations$ as v                          --note above is not a rank function but rolling functioon
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null 
	)
	select *, (rolling_people_vaccinated/popuation)*100 
	from popvsvac
	
-- creating view to store data for later visualisation
	
	create view PercentPopulationVacinated as 
	
	select d.continent, d.location, d.date, d.population, 
			sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated 
	from CovidDeaths$ as d join CovidVaccinations$ as v                         
	on d.location = v.location
	and d.date = v.date
	where d.continent is not null 


	select * from dbo.PercentPopulationVacinated