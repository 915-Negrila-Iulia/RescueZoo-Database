/*
Lab 5. Indexes

Work on 3 tables of the form Ta(aid, a2, …), Tb(bid, b2, …), Tc(cid, aid, bid, …), where:
    - aid, bid, cid, a2, b2 are integers;
    - the primary keys are underlined;
    - a2 is UNIQUE in Ta;
    - aid and bid are foreign keys in Tc, referencing the primary keys in Ta and Tb, respectively.
    
a. Write queries on Ta such that their execution plans contain the following operators:
    - clustered index scan;
    - clustered index seek;
    - nonclustered index scan;
    - nonclustered index seek;
    - key lookup.
    
b. Write a query on table Tb with a WHERE clause of the form WHERE b2 = value and analyze its execution plan. 
   Create a nonclustered index that can speed up the query. Examine the execution plan again.
   
c. Create a view that joins at least 2 tables. Check whether existing indexes are helpful; 
   if not, reassess existing indexes / examine the cardinality of the tables.
*/


/*** Indexes ***/
/* Ta = Participant; aid = participantID (int); a2 = phone (unique and int);                      */
/* Tb = VIPEvent   ; bid = eventID (int)      ; b2 = duration (int)        ;                      */
/* Tc = DetailsVIP ; cid = detailsID (int)    ; aid = Ta.aid (int)         ; bid = Tb.bid (int) ; */

-- a)

/* clustered index scan */
SELECT *
FROM Participant

SELECT firstName
FROM Participant

/* clustered index seek */
SELECT *
FROM Participant
WHERE participantID < 5

/* nonclustered index scan */
SELECT phone
FROM Participant

SELECT email
FROM Participant

/* nonclustered index seek */
SELECT phone
FROM Participant
WHERE phone > 749999999

/* key lookup */
-- nonclustered index seek + key lookup
SELECT *
FROM Participant
WHERE phone = 0749621477

SELECT *
FROM Participant
WHERE email = '25emma25@yahoo.com'

-- create nonclustered index with search key = Participant.phone
CREATE NONCLUSTERED
INDEX nonclustered_phone
ON Participant(phone)

DROP INDEX Participant.nonclustered_phone
GO

sp_helpindex Participant

-- nonclustered index seek + key lookup 
SELECT *
FROM Participant
WITH(INDEX(nonclustered_phone))
WHERE phone > 749999999

-- nonclustered index scan + key lookup
SELECT *
FROM Participant
WITH(INDEX(nonclustered_phone))
WHERE phone like '723%'

-- b)

-- cost before nonclustered index: 0,016... 
-- cost after nonclustered index: 0,011...
SELECT tourName
FROM VIPEvent
WHERE duration = 2

CREATE 
INDEX noncl_duration_include_name
ON VIPEvent(duration)
INCLUDE (tourName)

DROP INDEX VIPEvent.noncl_duration_include_name

-- c)

-- participant and total duration of all its VIPevents
-- cost before: 0,027...
-- cost after: 0,013...
CREATE VIEW totalDurationView
AS
SELECT P.participantID, SUM(VE.duration) AS total_duration
FROM Participant AS P JOIN DetailsVIP AS DV ON P.participantID = DV.participantID
					  JOIN VIPEvent AS VE ON DV.eventID = VE.eventID
GROUP BY P.participantID
GO

SELECT *
FROM totalDurationView

DROP VIEW totalDurationView

-- noncl_duration_include_name index on table VIPEvent does not help
-- index with participantIDs (sorted) and corresponding eventID on table DetailsVIP
CREATE 
INDEX noncl_participantID_include_eventID
ON DetailsVIP(participantID)
INCLUDE (eventID)

DROP INDEX DetailsVIP.noncl_participantID_include_eventID
