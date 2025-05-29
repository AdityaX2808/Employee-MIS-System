-- Attendance
BEGIN
  FOR i IN 1..15 LOOP
    INSERT INTO Attendance (Emp_ID, Att_Date, Status)
    VALUES (i, DATE '2025-05-01', 'Present');
    INSERT INTO Attendance (Emp_ID, Att_Date, Status)
    VALUES (i, DATE '2025-05-02', 'Absent');
  END LOOP;
END;
/