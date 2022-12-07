/* The TPC Benchmark™H (TPC-H) is a decision support benchmark. 
It consists of a suite of business oriented ad-hoc queries and concurrent data modifications. 
The queries and the data populating the database have been chosen to have broad industry-wide relevance. 
This benchmark illustrates decision support systems that examine large volumes of data, execute queries with a high degree of complexity, 
and give answers to critical business questions. */

-- CREATE DATABASE AND SCHEMA
DROP DATABASE IF EXISTS tpch;
CREATE DATABASE tpch;
USE tpch;

CREATE TABLE `customer` (
  `c_custkey` int(11) NOT NULL,
  `c_name` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `c_address` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `c_nationkey` int(11) NOT NULL,
  `c_phone` char(15) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `c_acctbal` decimal(15,2) NOT NULL,
  `c_mktsegment` char(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `c_comment` varchar(117) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`c_custkey`) UNENFORCED RELY,
  SHARD KEY (`c_custkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `lineitem` (
  `l_orderkey` bigint(11) NOT NULL,
  `l_partkey` int(11) NOT NULL,
  `l_suppkey` int(11) NOT NULL,
  `l_linenumber` int(11) NOT NULL,
  `l_quantity` decimal(15,2) NOT NULL,
  `l_extendedprice` decimal(15,2) NOT NULL,
  `l_discount` decimal(15,2) NOT NULL,
  `l_tax` decimal(15,2) NOT NULL,
  `l_returnflag` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `l_linestatus` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `l_shipdate` date NOT NULL,
  `l_commitdate` date NOT NULL,
  `l_receiptdate` date NOT NULL,
  `l_shipinstruct` char(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `l_shipmode` char(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `l_comment` varchar(44) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`l_orderkey`, `l_linenumber`) UNENFORCED RELY,
  SHARD KEY (`l_orderkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `nation` (
  `n_nationkey` int(11) NOT NULL,
  `n_name` char(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `n_regionkey` int(11) NOT NULL,
  `n_comment` varchar(152) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`n_nationkey`) UNENFORCED RELY,
  SHARD KEY (`n_nationkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `orders` (
  `o_orderkey` bigint(11) NOT NULL,
  `o_custkey` int(11) NOT NULL,
  `o_orderstatus` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `o_totalprice` decimal(15,2) NOT NULL,
  `o_orderdate` date NOT NULL,
  `o_orderpriority` char(15) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `o_clerk` char(15) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `o_shippriority` int(11) NOT NULL,
  `o_comment` varchar(79) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`o_orderkey`) UNENFORCED RELY,
  SHARD KEY (`o_orderkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `part` (
  `p_partkey` int(11) NOT NULL,
  `p_name` varchar(55) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `p_mfgr` char(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `p_brand` char(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `p_type` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `p_size` int(11) NOT NULL,
  `p_container` char(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `p_retailprice` decimal(15,2) NOT NULL,
  `p_comment` varchar(23) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`p_partkey`) UNENFORCED RELY,
  SHARD KEY (`p_partkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `partsupp` (
  `ps_partkey` int(11) NOT NULL,
  `ps_suppkey` int(11) NOT NULL,
  `ps_availqty` int(11) NOT NULL,
  `ps_supplycost` decimal(15,2) NOT NULL,
  `ps_comment` varchar(199) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`ps_partkey`,`ps_suppkey`) UNENFORCED RELY,
  SHARD KEY(`ps_partkey`),
  KEY (`ps_partkey`,`ps_suppkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `region` (
  `r_regionkey` int(11) NOT NULL,
  `r_name` char(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `r_comment` varchar(152) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`r_regionkey`) UNENFORCED RELY,
  SHARD KEY (`r_regionkey`) USING CLUSTERED COLUMNSTORE
);

CREATE TABLE `supplier` (
  `s_suppkey` int(11) NOT NULL,
  `s_name` char(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `s_address` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `s_nationkey` int(11) NOT NULL,
  `s_phone` char(15) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `s_acctbal` decimal(15,2) NOT NULL,
  `s_comment` varchar(101) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY pk (`s_suppkey`) UNENFORCED RELY,
  SHARD KEY (`s_suppkey`) USING CLUSTERED COLUMNSTORE
);

-- LOAD DATA WITH PIPELINES
/* This part of the guide will show you how to pull the TPC-H data from a public S3 bucket into your SingleStoreDB Cloud 
database using Pipelines. Because of the powerful Pipelines functionality, loading TPC-H SF100 (approximately 100 GBs of row files) 
will take around four minutes on your workspace in AWS. Once a pipeline has been created, 
SingleStoreDB Cloud will continuously pull data from the bucket. */

CREATE OR REPLACE PIPELINE tpch_100_lineitem
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/lineitem/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE lineitem
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_customer
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/customer/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE customer
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_nation
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/nation/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE nation
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_orders
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/orders/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE orders
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_part
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/part/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE part
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_partsupp
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/partsupp/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE partsupp
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_region
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/region/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE region
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';

CREATE OR REPLACE PIPELINE tpch_100_supplier
    AS LOAD DATA S3 'memsql-tpch-dataset/sf_100/supplier/'
    config '{"region":"us-east-1"}'
    SKIP DUPLICATE KEY ERRORS
    INTO TABLE supplier
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '|\n';
    
-- START PIPELINES
START ALL PIPELINES;

-- VERIFY PIPELINE SUCCESS
-- The entire loading process takes around four minutes, but you do not need to wait for Pipelines to finish before querying.
-- You can query the data as soon as you have started the loading process; this is part of the powerful functionality of Pipelines.

-- Check the status of one pipeline
SELECT * FROM information_schema.pipelines_files WHERE pipeline_name = "tpch_100_lineitem";