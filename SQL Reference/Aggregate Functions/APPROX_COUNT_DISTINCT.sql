
/* Learn about use cases with the APPROX_COUNT_DISTINCT function \
An aggregate function that returns the total of non-NULL distinct values in a data set.
 - Aggregate Function
 - Window Function
*/

-- EXAMPLES

-- Setup
create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS assets;

-- Create Table and Insert data
CREATE TABLE assets(
asset_id int,
asset_type varchar(50),
asset_desc varchar(50),
asset_value decimal(6,2)
);

INSERT into assets values('1049', 'laptop', 'mac_book_pro', '1999.00'),
('49', 'cell_phone', 'iphone_12','879.00'),
('1100', 'laptop', 'mac_book_pro','1999.00'),
('2037', 'laptop', 'mac_book_air_M2','1199.00'),
('58', 'cell_phone', 'iphone_12', '879.00'),
('130', 'cell_phone', 'iphone_13', '699'),
('210', 'laptop', 'mac_book_pro','2500.00'),
('111', 'laptop', 'mac_book_pro','2100.00'),
('099', 'laptop', 'mac_book_air_M1','999'),
('140', 'cell_phone', 'iphone_13_pro','999.00');

-- Without group by
SELECT approx_count_distinct(asset_id) AS approx_distinct_asset_id 
FROM assets;

-- With group by
SELECT asset_type, APPROX_COUNT_DISTINCT(asset_id) AS approx_distinct_asset_id
FROM assets
GROUP BY asset_type;