## General Notes

1. All SQL scripts in this repository are written in T-SQL
2. The script for creating DimHoliday table depends on the script for creating DimDate which is dependent on the script for creating the Numbers Table.
   Therefore, you should run the scripts in the ff. order:
   1. CreateNumbers.sql
   2. CreateDimDate.sql
   3. CreateDimHoliday.sql


## Tables Documentation

### 1. dbo.Numbers Table
--------------------------------------------------------------------------

#### Description
Contains Numbers from 0 to 1,000,000; Used to perform a set-based implementation of Calendar Table.

#### Properties

|     Attribute           |     Value                      |
|-------------------------|--------------------------------|
|     Creation Date       |     12/22/2023   1:11:16 pm    |
|     File Group          |     PRIMARY                    |
|     Rows                |     1,000,001                  |
|     Data Space Used     |     16,840.00 KB               |
|     Index Space Used    |     144.00 KB                  |

#### Columns

|     Key    |     Column Name    |     Description                       |     Data Type    |     Length    |     Allow Nulls    |     References    |
|------------|--------------------|---------------------------------------|------------------|---------------|--------------------|-------------------|
|            |     N              |     Integers from 0   to 1,000,000    |     Int          |     8         |     ✓              |                   |

#### Indexes

|     Index              |     Description        |     Primary    |     Unique    |
|------------------------|------------------------|----------------|---------------|
|     CIDX_Numbers_N     |     Clustered Index    |                |     ✓         |





### 2. dbo.DimDate Table
--------------------------------------------------------------------------

#### Description
Dimension Table representing a Calendar of year 2024 which includes derived date properties.

#### Properties
|     Attribute           |     Value                    |
|-------------------------|------------------------------|
|     Creation Date       |     12/23/2023 11:56   pm    |
|     File Group          |     PRIMARY                  |
|     Rows                |     366                      |
|     Data Space Used     |     40 KB                    |
|     Index Space Used    |     32 KB                    |

#### Columns
|     Key            |     Column Name            |     Description                                                                        |     Data Type    |     Length    |     Allow Nulls    |     References        |
|--------------------|----------------------------|----------------------------------------------------------------------------------------|------------------|---------------|--------------------|-----------------------|
|     Primary Key    |     DateKey                |                                                                                        |     int          |     4         |                    |     dbo.DimHoliday    |
|                    |     Date                   |     Date in   yyyy-mm-dd format                                                        |     Date         |     3         |                    |                       |
|                    |     Year                   |     Year of the date.                                                                  |     int          |     4         |                    |                       |
|                    |     YearHalfID             |     Concatenated   string containing year and year half.                               |     char         |     6         |                    |                       |
|                    |     YearHalf               |     Identifies whether   the date belongs in the first or second half of the year.     |     int          |     4         |                    |                       |
|                    |     QuarterID              |     Concatenated   string containing year and quarter.                                 |     char         |     6         |                    |                       |
|                    |     Quarter                |     Quarter which the   date belongs ( 1 to 4).                                        |     int          |     4         |                    |                       |
|                    |     MonthID                |     Concatenated   string containing year and month.                                   |     char         |     6         |                    |                       |
|                    |     Month                  |     Month of the date   expressed in numbers from 1 to 12.                             |     int          |     4         |                    |                       |
|                    |     MonthName              |     Month of the date   in words.                                                      |     varchar      |     10        |                    |                       |
|                    |     ShortMonthName         |     Shortened month   name.                                                            |     char         |     3         |                    |                       |
|                    |     WeekID                 |     Concatenated   string containing year and week number.                             |     char         |     7         |                    |                       |
|                    |     WeekOfYear             |     Week of the year   the date falls (1 to 52 or 53).                                 |     int          |     4         |                    |                       |
|                    |     WeekOfMonth            |     Week of the month   the date falls (1 to 4, 5 or 6).                               |     int          |     4         |                    |                       |
|                    |     DayOfYear              |     Day of year the   date falls (1 to 365 or 366).                                    |     int          |     4         |                    |                       |
|                    |     DayOfMonth             |     Day of month the   date falls (1 to 28, 29, 30 or 31).                             |     int          |     4         |                    |                       |
|                    |     DayOfWeek              |     Day of week the   date falls (1 to 7).                                             |     int          |     4         |                    |                       |
|                    |     DayName                |     Month of the Day   in words                                                        |     varchar      |     10        |                    |                       |
|                    |     ShortDayName           |     Shortened day   name.                                                              |     char         |     3         |                    |                       |
|                    |     CurrentDayIndicator    |     Flags users if   the current row instance describes current date                   |     varchar      |     16        |                    |                       |


#### Indexes
|     Index                 |     Description                             |     Primary    |     Unique    |
|---------------------------|---------------------------------------------|----------------|---------------|
|     PK_DimDate_DateKey    |     Primary key (clustered)   constraint    |     ✓          |     ✓         |

#### Relationships
|     Foreign Table    |     Primary Table    |     Join                                              |     Foreign Key                      |
|----------------------|----------------------|-------------------------------------------------------|--------------------------------------|
|     DimDate          |     DimHoliday       |     dbo.DimDate.DateKey =   dbo.DimHoliday.DateKey    |     FK_DimHoliday_DimDate_DateKey    |


#### Unique Keys

|     Key Name              |     Column Name    |
|---------------------------|--------------------|
|     PK_DimDate_Datekey    |     DateKey        |




### 3. dbo.DimHoliday Table
--------------------------------------------------------------------------
#### Description
Dimension Table containing the holidays for the dates in DimDate table.

#### Properties
|     Attribute           |     Value                   |
|-------------------------|-----------------------------|
|     Creation Date       |     12/26/2023 1:07   am    |
|     File Group          |     PRIMARY                 |
|     Rows                |     19                      |
|     Data Space Used     |     8 KB                    |
|     Index Space Used    |     24 KB                   |

#### Columns
|     Key            |     Column Name    |     Description                                              |     Data Type    |     Length    |     Allow Nulls    |     References    |
|--------------------|--------------------|--------------------------------------------------------------|------------------|---------------|--------------------|-------------------|
|     Primary Key    |     HolidayID      |     Surrogate key for   unique identification of holiday.    |     int          |     4         |                    |                   |
|     Foreign Key    |     DateKey        |     Connecting key to   DimDate.                             |     int          |     4         |                    |     DimDate       |
|                    |     Name           |     Name of holiday.                                         |     char         |     50        |                    |                   |
|                    |     Type           |     Type of holiday.                                         |     varchar      |     30        |                    |                   |

#### Indexes
|     Index                      |     Description                             |     Primary    |     Unique    |
|--------------------------------|---------------------------------------------|----------------|---------------|
|     PK_DimHoliday_HolidayID    |     Primary key (clustered)   constraint    |     ✓          |     ✓         |


#### Relationships
|     Foreign Table    |     Primary Table    |     Join                                              |     Foreign Key                      |
|----------------------|----------------------|-------------------------------------------------------|--------------------------------------|
|     DimDate          |     DimHoliday       |     dbo.DimDate.DateKey =   dbo.DimHoliday.DateKey    |     FK_DimHoliday_DimDate_DateKey    |

#### Unique Keys
|     Key Name                   |     Column Name    |
|--------------------------------|--------------------|
|     PK_DimHoliday_HolidayID    |     HolidayID      |
