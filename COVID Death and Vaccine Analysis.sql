-- Switch to the Covid Death database
use `Covid Death`;

-- 1. View all records with non-null continent
select * 
from coviddeaths
where continent is not null
order by 1, 2;

---------------------------------------------------------
-- 2. Case Fatality Rate Over Time in Canada
-- Shows likelihood of dying if you contract COVID-19
select 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    round((total_deaths/total_cases)*100, 2) as DeathPercentage
from coviddeaths
where location like "%canada%" 
    and continent is not null
order by location, CAST(date AS DATE);

---------------------------------------------------------
-- 3. Total Cases vs Population in Canada
-- Shows percentage of population infected each day
select 
    location, 
    date, 
    total_cases, 
    population, 
    round((total_cases/population)*100, 2) as PercentPopulationInfected
from coviddeaths
where location like "%canada%" 
    and continent is not null
order by location, CAST(date AS DATE);

---------------------------------------------------------
-- 4. Countries with Highest Infection Rate (relative to population)
select 
    location, 
    population, 
    max(total_cases) as HighestInfectionCount, 
    max(round((total_cases/population)*100, 2)) as PercentPopulationInfected
from coviddeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;

---------------------------------------------------------
-- 5. Continent with Highest Death Count
select 
    continent, 
    MAX(CAST(total_deaths AS signed)) AS TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

---------------------------------------------------------
-- 6. Mortality Disparity Across Regions (per 100k population)
select 
    continent,
    sum(cast(total_deaths as signed)) as total_deaths,
    sum(population) as total_population,
    round((sum(cast(total_deaths as signed)) / sum(population)) * 100000, 2) as deaths_per_100k
from coviddeaths
where continent is not null
group by continent
order by deaths_per_100k desc;

---------------------------------------------------------
-- 7. Global Case and Mortality Trends
select
    sum(new_cases) as total_cases,
    sum(cast(new_deaths as signed)) as total_deaths
from coviddeaths;

---------------------------------------------------------
-- 8. Global Vaccination Progress
select
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
from coviddeaths as dea
join covidvaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date;

---------------------------------------------------------
-- 9. Impact of Vaccinations on Cases and Deaths
select
    dea.continent,
    dea.location,
    sum(dea.new_cases) as total_cases,
    sum(cast(dea.new_deaths as signed)) as total_deaths
from coviddeaths as dea
join covidvaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where vac.new_vaccinations is not null
    and dea.continent is not null
group by dea.continent, dea.location
order by total_deaths desc;

---------------------------------------------------------
-- 10. Correlation Between GDP and Pandemic Impact
select
    dea.location,
    max(vac.gdp_per_capita) as gdp,
    max(cast(dea.total_deaths as signed)) as total_deaths
from coviddeaths as dea
join covidvaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
group by dea.location
order by total_deaths desc;

---------------------------------------------------------
-- 11. Vaccine Distribution Inequality (Top and Bottom Deciles)
-- 11. Vaccine Distribution Inequality (Top and Bottom Deciles) - using subquery
select *
from (
    select 
        v.location,
        max(cast(v.people_vaccinated as signed) / d.population) * 100 as percent_vaccinated,
        ntile(10) over (order by max(cast(v.people_vaccinated as signed) / d.population) * 100) as decile_group
    from covidvaccinations v
    join coviddeaths d 
        on v.location = d.location
    where v.continent is not null
    group by v.location, d.population
) as deciles
where decile_group in (1, 10);

---------------------------------------------------------
-- 12. Assessment of Vaccination Rollout and Population Coverage
select
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(convert(vac.new_vaccinations, signed)) over 
        (partition by dea.location order by dea.date) as rollingpeoplevaccinated,
    round((sum(convert(vac.new_vaccinations, signed)) over 
        (partition by dea.location order by dea.date)/population)*100, 2) as vaccinated_percentage
from coviddeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date;

---------------------------------------------------------
-- 13. Trend Forecasting Using Moving Averages
select 
    location,
    date,
    new_cases,
    avg(new_cases) over (partition by location order by date rows between 6 preceding and current row) as moving_avg_7d,
    avg(new_cases) over (partition by location order by date rows between 29 preceding and current row) as moving_avg_30d
from coviddeaths
where continent is not null;

---------------------------------------------------------
-- 14. Vaccination Effectiveness Analysis (Before vs After)
with before_after as (
    select 
        dea.location,
        case when vac.date < (select min(date) 
                              from covidvaccinations 
                              where location = dea.location 
                              and new_vaccinations > 0)
             then 'before_vaccine'
             else 'after_vaccine' end as period,
        avg(cast(new_deaths as signed)) as avg_daily_deaths
    from coviddeaths dea
    join covidvaccinations vac 
        on dea.location = vac.location and dea.date = vac.date
    where dea.continent is not null
    group by dea.location, period
)
select * from before_after;
