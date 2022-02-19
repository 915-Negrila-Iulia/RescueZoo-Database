/***lab3***/

use RescueZoo
go

/*** a. modify the type of a column ***/

/* 'Team' table has the column 'startShift' of type varchar(10)
	The 'modifyColumnType' procedure will change it to time type*/
CREATE PROCEDURE modifyColumnType
AS
BEGIN
	ALTER TABLE Team 
	ALTER COLUMN startShift time(0);
END
GO
--execute procedure
EXEC modifyColumnType
GO
--remove procedure
DROP PROCEDURE modifyColumnType
GO
/* reverse of the operation above */
/* 'Team' table has the column 'startShift' of type time
	The 'modifyColumnTypeReverse' procedure will change it to varchar(10) type*/
CREATE PROCEDURE modifyColumnTypeReverse
AS
BEGIN
	ALTER TABLE Team 
	ALTER COLUMN startShift varchar(10)
END
GO
--execute procedure
EXEC modifyColumnTypeReverse
GO
--remove procedure
DROP PROCEDURE modifyColumnTypeReverse
GO
/* to check */
SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='Team' AND COLUMN_NAME='startShift'


/*** b. add/remove a column ***/

/* Add column 'numberOfLikes' in the 'ZooEvent' table 
	only if it does not exist already */
CREATE PROCEDURE addColumn
AS
BEGIN
	IF COL_LENGTH('ZooEvent','numberOfLikes') IS NULL
		BEGIN
			ALTER TABLE ZooEvent
			ADD numberOfLikes INT
		END
	ELSE
		BEGIN
			PRINT N'column already exists'
		END
END
GO
--execute procedure
EXEC addColumn
GO
--remove procedure
DROP PROCEDURE addColumn
GO
/* Remove column 'numberOfLikes' in the 'ZooEvent' table 
	only if it exists */
CREATE PROCEDURE removeColumn
AS
BEGIN
	IF COL_LENGTH('ZooEvent','numberOfLikes') IS NOT NULL
		BEGIN
			ALTER TABLE ZooEvent
			DROP COLUMN numberOfLikes
		END
	ELSE
		BEGIN
			PRINT N'column does not exist'
		END
END
GO
--execute procedure
EXEC removeColumn
GO
--remove procedure
DROP PROCEDURE removeColumn
GO
/* to check */
SELECT *
FROM ZooEvent
GO


/*** c. add/remove a default constraint ***/

/* Add for the column 'vaccinated' of the table 'Animal' a default constraint 
	which initializes with 0 the 'vaccinated' attribute of an 'Animal' instance
	for which this field was not explicitly initialized */
/* Make sure that the column exists and the constraint is not already created */
CREATE PROCEDURE addDefaultConstraint
AS
BEGIN
	IF COL_LENGTH('Animal','vaccinated') IS NOT NULL
		IF NOT EXISTS(SELECT name FROM sys.default_constraints WHERE name='default_vaccinated')
			BEGIN
				ALTER TABLE Animal
				ADD CONSTRAINT default_vaccinated
				DEFAULT 0 FOR vaccinated
			END
		ELSE
			PRINT N'default constraint already exists'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC addDefaultConstraint
GO
--remove procedure
DROP PROCEDURE addDefaultConstraint
GO
/* Remove the default constraint for column 'vaccinated' created above */
/* Make sure that the the column and the constraint exist */
CREATE PROCEDURE removeDefaultConstraint
AS
BEGIN
	IF COL_LENGTH('Animal','vaccinated') IS NOT NULL
		IF EXISTS(SELECT name FROM sys.default_constraints WHERE name='default_vaccinated')
			BEGIN
				ALTER TABLE Animal
				DROP CONSTRAINT default_vaccinated
			END
		ELSE
			PRINT N'constraint does not exist'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC removeDefaultConstraint
GO
--remove procedure
DROP PROCEDURE removeDefaultConstraint
GO
/* to check */
USE RescueZoo;
SELECT * 
FROM sys.default_constraints;
GO

/*** d. add/remove a primary key ***/

/* Remove the primary key constraint for 'foodName' column from the 'FoodItem' table. 
	But before this, remove the foreign key constraint for 'foodName' column from the 'Recipe' table */
/* Make sure that the column exists and has a primary key constraint */
CREATE PROCEDURE removePrimaryKey
AS
BEGIN
	IF COL_LENGTH('FoodItem','foodName') IS NOT NULL
		IF EXISTS(SELECT * FROM sys.key_constraints WHERE type = 'PK' AND name LIKE '%FoodItem%')
			BEGIN
				ALTER TABLE Recipe
				DROP CONSTRAINT FK_Recipe_foodName

				ALTER TABLE FoodItem
				DROP CONSTRAINT PK_FoodItem
			END
		ELSE 
			PRINT N'primary key constraint does not exist'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC removePrimaryKey
GO
--remove procedure
DROP PROCEDURE removePrimaryKey
GO
/* Add the primary key constraint for 'foodName' column from the 'FoodItem' table. 
	After this, add the foreign key constraint for 'foodName' column from the 'Recipe' table */
/* Make sure that the column exists and does not have a primary key constraint */
CREATE PROCEDURE addPrimaryKey
AS
BEGIN
	IF COL_LENGTH('FoodItem','foodName') IS NOT NULL
		IF NOT EXISTS(SELECT * FROM sys.key_constraints WHERE type = 'PK' AND name LIKE '%FoodItem%')
			BEGIN
				ALTER TABLE FoodItem
				ADD CONSTRAINT PK_FoodItem PRIMARY KEY (foodName)

				ALTER TABLE Recipe
				ADD CONSTRAINT FK_Recipe_foodName
					FOREIGN KEY (foodName) REFERENCES FoodItem(foodName)
			END
		ELSE 
			PRINT N'primary key constraint already exists'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC addPrimaryKey
GO
--remove procedure
DROP PROCEDURE addPrimaryKey
GO
/* to check */
SELECT *
FROM sys.key_constraints
WHERE type = 'PK' AND name='PK_FoodItem'
SELECT *
FROM sys.foreign_keys
WHERE name = 'FK_Recipe_foodName'
GO


/*** e. add/remove candidate key ***/

/* Remove the candidate key constraint for 'email' column from the 'Participant' table (unique) */
/* Make sure that the column exists and has a candidate key constraint */
CREATE PROCEDURE removeCandidateKey
AS
BEGIN
		IF COL_LENGTH('Participant','email') IS NOT NULL
		IF EXISTS(SELECT * FROM sys.key_constraints WHERE type = 'UQ' AND name LIKE '%Particip%')
			BEGIN
				ALTER TABLE Participant
				DROP CONSTRAINT UQ_Particip
			END
		ELSE 
			PRINT N'candidate key constraint does not exist'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC removeCandidateKey
GO
--remove procedure
DROP PROCEDURE removeCandidateKey
GO
/* Add the candidate key constraint for 'email' column from the 'Participant' table (unique) */
/* Make sure that the column exists and does not have a candidate key constraint */
CREATE PROCEDURE addCandidateKey
AS
BEGIN
		IF COL_LENGTH('Participant','email') IS NOT NULL
		IF NOT EXISTS(SELECT * FROM sys.key_constraints WHERE type = 'UQ' AND name LIKE '%Particip%')
			BEGIN
				ALTER TABLE Participant
				ADD CONSTRAINT UQ_Particip UNIQUE (email)
			END
		ELSE 
			PRINT N'candidate key constraint already exists'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC addCandidateKey
GO
--remove procedure
DROP PROCEDURE addCandidateKey
GO
/* to check */
SELECT *
FROM sys.key_constraints
WHERE type='UQ' AND name LIKE '%Particip%'
GO


/*** f. add/remove a foreign key ***/

/* Remove the foreign key constraint for 'eventName' and 'eventDate' columns from the 'Ticket' table. */
/* Make sure that the columns exist and are used to determine a foreign key */
CREATE PROCEDURE removeForeignKey
AS
BEGIN
	IF COL_LENGTH('Ticket','eventNAme') IS NOT NULL OR COL_LENGTH('Ticket','eventDate') IS NOT NULL
		IF EXISTS(SELECT * FROM sys.foreign_keys WHERE name LIKE '%FK_Ticket%')
			BEGIN
				ALTER TABLE Ticket
				DROP CONSTRAINT FK_Ticket
			END
		ELSE 
			PRINT N'foreign key constraint does not exist'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC removeForeignKey
GO
--remove procedure
DROP PROCEDURE removeForeignKey
GO
/* Add the foreign key constraint for 'eventName' and 'eventDate' columns from the 'Ticket' table. */
/* Make sure that the columns exist and are not used to determine a foreign key */
CREATE PROCEDURE addForeignKey
AS
BEGIN
	IF COL_LENGTH('Ticket','eventName') IS NOT NULL OR COL_LENGTH('Ticket','eventDate') IS NOT NULL
		IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE name LIKE '%FK_Ticket%')
			BEGIN
				ALTER TABLE Ticket
				ADD CONSTRAINT FK_Ticket
					FOREIGN KEY (eventName,eventDate) REFERENCES ZooEvent(eventName, eventDate)
			END
		ELSE 
			PRINT N'foreign key constraint already exists'
	ELSE
		PRINT N'column does not exist'
END
GO
--execute procedure
EXEC addForeignKey
GO
--remove procedure
DROP PROCEDURE addForeignKey
GO
/* to check */
SELECT *
FROM sys.foreign_keys
WHERE name='FK_Ticket'
GO


/*** g. create/drop a table ***/

/* Create a table named 'MyAnimal' which contains data 
	(name, dateOfBirth, animalName) about specific animals. 
	myName - (varchar(50)) primary key 
	dateOfBirth - (date) attribute
	animalID - (int) foreign key which references Animal(animalID), the species of 'MyAnimal' */
CREATE PROCEDURE createTable
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM sys.tables WHERE name='MyAnimal')
		BEGIN
			CREATE TABLE MyAnimal
			( myName varchar(50) primary key,
			  dateOfBirth date,
			  animalID int references Animal(animalID)
			)
		END
	ELSE
		PRINT N'table already exists'
END
GO
--execute procedure
EXEC createTable
GO
--remove procedure
DROP PROCEDURE createTable
GO
/* Drop table named 'myAnimal' */
CREATE PROCEDURE dropTable
AS
BEGIN
	IF EXISTS(SELECT * FROM sys.tables WHERE name='MyAnimal')
		BEGIN
			DROP TABLE myAnimal
		END
	ELSE
		PRINT N'table does not exist'
END
GO
--execute procedure
EXEC dropTable
GO
--remove procedure
DROP PROCEDURE dropTable
GO
/* to check */
SELECT *
FROM sys.tables
WHERE name = 'myAnimal'
SELECT *
FROM myAnimal
GO

/* Create a table that holds the current version of the database.
   Insert instance having currentVersion = 0 */
CREATE TABLE VersionDBTable
( currentVersion INT)
INSERT INTO VersionDBTable VALUES
(0)
GO
/* Stored procedure that receives as (input)parameter a version number 
	and brings the database to that version */
/* 0 - original DB
   1 = + procedure from point a.
	   - reverse procedure from point a.
   2 = + procedure from point b.
	   - reverse procedure from point b.
   ...
   7 = + procedure from point g.
	   - reverse procedure from point g.
*/
CREATE PROCEDURE changeVersion (@version INT)
AS
BEGIN
	DECLARE @currentVersion INT
	SET @currentVersion = (SELECT TOP(1) currentVersion FROM VersionDBTable)
	IF (@version > @currentVersion)
		BEGIN
			WHILE(@version > @currentVersion)
			BEGIN
				IF @currentVersion = 0
					EXEC modifyColumnType
				ELSE IF @currentVersion = 1
					EXEC addColumn
				ELSE IF @currentVersion = 2
					EXEC addDefaultConstraint
				ELSE IF @currentVersion = 3
					EXEC removePrimaryKey
				ELSE IF @currentVersion = 4
					EXEC removeCandidateKey
				ELSE IF @currentVersion = 5
					EXEC removeForeignKey
				ELSE IF @currentVersion = 6
					EXEC createTable
				SET @currentVersion = @currentVersion + 1
				UPDATE VersionDBTable
				SET currentVersion = @currentVersion
				PRINT 'changed to version: ' + CAST(@currentVersion AS VARCHAR)
			END
		END
	ELSE IF (@version < @currentVersion)
		BEGIN
			WHILE (@version < @currentVersion)
			BEGIN
				IF @currentVersion = 7
					EXEC dropTable
				ELSE IF @currentVersion = 6
					EXEC addForeignKey
				ELSE IF @currentVersion = 5
					EXEC addCandidateKey
				ELSE IF @currentVersion = 4
					EXEC addPrimaryKey
				ELSE IF @currentVersion = 3
					EXEC removeDefaultConstraint
				ELSE IF @currentVersion = 2
					EXEC removeColumn
				ELSE IF @currentVersion = 1
					EXEC modifyColumnTypeReverse
				SET @currentVersion = @currentVersion - 1
				UPDATE VersionDBTable
				SET currentVersion = @currentVersion
				PRINT 'changed to version: ' + CAST(@currentVersion AS VARCHAR)
			END
		END
END
GO
--execute procedure
EXEC changeVersion 0
GO
--remove procedure
DROP PROCEDURE changeVersion
GO

SELECT *
FROM VersionDBTable

/* Create a table that keeps the names of each version
   and their related procedure and reverse procedure
*/

CREATE TABLE Versions
( versionName INT,
  procedureName VARCHAR(50),
  reverseProcedureName VARCHAR(50)
)
INSERT INTO Versions VALUES
(0, null, null),
(1, 'modifyColumnType', 'modifyColumnTypeReverse'),
(2, 'addColumn', 'removeColumn'),
(3, 'addDefaultConstraint', 'removeDefaultConstraint'),
(4, 'removePrimaryKey', 'addPrimaryKey'),
(5, 'removeCandidateKey', 'addCandidateKey'),
(6, 'removeForeignKey', 'addForeignKey'),
(7, 'createTable', 'dropTable')

SELECT *
FROM Versions
GO

/*
	Procedure that changes the version of the database to the one given as input parameter
	Use cursor of type scroll to parse the table of versions forward and backward
	and executes the procedures or reverse procedures needed
*/

CREATE PROCEDURE changeVersion (@versionWanted INT)
AS
BEGIN

	/*make sure that the given version is valid*/
	IF @versionWanted < 0 OR @versionWanted > 7 OR ISNUMERIC(@versionWanted) = 0
		PRINT 'requested version does not exist' 

	ELSE
		BEGIN

		/*initialise the current version with the one from the 'VersionDBTable' table*/
		DECLARE @currentVersion INT
		SET @currentVersion = (SELECT TOP(1) currentVersion FROM VersionDBTable)

		IF @versionWanted != @currentVersion
		BEGIN

				/*declare the cursor and the parameters needed*/
				DECLARE @versionName INT, @proc VARCHAR(50), @reverseProc VARCHAR(50)
				DECLARE CursorVersions CURSOR SCROLL FOR
				SELECT versionName, procedureName, reverseProcedureName
				FROM Versions

				/*open the cursor and fetch the first row from the 
				result set(specified above by the select statement)*/
				OPEN CursorVersions
				FETCH CursorVersions
				INTO @versionName, @proc, @reverseProc

				/*fetch next until we get to the row having the current version*/
				WHILE @versionName < @currentVersion
				BEGIN
					FETCH CursorVersions
					INTO @versionName, @proc, @reverseProc
				END

				/*if version wanted is greater than the current one
				fetch next and for each version execute its corresponding procedure,
				update the current version and the 'VersionDBTable'
				also print the new version at each step*/
				IF (@versionWanted > @currentVersion)
					BEGIN
						WHILE(@versionWanted > @currentVersion)
						BEGIN
							FETCH NEXT FROM CursorVersions
							INTO @versionName, @proc, @reverseProc

							EXEC @proc

							SET @currentVersion = @versionName
							UPDATE VersionDBTable
							SET currentVersion = @currentVersion
							PRINT 'changed to version: ' + CAST(@currentVersion AS VARCHAR)
						END
					END

				/*if version wanted is less than the current one
				fetch prior and for each version execute its corresponding reverse procedure,
				update the current version and the 'VersionDBTable'
				also print the new version at each step*/
				ELSE IF (@versionWanted < @currentVersion)
					BEGIN
						WHILE (@versionWanted < @currentVersion)
						BEGIN
							EXEC @reverseProc
				
							FETCH PRIOR FROM CursorVersions
							INTO @versionName, @proc, @reverseProc

							SET @currentVersion = @versionName
							UPDATE VersionDBTable
							SET currentVersion = @currentVersion
							PRINT 'changed to version: ' + CAST(@currentVersion AS VARCHAR)
						END
					END

			/*close the cursor and free used resources (result set)*/
			CLOSE CursorVersions

			/*deallocate the cursor and release the resources allocated to the cursor (name of the cursor)*/
			DEALLOCATE CursorVersions
		END
		
		ELSE
			PRINT N'version wanted is the current version'
		END
END
GO

DROP TABLE Versions
GO

--execute procedure
EXEC changeVersion 0
GO
--remove procedure
DROP PROCEDURE changeVersion
GO

SELECT *
FROM VersionDBTable

