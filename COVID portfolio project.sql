select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- analyzing what percentage of people who got covid ended up dying 
-- lieklihood of dying if you were in Canada
select location, date, total_cases, total_deaths, (total_deaths*1.0 /total_cases)*100 as DeathPercentage
from CovidDeaths
where location like "%Canada%"
order by 1, 2

-- looking at the total cases vs the population to see percentage affected
select location, date, population, total_cases, (total_cases *1.0 / population)*100 as AffectedPercentage
from CovidDeaths
where location like "%canada%"
order by 1,2;

-- looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max(total_cases *1.0 / population)*100 as PercentPopulationAffected
from CovidDeaths
group by location, population
order by PercentPopulationAffected desc


-- countries with highest death count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null -- this is because of the way the data is in the data base
group by location
order by TotalDeathCount desc

-- breaking it down by continent; showing the continents with the higehst death count

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null  -- because when continent is set as null, location is set as that continent's name
group by location
order by TotalDeathCount desc



-- global numbers
select date, sum(new_cases), sum(cast(new_deaths as int)) 
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- death percentage globally
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2


select * 
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date

-- looking at how many people got vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 1,2;

-- looking at how many people got vaccinated
-- using CTE 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2, 3
)
select * , (RollingPeopleVaccinated*1.0/population*1.0)*100 as VaccinePercentage
from PopvsVac




-- temp TABLE
drop table if exists PercentpopulationVaccinated;
Create temp Table PercentpopulationVaccinated
(
Continent text,
Location text,
Date text,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
insert into PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL;
--order by 2, 3
select * , (RollingPeopleVaccinated*1.0/population*1.0)*100 as VaccinePercentage
from PercentpopulationVaccinated;


--creating view to store data for later visualizations
create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL;


Select *
from PercentpopulationVaccinated;



