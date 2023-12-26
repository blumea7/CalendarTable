USE CalendarTable
GO

/*

Create Source of Numbers which will be later on used in creating DimDate Table.
Numbers table can be used in other purposes like Splitting Strings, Sequence Generation, Debugging and Testing among others
so a separated table for it was created rather than referencing a CTE containing the numbers

*/


DECLARE @num_limit int = 1000000

;WITH NumbersCTE AS ( -- Generate set of Numbers from 0 to 1000000
	SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1 AS N 
	FROM sys.all_columns sac1 CROSS JOIN sys.all_columns sac2
)

-- Populate the set of numbers into the table named Numbers
SELECT ncte.N
INTO dbo.Numbers -- this will automatically create a table named Numbers
FROM NumbersCTE ncte 
WHERE ncte.N <= @num_limit

CREATE UNIQUE CLUSTERED INDEX CIDX_Numbers_N ON dbo.Numbers(N)



-- Check Values of Numbers Table
SELECT TOP(10) * FROM dbo.Numbers