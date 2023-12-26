## Notes

1. All SQL scripts in this repository are written in T-SQL
2. The script for creating DimHoliday table depends on the script for creating DimDate which is dependent on the script for creating the Numbers Table.
   Therefore, you should run the scripts in the ff. order:
        1. CreateNumbers.sql
        2. CreateDimDate.sql
        3. CreateDimHoliday.sql
