-- DEDUCTIONS
BEGIN
  FOR i IN 1..15 LOOP
    INSERT INTO Deductions (Emp_ID, Deduction_Type, Amount, Deduction_Date)
    VALUES (i, 'Professional Tax', 200, DATE '2025-05-25');
    INSERT INTO Deductions (Emp_ID, Deduction_Type, Amount, Deduction_Date)
    VALUES (i, 'Income Tax', 500, DATE '2025-05-25');
  END LOOP;
END;
/