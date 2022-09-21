
Select *
From PortfolioProject..['owid-CovidDeath-data$']
Order By 3,4

--Select *
--From PortfolioProject..['owid-CovidVaccination-data$']
--Order By 3,4

--Select Data that we are going to be using
Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..['owid-CovidDeath-data$']
Order By 1,2

--looking at total cases vr total deaths
--shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['owid-CovidDeath-data$']
where location like '%India%'
Order By 1,2

--Looking at the total cases vs population
--shows what percentage of population get covid
Select location,date,population,total_cases ,(total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..['owid-CovidDeath-data$']
where location like '%India%'
Order By 1,2

--looking at contries with highest infection rate compared to population
Select location,population,Max(total_cases) as HighestInfectionCount ,Max((total_cases/population))*100 as percentpopulationinfected
From PortfolioProject..['owid-CovidDeath-data$']
--where location like '%India%'
group by location,population


--showing countries with highest death count per population
SELECT
	  location,
       MAX (CAST (total_deaths AS INT)) AS [TotalDeathCount]
from PortfolioProject..['owid-CovidDeath-data$']
where continent is not null
group by location
Order by TotalDeathCount desc
	
--lets break things down by continent
SELECT
	  continent,
       MAX (CAST (total_deaths AS INT)) AS [TotalDeathCount]
from PortfolioProject..['owid-CovidDeath-data$']
where continent is not null
group by continent
Order by TotalDeathCount desc

--Global Numbers
Select date,SUM(new_cases) AS total_new_cases ,
SUM(cast(new_deaths as int ))AS total_new_death,
SUM(cast(new_deaths as int ))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['owid-CovidDeath-data$']
--where location like '%India%'
where continent is not null
group by date
Order By date

--Looking at total population vs vaccination
--that means in world how many peoples are vaccinated

select dea.continent,dea.location,dea.date,dea.population,vcc.new_vaccinations,
Sum(CONVERT(int,vcc.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..['owid-CovidDeath-data$'] dea
join PortfolioProject..['owid-CovidVaccination-data$'] vcc
on dea.location = vcc.location
and dea.date = vcc.date
where dea.continent is not null
--and dea.location='india'
order by 2,3

--cte
with popvsVac(Continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vcc.new_vaccinations,
Sum(CONVERT(int,vcc.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..['owid-CovidDeath-data$'] dea
join PortfolioProject..['owid-CovidVaccination-data$'] vcc
on dea.location = vcc.location
and dea.date = vcc.date
where dea.continent is not null
--and dea.location='india'
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 as percentageofrolling
from popvsVac

--tamp table
/*drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vcc.new_vaccinations,
Sum(CONVERT(int,vcc.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..['owid-CovidDeath-data$'] dea
join PortfolioProject..['owid-CovidVaccination-data$'] vcc
on dea.location = vcc.location
and dea.date = vcc.date
--where dea.continent is not null
--and dea.location='india'
--order by 2,3
select *,(rollingpeoplevaccinated/Population)*100 
from #PercentPopulationVaccinated*/


--creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vcc.new_vaccinations,
Sum(CONVERT(int,vcc.new_vaccinations))OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..['owid-CovidDeath-data$'] dea
join PortfolioProject..['owid-CovidVaccination-data$'] vcc
on dea.location = vcc.location
and dea.date = vcc.date
where dea.continent is not null
--and dea.location='india'
--order by 2,3
select * from PercentPopulationVaccinated 