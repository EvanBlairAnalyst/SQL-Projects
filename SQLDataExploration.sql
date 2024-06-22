-- Selecting Data that we are going to use for this project

Select 
	Location,
	Date,
	total_cases,
	new_cases,
	total_deaths,
	Population
From
	PortfolioProject..CovidDeaths
Where
	continent is not null
Order By
	Location,
	Date

-- Looking at Total Cases vs Total Deaths
-- Converted total_deaths and total_cases to a float to calculate Death Percentage
-- Looking at likelihood of death by country

Select
	Location,
	Date,
	total_deaths,
	total_cases,
	(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From
	PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where 
	continent is not null
Order By
	Location,
	Date

-- Looking at Total Cases Vs Population (Shows Percentage of population that got Covid)

Select
	Location,
	Date,
	Population,
	total_cases,
	(cast(total_cases as float)/cast(population as float))*100 as InfectedPercentage
From
	PortfolioProject..CovidDeaths
Where
	continent is not null
Order By
	Location,
	Date

--Looking at Countries with Highest Infection Rate Compared to Population

Select 
	Location,
	Population,
	MAX(cast(total_cases as float)) as HighestInfectionCount,
	MAX(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From
	PortfolioProject..CovidDeaths
Where
	continent is not null
Group by
	Location, Population
Order By
	PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select 
	Location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
From
	PortfolioProject..CovidDeaths
Where
	continent is not null
Group by
	Location
Order By
	TotalDeathCount desc

-- Breaking things down by Continent

-- Showing Continents with the Highest Death Counts

Select
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
From 
	PortfolioProject..CovidDeaths
Where 
	continent is not null
Group by
	Continent
Order By
	TotalDeathCount desc

-- Showing Global Covid Numbers by Date

Select
	date,
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(new_deaths)/NULLIF(SUM(cast(new_cases as int)), 0) *100 as GlobalDeathPercentage
From 
	PortfolioProject..CovidDeaths
Where 
	continent is not null
Group by
	date
Order By
	date,
	total_cases

-- Showing Global Covid Numbers in Total

Select 
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(new_deaths)/NULLIF(SUM(cast(new_cases as int)), 0) *100 as GlobalDeathPercentage
From
	PortfolioProject..CovidDeaths
Where
	continent is not null
Order By
	total_cases,
	total_deaths

--Looking at Total Population vs Vaccinations

Select
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations
From 
	PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE 
	death.continent is not null
ORDER BY 
	location,
	date

--

Select
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated,
	(rollingpeoplevaccinated/population) *100
From
	PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE
	death.continent is not null
ORDER BY
	2,3

-- Use a CTE to Find Number of Vaccinated Versus Population

WITH
	PopulationVersusVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
	Select
		death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
	From
		PortfolioProject..CovidDeaths death
		Join PortfolioProject..CovidVaccinations vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE 
		death.continent is not null
)
Select
	*,
	(RollingPeopleVaccinated/Population) *100
From
	PopulationVersusVaccination

-- Creating a Temp Table 

DROP TABLE if
	exists #PercentPopulastionVaccinated
Create Table
	#PercentPopulastionVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into
	#PercentPopulastionVaccinated
Select
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From 
	PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE
	death.continent is not null

Select
	*,
	(RollingPeopleVaccinated/Population) *100 as PercentPopulationVac
From
	#PercentPopulastionVaccinated
Order by
	Location,
	date

-- Creating a View to store data for later visualizations

Create view 
	PercentPopulationVaccinated as
Select 
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From 
	PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE
	death.continent is not null

Select *

From 
	PercentPopulationVaccinated






