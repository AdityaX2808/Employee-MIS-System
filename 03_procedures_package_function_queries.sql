-- 1. Create a Function: FUNC_CALC_NET_PAY
CREATE OR REPLACE FUNCTION FUNC_CALC_NET_PAY (
  p_basic     NUMBER,
  p_hra       NUMBER,
  p_da        NUMBER,
  p_other     NUMBER,
  p_deduct    NUMBER
) RETURN NUMBER IS
BEGIN
  RETURN (p_basic + p_hra + p_da + p_other) - p_deduct;
END;
/


-- 2. Create a Procedure: PROC_PAYROLL_GEN
CREATE OR REPLACE PROCEDURE PROC_PAYROLL_GEN IS
  CURSOR sal_cursor IS
    SELECT s.Emp_ID, s.Basic_Pay, s.HRA, s.DA, s.Other_Allowances
    FROM Salaries s
    WHERE s.Effective_To IS NULL;

  v_gross     NUMBER;
  v_net       NUMBER;
  v_deduction NUMBER := 2000;  -- Fixed deduction
BEGIN
  FOR rec IN sal_cursor LOOP
    v_gross := rec.Basic_Pay + rec.HRA + rec.DA + rec.Other_Allowances;
    v_net   := FUNC_CALC_NET_PAY(rec.Basic_Pay, rec.HRA, rec.DA, rec.Other_Allowances, v_deduction);

    INSERT INTO Payroll (Emp_ID, Pay_Period, Gross_Salary, Total_Deductions, Net_Pay, Pay_Date)
    VALUES (rec.Emp_ID, TO_CHAR(SYSDATE, 'YYYY-MM'), v_gross, v_deduction, v_net, SYSDATE);
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('✅ Payroll generated using FUNC_CALC_NET_PAY.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
END;
/


-- 3. Create a Package: PKG_EMP_PAYROLL
CREATE OR REPLACE PACKAGE PKG_EMP_PAYROLL IS
  TYPE ref_cursor IS REF CURSOR;

  FUNCTION CALC_NET (
    p_basic     NUMBER,
    p_hra       NUMBER,
    p_da        NUMBER,
    p_other     NUMBER,
    p_deduct    NUMBER
  ) RETURN NUMBER;

  PROCEDURE PAYROLL_BATCH;

  FUNCTION GET_EMP_CURSOR(p_status VARCHAR2) RETURN ref_cursor;

END PKG_EMP_PAYROLL;
/


-- 4. Package Body: PKG_EMP_PAYROLL
CREATE OR REPLACE PACKAGE BODY PKG_EMP_PAYROLL IS

  FUNCTION CALC_NET (
    p_basic     NUMBER,
    p_hra       NUMBER,
    p_da        NUMBER,
    p_other     NUMBER,
    p_deduct    NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN (p_basic + p_hra + p_da + p_other) - p_deduct;
  END;

  PROCEDURE PAYROLL_BATCH IS
    CURSOR c1 IS
      SELECT s.Emp_ID, s.Basic_Pay, s.HRA, s.DA, s.Other_Allowances
      FROM Salaries s
      WHERE s.Effective_To IS NULL;

    v_gross     NUMBER;
    v_net       NUMBER;
    v_deduct    NUMBER := 2000;

  BEGIN
    FOR emp IN c1 LOOP
      v_gross := emp.Basic_Pay + emp.HRA + emp.DA + emp.Other_Allowances;
      v_net := CALC_NET(emp.Basic_Pay, emp.HRA, emp.DA, emp.Other_Allowances, v_deduct);

      INSERT INTO Payroll (Emp_ID, Pay_Period, Gross_Salary, Total_Deductions, Net_Pay, Pay_Date)
      VALUES (emp.Emp_ID, TO_CHAR(SYSDATE, 'YYYY-MM'), v_gross, v_deduct, v_net, SYSDATE);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Payroll inserted via PKG_EMP_PAYROLL.PAYROLL_BATCH');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('❌ Failed: ' || SQLERRM);
  END;

  FUNCTION GET_EMP_CURSOR(p_status VARCHAR2) RETURN ref_cursor IS
    v_ref_cursor ref_cursor;
  BEGIN
    OPEN v_ref_cursor FOR
      SELECT * FROM Employees e
      WHERE EXISTS (
        SELECT 1 FROM Attendance a
        WHERE a.Emp_ID = e.Emp_ID AND a.Status = p_status
      );
    RETURN v_ref_cursor;
  END;

END PKG_EMP_PAYROLL;
/



--  Test the Package
-- Call payroll batch via package
EXEC PKG_EMP_PAYROLL.PAYROLL_BATCH;

-- Use the function directly
SELECT PKG_EMP_PAYROLL.CALC_NET(30000, 5000, 4000, 2000, 2000) AS Net_Pay FROM DUAL;

-- Use ref cursor
DECLARE
  v_ref_cursor PKG_EMP_PAYROLL.ref_cursor;
  v_emp Employees%ROWTYPE;
BEGIN
  -- Open the REF CURSOR by calling the package function
  v_ref_cursor := PKG_EMP_PAYROLL.GET_EMP_CURSOR('Absent');

  -- Loop to fetch all rows
  LOOP
    FETCH v_ref_cursor INTO v_emp;
    EXIT WHEN v_ref_cursor%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Absent Employee: ' || v_emp.First_Name || ' ' || v_emp.Last_Name);
  END LOOP;

  CLOSE v_ref_cursor;
END;
/