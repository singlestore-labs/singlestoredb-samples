/* Learn about use cases with the ANY_VALUE function \
An aggregate function that arbitrarily picks one value from the group. This can include a NULL value if one is present in the group.
 - Aggregate Function
 - Window Function
*/

-- EXAMPLES

-- Setup
create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS employees;

-- Create Table and Insert data
CREATE TABLE employees(
emp_id NUMERIC(5),
emp_lastname VARCHAR(25),
emp_firstname VARCHAR(25),
emp_title VARCHAR(25),
dept VARCHAR(25),
emp_city VARCHAR(25),
emp_state VARCHAR(2)
);

INSERT INTO employees VALUES('014', 'Bateman', 'Patrick','Prod_Mgr', 'prod_dev', 'NYC', 'NY'),
('102', 'Karras', 'Damien', 'Doctor','R&D', 'NYC', 'NY'),
('298', 'Denbrough', 'Bill', 'Salesperson','Sales', 'Bangor', 'ME'),
('399', 'Torrance', 'Jack', 'PR Dir', 'PR','Estes Park','CO'),
('410', 'Wilkes', 'Annie', 'HR Mgr','HR','Silver Creek', 'CO'),
('110', 'Strode', 'Laurie', 'VP Sales','Sales', 'Haddonfield', 'IL'),
('312', 'Cady', 'Max', 'IT Dir', 'IT', 'New Essex','FL'),
('089', 'Whateley', 'Wilbur', 'CEO', 'Sen_Mgmt', 'Dunwich', 'MA'),
('075', 'White', 'Carrie', 'Receptionist', 'HR','Chamberlain', 'ME'),
('263', 'MacNeil', 'Regan', 'R&D Mgr','R&D', 'Washington', 'DC');

-- Aggregate Function
SELECT ANY_VALUE(emp_lastname), emp_city FROM employees GROUP BY emp_city;

-- Window Function
SELECT emp_id, any_value(emp_id) OVER (ORDER BY emp_id) FROM employees;