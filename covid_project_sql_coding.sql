SELECT * FROM covid_death;
 /* OVERVIEW*/
 
 SELECT location , population, MAX(total_cases) AS total_covid_cases,
 MAX(CAST(total_deaths AS FLOAT)) AS total_deaths_occured
FROM covid_death
GROUP BY 1,2
ORDER BY 2 DESC,3;

/* RANKING COUNTRIES BASED ON THEIR DEATH COUNTS*/
SELECT RANK() OVER (ORDER BY CAST(A.total_deaths AS FLOAT) DESC), A.* FROM
(SELECT location, population, MAX(total_deaths) AS total_deaths
FROM covid_death GROUP BY 1,2) A;


/* LOOKING AT TOTAL CASES AND TOTAL TOTAL DEATHS PER COUNTRY*/

SELECT location ,
 MAX(total_cases) AS total_cases_per_country,
 MAX(total_deaths) AS total_deaths_per_country
FROM covid_death
GROUP BY location;

/* LOOKING FOR DEATH PERCENTAGE IN INDIA */
/*SHOWS % OF PEOPLE DIED OUT OF TOTAL COVID INFECTED PATIENTS*/

SELECT location, date, total_cases, new_cases, total_deaths,
 CONCAT(ROUND(100*(total_deaths/total_cases),2),"%") AS death_perecentage
FROM covid_death
WHERE location = "India";

/* LOOKING FOR PERCENTAGE OF TOTAL CASES OUT OF POPULATION*/

SELECT location, date, population, total_cases,
 CONCAT(100*(total_cases/population),"%") AS percentage_of_infected_people
 FROM covid_death
 WHERE location = "India";
 
 /*LOOKING FOR COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION*/
 
 SELECT A.*,
 100*(A.max_cases/A.population) AS percent_of_infected_population
 FROM
 (SELECT location, population, MAX(total_cases) AS max_cases
 FROM covid_death
 GROUP BY 1,2) A
 ORDER BY  percent_of_infected_population DESC;
 
 /* COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION*/
 
 WITH total_death_table AS 
 (SELECT location, population,
 MAX(total_cases) AS infection_cases ,  MAX(CAST(total_deaths AS FLOAT)) AS death_count
 FROM covid_death
 GROUP BY 1,2)
 SELECT A.*, 
 ROUND(100*(A.death_count/A.population),4) AS death_percentage
 FROM total_death_table A
 ORDER BY death_percentage DESC;
 
 /* TOTAL POPULATION VS TOTAL CASES VS TOTAL VACCINATIONS*/
 
 SELECT dea.location, dea.population, MAX(dea.total_cases) AS death_count,
 MAX(CAST(vac.total_vaccinations AS FLOAT)) AS total_vaccinations
 FROM covid_death dea
 LEFT JOIN 
 covid_vaccine vac
 ON dea.location = vac.location
 GROUP BY 1,2

 ORDER BY total_vaccinations;
 
 /*COUNTRIES CASES COUNTS VS  VACCINATIONS COUNTS , CUMULATIVE VACCINATION COUNT, % VACCINATIONS OUT OF POPULATION USING TEMP TABLE */
WITH cumulative_vacc AS 
(
 SELECT dea.location, dea.date, 
 dea.population, dea.total_cases, dea.total_deaths,
 CONVERT(vac.new_vaccinations,FLOAT) AS new_vaccinations,
 SUM(CONVERT(vac.new_vaccinations,FLOAT)) OVER(PARTITION BY dea.location 
 ORDER BY dea.location AND dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS cumulative_vaccination_count
 FROM covid_death AS dea
 LEFT JOIN
 covid_vaccine AS vac
 ON dea.location = vac.location
 AND dea.date = VAC.date
 )
 SELECT A.*, 100*(A.cumulative_vaccination_count/A.population) AS cumulative_percentage_vaccinations_done
 FROM cumulative_vacc A;
 
 /* CREATING VIEW */
 
 CREATE VIEW vaccination_table AS
 (SELECT A.*,100*(A.cumulative_vaccination_count/A.population) AS cumulative_percentage_vaccinations_done
 FROM (SELECT dea.location, dea.date, 
 dea.population, dea.total_cases, dea.total_deaths,
 CONVERT(vac.new_vaccinations,FLOAT) AS new_vaccinations,
 SUM(CONVERT(vac.new_vaccinations,FLOAT)) OVER(PARTITION BY dea.location 
 ORDER BY dea.location AND dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS cumulative_vaccination_count
 FROM covid_death AS dea
 LEFT JOIN
 covid_vaccine AS vac
 ON dea.location = vac.location
 AND dea.date = VAC.date) A);
 
 SELECT * FROM vaccination_table;
 