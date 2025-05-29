-- 06_data_dictionary.sql
-- Using Data Dictionary Views to analyze Employees Payroll database objects

-- 1. List all tables owned by the current user
SELECT table_name, tablespace_name, num_rows, last_analyzed
FROM user_tables
ORDER BY table_name;

-- 2. List all columns in Employees table with data types and nullable info
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'EMPLOYEES'
ORDER BY column_id;

-- 3. List indexes on Payroll table
SELECT index_name, index_type, uniqueness, status
FROM user_indexes
WHERE table_name = 'PAYROLL';

-- 4. List constraints on Salaries table (primary key, foreign key, etc.)
SELECT constraint_name, constraint_type, status, search_condition, r_constraint_name
FROM user_constraints
WHERE table_name = 'SALARIES';

-- 5. Show dependencies of a package (e.g. PKG_PAYROLL_BULK)
SELECT referenced_owner, referenced_name, referenced_type
FROM user_dependencies
WHERE name = 'PKG_PAYROLL_BULK';

-- 6. List stored procedures/functions in your schema
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
ORDER BY object_name;

-- 7. Find the source code of a procedure/package
SELECT text
FROM user_source
WHERE name = 'PKG_PAYROLL_BULK'
ORDER BY line;

-- 8. Show all users who have created sessions currently (example for DBAs)
-- Note: Requires DBA privilege
-- SELECT username, status, osuser, machine, terminal, program
-- FROM v$session
-- WHERE username IS NOT NULL;

-- 9. Check for any invalid objects in schema
SELECT object_name, object_type, status
FROM user_objects
WHERE status = 'INVALID';

-- 10. Query to see table sizes (number of rows and size in bytes)
SELECT
  table_name,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt
FROM user_tables
ORDER BY table_name;

-- 11. List triggers on Employees table
SELECT trigger_name, status, triggering_event, description
FROM user_triggers
WHERE table_name = 'EMPLOYEES';

-- 12. View current grants on your tables
SELECT grantee, table_name, privilege, grantable
FROM user_tab_privileges
WHERE table_name IN ('EMPLOYEES', 'SALARIES', 'PAYROLL');