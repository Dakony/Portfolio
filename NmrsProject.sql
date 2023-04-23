
-- Facility with high viral load and retention rate using SQL
----------------------------------------------------------------------------------------------------------------------------
--Load ola Dataset
SELECT * 
FROM NmrsProject..Ola

--looking at the Current ART status of all patients in ola

SELECT CurrentARTStatus_Pharmacy, count(CurrentARTStatus_Pharmacy) as TotalCurrentARTStatus
FROM NmrsProject..Ola
Group by CurrentARTStatus_Pharmacy
order by 1

-------------------------------------------------------------------------------------------------------------------------

--Looking at the % of ARTStatus over ever enrolled patients at Ola 

--Creating Temp Table
DROP TABLE IF EXISTS #ARTStatus
CREATE TABLE #ARTStatus
(CurrentARTStatus_Pharmacy varchar(255),
TotalCurrentARTStatus int)

INSERT INTO #ARTStatus
SELECT CurrentARTStatus_Pharmacy, count(CurrentARTStatus_Pharmacy) as TotalCurrentARTStatus
FROM NmrsProject..Ola
Group by CurrentARTStatus_Pharmacy

--Let's get the total number of ever enrolled at Ola

SELECT SUM(TotalCurrentARTStatus) EverEnrolled
FROM #ARTStatus

--Let's get the percentage of ARTStatus over ever enrolled

SELECT CurrentARTStatus_Pharmacy, TotalCurrentARTStatus,
(TotalCurrentARTStatus*100 / (SELECT SUM(TotalCurrentARTStatus) FROM #ARTStatus)) AS '% Of ARTStatus Ola'
FROM #ARTStatus
order by 1


-----------------------------------------------------------------------------------------------------------

--Lets look at Active patients with viral load results 

SELECT PepID, Convert(Date,Pharmacy_LastPickupdate), CurrentARTStatus_Pharmacy, CurrentViralLoad, Convert(Date,DateofCurrentViralLoad)
FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'Active'
ORDER BY DateofCurrentViralLoad DESC


--Let's look at Viral load of active patients in details of Ola
 
SELECT PepID,Convert(Date,Pharmacy_LastPickupdate) PharmacyLastPickup,CurrentViralLoad,
Convert(Date,DateofCurrentViralLoad) ViralLoadDate
FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'ACTIVE' 
ORDER BY ViralLoadDate DESC 

---------------------------------------------------------------------------------------------------------------

--Let's look at the patients with low viral load

SELECT PepID,Convert(Date,Pharmacy_LastPickupdate) PharmacyLastPickup,CurrentViralLoad,
Convert(Date,DateofCurrentViralLoad) ViralLoadDate
FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'ACTIVE' AND CurrentViralLoad <= 50
ORDER BY CurrentViralLoad  


-----------------------------------------------------------------------------------------------------------------

--Let's look at the patients with High viral load

SELECT PepID,Convert(Date,Pharmacy_LastPickupdate) PharmacyLastPickup,CurrentViralLoad,
Convert(Date,DateofCurrentViralLoad) ViralLoadDate
FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'ACTIVE' AND CurrentViralLoad > 50
ORDER BY CurrentViralLoad  


------------------------------------------------------------------------------------------------------------------

--Lets look at the number of patients with low, High and total viral load in Ola

SELECT COUNT(IIF(CurrentViralLoad <= 50,1,NULL)) NumOfLowViralLoad,
		COUNT(IIF(CurrentViralLoad > 50,1,NULL)) NumOfHighViralLoad,
		COUNT(CurrentViralLoad) CountOfTotalViralLoad
FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'Active' AND CurrentViralLoad IS NOT NULL

-- Creating a temp table to save low high and total number of patients with viral load results
DROP TABLE IF EXISTS #ViralLoadCount
CREATE TABLE #ViralLoadCount
(NumOfLowViralLoad int,
NumOfHighViralLoad int,
CountOfTotalViralLoad int
)

INSERT INTO #ViralLoadCount
SELECT COUNT(IIF(CurrentViralLoad <= 50,1,NULL)) NumOfLowViralLoad,
		COUNT(IIF(CurrentViralLoad > 50,1,NULL)) NumOfHighViralLoad,
		COUNT(CurrentViralLoad) CountOfTotalViralLoad
FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'Active' AND CurrentViralLoad IS NOT NULL

----------------------------------------------------------------------------------------------------------

--Let's look at the percentage of patients with low and high viral results to the total number of patients with viral load results in Ola

SELECT NumOfLowViralLoad, (NumOfLowViralLoad *100 /CountOfTotalViralLoad) '% of lowViralLoad',
		NumOfHighViralLoad, (NumOfHighViralLoad *100 /CountOfTotalViralLoad) '% of HighViralLoad'
FROM #ViralLoadCount

---------------------------------------------------------------------------------------------------------------------------------

--Total sum of low viral load and High Viral results of patients in Ola

SELECT SUM(CASE WHEN CurrentViralLoad <= 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfLowViralLoadResults,
	   SUM(CASE WHEN CurrentViralLoad > 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfHighViralLoadResults,
        SUM(CurrentViralLoad) AS TotalViralLoad

FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'Active' 

--Creating Temp table to store the sum of high, low and total results
DROP TABLE IF EXISTS #TotalSumOfResults
CREATE TABLE #TotalSumOfResults
(TotalOfLowViralLoadResults float,
TotalOfHighViralLoadResults float,
TotalViralLoad float
)
INSERT INTO #TotalSumOfResults
SELECT SUM(CASE WHEN CurrentViralLoad <= 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfLowViralLoadResults,
	   SUM(CASE WHEN CurrentViralLoad > 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfHighViralLoadResults,
        SUM(CurrentViralLoad) AS TotalViralLoad

FROM NmrsProject..Ola
WHERE CurrentARTStatus_Pharmacy = 'Active' 

--Percentage of sum of low and high viral load results to the total sum of results in Ola

SELECT TotalOfLowViralLoadResults, (TotalOfLowViralLoadResults *100/TotalViralLoad) '% SumOfLowViralload',
		TotalOfHighViralLoadResults, (TotalOfHighViralLoadResults *100/TotalViralLoad) '% SumOfHighViralLoad'
FROM #TotalSumOfResults


-----------------------------------------------------------------------------------------------------------------------------
---Let's Look at Pssh rentention rate and Viral load
--Load PSSH Dataset
SELECT *
FROM NmrsProject..Pssh

------------------------------------------------------------------------------------------------------------------

--looking at the Current ART status of all Pssh patients

SELECT CurrentARTStatus_Pharmacy, count(CurrentARTStatus_Pharmacy) as TotalCurrentARTStatus
FROM NmrsProject..Pssh
Group by CurrentARTStatus_Pharmacy
order by 1


--Looking at the % of ARTStatus over ever enrolled patients at PSSH 

--Creating Temp Table
DROP TABLE IF EXISTS #ARTStatusPssh
CREATE TABLE #ARTStatusPssh
(CurrentARTStatus_Pharmacy varchar(255),
TotalCurrentARTStatus int)

INSERT INTO #ARTStatusPssh
SELECT CurrentARTStatus_Pharmacy, count(CurrentARTStatus_Pharmacy) as TotalCurrentARTStatus
FROM NmrsProject..Pssh
Group by CurrentARTStatus_Pharmacy


--Let's get the number of ever enrolled in Pssh
SELECT SUM(TotalCurrentARTStatus) EverEnrolled
FROM #ARTStatusPssh

--Let's get the percentage of ARTStatus over ever enrolled

SELECT CurrentARTStatus_Pharmacy, TotalCurrentARTStatus,
(TotalCurrentARTStatus*100 / (SELECT SUM(TotalCurrentARTStatus) FROM #ARTStatusPssh)) AS '% Of ARTStatus Pssh'
FROM #ARTStatusPssh
order by 1


-----------------------------------------------------------------------------------------------------------------------------

--Let's Compare the ARTstatus of Pssh and Ola

SELECT *
FROM #ARTStatus O
JOIN #ARTStatusPssh P
ON O.CurrentARTStatus_Pharmacy = P.CurrentARTStatus_Pharmacy
ORDER BY O.CurrentARTStatus_Pharmacy

-------------------------------------------------------------------------------------------------------------------------

--Lets look at Active patients with viral load results at Pssh 

SELECT PepID, Convert(Date,Pharmacy_LastPickupdate), CurrentARTStatus_Pharmacy, CurrentViralLoad, Convert(Date,DateofCurrentViralLoad)
FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'Active'
ORDER BY DateofCurrentViralLoad DESC

-----------------------------------------------------------------------------------------------------------------------
--Let's look at the patients with low viral load at Pssh

SELECT PepID,Convert(Date,Pharmacy_LastPickupdate) PharmacyLastPickup,CurrentViralLoad,
Convert(Date,DateofCurrentViralLoad) ViralLoadDate
FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'ACTIVE' AND CurrentViralLoad <= 50
ORDER BY CurrentViralLoad  

---------------------------------------------------------------------------------------------------------------------
--Let's look at the patients with High viral load at Pssh

SELECT PepID,Convert(Date,Pharmacy_LastPickupdate) PharmacyLastPickup,CurrentViralLoad,
Convert(Date,DateofCurrentViralLoad) ViralLoadDate
FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'ACTIVE' AND CurrentViralLoad > 50
ORDER BY CurrentViralLoad  

-----------------------------------------------------------------------------------------------------------
--Lets look at the number of patients with low, High and total viral load in Pssh

SELECT COUNT(IIF(CurrentViralLoad <= 50,1,NULL)) NumOfLowViralLoad,
		COUNT(IIF(CurrentViralLoad > 50,1,NULL)) NumOfHighViralLoad,
		COUNT(CurrentViralLoad) CountOfTotalViralLoad
FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'Active' AND CurrentViralLoad IS NOT NULL

-- Creating a temp table to save low high and total number of patients with viral load results in Pssh

DROP TABLE IF EXISTS #ViralLoadCountPssh
CREATE TABLE #ViralLoadCountPssh
(NumOfLowViralLoad int,
NumOfHighViralLoad int,
CountOfTotalViralLoad int
)

INSERT INTO #ViralLoadCountPssh
SELECT COUNT(IIF(CurrentViralLoad <= 50,1,NULL)) NumOfLowViralLoad,
		COUNT(IIF(CurrentViralLoad > 50,1,NULL)) NumOfHighViralLoad,
		COUNT(CurrentViralLoad) CountOfTotalViralLoad
FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'Active' AND CurrentViralLoad IS NOT NULL

----------------------------------------------------------------------------------------------------------

--Let's look at the percentage of patients with low and high viral results to the total number of patients with viral load results in Pssh

SELECT NumOfLowViralLoad, (NumOfLowViralLoad *100 /CountOfTotalViralLoad) '% of lowViralLoad',
		NumOfHighViralLoad, (NumOfHighViralLoad *100 /CountOfTotalViralLoad) '% of HighViralLoad'
FROM #ViralLoadCountPssh

------------------------------------------------------------------------------------------------------------
--Total sum of low viral load and High Viral results of patients in Pssh

SELECT SUM(CASE WHEN CurrentViralLoad <= 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfLowViralLoadResultsPssh,
	   SUM(CASE WHEN CurrentViralLoad > 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfHighViralLoadResultsPssh,
        SUM(CurrentViralLoad) AS TotalViralLoadPssh

FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'Active'

--Creating Temp table to store the sum of high, low and total results
DROP TABLE IF EXISTS #TotalSumOfResultsPssh
CREATE TABLE #TotalSumOfResultsPssh
(TotalOfLowViralLoadResultsPssh float,
TotalOfHighViralLoadResultsPssh float,
TotalViralLoadPssh float
)
INSERT INTO #TotalSumOfResultsPssh
SELECT SUM(CASE WHEN CurrentViralLoad <= 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfLowViralLoadResultsPssh,
	   SUM(CASE WHEN CurrentViralLoad > 50 THEN CurrentViralLoad ELSE 0 END) as TotalOfHighViralLoadResultsPssh,
        SUM(CurrentViralLoad) AS TotalViralLoadPssh

FROM NmrsProject..Pssh
WHERE CurrentARTStatus_Pharmacy = 'Active' 


--Percentage of sum of low and high viral load results to the total sum of results in Pssh

SELECT TotalOfLowViralLoadResultsPssh, (TotalOfLowViralLoadResultsPssh *100/TotalViralLoadPssh) '% SumOfLowViralload',
		TotalOfHighViralLoadResultsPssh, (TotalOfHighViralLoadResultsPssh *100/TotalViralLoadPssh) '% SumOfHighViralLoad'
FROM #TotalSumOfResultsPssh

