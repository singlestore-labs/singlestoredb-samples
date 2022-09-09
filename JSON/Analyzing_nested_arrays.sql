-- https://docs.singlestore.com/managed-service/en/create-a-database/physical-database-schema-design/procedures-for-physical-database-schema-design/using-json.html
-- Working with Nested Arrays in a JSON Column

-- Database Configuration

create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS json_tab;

-- Create table
CREATE TABLE json_tab (`id` INT(11) DEFAULT NULL,`jsondata` JSON COLLATE utf8_bin);

-- Insert values

INSERT INTO json_tab VALUES 
( 8765 ,' {"city":"SFO","sports_teams":[{"sport_name":"football","teams":  [{"club_name":"Raiders"},{"club_name":"49ers"}]},
{"sport_name":"baseball","teams" : [{"club_name":"As"},{"club_name":"SF Giants"}]}]}') ; 

INSERT INTO json_tab VALUES 
( 9876,'{"city":"NY","sports_teams" : [{ "sport_name":"football","teams" : [{ "club_name":"Jets"},{"club_name":"Giants"}]},
{"sport_name":"baseball","teams" : [ {"club_name":"Mets"},{"club_name":"Yankees"}]},
{"sport_name":"basketball","teams" : [{"club_name":"Nets"},{"club_name":"Knicks"}]}]}');

-- Query Table as is

select * from json_tab

-- Query Table by flattening the arrays using JSON_TO_ARRAY

WITH t AS(
SELECT id, jsondata::city city , table_col AS sports_clubs FROM json_tab JOIN TABLE(JSON_TO_ARRAY(jsondata::sports_teams))),
t1 AS(
SELECT t.id, t.city, t.sports_clubs::sport_name sport, table_col AS clubs FROM t JOIN TABLE(JSON_TO_ARRAY(t.sports_clubs::teams)))
SELECT t1.id, t1.city,t1.sport,t1.clubs::club_name club_name FROM t1;

-- Query Table by flattening the arrays using JSON_TO_ARRAY with filtering on club_name

WITH t AS
(SELECT id, jsondata::city city , table_col AS sports_clubs FROM json_tab JOIN TABLE(JSON_TO_ARRAY(jsondata::sports_teams))),
t1 AS
(SELECT t.id, t.city, t.sports_clubs::sport_name sport, table_col AS clubs FROM t JOIN TABLE(JSON_TO_ARRAY(t.sports_clubs::teams))) 
SELECT t1.id, t1.city,t1.sport,t1.clubs::club_name club_name FROM t1 WHERE t1.clubs::$club_name = 'Yankees';