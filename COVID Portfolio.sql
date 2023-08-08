select*
from COVIDDeaths
where continent is not null
order by 3,4


--[CATEGORIZED BY COUNTRIES]

--[Total Cases vs Total Deaths, Chance of dying if infected based on country]
--create view cases_deaths_percentage as
select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 death_percentage
from COVIDDeaths
where continent is not null
--where location like 'Indonesia'
--order by 1,2

--[Total Cases vs Population, Percentage of population infected]
select location, date, population, total_cases, (total_cases/population)*100 infected_percentage
from COVIDDeaths
where continent is not null
--where location like 'Indonesia'
order by 1,2

--[Countries with the highest infection rate/population]
select location, population, max(total_cases) top_infection, max((total_cases/population))*100 population_per_infected
from COVIDDeaths
where continent is not null
--where location like 'Indonesia'
group by location, population
order by population_per_infected desc

--[Countries with the highest death count/population]
select location, max(cast(total_deaths as int)) total_death_count
from COVIDDeaths
where continent is not null
--where location like 'Indonesia'
group by location
order by total_death_count desc


--[CATEGORIZED BY CONTINENTS]

--[Countries with the highest infection rate/population]
select location, population, max(total_cases) top_infection, max((total_cases/population))*100 population_per_infected
from COVIDDeaths
where continent is null
group by location, population
order by population_per_infected desc

--[Continents with the highest death count/population]
select location, population, max(cast(total_deaths as int)) total_death_count
from COVIDDeaths
where continent is null
group by location, population
order by total_death_count desc


--[GLOBAL COUNT]

--[Total Cases vs Total Deaths, Chance of dying if infected globally]
select date, sum(new_cases) new_total_cases, sum(cast(new_deaths as int)) new_total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 global_death_percentage
from COVIDDeaths
where continent is not null
--where location like 'Indonesia'
group by date
order by 1,2

select sum(new_cases) new_total_cases, sum(cast(new_deaths as int)) new_total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 global_death_percentage
from COVIDDeaths
where continent is not null
--where location like 'Indonesia'
order by 1,2


--[COVID DEATHS & VACCINATIONS]

select*
from COVIDDeaths dea
join COVIDVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

--[Total population vs Total vaccinations]
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COVIDDeaths dea
join COVIDVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) rolling_vaccinated
from COVIDDeaths dea
join COVIDVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--[CTE]
with population_vs_vaccinations (continent, location, date, population, new_vaccinations, rolling_vaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) rolling_vaccinated
from COVIDDeaths dea
join COVIDVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select*, (rolling_vaccinated/population)*100 vaccinated_percentage
from population_vs_vaccinations


--[DATA VIEW FOR VISUALIZATIONS]

create view population_vs_vaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) rolling_vaccinated
from COVIDDeaths dea
join COVIDVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select*
from population_vs_vaccinations