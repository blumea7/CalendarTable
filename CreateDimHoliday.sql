USE CalendarTable
GO

DROP TABLE IF EXISTS dbo.DimHoliday


CREATE TABLE dbo.DimHoliday (
	HolidayID int IDENTITY(1,1) -- Autoincrementing surrogate key
	, DateKey char(8) UNIQUE NOT NULL -- FK
	, [Name] varchar(50) NOT NULL
	, [Type] varchar(30) NOT NULL
	CONSTRAINT PK_DimHoliday_HolidayID PRIMARY KEY CLUSTERED (HolidayID ASC) 
	CONSTRAINT FK_DimHoliday_DimDate_DateKey FOREIGN KEY (DateKey) REFERENCES dbo.DimDate (DateKey)
)


-- Non-moving holidays 

INSERT INTO dbo.DimHoliday
SELECT
	[DateKey] = dd.DateKey
	,[Name] = CASE WHEN dd.[Month] = 1 AND dd.[DayOfMonth] = 1 THEN 'New Year’s Day'
				   WHEN dd.[Month] = 2 AND dd.[DayOfMonth] = 10 THEN 'Chinese New Year'
				   WHEN dd.[Month] = 4 AND dd.[DayOfMonth] = 9 THEN 'Araw ng Kagitingan'
				   WHEN dd.[Month] = 5 AND dd.[DayOfMonth] = 1 THEN 'Labor Day'
				   WHEN dd.[Month] = 6 AND dd.[DayOfMonth] = 12 THEN 'Independence Day'
				   WHEN dd.[Month] = 8 AND dd.[DayOfMonth] = 21 THEN 'Ninoy Aquino Day'
				   WHEN dd.[Month] = 8 AND dd.[DayOfMonth] = 26 THEN 'National Heroes Day'
				   WHEN dd.[Month] = 11 AND dd.[DayOfMonth] = 1 THEN 'All Saints'' Day'
				   WHEN dd.[Month] = 11 AND dd.[DayOfMonth] = 2 THEN 'All Souls'' Day'
				   WHEN dd.[Month] = 11 AND dd.[DayOfMonth] = 30 THEN 'Bonifacio Day'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 8 THEN 'Feast of the Immaculate Conception of Mary'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 24 THEN 'Christmas Eve'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 25 THEN 'Christmas Day'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 30 THEN 'Rizal Day'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 31 THEN 'Last Day of the Year'
			  END
	, [Type] = CASE WHEN dd.[Month] = 1 AND dd.[DayOfMonth] = 1 THEN 'Regular'
				   WHEN dd.[Month] = 2 AND dd.[DayOfMonth] = 10 THEN 'Special Non-Working'
				   WHEN dd.[Month] = 4 AND dd.[DayOfMonth] = 9 THEN 'Regular'
				   WHEN dd.[Month] = 5 AND dd.[DayOfMonth] = 1 THEN 'Regular'
				   WHEN dd.[Month] = 6 AND dd.[DayOfMonth] = 12 THEN 'Regular'
				   WHEN dd.[Month] = 8 AND dd.[DayOfMonth] = 21 THEN 'Special Non-Working'
				   WHEN dd.[Month] = 8 AND dd.[DayOfMonth] = 26 THEN 'Regular'
				   WHEN dd.[Month] = 11 AND dd.[DayOfMonth] = 1 THEN 'Special Non-Working'
				   WHEN dd.[Month] = 11 AND dd.[DayOfMonth] = 2 THEN 'Special Non-Working'
				   WHEN dd.[Month] = 11 AND dd.[DayOfMonth] = 30 THEN 'Regular'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 8 THEN 'Special Non-Working'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 24 THEN 'Special Non-Working'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 25 THEN 'Regular'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 30 THEN 'Regular'
				   WHEN dd.[Month] = 12 AND dd.[DayOfMonth] = 31 THEN 'Special Non-Working'
			   END
FROM dbo.DimDate dd
WHERE
	dd.[Month] = 1 AND dd.[DayOfMonth] = 1 
	OR dd.[Month] = 2 AND dd.[DayOfMonth] = 10 
	OR dd.[Month] = 4 AND dd.[DayOfMonth] = 9 
	OR dd.[Month] = 5 AND dd.[DayOfMonth] = 1 
	OR dd.[Month] = 6 AND dd.[DayOfMonth] = 12 
	OR dd.[Month] = 8 AND dd.[DayOfMonth] = 21 
	OR dd.[Month] = 8 AND dd.[DayOfMonth] = 26 
	OR dd.[Month] = 11 AND dd.[DayOfMonth] = 1 
	OR dd.[Month] = 11 AND dd.[DayOfMonth] = 2 
	OR dd.[Month] = 11 AND dd.[DayOfMonth] = 30 
	OR dd.[Month] = 12 AND dd.[DayOfMonth] = 8 
	OR dd.[Month] = 12 AND dd.[DayOfMonth] = 24 
	OR dd.[Month] = 12 AND dd.[DayOfMonth] = 25 
	OR dd.[Month] = 12 AND dd.[DayOfMonth] = 30 
	OR dd.[Month] = 12 AND dd.[DayOfMonth] = 31 




-- Moving Holidays (Holy Week) 
/*
	Context:
		Easter is a moving feast which may happen any time between March 22 and April 25.
		For this reason, it is not practical to populate the Lenten Holidays every year.
		https://en.wikipedia.org/wiki/Date_of_Easter offers various algorithms to compute the date of Easter Sunday.
		The code below follows the Anonymous Gregorian algorithm found in the aforesaid wikipage.

*/

;WITH ComputationCTE AS (
		SELECT
		Year
		, a = [Year]%19
		, b = [Year]/100
		, c = [Year]%100
		, d = [Year]/400
		, e = ([Year]/100) % 4
		, f = ([Year]/100 + 8)/25
	FROM dbo.DimDate
	GROUP BY Year
)

, ComputationCTE2 AS (
	SELECT
	*
	, g = (8*b+13)/25
	, h = (19*a + b - d - ((b - f + 1)/3) + 15 ) % 30
	, i = c/4
	, k = c % 4
	FROM ComputationCTE 
)

, ComputationCTE3 AS (
	SELECT 
		*
		, l = (32 + 2*e + 2*i - h -k)%7
	FROM ComputationCTE2
)

, ComputationCTE4 AS (
	SELECT
		*
		, m = (a + 11*h + 19*l)/453
	FROM ComputationCTE3
)

, ComputationCTE5 AS (
	SELECT
		*
		, n = (h + l - 7*m +90)/25 -- Month when Easter Sunday occurs
	FROM ComputationCTE4
)

, ComputationCTE6 AS (
	SELECT
		*
		, p = (h + l - 7*m + 33*n + 19)%32 -- Day of Easter Sunday
	FROM ComputationCTE5
)

, ComputationCTE7 AS (
	SELECT 
		*
		, EasterSundayDate = DATEFROMPARTS([Year], n, p)
	FROM ComputationCTE6
)

, LentenHolidays AS ( 
SELECT  [Date] = EasterSundayDate, [Name] = 'Easter Sunday', [Type] = 'Regular'
FROM ComputationCTE7
UNION ALL 
SELECT  [Date] = DATEADD(day, -1, EasterSundayDate) , [Name] = 'Black Saturday', [Type] = 'Special Non-Working'
FROM ComputationCTE7
UNION ALL 
SELECT  [Date] = DATEADD(day, -2, EasterSundayDate) , [Name] = 'Good Friday', [Type] = 'Regular'
FROM ComputationCTE7
UNION ALL 
SELECT  [Date] = DATEADD(day, -3,  EasterSundayDate) , [Name] = 'Good Saturday', [Type] = 'Regular'
FROM ComputationCTE7 
)

-- Populate DimHoliday Table with lenten holidays
INSERT INTO dbo.DimHoliday
SELECT
	DateKey = dd.DateKey
	, [Name] = lh.[Name]
	, [Type] = lh.[Type]
FROM LentenHolidays lh
INNER JOIN dbo.DimDate dd ON dd.Date = lh.Date



-- Check Values of DimHoliday Table
SELECT TOP(50) * FROM dbo.DimHoliday
