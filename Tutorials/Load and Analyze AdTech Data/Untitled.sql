/* In this tutorial, we will create a database to ingest millions of simulated Ad Campaign events from a Kafka workspace. 
We will then use a dashboard tool to connect to the database to visualize and analyze the event data. */

-- Create a database called adtech with two tables: events and campaigns.

CREATE DATABASE IF NOT EXISTS adtech;
USE adtech;

-- The events table is a columnstore table containing information about the advertiser, campaign and demographic information about the user.
CREATE TABLE events (
    user_id int,
    event_name varchar(128),
    advertiser varchar(128),
    campaign int(11),
    gender varchar(128),
    income varchar(128),
    page_url varchar(128),
    region varchar(128),
    country varchar(128),
    SORT KEY adtmidx (user_id, event_name, advertiser, campaign),
    SHARD KEY user_id (user_id)
);

-- The campaigns table is a small reference rowstore table.

CREATE REFERENCE TABLE campaigns (
    campaign_id smallint(6) NOT NULL DEFAULT '0',
    campaign_name varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
    PRIMARY KEY (campaign_id)
);

-- we now insert the names of the 14 ad campaigns that are currently running into the campaigns table.

INSERT INTO `campaigns` VALUES (1,'demand great'),(2,'blackout'),(3,'flame broiled'),(4,'take it from a fish'),(5,'thank you'),
(6,'designed by you'),(7,'virtual launch'),(8,'ultra light'),(9,'warmth'),(10,'run healthy'),(11,'virtual city'),(12,'online lifestyle'),
(13,'dream burger'),(14,'super bowl tweet');


/* This query will create a pipeline to ingest event data from a Kafka workspace into the events table. 
The BATCH_INTERVAL has been set to 2500 milliseconds to slow down and simulate event data.
You can change this interval to increase or decrease the data ingestion rate. */

CREATE PIPELINE events
AS LOAD DATA KAFKA 'public-kafka.memcompute.com:9092/ad_events'
BATCH_INTERVAL 2500
INTO TABLE events
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY ''
(user_id,event_name,advertiser,campaign,gender,income,page_url,region,country);

/* Configure the pipeline to start reading from the earliest (or oldest) available offset in the data source. 
Then start the pipeline to begin ingesting event data from the Kafka workspace. */

ALTER PIPELINE events SET OFFSETS EARLIEST;
START PIPELINE events;

-- ANALYZE
-- Total Number of Events
SELECT count(*) FROM events;

-- Events by Region
SELECT
events.country  AS `events.country`,
count(events.country) AS 'events.countofevents'
FROM adtech.events AS events
group by 1;

-- Events by Top 5 Advertisers
SELECT
    events.advertiser  AS `events.advertiser`,
    COUNT(*) AS `events.count`
FROM adtech.events  AS events
WHERE
    (events.advertiser LIKE '%Subway%' OR events.advertiser LIKE '%McDonals%' OR events.advertiser LIKE '%Starbucks%' OR events.advertiser LIKE '%Dollar General%' OR events.advertiser LIKE '%YUM! Brands%' OR events.advertiser LIKE '%Dunkin Brands Group%')
GROUP BY 1
ORDER BY 2 DESC;

-- Ad Visitors by Gender and Income
SELECT * FROM (
SELECT *, DENSE_RANK() OVER (ORDER BY z___min_rank) as z___pivot_row_rank, RANK() OVER (PARTITION BY z__pivot_col_rank ORDER BY z___min_rank) as z__pivot_col_ordering, CASE WHEN z___min_rank = z___rank THEN 1 ELSE 0 END AS z__is_highest_ranked_cell FROM (
SELECT *, MIN(z___rank) OVER (PARTITION BY `events.income`) as z___min_rank FROM (
SELECT *, RANK() OVER (ORDER BY CASE WHEN z__pivot_col_rank=1 THEN (CASE WHEN `events.count` IS NOT NULL THEN 0 ELSE 1 END) ELSE 2 END, CASE WHEN z__pivot_col_rank=1 THEN `events.count` ELSE NULL END DESC, `events.count` DESC, z__pivot_col_rank, `events.income`) AS z___rank FROM (
SELECT *, DENSE_RANK() OVER (ORDER BY CASE WHEN `events.gender` IS NULL THEN 1 ELSE 0 END, `events.gender`) AS z__pivot_col_rank FROM (
SELECT
    events.gender  AS `events.gender`,
    events.income  AS `events.income`,
    COUNT(*) AS `events.count`
FROM adtech.events  AS events
WHERE
    (events.income <> 'unknown' OR events.income IS NULL)
GROUP BY 1,2) ww
) bb WHERE z__pivot_col_rank <= 16384
) aa
) xx
) zz
WHERE (z__pivot_col_rank <= 50 OR z__is_highest_ranked_cell = 1) AND 
(z___pivot_row_rank <= 500 OR z__pivot_col_ordering = 1) ORDER BY z___pivot_row_rank
