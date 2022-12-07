/* Learn about use cases with the count function 
 - Aggregate Function
 - Window Function
 - Window Frame Clause
*/

-- EXAMPLES

-- Setup
create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS equipment;

-- Create Table
CREATE TABLE equipment(
equip_id INT,
equip_type VARCHAR(50),
manufacturer VARCHAR(50),
model VARCHAR(25),
model_number VARCHAR (10),
purchase_yr VARCHAR (4),
quantity INT,
per_item_cost DECIMAL(12,2)
);

INSERT INTO equipment values('1100', 'switch', 'Cisco', 'Catalyst', '9500', '2021', '3', '18110.00'),
('2100', 'access point', 'Cisco', 'Catalyst', '9150', '2022', '22', '2095.00'),
('4100', 'switch', 'Juniper', 'EX', '3300', '2019', '42', '450.00'),
('5200', 'server', 'Dell', 'PowerEdge MX', '7000', '2021', '14', '7250.00');

-- Aggregate Function
SELECT COUNT(*) FROM equipment;
SELECT COUNT(manufacturer) AS company FROM equipment;
SELECT COUNT(DISTINCT manufacturer) AS company FROM equipment;

-- Window Function
SELECT equip_id, equip_type, quantity, COUNT(*) OVER (ORDER BY equip_id) AS 
     COUNT FROM equipment ORDER BY equip_id;
     
-- Window Frame Clause
SELECT equip_type, quantity, per_item_cost,
COUNT(*) OVER (ORDER BY quantity RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
AS total_count FROM equipment;