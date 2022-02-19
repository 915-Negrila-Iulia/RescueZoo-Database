
/********	TEST 2 (4 tables and 3 views)	********/
/*
   Team - 1 column PK, no FK
   Animal, ZooZone - 1 column PK, 2 FKs
   Recipe - 2 columns PK 
*/

/*** procedures for deleting data from tables ***/

/* Recipe */
CREATE PROCEDURE deleteRecipe
AS
BEGIN
	DECLARE @rowsCount INT
	SET @rowsCount = (SELECT COUNT(*) FROM Recipe)

	IF @rowsCount = 0
		PRINT 'no data stored in Recipe table'

	ELSE
	BEGIN
		WHILE @rowsCount != 0												-- number of records
		BEGIN
			DECLARE @currentID1 VARCHAR(50)
			SET @currentID1 = (SELECT TOP(1) animalID FROM Recipe)		-- first ID (first part - animalID)
			DECLARE @currentID2 VARCHAR(50)
			SET @currentID2 = (SELECT TOP(1) foodName FROM Recipe)		-- first ID (second part - foodName)

			DELETE FROM Recipe
			WHERE animalID = @currentID1 AND foodName = @currentID2
			SET @rowsCount = @rowsCount - 1
		END
	END
END

EXEC deleteRecipe

DROP PROCEDURE deleteRecipe

SELECT * 
FROM Recipe


/* Animal */
CREATE PROCEDURE deleteAnimal
AS
BEGIN
	DECLARE @rowsCount INT
	SET @rowsCount = (SELECT COUNT(*) FROM Animal)

	IF @rowsCount = 0
		PRINT 'no data stored in Animal table'

	ELSE
	BEGIN
		WHILE @rowsCount != 0											-- number of records
		BEGIN
			DECLARE @currentID VARCHAR(50)
			SET @currentID = (SELECT TOP(1) animalID FROM Animal)		-- first ID

			DELETE FROM Animal
			WHERE animalID = @currentID
			SET @rowsCount = @rowsCount - 1
		END
	END
END

EXEC deleteAnimal

DROP PROCEDURE deleteAnimal

SELECT * 
FROM Animal


/* ZooZone */
CREATE PROCEDURE deleteZooZone
AS
BEGIN
	DECLARE @rowsCount INT
	SET @rowsCount = (SELECT COUNT(*) FROM ZooZone)

	IF @rowsCount = 0
		PRINT 'no data stored in ZooZone table'

	ELSE
	BEGIN
		WHILE @rowsCount != 0											-- number of records
		BEGIN
			DECLARE @currentID VARCHAR(50)
			SET @currentID = (SELECT TOP(1) zoneName FROM ZooZone)		-- first ID

			DELETE FROM ZooZone
			WHERE zoneName = @currentID
			SET @rowsCount = @rowsCount - 1
		END
	END
END

EXEC deleteZooZone

DROP PROCEDURE deleteZooZone

SELECT * 
FROM ZooZone

/* Team */
/* -> already created for Test 1 */
EXEC deleteTeam

DROP PROCEDURE deleteTeam

SELECT * 
FROM Team


/*** procedures for inserting data into tables ***/

/* Recipe */
CREATE PROCEDURE insertRecipe(@records INT)							-- records = number of records to be inserted in table
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE

	DECLARE @firstAnimalID INT,											-- get the first and last animalIDs from Animal table
			@lastAnimalID INT												-- in order to insert valid data into Recipe table
	SET @firstAnimalID = (SELECT TOP(1) animalID FROM Animal)
	SET @lastAnimalID = @firstAnimalID + (SELECT COUNT(*) FROM Animal) - 1

	BEGIN
		WHILE @records != 0
		BEGIN
			IF NOT EXISTS( SELECT * FROM FoodItem WHERE foodName = 'food'+CONVERT(VARCHAR,@records))	-- insert new record only if the foodName is not used
				INSERT INTO FoodItem VALUES																-- insert 2 records in FoodItem table
				('food'+CONVERT(VARCHAR,@records),'Superfood Village','Portugal, Lisbon',350)			-- in order to insert valid data into Recipe table

			INSERT INTO Recipe VALUES
			(CONVERT(INT,FLOOR(RAND()*(@lastAnimalID-@firstAnimalID+1)+@firstAnimalID)),		-- AnimalID
			'food'+CONVERT(VARCHAR,@records))													-- foodName
			SET @records = @records - 1
		END
	END
END

EXEC insertRecipe 1000

DROP PROCEDURE insertRecipe

SELECT * 
FROM Recipe


/* Animal */
CREATE PROCEDURE insertAnimal(@records INT)							-- records = number of records to be inserted in table
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE
	DECLARE @firstZoneID INT,											-- get the first and last zoneNames from ZooZone table
			@lastZoneID INT												-- in order to insert valid data into Animal table
	SET @firstZoneID = 1
	SET @lastZoneID = @firstZoneID + (SELECT COUNT(*) FROM ZooZone) - 1

	BEGIN
		WHILE @records != 0
		BEGIN
			IF @records%2 = 0
				INSERT INTO Animal VALUES
				('zone'+CONVERT(VARCHAR,FLOOR(RAND()*(@lastZoneID-@firstZoneID+1)+@firstZoneID)),	-- teamID
				'Wolly Monkey',0											-- name, is_vaccinated
				)
			ELSE
				INSERT INTO Animal VALUES
				('zone'+CONVERT(VARCHAR,FLOOR(RAND()*(@lastZoneID-@firstZoneID+1)+@firstZoneID)),	-- teamID
				'Jaguar',1													-- name, is_vaccinated
				)
			SET @records = @records - 1
		END
	END
END

EXEC insertAnimal 1000

DROP PROCEDURE insertAnimal

SELECT * 
FROM Animal

/* ZooZone */
CREATE PROCEDURE insertZooZone(@records INT)							-- records = number of records to be inserted in table
AS
BEGIN
	IF @records <= 0
		PRINT 'invalid number of records to be inserted'

	ELSE
	DECLARE @firstTeamID INT,											-- get the first and last TeamIDs from Team table
			@lastTeamID INT												-- in order to insert valid data into ZooZone table
	SET @firstTeamID = (SELECT TOP(1) teamID FROM Team)
	SET @lastTeamID = @firstTeamID + (SELECT COUNT(*) FROM Team) - 1

	BEGIN
		WHILE @records != 0
		BEGIN
			INSERT INTO ZooZone VALUES
			('zone'+CONVERT(VARCHAR,@records),											-- zoneName
			CONVERT(INT,FLOOR(RAND()*(@lastTeamID-@firstTeamID+1)+@firstTeamID)),		-- teamID
			@records%10+1)																	-- nrOfRareSpecies
			SET @records = @records - 1
		END
	END
END

EXEC insertZooZone 300

DROP PROCEDURE insertZooZone

SELECT * 
FROM ZooZone


/* Team */
/* -> already created for Test 1 */
EXEC insertTeam 200

DROP PROCEDURE insertTeam

SELECT * 
FROM Team
GO


/*** Views ***/

/* select on ZooZone table */
/* name of zoo zones having more than 8 rare species */
CREATE VIEW rareZones
AS
SELECT zoneName, nrRareSpecies
FROM ZooZone
WHERE nrRareSpecies > 8
GO

SELECT *
FROM rareZones
GO

DROP VIEW rareZones
GO

/* select on tables: Animal, Recipe */
/* display animal and its recipe */
CREATE VIEW animalRecipe
AS
SELECT A.animalID, A.animalName, R.foodName
FROM Animal AS A JOIN Recipe AS R ON A.animalID = R.animalID
GO

SELECT *
FROM animalRecipe
GO

DROP VIEW animalRecipe
GO

/* select with group by clause on tables: Animal, ZooZone, Team */
/* number of animals distributed to each team */
CREATE VIEW animalsPerTeam
AS
SELECT T.teamID, COUNT(A.animalID) AS nr_animals
FROM Animal AS A JOIN ZooZone AS Z ON A.zoneName = Z.zoneName JOIN Team AS T ON Z.teamID=T.teamID
GROUP BY T.teamID
GO

SELECT *
FROM animalsPerTeam
GO

DROP VIEW animalsPerTeam
GO