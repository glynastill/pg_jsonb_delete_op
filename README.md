Hstore style delete "-" operator for jsonb
===========================================

PostgreSQL 9.4 intorduced the [jsonb](http://www.postgresql.org/docs/9.4/static/functions-json.html#FUNCTIONS-JSON-OP-TABLE) 
type, but it'd be nice to be able to delete keys and pairs using the "-" operator 
just like you can with the [hstore](http://www.postgresql.org/docs/9.4/static/hstore.html#HSTORE-OP-TABLE) type.

This sql script attempts to achieve that. E.g.

Install
-------

Run the script

```sql
TEST=# \i pg_jsonb_delete_op.sql
SET
CREATE FUNCTION
COMMENT
CREATE OPERATOR
COMMENT
CREATE FUNCTION
COMMENT
CREATE OPERATOR
COMMENT
CREATE FUNCTION
COMMENT
CREATE OPERATOR
COMMENT
```

Usage
-----

E.g.

```sql
TEST=# SELECT '{"a": 1, "b": 2, "c": 3}'::jsonb - 'b'::text;
     ?column?     
------------------
 {"a": 1, "c": 3}
(1 row)

Time: 2.290 ms


TEST=# SELECT '{"a": 1, "b": 2, "c": 3}'::jsonb - ARRAY['a','b'];
 ?column? 
----------
 {"c": 3}
(1 row)

Time: 6.651 ms

TEST=# SELECT '{"a": 1, "b": 2, "c": 3}'::jsonb - '{"a": 4, "b": 2}'::jsonb;
     ?column?     
------------------
 {"a": 1, "c": 3}
(1 row)

Time: 4.275 ms
```

...


```sql
TEST=# CREATE TABLE jsonb_test (a jsonb, b jsonb);
CREATE TABLE
Time: 207.038 ms

TEST=# INSERT INTO jsonb_test VALUES ('{"a": 1, "b": 2, "c": 3}', '{"a": 4, "b": 2}');
INSERT 0 1
Time: 39.979 ms

TEST=# SELECT * FROM jsonb_test WHERE a-b = '{"a": 1, "c": 3}'::jsonb;
            a             |        b         
--------------------------+------------------
 {"a": 1, "b": 2, "c": 3} | {"a": 4, "b": 2}
(1 row)

Time: 47.197 ms
```

In an index:

```sql

TEST=# INSERT INTO jsonb_test
TEST-# SELECT ('{"a" : ' || i+1 || ',"b" : ' || i+2 || ',"c": ' || i+3 || '}')::jsonb,
TEST-# ('{"a" : ' || i+2 || ',"b" : ' || i || ',"c": ' || i+5 || '}')::jsonb
TEST-# FROM generate_series(1,1000) i;
INSERT 0 1000
Time: 84.765 ms

TEST=# CREATE INDEX ON jsonb_test USING gin((a-b));
CREATE INDEX
Time: 229.050 ms
TEST=# EXPLAIN SELECT * FROM jsonb_test WHERE a-b @> '{"a": 1, "c": 3}';
                                    QUERY PLAN                                     
-----------------------------------------------------------------------------------
 Bitmap Heap Scan on jsonb_test  (cost=20.26..24.52 rows=1 width=113)
   Recheck Cond: ((a - b) @> '{"a": 1, "c": 3}'::jsonb)
   ->  Bitmap Index Scan on jsonb_test_expr_idx  (cost=0.00..20.26 rows=1 width=0)
         Index Cond: ((a - b) @> '{"a": 1, "c": 3}'::jsonb)
(4 rows)

Time: 13.277 ms

```
