
/***queries***/

------ a. union operation; use UNION [ALL] and OR;
-------  UNION ALL - Includes duplicates.
-------  UNION - Excludes duplicates. 

/* Display first and last name of employees and participant */
SELECT firstName, lastName
FROM Employee
UNION
SELECT firstName, lastName
FROM Participant

/* Display animals which belong to Africa or Madagascar zone */
SELECT A.animalName, ZZ.zoneName
FROM Animal AS A, ZooZone AS ZZ
WHERE A.zoneName = ZZ.zoneName AND (ZZ.zoneName='Africa' OR ZZ.zoneName='Madagascar')


------- b. intersection operation; use INTERSECT and IN; 

/* Show the female employees born after/in year 2000 */
SELECT firstName, gender, dateOfBirth
FROM Employee
WHERE gender = 'Female'
INTERSECT
SELECT firstName, gender, dateOfBirth
FROM Employee
WHERE YEAR(dateOfBirth) >= 2000

/* Show providers with service of quality graded by 8  and which provide food items having letter 'a' in their names  */
SELECT FP.providerName, FI.foodName
FROM FoodProvider AS FP, FoodItem AS FI
WHERE FP.providerName = FI.providerName AND FP.providerAddress = FI.providerAddress
	AND FP.serviceQuality = 8 AND FI.foodName IN 
	  ( SELECT foodName
		FROM FoodItem
		WHERE foodName LIKE '%a%' )
	

------ c. difference operation; use EXCEPT and NOT IN; 

/* Display animals (with all their attributes) except those which are not vaccinated */
SELECT *
FROM Animal
WHERE zoneName NOT IN ('Africa','Patagonia','Madagascar')
EXCEPT
SELECT *
FROM Animal
WHERE vaccinated = 0

/* Display participant name, event name, ticket price
   for events whose names do not finish with'!' and
   for tickets which do not have a price greater than 30 */
SELECT T.participantID, ZE.eventName, T.price
FROM ZooEvent AS ZE, Ticket AS T
WHERE ZE.eventName = T.eventName AND ZE.eventDate = T.eventDate 
	AND ZE.eventName NOT LIKE '%!' AND T.price NOT IN
	  ( SELECT price
		FROM Ticket
		WHERE price > 30)


------ d. INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN; 
-------	one query will join at least 3 tables, 
------- while another one will join at least two many-to-many relationships; 

/* join 2 m:n relationships: ZooZone-Employee and ZooZone-ZooEvent 
   Show employees who are part of a team which is resposible of an event which has no descritpion (description is null) 
   and are part of a team wich is responsible for Europe zoo zone */
SELECT E.firstName, E.lastName, ZE.shortDescription, ZZ.zoneName, ZZ.teamID
FROM ZooZone AS ZZ INNER JOIN Team AS T ON ZZ.teamID = T.teamID 
					INNER JOIN Employee AS E ON E.teamID = T.teamID
					INNER JOIN ZooEvent AS ZE ON ZE.teamID = T.teamID
WHERE ZE.shortDescription is null AND ZZ.zoneName = 'Europe'

/* Display food items and their provider if their food name has an 's' 
   including the food items which have null value for name and address of the provider */
SELECT *
FROM FoodItem AS FI LEFT JOIN FoodProvider AS FP ON (FI.providerName = FP.providerName AND FI.providerAddress = FP.providerAddress)
WHERE FI.foodName LIKE '%s%'

/* employee's first and last name and the zone they respond of for the employees who have a teamdID and all the zoo zones
   including the ZooZones which do not have a team id*/
SELECT E.firstName, E.lastName, ZZ.zoneName
FROM Employee AS E RIGHT JOIN ZooZone AS ZZ ON E.teamID = ZZ.teamID

/* join 4 tables: Animal, ZooZone, Recipe, FoodItem, FoodProvider
   Show food name, food quantity, provider name without duplicates ordered by food quantity in descending order
   even for entities which have value null for the reference key */
SELECT DISTINCT FI.foodName, FI.quantity, FP.providerName
FROM ZooZone AS ZZ FULL JOIN Animal AS A ON ZZ.zoneName = A.zoneName
					FULL JOIN Recipe AS R ON A.animalID = R.animalID
					FULL JOIN FoodItem AS FI ON R.foodName = FI.foodName
					FULL JOIN FoodProvider AS FP ON (FI.providerName = FP.providerName AND FI.providerAddress = FP.providerAddress)
ORDER BY FI.quantity DESC

------ e. 2 queries with IN operator and a subquery in the WHERE clause; 
-------	  in at least one case, the subquery should include a subquery in its own WHERE clause; 

/* Display animals which have meat in their recipes and eat a food item which is provided by the Zoo in a quantity larger than 1000*/
SELECT DISTINCT A.animalName
FROM Animal AS A INNER JOIN Recipe AS R ON A.animalID = R.animalID
WHERE R.foodName IN 
	( SELECT foodName
	  FROM FoodItem 
	  WHERE foodName IN ('Chicken', 'Beef', 'Duck', 'Fish') AND quantity > 1000
	)

/* employee's name and salary for employees who work in a zoo zone which has animals with names containing 'i' on the second position */
SELECT E.firstName, E.lastName, ES.salary
FROM Employee AS E INNER JOIN EmployeeSalary AS ES ON E.jobTitle = ES.jobTitle
WHERE E.employeeID IN 
	( SELECT E.employeeID
	  FROM Employee AS E FULL JOIN ZooZone AS ZZ ON E.teamID = ZZ.teamID
	  WHERE ZZ.zoneName IN 
				( SELECT ZZ.zoneName 
				  FROM ZooZone AS ZZ INNER JOIN Animal AS A ON ZZ.zoneName = A.zoneName
				  WHERE animalName LIKE '_i%'
			     )
	)

------- f. 2 queries with EXISTS operator and a subquery in the WHERE clause; 

/* Participants who booked a ticket having the price equal to 35 */
SELECT P.firstName, P.lastName
FROM Participant AS P
WHERE EXISTS
	( SELECT T.* 
	  FROM Ticket AS T
	  WHERE P.participantID = T.participantID AND T.price = 35
	)

/* teams schedule (start and end of a shift) which are responsible of at least an event in december */
SELECT T.teamID, T.startShift, T.endShift
FROM Team as T
WHERE EXISTS
	( SELECT *
	  FROM ZooEvent as ZE
	  WHERE T.teamID = ZE.teamID AND SUBSTRING(ZE.eventDate,6,4) LIKE '%dec%'
	)

------- g. 2 queries with a subquery in the FROM clause; 

/* top 5 participant who bought the most tickets */
SELECT TOP 5 P.firstName, P.lastName, nr_tickets
FROM 
	( SELECT T.participantID, COUNT(*) AS nr_tickets 
	  FROM Ticket AS T
	  GROUP BY T.participantID
	) 
	AS tickets_per_participant, Participant AS P
WHERE tickets_per_participant.participantID = P.participantID
ORDER BY nr_tickets DESC

/* for each zoo zone how many animals are vaccinated */
SELECT *
FROM 
	( SELECT A.zoneName, COUNT(*) AS nr_vaccinated
	  FROM Animal AS A
	  WHERE A.vaccinated = 1
	  GROUP BY A.zoneName
	) AS vaccinated_per_zone

-------- h. 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 
----------  2 of the latter will also have a subquery in the HAVING clause; 
----------  use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;

/* contain only GROUP BY clause 
   compute number of employees for each group */
SELECT E.teamID, COUNT(*) AS nr_employees
FROM Employee AS E
GROUP BY E.teamID

/*  contain the HAVING clause
   compute average of employee salary for each group with the conditions: job title != null and group != null */
SELECT E.teamID, AVG(ES.salary) AS average_salary
FROM Employee AS E INNER JOIN EmployeeSalary AS ES ON E.jobTitle = ES.jobTitle
GROUP BY E.teamID
HAVING E.teamID is not null

/*  have a subquery in the HAVING clause
	provider adresses and quantity of food they provide for providers with quality better or eual to 9 */
SELECT FI.providerAddress, SUM(FI.quantity) AS quantity_sum
FROM FoodItem AS FI
GROUP BY FI.providerAddress
HAVING FI.providerAddress IN 
		( SELECT FP.providerAddress
		  FROM FoodProvider AS FP
		  WHERE FP.serviceQuality >= 9
		)

/*  have a subquery in the HAVING clause
	events of years 2019-2020  wich are the most or the least expensive in those years (have maximum ticket price) */
SELECT T.eventName, T.eventDate, T.price
FROM Ticket AS T
WHERE T.eventDate LIKE '%2019%' OR T.eventDate LIKE '%2020%'
GROUP BY T.eventName, T.eventDate, T.price
HAVING T.price = 
		( SELECT MIN(T.price)
		  FROM Ticket AS T
		  WHERE T.eventDate LIKE '%2019%' OR T.eventDate LIKE '%2020%'
	    ) OR T.price = 
		( SELECT MAX(T.price)
		  FROM Ticket AS T
		  WHERE T.eventDate LIKE '%2019%' OR T.eventDate LIKE '%2020%'
	    ) 

------ i. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator); 
--------  rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.

/* find the biggest salary */
SELECT * 
FROM EmployeeSalary AS ES
WHERE ES.salary >= ALL 
		( SELECT salary
		  FROM EmployeeSalary
		)
/* rewrite using aggregation operator MAX */
SELECT *
FROM EmployeeSalary AS ES
WHERE ES.salary = 
		( SELECT MAX(salary)
		  FROM EmployeeSalary
		)

/* employees that did not organised an event in year 2020 */
SELECT *
FROM Employee AS E
WHERE E.teamID <> ALL
		( SELECT teamID
		  FROM ZooEvent
		  WHERE eventDate LIKE '%2020%'
		)
/* rewrite using NOT IN */
SELECT *
FROM Employee AS E
WHERE E.teamID NOT IN
		( SELECT teamID
		  FROM ZooEvent
		  WHERE eventDate LIKE '%2020%'
	    )

/* zoo zones except the one with minimum number of rare species and the ones having null values */
SELECT *
FROM ZooZone AS ZZ
WHERE ZZ.nrRareSpecies > ANY 
		( SELECT nrRareSpecies 
		  FROM ZooZone
		)
/* rewrite using  aggregation operator MIN */
SELECT *
FROM ZooZone AS ZZ
WHERE ZZ.nrRareSpecies <>
		( SELECT MIN(nrRareSpecies)
		  FROM ZooZone
		)

/* animals which have Banana, Orange or Strawberry on their food recipes */
SELECT *
FROM Animal AS A
WHERE A.animalID = ANY 
		( SELECT animalID
		  FROM Recipe
		  WHERE foodName LIKE 'Banana' OR foodName LIKE 'Orange' OR foodName LIKE 'Strawberry'
		)
/* rewrite using IN */
SELECT *
FROM Animal AS A
WHERE A.animalID IN 
		( SELECT animalID
		  FROM Recipe
		  WHERE foodName IN ('Banana','Orange','Strawberry')
		)