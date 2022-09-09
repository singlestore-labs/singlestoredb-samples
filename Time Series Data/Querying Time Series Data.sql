-- documentation link: https://docs.singlestore.com/managed-service/en/developer-resources/functional-extensions/analyzing-time-series-data.html

-- Database Configuration

create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS turbine_reading;
DROP TABLE IF EXISTS turbine;

-- Create table

CREATE TABLE turbine_reading(
  tid int NOT NULL, -- turbine ID
  ts datetime(6) NOT NULL,
  rpm double,
  temperature double,
  vibration double,
  output double,
  wind_direction double,
  wind_speed double,
  SHARD(tid),
  KEY(ts)
);

-- For descriptive property information about time series elements that is static
-- from one element to the next, it’s recommended to normalize this information into another table. 
-- For example, information about individual turbines could be kept in a separate table like this:

CREATE REFERENCE TABLE turbine(
  tid int,
  name varchar(60),
  model varchar(60),
  max_output double,
  lattitude double,
  longitude double,
  PRIMARY KEY(tid)
);

-- Insert values
INSERT turbine_reading VALUES
  (1, '2020-03-14 13:00:33', 10, 33, 100, 1000000, 90, 15),
  (1, '2020-03-14 13:00:34', 10, 33, 100, 1000000, 90, 15),
  (1, '2020-03-14 13:00:35', 11, 33, 105, 1050000, 91, 16),
  (1, '2020-03-14 13:00:36', 11, 33.1, 104, 1000000, 90, 16),
  (2, '2020-03-14 13:00:33', 18, 30, 170, 2000000, 0, 23),
  (2, '2020-03-14 13:00:34', 18, 30, 170, 2000000, 0, 23),
  (2, '2020-03-14 13:00:35', 18.5, 30, 176, 2050000, 0, 23.5),
  (2, '2020-03-14 13:00:36', 19, 30.1, 174, 2070000, 1, 23.6),
  (1, '2020-03-15 13:00:33', 11, 32, 99, 1010000, 45, 15.1),
  (1, '2020-03-15 13:00:34', 11, 32, 99, 1020000, 45, 15.2),
  (1, '2020-03-15 13:00:35', 12, 32.1, 101, 1030000, 45, 15.2),
  (1, '2020-03-15 13:00:36', 13, 32.15, 102, 1030000, 46, 15.2);

INSERT INTO turbine VALUES
  (1, 'Hood River A', 'Volkswind Mega 5', 5.0, 47.130, 113.187),
  (2, 'Hood River B', 'Volkswind Mega 5+', 5.3, 47.141, 113.199);

-- average RPM by turbine
SELECT tid, AVG(rpm)
FROM turbine_reading
GROUP BY tid;

-- Time Bucketing

-- Find high, low, and average output for each turbine, bucketed by day,
-- sorted by day.
SELECT tid, ts :> date, MIN(output), MAX(output), AVG(output)
FROM turbine_reading
GROUP by 1, 2
ORDER BY 1, 2;

-- Find high, low, and average output for each turbine,
-- bucketed by three second intervals, sorted by interval start time.

SELECT tid,
       from_unixtime(unix_timestamp(ts) DIV 3 * 3) as ts,
       MIN(output), MAX(output), AVG(output)
FROM turbine_reading
GROUP by 1, 2
ORDER BY 1, 2;

-- use the TIME_BUCKET aggregate function to normalize time to the nearest bucket start time.
-- The following example uses TIME_BUCKET to find the average time series value grouped by 5 day intervals:

SELECT tid, TIME_BUCKET("5d", ts), AVG(output) FROM turbine_reading GROUP BY 1, 2 ORDER BY 1, 2;

-- Smoothing
-- Time series can be smoothed using AVG as a windowed aggregate. 
-- For example, the following query yields output and the moving average of output over a two-element window, 
-- on a specified date.

SELECT tid, ts, output, AVG(output) OVER w
FROM turbine_reading
WHERE DATE(ts) = '2020-03-14'
WINDOW w as (PARTITION BY tid ORDER BY ts
             ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
ORDER BY 1, 2;

-- Finding a Row Current AS OF a Point in Time

-- A common operation on time series data is to find the row that is current AS OF a point in time.
-- You can do this with a query that uses ORDER BY and LIMIT as follows.

-- find turbine reading for tid 1 that is current
-- AS OF 2020-03-14 13:00:35.5
SELECT *
FROM turbine_reading
WHERE ts <= '2020-03-14 13:00:35.5'
AND tid = 1
ORDER BY ts DESC
LIMIT 1;

-- To find the current row for each turbine as of a specific point in time, 
-- you can use a stored procedure, as shown below.

DELIMITER //
CREATE OR REPLACE PROCEDURE get_turbine_readings_as_of(_ts datetime(6))
AS
DECLARE
  q_turbines QUERY(tid int) = SELECT tid FROM turbine;
  a ARRAY(RECORD(tid int));
  _tid int;
BEGIN
  DROP TABLE IF EXISTS r;
  CREATE TEMPORARY TABLE r LIKE turbine_reading;

  a = COLLECT(q_turbines);
  FOR x IN a LOOP
    _tid = x.tid;
    INSERT INTO r
      SELECT *
      FROM turbine_reading t
      WHERE t.tid = _tid
      AND ts <= _ts
      ORDER BY ts DESC
      LIMIT 1;
  END LOOP;
  ECHO SELECT * FROM r ORDER BY tid;
  DROP TABLE r;
END //
DELIMITER ;

CALL get_turbine_readings_as_of('2020-03-14 13:00:35.5');
