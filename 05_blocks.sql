-- 05_blocks.sql
-- Demonstration of Anonymous and Named PL/SQL Blocks
-- Using Employee Payroll MIS example

-- ============================================
-- 1. Anonymous Block: Simple payroll calculation
-- ============================================

DECLARE
  v_emp_id      Employees.Emp_ID%TYPE := 101;
  v_basic       Salaries.Basic_Pay%TYPE;
  v_hra         Salaries.HRA%TYPE;
  v_da          Salaries.DA%TYPE;
  v_other       Salaries.Other_Allowances%TYPE;
  v_deduct      NUMBER := 2000;
  v_gross       NUMBER;
  v_net         NUMBER;
BEGIN
  -- Fetch salary components for employee 101
  SELECT Basic_Pay, HRA, DA, Other_Allowances
  INTO v_basic, v_hra, v_da, v_other
  FROM Salaries
  WHERE Emp_ID = v_emp_id AND Effective_To IS NULL;

  -- Calculate gross and net pay
  v_gross := v_basic + v_hra + v_da + v_other;
  v_net := v_gross - v_deduct;

  DBMS_OUTPUT.PUT_LINE('Anonymous Block: Payroll for Employee ' || v_emp_id);
  DBMS_OUTPUT.PUT_LINE('Gross Salary: ' || v_gross);
  DBMS_OUTPUT.PUT_LINE('Net Salary: ' || v_net);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No salary data found for Employee ' || v_emp_id);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- ============================================
-- 2. Named Block: Procedure to calculate and print payroll
-- ============================================

CREATE OR REPLACE PROCEDURE print_employee_payroll (p_emp_id IN NUMBER) IS
  v_basic       Salaries.Basic_Pay%TYPE;
  v_hra         Salaries.HRA%TYPE;
  v_da          Salaries.DA%TYPE;
  v_other       Salaries.Other_Allowances%TYPE;
  v_deduct      NUMBER := 2000;
  v_gross       NUMBER;
  v_net         NUMBER;
BEGIN
  SELECT Basic_Pay, HRA, DA, Other_Allowances
  INTO v_basic, v_hra, v_da, v_other
  FROM Salaries
  WHERE Emp_ID = p_emp_id AND Effective_To IS NULL;

  v_gross := v_basic + v_hra + v_da + v_other;
  v_net := v_gross - v_deduct;

  DBMS_OUTPUT.PUT_LINE('Named Block (Procedure): Payroll for Employee ' || p_emp_id);
  DBMS_OUTPUT.PUT_LINE('Gross Salary: ' || v_gross);
  DBMS_OUTPUT.PUT_LINE('Net Salary: ' || v_net);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No salary data found for Employee ' || p_emp_id);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END print_employee_payroll;
/
SHOW ERRORS;

-- ============================================
-- 3. Calling the Named Block Procedure
-- ============================================

BEGIN
  print_employee_payroll(101);
END;
/