
/***UPDATE DATA, DELETE DATA***/

/* Increase salary some employees */
UPDATE EmployeeSalary
SET salary = salary + 10
WHERE jobLevel <> 'beginner' AND salary BETWEEN 300 AND 700


/* Increase quantity by 100 for the fooditems which are provided by a foodprovider having perfect quality(10) */
UPDATE FI
SET FI.quantity = FI.quantity + 100
FROM FoodItem AS FI, FoodProvider AS FP
WHERE FP.providerName = FI.providerName AND FP.providerAddress = FI.providerAddress AND FP.serviceQuality = 10


/* Move all 'volunteer' employees born in 2001 or 2002 in team 222 */
UPDATE Employee
SET teamID = 222
WHERE jobTitle = 'Volunteer' AND YEAR(dateOfBirth) IN (2001,2002)


/* Remove fooditems which have 'p' or 'P' as the first or last letter in their name 
   and also the recipe elements having the connection foreign key.
   This is done by using cascade option on delete */
DELETE
FROM FoodItem
WHERE foodName LIKE 'p%' OR foodName LIKE '%p'


/* Remove tickets which have NULL price */
DELETE
FROM Ticket
WHERE price IS NULL