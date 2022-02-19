/*
	Lab 1. Database Design
	Imagine a simple application that requires a database.
	Represent the application data in a relational structure and implement the structure in a SQL Server database.
	The database must contain at least: 10 tables, two 1:n relationships, one m:n relationship.
*/

/***CREATE DATABASE, CREATE TABLES, INSERT DATA***/


/*DROP DATABASE RescueZoo*/

CREATE DATABASE RescueZoo
go
use RescueZoo
go

CREATE TABLE Team
(
teamID INT PRIMARY KEY IDENTITY (221,1),
startShift varchar(10) not null,
endShift varchar(10) not null
)

CREATE TABLE ZooZone
(
zoneName VARCHAR(50) PRIMARY KEY,
teamID int,
FOREIGN KEY (teamID) REFERENCES Team(teamID) ON DELETE CASCADE,
nrRareSpecies int
)

CREATE TABLE Animal
(
animalID INT PRIMARY KEY IDENTITY (1,1),
zoneName VARCHAR(50)  not null,
FOREIGN KEY (zoneName) REFERENCES ZooZone(zoneName) ON DELETE CASCADE,
animalName varchar(50) not null,
vaccinated bit
)

CREATE TABLE EmployeeSalary
(
jobTitle VARCHAR(50) PRIMARY KEY,
salary int not null,
jobLevel varchar(50)
)

CREATE TABLE Employee
(
employeeID INT PRIMARY KEY IDENTITY (1000,1),
teamID INT,
FOREIGN KEY (teamID) REFERENCES Team(teamID) ON DELETE CASCADE,
jobTitle VARCHAR(50),
FOREIGN KEY (jobTitle) REFERENCES EmployeeSalary(jobTitle) ON DELETE CASCADE,
firstName varchar(50) not null,
lastName varchar(50) not null,
gender varchar(50) not null,
dateOfBirth date not null
)

CREATE TABLE ZooEvent
(
PRIMARY KEY(eventName, eventDate),
eventName varchar(50) not null,
shortDescription varchar(500),
eventDate varchar(25) not null,
teamID INT not null,
FOREIGN KEY (teamID) REFERENCES Team(teamID) ON DELETE CASCADE
)

CREATE TABLE Participant
(
participantID INT PRIMARY KEY IDENTITY(1,1),
firstName varchar(50) not null,
lastName varchar(50) not null,
email varchar(50) not null,
donate bit not null,
phone int not null,
CONSTRAINT UQ_Particip UNIQUE (email),
CONSTRAINT UQ_ParticipPhone UNIQUE (phone)
)

CREATE TABLE Ticket
(
participantID INT not null,
FOREIGN KEY (participantID) REFERENCES Participant(participantID) ON DELETE CASCADE,
eventName varchar(50) not null,
eventDate varchar(25) not null,
price int,
CONSTRAINT FK_Ticket FOREIGN KEY (eventName, eventDate) REFERENCES ZooEvent(eventName, eventDate) ON DELETE CASCADE,
PRIMARY KEY(eventName, eventDate, participantID)
)

CREATE TABLE FoodProvider
(
providerName varchar(50) not null,
providerAddress varchar(50) not null,
serviceQuality int not null,
PRIMARY KEY(providerName,providerAddress)
)

CREATE TABLE FoodItem
(
foodName VARCHAR(50) not null,
providerName varchar(50),
providerAddress varchar(50),
quantity int,
CONSTRAINT PK_FoodItem PRIMARY KEY (foodName),
FOREIGN KEY (providerName,providerAddress) REFERENCES FoodProvider(providerName,providerAddress) ON DELETE CASCADE
)

CREATE TABLE Recipe
(
animalID INT not null,
FOREIGN KEY (animalID) REFERENCES Animal(animalID) ON DELETE CASCADE,
foodName VARCHAR(50) not null,
CONSTRAINT FK_Recipe_foodName FOREIGN KEY (foodName) REFERENCES FoodItem(foodName) ON DELETE CASCADE,
PRIMARY KEY(animalID, foodName)
)

CREATE TABLE VIPEvent
(
eventID INT not null,
duration INT,
tourName varchar(25),
PRIMARY KEY (eventID)
)

CREATE TABLE DetailsVIP
(
detailsID INT not null IDENTITY(800,1),
participantID INT not null,
eventID INT not null,
FOREIGN KEY (participantID) REFERENCES Participant(participantID) ON DELETE CASCADE,
FOREIGN KEY (eventID) REFERENCES VIPEvent(eventID) ON DELETE CASCADE,
PRIMARY KEY (detailsID)
)
   
DROP TABLE DetailsVIP, Recipe, FoodItem, FoodProvider, Animal, ZooZone, Ticket, Participant, ZooEvent, Employee, EmployeeSalary, Team, VIPEvent

INSERT INTO Team VALUES
('08:00:00','20:00:00'),
('20:00:00','08:00:00'),
('13:00:00','01:00:00')

INSERT INTO EmployeeSalary VALUES
('Cleaner',250,'beginner'),
('Veterinar',600,'pro'),
('Dangerous Animal Keeper',800,'pro'),
('Cook',350,'medium'),
('Volunteer',100,null)


INSERT INTO Employee VALUES
(null,null,'Zack', 'Kenveli', 'Male', '10-10-1999'),
(222,'Veterinar','Angela', 'Hudson', 'Female', '12-1-1998'),
(223,'Volunteer','Camilla', 'Jekkinson', 'Female', '04-5-2001'),
(221,'Dangerous Animal Keeper','John', 'Malone', 'Male', '7-15-1989'),
(null,'Cook','Tailor', 'Scott', 'Male', '6-23-1989'),
(223,'Veterinar','Kira', 'Maylor', 'Female', '10-14-2000'),
(222,null,'Anna', 'Phorigan', 'Female', '1-23-1985'),
(222,'Cleaner','Kendall', 'Schrute', 'Female', '4-14-2001'),
(221,'Veterinar','Martin', 'Punk', 'Male', '4-6-1999'),
(222,null,'John','Pickle','Male', '10-10-1989'),
(223,'Cook','Cameron','Pickle','Male', '10-10-1989'),
(null,'Volunteer','Eliza','Strepher','Female', '4-16-2000')


INSERT INTO ZooEvent VALUES
('Welcome to RescueZoo!','We are a team which cares about animals and wants to give them the carring they deserve. 
Come and meet us at RescueZoo and be part of our journey!','01-07 jun 2019',221),
('Nature Photography WorkShop','Have an unforgettable day learning how to take better photographs
of stunning animals and nature and understanding how to get the most out of your camera','10-12 jul 2019',222),
('Donation Days!',null,'01-07 sept 2019',222),
('RescueZoo Chrismtas Nights','Light up your winter! Make your evenings merry and 
bright this festive season with a magical journey through RescueZoo!','21-24 dec 2019',223),
('One year together celebration!','Let s celebrate one wonderful year of helping animals in need!','01-07 jun 2020',221),
('RescueZoo Chrismtas Nights','Designed for limited visitor numbers with a wide range of
safety measures in place, RescueZoo Christmas Nights are sure to light up your winter.','21-24 dec 2020',223),
('Two years together celebration!','Let s celebrate two amazing years of helping animals in need!','01-07 jun 2021',221),
('Donation Days!','Help us provide these sweet animals the joy of a happy life:)','01-07 sept 2021',222),
('RescueZoo Chrismtas Nights',null,'21-24 dec 2021',223),
('Three years together celebration!',null,'01-07 jun 2022',221),
('World Animal Day - Free Entrance','International day of action for animal rights.','04-05 oct 2022',222)


INSERT INTO Participant VALUES
('Oliver','Callorene','oli_cam@yahoo.com',1,0756312855),
('Kendall','Whitley','kenken_whitley@yahoo.com',1,0745326811),
('Anna','Jickinson','anna1999@gmail.com',0,0752123456),
('Kira','Winston','kiraWin09@gmail.com',0,0744236785),
('John','Famber','FamberJohn44@yahoo.com',1,0755698632),
('Jennifer','Camillton','CamilltonJen2001@gmail.com',1,0745698321),
('Pamela','Camillton','ItsPamela123@yahoo.com',0,0723569812),
('Oscar','Bill','oscar_bill_12@yahoo.com',1,0723985236),
('Emma','Copendoll','25emma25@yahoo.com',0,0748896321),
('Oliver','Robot','IamHumanToo@yahoo.com',1,0749621477)


INSERT INTO Ticket VALUES
(1,'Welcome to RescueZoo!','01-07 jun 2019',20),
(2,'Welcome to RescueZoo!','01-07 jun 2019',20),
(3,'Welcome to RescueZoo!','01-07 jun 2019',20),
(4,'Welcome to RescueZoo!','01-07 jun 2019',20),
(5,'Welcome to RescueZoo!','01-07 jun 2019',20),
(1,'Nature Photography WorkShop','10-12 jul 2019',30),
(2,'Nature Photography WorkShop','10-12 jul 2019',30),
(10,'Nature Photography WorkShop','10-12 jul 2019',30),
(1,'Donation Days!','01-07 sept 2019',10),
(2,'Donation Days!','01-07 sept 2019',10),
(3,'Donation Days!','01-07 sept 2019',10),
(10,'Donation Days!','01-07 sept 2019',10),
(4,'Donation Days!','01-07 sept 2019',10),
(7,'Donation Days!','01-07 sept 2019',10),
(5,'Donation Days!','01-07 sept 2019',10),
(1,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(2,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(3,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(5,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(6,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(8,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(9,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(10,'RescueZoo Chrismtas Nights','21-24 dec 2019',35),
(1,'One year together celebration!','01-07 jun 2020',20),
(2,'One year together celebration!','01-07 jun 2020',20),
(10,'One year together celebration!','01-07 jun 2020',20),
(6,'One year together celebration!','01-07 jun 2020',20),
(5,'One year together celebration!','01-07 jun 2020',20),
(8,'One year together celebration!','01-07 jun 2020',20),
(9,'One year together celebration!','01-07 jun 2020',20),
(4,'One year together celebration!','01-07 jun 2020',20),
(1,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(2,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(3,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(5,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(6,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(8,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(4,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(7,'RescueZoo Chrismtas Nights','21-24 dec 2020',35),
(1,'Two years together celebration!','01-07 jun 2021',25),
(4,'Two years together celebration!','01-07 jun 2021',25),
(6,'Two years together celebration!','01-07 jun 2021',25),
(9,'Two years together celebration!','01-07 jun 2021',25),
(10,'Two years together celebration!','01-07 jun 2021',25),
(7,'Two years together celebration!','01-07 jun 2021',25),
(3,'Two years together celebration!','01-07 jun 2021',25),
(2,'Two years together celebration!','01-07 jun 2021',25),
(1,'Donation Days!','01-07 sept 2021',10),
(4,'Donation Days!','01-07 sept 2021',10),
(5,'Donation Days!','01-07 sept 2021',10),
(10,'Donation Days!','01-07 sept 2021',10),
(9,'Donation Days!','01-07 sept 2021',10),
(8,'Donation Days!','01-07 sept 2021',10),
(2,'Donation Days!','01-07 sept 2021',10),
(1,'RescueZoo Chrismtas Nights','21-24 dec 2021',35),
(3,'RescueZoo Chrismtas Nights','21-24 dec 2021',35),
(5,'RescueZoo Chrismtas Nights','21-24 dec 2021',35),
(2,'RescueZoo Chrismtas Nights','21-24 dec 2021',35),
(8,'RescueZoo Chrismtas Nights','21-24 dec 2021',35),
(1,'Three years together celebration!','01-07 jun 2022',null),
(4,'Three years together celebration!','01-07 jun 2022',null),
(2,'Three years together celebration!','01-07 jun 2022',null),
(8,'Three years together celebration!','01-07 jun 2022',null),
(9,'Three years together celebration!','01-07 jun 2022',null),
(6,'Three years together celebration!','01-07 jun 2022',null),
(1,'World Animal Day - Free Entrance','04-05 oct 2022',0),
(2,'World Animal Day - Free Entrance','04-05 oct 2022',0),
(5,'World Animal Day - Free Entrance','04-05 oct 2022',0),
(7,'World Animal Day - Free Entrance','04-05 oct 2022',0),
(8,'World Animal Day - Free Entrance','04-05 oct 2022',0),
(9,'World Animal Day - Free Entrance','04-05 oct 2022',0)


INSERT INTO ZooZone VALUES
('Africa',221,5),
('Europe',222,null),
('Amazonia-French Guiana',null,2),
('Madagascar',223,4),
('Patagonia',221,null)


INSERT INTO Animal VALUES
('Africa','White Rinocher',1),
('Africa','Lion',1),
('Africa','Grevy Zebra',0),
('Africa','Giraffe',1),
('Africa','Greater Flamingo',0),
('Africa','Scimitar-Horned Oryx',0),
('Africa','Baboon',1),
('Europe','Turtle',1),
('Europe','Snake',1),
('Europe','Otter',0),
('Europe','Griffon Vulture',0),
('Europe','Iberian Wolf',1),
('Europe','Eurasian Lynx',1),
('Amazonia-French Guiana','Wolly Monkey',0),
('Amazonia-French Guiana','Jaguar',1),
('Amazonia-French Guiana','Snake',1),
('Amazonia-French Guiana','American Coati',1),
('Amazonia-French Guiana','Marmoset',0),
('Madagascar','Lemur',1),
('Madagascar','Turtle',0),
('Madagascar','Fossa',0),
('Madagascar','Chameleon',0),
('Madagascar','Bamboo Shark',1),
('Patagonia','Puma',1),
('Patagonia','Sea Lion',0),
('Patagonia','Humboldt Penguin',0),
('Patagonia','Guanoco',1)

 
INSERT INTO FoodProvider VALUES
('Superfood Village','Portugal, Lisbon',9),
('Smart Meals','France, Lyon',8),
('Nutrition Depot','Spain, San Sebastian',8),
('Hungry Helpers','USA, Kentucky, Louisville',9),
('Superfood Village','Italy, Florence',9),
('Nutrition Depot','Denmark, Copenhagen',10)


INSERT INTO FoodItem VALUES
('Carrot','Superfood Village','Portugal, Lisbon',500),
('Potato','Superfood Village','Portugal, Lisbon',500),
('Salad','Superfood Village','Portugal, Lisbon',null),
('Fish','Superfood Village','Italy, Florence',1000),
('Tomato','Superfood Village','Italy, Florence',500),
('Chicken','Hungry Helpers','USA, Kentucky, Louisville',null),
('Beef','Hungry Helpers','USA, Kentucky, Louisville',2000),
('Duck','Hungry Helpers','USA, Kentucky, Louisville',2000),
('Cucumber','Smart Meals','France, Lyon',500),
('Cauliflower','Smart Meals','France, Lyon',null),
('Apple','Nutrition Depot','Spain, San Sebastian',500),
('Pear','Nutrition Depot','Spain, San Sebastian',500),
('Strawberry',null,null,null),
('Banana','Nutrition Depot','Denmark, Copenhagen',500),
('Orange','Nutrition Depot','Denmark, Copenhagen',500)


INSERT INTO Recipe VALUES
--(56,'Carrot'),
(3,'Potato'),
(3,'Salad'),
(4,'Salad'),
(8,'Salad'),
(22,'Salad'),
(5,'Fish'),
(1,'Tomato'),
(3,'Tomato'),
(1,'Chicken'),
(2,'Chicken'),
(2,'Beef'),
(2,'Duck'),
(6,'Cucumber'),
(6,'Cauliflower'),
(4,'Apple'),
(4,'Pear'),
(8,'Strawberry'),
(7,'Banana'),
(9,'Orange'),
(24,'Carrot'),
(27,'Potato'),
(11,'Salad'),
(10,'Fish'),
(23,'Fish'),
(10,'Tomato'),
(11,'Chicken'),
(14,'Beef'),
(9,'Duck'),
(11,'Duck'),
(22,'Cucumber'),
(21,'Cauliflower'),
(27,'Apple'),
(27,'Pear'),
(23,'Strawberry'),
(14,'Banana'),
(12,'Orange'),
(21,'Carrot'),
(20,'Potato'),
(20,'Salad'),
(13,'Fish'),
(18,'Fish'),
(18,'Tomato'),
(12,'Chicken'),
(12,'Beef'),
(12,'Duck'),
(13,'Chicken'),
(13,'Beef'),
(13,'Duck'),
(15,'Chicken'),
(15,'Beef'),
(15,'Duck'),
(15,'Cucumber'),
(18,'Cauliflower'),
(16,'Apple'),
(16,'Pear'),
(19,'Strawberry'),
(19,'Banana'),
(16,'Orange'),
(17,'Chicken'),
(17,'Beef'),
(24,'Chicken'),
(24,'Beef'),
(24,'Duck'),
(25,'Fish'),
(26,'Fish')

INSERT INTO VIPEvent VALUES
(1,2,'From Europe To Africa'),
(2,1,'Secrets of Madagascar'),
(3,3,'Meeting the animals'),
(4,2,'It is lunch time'),
(5,2,'Rare species')

DECLARE @var INT
SET @var = 6
WHILE @var < 1000
BEGIN
	INSERT INTO VIPEvent VALUES
	(@var,2,'From Europe To Africa')
	SET @var = @var + 1
END

SET @var = 1500
WHILE @var < 2000
BEGIN
	IF @var % 3 = 0
		INSERT INTO VIPEvent VALUES
		(@var,3,'event1')
	ELSE
		INSERT INTO VIPEvent VALUES
		(@var,2,'event11')
	SET @var = @var + 1
END

SET @var = 7000
WHILE @var < 9000
BEGIN
	IF @var % 2 = 0
		INSERT INTO VIPEvent VALUES
		(@var,1,'event2')
	ELSE
		INSERT INTO VIPEvent VALUES
		(@var,2,'event22')
	SET @var = @var + 1
END


INSERT INTO DetailsVIP VALUES
(1,1),
(2,1),
(4,1),
(6,1),
(10,1),
(1,2),
(2,2),
(3,2),
(9,2),
(10,2),
(3,1),
(7,1),
(9,1),
(1,3),
(5,3),
(8,3),
(10,3),
(8,4),
(10,4),
(2,4),
(6,4),
(4,5),
(5,5),
(9,5)
