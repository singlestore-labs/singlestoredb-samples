/* Learn about use cases with the APPROX_PERCENTILE function \
APPROX_PERCENTILE is an aggregate function that Calculates the approximate percentile for a set of values. 

APPROX_PERCENTILE executes faster than the PERCENTILE_DISC and PERCENTILE_CONT and MEDIAN functions, and is an alternative to using those functions.
APPROX_PERCENTILE is useful for workloads with large datasets that require statistical analysis.

The calculation occurs for a given percentage.
 - Aggregate Function
 - Window Function
*/

-- EXAMPLES

-- Setup
create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS courses;

-- Create Table and Insert data
CREATE TABLE courses(course_code VARCHAR(25), course_name VARCHAR(25), 
  section_number INT, students_enrolled INT);

INSERT INTO courses VALUES ('HIS-101', 'World History', '10', '65'),
('ALG_201', 'Algebra 2', '20', '35'),
('PSY-400', 'Abnormal Psychology', '20', '28'),
('SOC-200', 'Sociology 2', '20', '25'),
('SCI-101', 'Biology 1', '10', '72'),
('HIS-101', 'World History', '20', '47'),
('ALG-101', 'Algebra 1', '10', '42'),
('PSY-401', 'Abnormal Psychology', '10', '25'),
('SOC-201', 'Sociology 2', '20', '28'),
('SCI-102', 'Biology 2', '20', '91');

-- Aggregate function
-- The following example demonstrates the usage of APPROX_PERCENTILE by calculating
-- the number of students across different courses for a given percentile.
SELECT course_code, APPROX_PERCENTILE(students_enrolled, 0.65) AS "percentile"
FROM courses GROUP BY course_code;

-- The following example calculates the median of the dataset.
SELECT course_code, APPROX_PERCENTILE(students_enrolled, 0.5) AS "approx_median"
FROM courses GROUP BY course_code;

-- Window Function
SELECT DISTINCT(course_code), APPROX_PERCENTILE(students_enrolled, 0.3) OVER
  (ORDER BY course_code) AS "percentile" FROM courses;