Select *
From CovidDeaths
Where continent is Not Null



--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths , population
From CovidDeaths 
Where continent is not null
order by 1,2



--Looking at total_cases and total_deaths 

Select location, date, total_cases , total_deaths , (total_deaths / total_cases)*100 As DeathPercentage
From CovidDeaths
Where continent is not null
Order by 1,2

Select location, date, total_cases , total_deaths , (total_deaths / total_cases)*100 As DeathPercentage
From CovidDeaths
Where location like '%india'
Order by 1,2
-- It shows likelihood of dying if tested covid positive in india



-- Looking at total_cases vs populations
-- It shows what percentage of population are tested covid positive

Select location, date, total_cases, population, Round(((total_cases/population)*100),5) As CovidPercentage 
From CovidDeaths
Where continent is not null
Order by 1,2



--Looking at the coountry with the highest percentage infection rate

Select location, population, Max(total_cases) as Total_cases, Max((total_cases/population))*100 As InfectionPercentage
From CovidDeaths
Where continent is not null
Group by location, population
Order by InfectionPercentage Desc



--Showing country with highest death count 
-- here Total_deaths is in String we cast it into Int

Select location, max(cast(total_deaths As int)) as TotalDeaths 
From CovidDeaths
Where continent is not null
Group by location
order by TotalDeaths Desc



--Let's show it by coontinent

Select continent, Max(Cast(total_deaths As int)) as TotalDeaths
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeaths Desc



--Now Look Global Number

Select date, Sum(total_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeaths, (sum(cast(total_deaths as int))/Sum(total_cases))* 100 as DeathsPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by date



--All Over DeathPercentage Till now

Select Top(1) date, Sum(total_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeaths, (sum(cast(total_deaths as int))/Sum(total_cases))* 100 as DeathsPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by date Desc




--Looking total population vs Total_vaccination

Select cd.continent, cd.location, cd.population, Max(cv.total_vaccinations) as total_vaccination
From CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
Group by cd.location, cd.population, cd.continent
order by 1,2 DESC



-- looking how vaccination increasing in different country day by day

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as VaccinatedPeople
From CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null
order by 2,3



-- Use CTE we can show percentage of increasing vaccination in different country day by day

With popvsvac
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as VaccinatedPeople
From CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null
)

select * , (VaccinatedPeople/population)*100 as VaccinatedPeoplePercentage
From popvsvac



--Store this data intoo temp table

Drop Table If Exists #RollingVaccinatedPeople
Create Table #RollingVaccinatedPeople
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatedPeople numeric
)

Insert into #RollingVaccinatedPeople
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as VaccinatedPeople
From CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null

select * , (VaccinatedPeople/population)*100 as VaccinatedPeoplePercentage
From #RollingVaccinatedPeople order by 2,3




--Create View to store data for later visualizations

Create View RollingVaccinatedPeople
as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location, cd.date) as VaccinatedPeople
From CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null

Select * 
From RollingVaccinatedPeople
