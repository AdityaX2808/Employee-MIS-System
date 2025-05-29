INSERT INTO Salaries (Emp_ID, Basic_Pay, HRA, DA, Other_Allowances, Effective_From, Effective_To)
SELECT Emp_ID,
       30000 + (ROWNUM * 1000),
       5000 + (ROWNUM * 100),
       4000 + (ROWNUM * 100),
       2000 + (ROWNUM * 100),
       DATE '2024-01-01',
       NULL
FROM (
    SELECT Emp_ID FROM Employees WHERE ROWNUM <= 15
);