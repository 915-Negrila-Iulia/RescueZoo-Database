
/* relational structure */

INSERT INTO Tests VALUES
('Employee-Salary-Events'),			-- id 1
('Animal-Recipe-Zone-Team')			-- id 2

INSERT INTO Tables VALUES
('Employee'),
('EmployeeSalary'),
('ZooEvent'),
('Team'),
('Recipe'),
('Animal'),
('ZooZone')

INSERT INTO TestTables VALUES
(1,1,1000,1),
(1,2,300,2),
(1,3,700,3),
(1,4,200,4),
(2,5,1000,1),
(2,6,2000,2),
(2,7,700,3),
(2,4,500,4)

INSERT INTO Views VALUES
('employeeAge'),
('employeeAtEvent'),
('employeePerSalary'),
('rareZones'),
('animalRecipe'),
('animalsPerTeam')

INSERT INTO TestViews VALUES
(1,1),
(1,2),
(1,3),
(2,4),
(2,5),
(2,6)

SELECT *
FROM Tests
SELECT *
FROM Tables
SELECT *
FROM TestTables
SELECT *
FROM Views
SELECT *
FROM TestViews
GO

SELECT *
FROM TestRunTables
GO
SELECT *
FROM TestRunViews
GO
SELECT *
FROM TestRuns
GO

CREATE PROCEDURE lab4
AS
BEGIN

	/* parse Tests table using a cursor (only fetch next) */
	/* declare cursor and parameters needed */
	DECLARE @testID INT, @testName nvarchar(50)
	DECLARE testsCursor CURSOR FOR
	SELECT T.TestID, T.Name
	FROM Tests AS T

	/* open cursor and fetch first row */
	OPEN testsCursor
	FETCH testsCursor
	INTO @testID, @testName

	/* parse Tests */
	WHILE @@FETCH_STATUS = 0
	BEGIN

		/* use tables: TestTables, Tables, TestRunTables */
		/* parse tables corresponding to a given test (@testID) (fetch next and prior => scroll) */
		/* tables are ordered by position (order of deleting tables) */
		/* declare cursor and parameters needed */
		DECLARE @tableID INT, @tableName nvarchar(50), @nrRows INT
		DECLARE tablesCursor CURSOR SCROLL FOR
		SELECT T.TableID, T.Name, TT.NoOfRows
		FROM TestTables AS TT JOIN Tables AS T ON TT.TableID = T.TableID
		WHERE TT.TestID = @testID
		ORDER BY TT.Position

		/* open cursor and fetch first row */
		OPEN tablesCursor
		FETCH tablesCursor
		INTO  @tableID, @tableName, @nrRows


		/* update or insert record in TestRuns table */
		/* depending if record with primary key @testID exists or not */
		IF EXISTS(SELECT * FROM TestRuns WHERE TestRunID = @testID)
		BEGIN	
			UPDATE TestRuns
			SET Description = @testName,
				StartAt = GETDATE()
			WHERE TestRunID = @testID
		END

		ELSE
		BEGIN
			INSERT INTO TestRuns VALUES
			(@testName,GETDATE(),GETDATE())
		END

		/* parse tables and delete records */
		WHILE @@FETCH_STATUS = 0
		BEGIN

			PRINT 'delete-> id: '+CONVERT(VARCHAR,@tableID)+', name: '+ @tableName
			
			SET NOCOUNT ON
			/* execute procedure which deletes records from current table */
			DECLARE @deleteProc nvarchar(25)
			SET @deleteProc = 'delete' + @tableName
			EXEC @deleteProc 
			SET NOCOUNT OFF

			FETCH NEXT FROM tablesCursor
			INTO @tableID, @tableName, @nrRows

		END

		FETCH PRIOR FROM tablesCursor
		INTO @tableID, @tableName, @nrRows
		/* parse tables and insert records */
		/* the cursor is fetched on the last row right now */
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			PRINT 'insert-> id: '+CONVERT(VARCHAR,@tableID)+', name: '+@tableName+', rows: '+CONVERT(VARCHAR,@nrRows)

			DECLARE @startDate datetime,
					@endDate datetime
			SET NOCOUNT ON
			/* execute procedure which inserts number of @nrRows records into current table */
			DECLARE @insertProc nvarchar(25)
			SET @insertProc = 'insert' + @tableName
			SET @startDate = GETDATE()				-- starting time of inserting records for current table
			EXEC @insertProc @nrRows
			SET @endDate = GETDATE()				-- ending time of inserting records for current table
			SET NOCOUNT OFF

			/* update or insert record in TestRunTables table */
			/* depending if record with primary key (@testID,@tableID) exists or not */
			IF EXISTS(SELECT * FROM TestRunTables WHERE TableID = @tableID)
			BEGIN	
				UPDATE TestRunTables 
				SET StartAt = @startDate, 
					EndAt = @endDate
				WHERE TestRunID = @testID AND TableID = @tableID
			END

			ELSE
			BEGIN
				INSERT INTO TestRunTables VALUES
				(@testID,@tableID,@startDate,@endDate)
			END

			FETCH PRIOR FROM tablesCursor
			INTO @tableID, @tableName, @nrRows

		END

		/* close cursor */
		CLOSE tablesCursor
		/* deallocate cursor */
		DEALLOCATE tablesCursor
		
		/* use tables: TestViews, Views, TestRunViews */
		/* parse and execute views corresponding to a given test (@testID) (only fetch next) */
		/* declare cursor and parameters needed */
		DECLARE @viewID INT, @viewName nvarchar(50)
		DECLARE viewsCursor CURSOR FOR
		SELECT V.ViewID, V.Name
		FROM TestViews AS TV JOIN Views AS V ON TV.ViewID = V.ViewID
		WHERE TV.TestID = @testID

		/* open cursor and fetch first row */
		OPEN viewsCursor
		FETCH viewsCursor
		INTO @viewID, @viewName

		/* parse and execute views stored in Views table*/
		WHILE @@FETCH_STATUS = 0
		BEGIN

			PRINT 'execute view-> id: '+CONVERT(VARCHAR,@viewID)+', name: '+ @viewName
			
			--SET NOCOUNT ON
			/* execute current view */
			DECLARE @execView nvarchar(100)
			SET @execView = 'SELECT * FROM ' + @viewName
			SET @startDate = GETDATE()					-- starting time of executing current view
			EXEC(@execView)
			SET @endDate = GETDATE()					-- ending time of executing current view
			--SET NOCOUNT OFF

			/* update or insert record in TestRunViews table */
			/* depending if record with primary key (@testID,@viewID) exists or not */
			IF EXISTS(SELECT * FROM TestRunViews WHERE ViewID = @viewID)
			BEGIN	
				UPDATE TestRunViews 
				SET StartAt = @startDate, 
					EndAt = @endDate
				WHERE TestRunID = @testID AND ViewID = @viewID
			END

			ELSE
			BEGIN
				INSERT INTO TestRunViews VALUES
				(@testID,@viewID,@startDate,@endDate)
			END

			FETCH NEXT FROM viewsCursor
			INTO @viewID, @viewName

		END

		/* close cursor */
		CLOSE viewsCursor
		/* deallocate cursor */
		DEALLOCATE viewsCursor
	

		/* update EndAt of the current test from TestRuns table */
		UPDATE TestRuns
		SET EndAt = GETDATE()
		WHERE TestRunID = @testID

		/* fetch to the next test from Tests table */
		FETCH NEXT FROM testsCursor
		INTO @testID, @testName

	END

	/* close cursor */
	CLOSE testsCursor
	/* deallocate cursor */
	DEALLOCATE testsCursor

END

EXEC lab4

DROP PROCEDURE lab4

SELECT *
FROM TestRunTables
GO
SELECT *
FROM TestRunViews
GO
SELECT *
FROM TestRuns
GO