select * 
from Portfolio_Project_1..CovidDeaths
where continent is not Null 
order by 3,4

--select *
--from Portfolio_Project_1..CovidVaccinations
--where continent is not Null 
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project_1..CovidDeaths
where continent is not Null 
order by 1,2

--Lokking at the total_cases Vs total_deaths
--Show Likelihood of dying if you contract covid in your country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From Portfolio_Project_1..CovidDeaths 
where location like '%sri%' and continent is not Null 
order by 1,2

--Looking at the total cases Vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as totalcases_percentage
From Portfolio_Project_1..CovidDeaths 
where continent is not Null 
--where location like '%sri%'
order by 1,2

--Looking at countries with highest infection rate compared to population 

select location, population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as percentPopulationInfected
From Portfolio_Project_1..CovidDeaths 
--where location like '%sri%'
where continent is not Null 
group by location, population
order by percentPopulationInfected desc 

--Showing countries with Highest Death Count per population

select location,MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)*100) as PercentDeathCountPerPopulation
from Portfolio_Project_1..CovidDeaths
--where location like '%sri%'
where continent is not Null 
group by location, population
order by PercentDeathCountPerPopulation desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

select location,MAX(cast(total_deaths as int)) as HighestDeathCount
from Portfolio_Project_1..CovidDeaths
--where location like '%sri%'
where continent is not Null 
group by location
order by HighestDeathCount desc


-- Showing contintents with the highest death count per population
select continent, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)*100) as PercenHighestDeathCountPerPopulation
from Portfolio_Project_1..CovidDeaths
where continent is not null
group by continent
order by PercenHighestDeathCountPerPopulation

--Global Numbers
select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, ((SUM(cast(new_deaths as int))/SUM(new_cases))*100) as Death_Percentage
from Portfolio_Project_1..CovidDeaths
where continent is not null and new_cases is not null and new_deaths is not null
--group by date
order by Death_Percentage


--Looking at Total Population Vs Vaccination 


select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project_1..CovidDeaths dea
join Portfolio_Project_1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continent, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project_1..CovidDeaths dea
join Portfolio_Project_1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac

--TEMP TABLE

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project_1..CovidDeaths dea
join Portfolio_Project_1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3


-- Creating view to store data for later visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project_1..CovidDeaths dea
join Portfolio_Project_1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated