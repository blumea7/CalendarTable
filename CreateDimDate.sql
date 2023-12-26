
USE CalendarTable
GO

-- Change default settings of MSSQL

SET DATEFIRST 7 -- 1 = Monday, 7 -- Sunday
SET DATEFORMAT ymd -- yyyy/mm/dd
SET LANGUAGE US_ENGLISH

DROP TABLE IF EXISTS dbo.DimDate

-- Create Date Dimension Table

CREATE TABLE dbo.DimDate (
	DateKey char(8) -- 20230101
	, [Date] date UNIQUE NOT NULL -- 2023-01-01
	, [Year] int NOT NULL -- 2023
	, YearHalfID char(6) NOT NULL -- 2023H1
	, YearHalf int NOT NULL -- 1 or 2
	, QuarterID char(6) NOT NULL -- 2023Q1
	, [Quarter] int NOT NULL -- 1, 2, 3, 4
	, MonthID char(6) NOT NULL -- 202301 
	, [Month] int NOT NULL -- 1 to 12
	, [MonthName] varchar(10)  NOT NULL -- JANUARY TO DECEMBER
	, ShortMonthName char(3) NOT NULL -- JAN TO DEC
	, WeekID char(7) NOT NULL -- 2023W01 
	, WeekofYear int NOT NULL -- 1 to 53
	, WeekofMonth int NOT NULL -- 1, 2, 3, 4, 5, 6
	, [DayOfYear] int NOT NULL -- 1 to 366
	, [DayOfMonth] int NOT NULL -- 1 to 31
	, [DayOfWeek] int NOT NULL -- 1 to 7
	, [DayName] varchar(10) NOT NULL -- SUNDAY TO SATURDAY
	, ShortDayName char(3) NOT NULL -- SUN TO SAT
	CONSTRAINT PK_DimDate_DateKey PRIMARY KEY CLUSTERED (DateKey ASC)
)

-- Declare start and end dates
DECLARE @start_date date = '2024-01-01'
DECLARE @end_date date = DATEADD(DAY, -1, DATEADD(YEAR, 1, @start_date)) -- 2024-12-31

-- Generate Set of Dates from 2024-01-01 to 2024-12-31
;WITH DatesCTE AS (
	SELECT
		[Date] = DATEADD(day, n.N, @start_date) 
	FROM dbo.Numbers n
	WHERE n.N <= DATEDIFF(day, @start_date, @end_date) 
)

-- Create a supplementary CTE dependent on DatesCTE, used as intermediary container for computation of 
-- date components to derive all values of columns of DimDate Table

, DateVariablesCTE AS (
SELECT 
	[Date]
	, MonthNum = RIGHT(('00' + CAST(DATEPART(m,[Date]) AS varchar)), 2)
	, DayNum = RIGHT(('00'+CAST(DATEPART(d,[Date]) AS varchar)),2)
	, [Year] = CAST(DATEPART(yy, [Date]) AS varchar)
	, YearHalfChar = CASE WHEN DATEPART(m, [Date]) <= 6 THEN 'H1' ELSE 'H2' END
	, YearHalfInt = CASE WHEN DATEPART(m, [Date]) <= 6 THEN 1 ELSE 2 END
	, QuarterChar = 'Q' + CAST(DATEPART(q, [Date]) AS varchar)
	, [MonthName] = UPPER(DATENAME(month, [Date]))
	, WeekofYearChar = 'W' + RIGHT('00'+CAST(DATEPART(wk, [Date]) AS varchar),2)
	, WeekOfYearInt = DATEPART(wk, [Date])
		/*
			Sample values of computation of WeekOfMonth
			Var	or Statement		|	Value		|	Description or Comment
			===============================================================
			[Date]	     		    | 2024-12-31	| Date currently being considered
			EOMONTH([Date],-1)      | 2024-11-30	| 2nd argumnet represents the months before or after the first argument.
									|				| So in words, this statement is equivalent to End of Month of 1 month prior 2010-12
									|				| or End of Month of 2009-11
			StartOfMonth            | 2010-12-01	| Add 1 day to EOMONTH(@iterator,-1) 
			BaselineWeek			| 49			| Week of Year of 2010-12-01
			WeekOfMonth 			| 5				| Week of Month of 2010-12-31
		*/
	, StartofMonth = DATEADD(Day, 1, EOMONTH([Date],-1))
	, BaselineWeek = DATEPART(wk, DATEADD(Day, 1, EOMONTH([Date],-1))) -- BaselineWeek = DATEPART(wk, StartofMonth)
	, [DayName] = UPPER(DATENAME(dw, [Date]))

FROM DatesCTE
)

-- Populate DimDate table 

INSERT INTO dbo.DimDate
SELECT
	DateKey = CONCAT([Year], MonthNum, DayNum)
	, [Date] = [Date]
	, [Year] = DATEPART(yyyy, [Date])
	, YearHalfID = CONCAT([Year], YearHalfChar)
	, YearHalf = [YearHalfInt]
	, QuarterID = CONCAT([Year], QuarterChar)
	, [Quarter] = DATEPART(q, [Date])
	, MonthID = CONCAT([Year], MonthNum)
	, [Month] = DATEPART(m, [Date])
	, [MonthName] = [MonthName]
	, ShortMonthName = LEFT([MonthName],3)
	, WeekID = CONCAT([Year], WeekofYearChar)
	, WeekOfYear = WeekOfYearInt
	, WeekOfMonth = WeekOfYearInt - BaselineWeek + 1
	, [DayOfYear] = DATEPART(dy, [Date]) 
	, [DayOfMonth] = DATEPART(d, [Date])
	, [DayOfWeek] = DATEPART(dw, [Date])
	, [DayName] = [DayName]
	, ShortDayName = LEFT([DayName],3)
FROM DateVariablesCTE 



/*
Same calendar table but using an iterator: 

DECLARE @start_date date = '2024-01-01'
DECLARE @end_date date = DATEADD(DAY, -1, DATEADD(YEAR, 1, @start_date)) -- 2024-12-31
DECLARE @iterator date = @start_date

-- Populate the Date Dimension Table
WHILE @iterator <= @end_date
	BEGIN
		DECLARE @month_num char(2) = RIGHT(('00' + CAST(DATEPART(m,@iterator) AS varchar)), 2)
		DECLARE @day_num char(2) = RIGHT(('00'+CAST(DATEPART(d,@iterator) AS varchar)),2)
		DECLARE @year char(4) = CAST(DATEPART(yy,@iterator) AS varchar)
		DECLARE @year_half char(2) = CASE WHEN DATEPART(m,@iterator) <= 6 THEN '01'
								     ELSE '02'				
									 END
	
		DECLARE @year_half_int int = CASE WHEN DATEPART(m,@iterator) <= 6 THEN 1	
									 ELSE 2
									 END

		DECLARE @quarter char(2)=  'Q' + CAST(DATEPART(q, @iterator) AS varchar)
		DECLARE @week_of_year char(3) = 'W' + RIGHT('00'+CAST(DATEPART(wk, @iterator) AS varchar),2)
		
		/*
			Sample values of an iteration for computation of @week_of_month: 

			Var	or Statement		|	Value		|	Description or Comment
			===============================================================
			@itertor			    | 2024-12-31	| Date currently being iterated
			EOMONTH(@iterator,-1)   | 2024-11-30	| 2nd argumnet represents the months before or after the first argument.
									|				| So in words, this statement is equivalent to End of Month of 1 month prior 2010-12
									|				| or End of Month of 2009-11
			@start_of_month         | 2024-12-01	| Add 1 day to EOMONTH(@iterator,-1) 
			@baseline_week			| 49			| Week of Year of 2010-12-01
			@week_of_iterator		| 53			| Week of Year of 210-12-31
			@week_of_month			| 5				| Week of Month of 2010-12-31
		*/

		-- Start of Computation for @week_of_month
		DECLARE @start_of_month date = DATEADD(d, 1, EOMONTH(@iterator,-1))
		DECLARE @baseline_week int = DATEPART(wk, @start_of_month)
		DECLARE @week_of_iterator int = DATEPART(wk, @iterator)
		DECLARE @week_of_month int = @week_of_iterator - @baseline_week + 1
		-- End of computation for @week_of_month


		INSERT INTO dbo.DimDate 
		VALUES(
			CONCAT(@year, @month_num, @day_num) -- DateKey
			, @iterator -- Date
			, DATEPART(yyyy,@iterator) -- Year
			, @year + @year_half -- YearHalfID
			, @year_half_int -- YearHalf 
			, @year + @quarter -- QuarterID
			, DATEPART(q, @iterator) -- Quarter
			, @year + @month_num -- MonthID
			, DATEPART(m,@iterator) -- Month
			, UPPER(DATENAME(month, @iterator)) -- MonthName
			, UPPER(LEFT(DATENAME(month, @iterator),3)) -- ShortMonthName
			, @year + @week_of_year -- WeekID
			, DATEPART(wk, @iterator) -- WeekofYear
			, @week_of_month -- WeekofMonth
			, DATEPART(dy, @iterator) -- DayofYear
			, DATEPART(d, @iterator) -- DayofMonth
			, DATEPART(dw, @iterator) -- DayofWeek
			, UPPER(DATENAME(dw, @iterator)) -- DayName
			, UPPER(LEFT(DATENAME(dw, @iterator),3)) -- ShortDayName
		)
		SET @iterator = DATEADD(day, 1,  @iterator)
	END
*/



