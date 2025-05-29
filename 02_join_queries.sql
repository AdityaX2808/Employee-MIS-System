-- Joins
-- 1. Employee with Department Info (INNER JOIN)
BEGIN
  DBMS_OUTPUT.PUT_LINE('Emp_ID | Name         | Dept      | Location');

  FOR emp_rec IN (
    SELECT e.Emp_ID, e.First_Name || ' ' || e.Last_Name AS Full_Name,
           d.Dept_Name, d.Location
    FROM Employees e
    JOIN Departments d ON e.Dept_ID = d.Dept_ID
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      emp_rec.Emp_ID || ' | ' ||
      RPAD(emp_rec.Full_Name, 12) || ' | ' ||
      RPAD(emp_rec.Dept_Name, 10) || ' | ' ||
      emp_rec.Location
    );
  END LOOP;
END;
/


-- 2. Employee Payroll Summary (Salaries + Payroll JOIN)
BEGIN
  DBMS_OUTPUT.PUT_LINE('Emp_ID | Name        | Gross | Deduct | Net');

  FOR pay_rec IN (
    SELECT e.Emp_ID, e.First_Name || ' ' || e.Last_Name AS Full_Name,
           p.Gross_Salary, p.Total_Deductions, p.Net_Pay
    FROM Employees e
    JOIN Payroll p ON e.Emp_ID = p.Emp_ID
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      pay_rec.Emp_ID || ' | ' ||
      RPAD(pay_rec.Full_Name, 12) || ' | ' ||
      LPAD(pay_rec.Gross_Salary, 6) || ' | ' ||
      LPAD(pay_rec.Total_Deductions, 6) || ' | ' ||
      LPAD(pay_rec.Net_Pay, 6)
    );
  END LOOP;
END;
/


-- 3. Leaves with Approver Info (Self-Join)
BEGIN
  DBMS_OUTPUT.PUT_LINE('Leave_ID | Employee   | Type   | Approved_By');

  FOR leave_rec IN (
    SELECT l.Leave_ID,
           e.First_Name || ' ' || e.Last_Name AS Employee,
           l.Leave_Type,
           a.First_Name || ' ' || a.Last_Name AS Approver
    FROM Leaves l
    JOIN Employees e ON l.Emp_ID = e.Emp_ID
    LEFT JOIN Employees a ON l.Approved_By = a.Emp_ID
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      leave_rec.Leave_ID || ' | ' ||
      RPAD(leave_rec.Employee, 10) || ' | ' ||
      RPAD(leave_rec.Leave_Type, 6) || ' | ' ||
      NVL(leave_rec.Approver, 'Pending')
    );
  END LOOP;
END;
/


-- 4. Department-wise Payroll Summary (GROUP BY JOIN)
BEGIN
  DBMS_OUTPUT.PUT_LINE('Dept       | Employees | Total Payout');

  FOR dept_pay IN (
    SELECT d.Dept_Name,
           COUNT(e.Emp_ID) AS Num_Employees,
           SUM(p.Net_Pay) AS Total_Payout
    FROM Departments d
    JOIN Employees e ON d.Dept_ID = e.Dept_ID
    JOIN Payroll p ON e.Emp_ID = p.Emp_ID
    GROUP BY d.Dept_Name
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      RPAD(dept_pay.Dept_Name, 10) || ' | ' ||
      LPAD(dept_pay.Num_Employees, 9) || ' | ' ||
      LPAD(dept_pay.Total_Payout, 13)
    );
  END LOOP;
END;
/