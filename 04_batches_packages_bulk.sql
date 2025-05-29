-- 04_batches_packages_bulk.sql
-- Demonstrates Batches, Packages, and Bulk Processing in Employee Payroll MIS

-- ===============================
-- 1. Package Specification
-- ===============================
CREATE OR REPLACE PACKAGE pkg_payroll_bulk IS

  -- Function to calculate net pay
  FUNCTION calc_net_pay(
    p_basic   NUMBER,
    p_hra     NUMBER,
    p_da      NUMBER,
    p_other   NUMBER,
    p_deduct  NUMBER
  ) RETURN NUMBER;

  -- Procedure to generate payroll in batch (row by row)
  PROCEDURE proc_generate_payroll_batch;

  -- Procedure to generate payroll using bulk processing (bulk collect + forall)
  PROCEDURE proc_generate_payroll_bulk;

END pkg_payroll_bulk;
/
SHOW ERRORS;

-- ===============================
-- 2. Package Body
-- ===============================
CREATE OR REPLACE PACKAGE BODY pkg_payroll_bulk IS

  -- Calculate net pay function
  FUNCTION calc_net_pay(
    p_basic   NUMBER,
    p_hra     NUMBER,
    p_da      NUMBER,
    p_other   NUMBER,
    p_deduct  NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN (p_basic + p_hra + p_da + p_other) - p_deduct;
  END calc_net_pay;

  -- Row by row batch payroll generation
  PROCEDURE proc_generate_payroll_batch IS
    CURSOR cur_salary IS
      SELECT Emp_ID, Basic_Pay, HRA, DA, Other_Allowances
      FROM Salaries
      WHERE Effective_To IS NULL;

    v_gross     NUMBER;
    v_net       NUMBER;
    v_deduction NUMBER := 2000;
  BEGIN
    FOR rec IN cur_salary LOOP
      v_gross := rec.Basic_Pay + rec.HRA + rec.DA + rec.Other_Allowances;
      v_net   := calc_net_pay(rec.Basic_Pay, rec.HRA, rec.DA, rec.Other_Allowances, v_deduction);

      INSERT INTO Payroll (Emp_ID, Pay_Period, Gross_Salary, Total_Deductions, Net_Pay, Pay_Date)
      VALUES (rec.Emp_ID, TO_CHAR(SYSDATE, 'YYYY-MM'), v_gross, v_deduction, v_net, SYSDATE);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payroll generated using row-by-row batch processing.');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Error in proc_generate_payroll_batch: ' || SQLERRM);
  END proc_generate_payroll_batch;

  -- Bulk processing payroll generation
  PROCEDURE proc_generate_payroll_bulk IS
    TYPE t_emp_id_tab IS TABLE OF Salaries.Emp_ID%TYPE;
    TYPE t_num_tab    IS TABLE OF NUMBER;

    v_emp_ids    t_emp_id_tab;
    v_basic      t_num_tab;
    v_hra        t_num_tab;
    v_da         t_num_tab;
    v_other      t_num_tab;
    v_gross      t_num_tab;
    v_net        t_num_tab;
    v_deduction  NUMBER := 2000;

  BEGIN
    -- Bulk collect salary details into collections
    SELECT Emp_ID, Basic_Pay, HRA, DA, Other_Allowances
    BULK COLLECT INTO v_emp_ids, v_basic, v_hra, v_da, v_other
    FROM Salaries
    WHERE Effective_To IS NULL;

    -- Calculate gross and net pay in bulk
    v_gross := t_num_tab();
    v_net := t_num_tab();

    FOR i IN 1 .. v_emp_ids.COUNT LOOP
      v_gross.EXTEND;
      v_net.EXTEND;

      v_gross(i) := v_basic(i) + v_hra(i) + v_da(i) + v_other(i);
      v_net(i) := calc_net_pay(v_basic(i), v_hra(i), v_da(i), v_other(i), v_deduction);
    END LOOP;

    -- Bulk insert payroll records using FORALL
    FORALL i IN 1 .. v_emp_ids.COUNT
      INSERT INTO Payroll (Emp_ID, Pay_Period, Gross_Salary, Total_Deductions, Net_Pay, Pay_Date)
      VALUES (v_emp_ids(i), TO_CHAR(SYSDATE, 'YYYY-MM'), v_gross(i), v_deduction, v_net(i), SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payroll generated using BULK COLLECT and FORALL bulk processing.');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Error in proc_generate_payroll_bulk: ' || SQLERRM);
  END proc_generate_payroll_bulk;

END pkg_payroll_bulk;
/
SHOW ERRORS;


-- 3. Test the procedures
BEGIN
  DBMS_OUTPUT.PUT_LINE('Starting row-by-row payroll generation...');
  pkg_payroll_bulk.proc_generate_payroll_batch;

  DBMS_OUTPUT.PUT_LINE('Starting bulk payroll generation...');
  pkg_payroll_bulk.proc_generate_payroll_bulk;
END;
/