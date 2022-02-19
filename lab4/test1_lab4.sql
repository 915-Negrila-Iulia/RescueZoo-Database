
/********	TEST 1 (4 tables and 3 views)	********/
/*
   EmployeeSalary, Team - 1 column PK, no FK
   Employee - 1 column PK, 2 FKs
   ZooEvent - 2 columns PK 
*/

/*** procedures for deleting data from tables ***/

/* Employee */
CREATE PROCEDURE deleteEmployee 
AS
BEGIN
	DECLARE @maxID INT
	SET @maxID = (SELECT COUNT(*) FROM Employee)

	IF @maxID = 0
		PRINT 'no data stored in Employee table'

	ELSE
	BEGIN
		DECLARE @currentID INT
		SET @currentID = (SELECT TOP(1) employeeID FROM Employee)   -- first ID

		SET @maxID = @currentID+@maxID								-- last ID

		WHILE @currentID < @maxID
		BEGIN
			DELETE FROM Employee
			WHERE employeeID = @currentID
			SET @currentID = @currentID + 1
		END
	END
END

EXEC deleteEmployee

DROP PROCEDURE deleteEmployee

SELECT * 
FROM Employee

/* EmployeeSalary */
CREATE PROCEDURE deleteEmployeeSalary 
AS
BEGIN
	DECLARE @rowsCount INT
	SET @rowsCount = (SELECT COUNT(*) FROM EmployeeSalary)

	IF @rowsCount = 0
		PRINT 'no data stored in EmployeeSalary table'

	ELSE
	BEGIN
		WHILE @rowsCount != 0												-- number of records
		BEGIN
			DECLARE @currentID VARCHAR(50)
			SET @currentID = (SELECT TOP(1) jobTitle FROM EmployeeSalary)   -- first ID

			DELETE FROM EmployeeSalary
			WHERE jobTitle = @currentID
			SET @rowsCount = @rowsCount - 1
		END
	END
END

EXEC deleteEmployeeSalary

DROP PROCEDURE deleteEmployeeSalary

SELECT * 
FROM EmployeeSalary

/* ZooEvent */
CREATE PROCEDURE deleteZooEvent
AS
BEGIN
	DECLARE @rowsCount INT
	SET @rowsCount = (SELECT COUNT(*) FROM ZooEvent)

	IF @rowsCount = 0
		PRINT 'no data stored in ZooEvent table'

	ELSE
	BEGIN
		WHILE @rowsCount != 0												-- number of records
		BEGIN
			DECLARE @currentID1 VARCHAR(50)
			SET @currentID1 = (SELECT TOP(1) eventName FROM ZooEvent)		-- first ID (first part - Name)
			DECLARE @currentID2 VARCHAR(50)
			SET @currentID2 = (SELECT TOP(1) eventDate FROM ZooEvent)		-- first ID (second part - Date)

			DELETE FROM Ticket
			WHERE eventName = @currentID1 AND eventDate = @currentID2		-- delete records from Ticket Table to which
																			-- records from ZooEvent Table refer to

			DELETE FROM ZooEvent
			WHERE eventName = @currentID1 AND eventDate = @currentID2
			SET @rowsCount = @rowsCount - 1
		END
	END
END

EXEC deleteZooEvent

DROP PROCEDURE deleteZooEvent

SELECT * 
FROM ZooEvent

/* Team */
CREATE PROCEDURE deleteTeam
AS
BEGIN
	DECLARE @rowsCount INT
	SET @rowsCount = (SELECT COUNT(*) FROM Team)

	IF @rowsCount = 0
		PRINT 'no data stored in Team table'

	ELSE
	BEGIN
		WHILE @rowsCount != 0												-- number of records
		BEGIN
			DECLARE @currentID VARCHAR(50)
			SET @currentID = (SELECT TOP(1) teamID FROM Team)				-- first ID

			DELETE FROM ZooZone												-- delete records from ZooZone Table to which
			WHERE teamID = @currentID										-- records from Team Table refer to

			DELETE FROM Team
			WHERE teamID = @currentID
			SET @rowsCount = @rowsCount - 1
		END
	END
END

EXEC deleteTeam

DROP PROCEDURE deleteTeam

SELECT * 
FROM Team



/*** procedures for inserting data into tables ***/

/* Employee */
CREATE PROCEDURE insertEmployee(@records INT)							-- records = number of records to be inserted in table
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE
	DECLARE @firstTeamID INT,											-- get the first and last TeamIDs
			@lastTeamID INT												-- in order to insert valid data into Employee table
	SET @firstTeamID = (SELECT TOP(1) teamID FROM Team)
	SET @lastTeamID = @firstTeamID + (SELECT COUNT(*) FROM Team) - 1

	BEGIN
		WHILE @records != 0
		BEGIN
			INSERT INTO Employee VALUES
			(CONVERT(INT,FLOOR(RAND()*(@lastTeamID-@firstTeamID+1)+@firstTeamID)),		-- teamID
			'job'+CONVERT(VARCHAR,@records%2),'Kenny','Aquarian','Male',				-- jobTitle, firstName, lastName, gender
			CONVERT(VARCHAR,@records%12+1)+'-'+CONVERT(VARCHAR,@records%25+1)			-- dateOfBirth
			+'-'+CONVERT(VARCHAR,1960+@records%50)
			)
			SET @records = @records - 1
		END
	END
END

EXEC insertEmployee 1000

DROP PROCEDURE insertEmployee

SELECT * 
FROM Employee


/* EmployeeSalary */
CREATE PROCEDURE insertEmployeeSalary(@records INT)
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE
	BEGIN
		WHILE @records != 0
		BEGIN
			IF @records = 1
				INSERT INTO EmployeeSalary VALUES
				('job0',CONVERT(INT,FLOOR(RAND()*(200-100+1)+100)),'beginner')			-- must have job0 and job1 because they are used
			ELSE IF @records = 2														-- in the Employee table
				INSERT INTO EmployeeSalary VALUES
				('job1',CONVERT(INT,FLOOR(RAND()*(500-300+1)+300)),'pro')
			ELSE
				INSERT INTO EmployeeSalary VALUES
				('job'+CONVERT(VARCHAR,@records+10),CONVERT(INT,FLOOR(RAND()*(400-200+1)+200)),'medium')
			SET @records = @records - 1
		END
	END
END

EXEC insertEmployeeSalary 300

DROP PROCEDURE insertEmployeeSalary

SELECT * 
FROM EmployeeSalary


/* ZooEvent */
CREATE PROCEDURE insertZooEvent(@records INT)
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE
	DECLARE @firstTeamID INT,
			@lastTeamID INT
	SET @firstTeamID = (SELECT TOP(1) teamID FROM Team)
	SET @lastTeamID = @firstTeamID + (SELECT COUNT(*) FROM Team) - 1

	BEGIN
		WHILE @records != 0
		BEGIN
			IF @records%3 = 1
				INSERT INTO ZooEvent VALUES
				('event'+CONVERT(VARCHAR,@records),'Winter surprise :)',
				CONVERT(VARCHAR,@records%20+1)+'-'+CONVERT(VARCHAR,@records%20+3)+' dec '+CONVERT(VARCHAR,2010+@records%10),
				CONVERT(INT,FLOOR(RAND()*(@lastTeamID-@firstTeamID+1)+@firstTeamID))
				)
			ELSE
				INSERT INTO ZooEvent VALUES
				('event'+CONVERT(VARCHAR,@records),null,
				CONVERT(VARCHAR,@records%20+1)+'-'+CONVERT(VARCHAR,@records%20+3)+' jun '+CONVERT(VARCHAR,2010+@records%10),
				CONVERT(INT,FLOOR(RAND()*(@lastTeamID-@firstTeamID+1)+@firstTeamID))
				)
			SET @records = @records - 1
		END
	END
END

EXEC insertZooEvent 700

DROP PROCEDURE insertZooEvent

SELECT * 
FROM ZooEvent

/* Team */
CREATE PROCEDURE insertTeam(@records INT)
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE
	BEGIN
		WHILE @records != 0
		BEGIN
			IF @records%3 = 0
				INSERT INTO Team VALUES
				('08:00:00','20:00:00')
			ELSE IF @records%3 = 1
				INSERT INTO Team VALUES
				('20:00:00','08:00:00')
			ELSE
				INSERT INTO Team VALUES
				('13:00:00','01:00:00')
			SET @records = @records - 1
		END
	END
END

EXEC insertTeam 200

DROP PROCEDURE insertTeam

SELECT * 
FROM Team
GO


/*** Views ***/

/* select on Employee table */
/* employee name and date of birth */
CREATE VIEW employeeAge
AS
SELECT firstName, dateOfBirth
FROM Employee
GO

SELECT *
FROM employeeAge
GO

DROP VIEW employeeAge
GO

/* select on tables: Employee, Team, ZooEvent */
/* participation of employees at events in December*/
CREATE VIEW employeeAtEvent
AS
SELECT E.employeeID, ZE.eventName, ZE.eventDate
FROM Employee AS E JOIN ZooEvent AS ZE ON E.teamID = ZE.teamID
WHERE ZE.eventDate like '%dec%'
GO

SELECT *
FROM employeeAtEvent
GO

DROP VIEW employeeAtEvent
GO

/* select with group by clause on tables: Employee and EmployeeSalary */
/* number of employees for each salary */
CREATE VIEW employeePerSalary
AS
SELECT ES.salary, COUNT(E.employeeID) AS nr_employees
FROM Employee AS E JOIN EmployeeSalary AS ES ON E.jobTitle = ES.jobTitle
GROUP BY ES.salary
GO

SELECT *
FROM employeePerSalary
GO

DROP VIEW employeePerSalary
GO

