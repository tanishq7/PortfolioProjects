select * 
from Projects..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from Projects..CovidVaccines
--order by 3,4


select location,date, total_cases, new_cases, total_deaths,population
from Projects..CovidDeaths
order by 1,2

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where location like '%india%'
order by 1,2

select location,date, total_cases,population, total_deaths, (total_cases/population)*100 as InfectedPercentage
from Projects..CovidDeaths
--where location like '%India'
order by 1,2

select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
from Projects..CovidDeaths
--where location like '%India'
group by location, population
order by InfectedPercentage desc


select location, max(cast(total_deaths as int)) as TotalDeathCount
from Projects..CovidDeaths
--where location like '%India'
where continent is not null
group by location
order by TotalDeathCount desc

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Projects..CovidDeaths
--where location like '%India'
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Projects..CovidDeaths
--where location like '%India'
where continent is null
group by location
order by TotalDeathCount desc

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where continent is not null
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Projects..CovidDeaths dea
Join Projects..CovidVaccines vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
Join Projects..CovidVaccines vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
Join Projects..CovidVaccines vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
Join Projects..CovidVaccines vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from Projects..CovidDeaths dea
Join Projects..CovidVaccines vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated










