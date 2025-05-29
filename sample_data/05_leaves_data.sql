-- Leaves
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO Leaves (Emp_ID, Leave_Date, Leave_Type, Reason, Approved_By)
    VALUES (i, DATE '2025-04-15', 'Sick Leave', 'Fever', 1);
  END LOOP;
END;
/