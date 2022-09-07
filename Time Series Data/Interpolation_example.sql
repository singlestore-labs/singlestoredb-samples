-- documentation link: https://docs.singlestore.com/managed-service/en/developer-resources/functional-extensions/analyzing-time-series-data.html

-- Database Configuration

create database if not exists documentation_s2;
use documentation_s2;
DROP TABLE IF EXISTS tick;

-- Table definition 
CREATE TABLE tick(ts datetime(6), symbol varchar(5),
   price numeric(18,4));

-- Insert sample data

INSERT INTO tick VALUES
  ('2019-02-18 10:55:36.000000', 'ABC', 100.00),
  ('2019-02-18 10:55:37.000000', 'ABC', 102.00),
  ('2019-02-18 10:55:40.000000', 'ABC', 103.00),
  ('2019-02-18 10:55:42.000000', 'ABC', 104.00);

-- Interpolation with time-series
-- Create a stored procedure to fill gaps between timestamps and then average the value between those gaps

DELIMITER //
CREATE OR REPLACE PROCEDURE driver() AS
DECLARE
  q query(ts datetime(6), symbol varchar(5), price numeric(18,4));
BEGIN
  q = SELECT ts, symbol, price FROM tick ORDER BY ts;
  ECHO SELECT 'Input time series' AS message;
  ECHO SELECT * FROM q ORDER BY ts;
  ECHO SELECT 'Interpolated time series' AS message;
  CALL interpolate_ts(q);
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE interpolate_ts(
  q query(ts datetime(6), symbol varchar(5), price numeric(18,4)))
    -- Important: q must produce sorted output by ts
AS
DECLARE
  c array(record(ts datetime(6), symbol varchar(5), price numeric(18,4)));
  r record(ts datetime(6), symbol varchar(5), price numeric(18,4));
  r_next record(ts datetime(6), symbol varchar(5), price numeric(18,4));
  n int;
  i int;
  _ts datetime(6); _symbol varchar(5); _price numeric(18,4);
  time_diff int;
  delta numeric(18,4);
BEGIN
  DROP TABLE IF EXISTS tmp;
  CREATE TEMPORARY TABLE tmp LIKE tick;
  c = collect(q);
  n = length(c);
  IF n < 2 THEN
    ECHO SELECT * FROM q ORDER BY ts;
    return;
  END IF;

  i = 0;
  r = c[i];
  r_next = c[i + 1];

  WHILE (i < n) LOOP
    -- IF at last row THEN output it and exit
    IF i = n - 1 THEN
      _ts = r.ts; _symbol = r.symbol; _price = r.price;
      INSERT INTO tmp VALUES(_ts, _symbol, _price);
      i += 1;
      CONTINUE;
    END IF;

    time_diff = unix_timestamp(r_next.ts) - unix_timestamp(r.ts);

    IF time_diff <= 0 THEN
      RAISE user_exception("time series not sorted or has duplicate timestamps");
    END IF;

    -- output r
    _ts = r.ts; _symbol = r.symbol; _price = r.price;
    INSERT INTO tmp VALUES(_ts, _symbol, _price);

    IF time_diff = 1 THEN
      r = r_next; -- advance to next row
    ELSIF time_diff > 1 THEN
      -- output time_diff-1 rows by extending current row and interpolating price
      delta = (r_next.price - r.price) / time_diff;
      FOR j in 1..time_diff-1 LOOP
        _ts += 1; _price += delta;
        INSERT INTO tmp VALUES(_ts, _symbol, _price);
      END LOOP;
      r = r_next; -- advance to next row
    ELSE
      RAISE user_exception("time series not sorted");
    END IF;

    i += 1;
    IF i < n - 1 THEN r_next = c[i + 1]; END IF;
  END LOOP;
  ECHO SELECT * FROM tmp ORDER BY ts;
  DROP TABLE tmp;
END //
DELIMITER ;

-- Call the stored procedure driver to see the result

CALL driver();