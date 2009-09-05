/*s*/DROP USER peon1;
/*s*/DROP USER peon2;
/*s*/DROP USER peon3;
/*s*/DROP ROLE r1;
/*s*/DROP ROLE r2;
/*s*/DROP ROLE r3;
/*s*/DROP ROLE r12;
DROP TABLE t1 IF exists;
DROP TABLE t2 IF exists;
DROP TABLE t3 IF exists;
DROP TABLE t4 IF exists;
CREATE TABLE t1(i int);
CREATE TABLE t2(i int);
CREATE TABLE t3(i int);
CREATE TABLE t4(i int);
INSERT INTO t1 VALUES(1);
INSERT INTO t2 VALUES(2);
INSERT INTO t3 VALUES(3);
INSERT INTO t4 VALUES(4);
COMMIT;
CREATE USER peon1 PASSWORD password;
CREATE USER peon2 PASSWORD password;
CREATE USER peon3 PASSWORD password;
/*u0*/GRANT CHANGE_AUTHORIZATION TO peon1;
/*u0*/GRANT CHANGE_AUTHORIZATION TO peon2;
/*u0*/GRANT CHANGE_AUTHORIZATION TO peon3;

/*u0*/CREATE ROLE r1;
/*u0*/CREATE ROLE r2;
/*u0*/CREATE ROLE r3;
/*u0*/CREATE ROLE r12;
/*u0*/GRANT ALL ON t1 TO r1;
/*u0*/GRANT ALL ON t1 TO r12;
/*u0*/GRANT ALL ON t2 TO r2;
/*u0*/GRANT ALL ON t2 TO r12;
/*u0*/GRANT ALL ON t3 TO r3;

-- Can't mix right-grants and role-grants
/*e*/GRANT r1, SELECT ON t1 TO peon1;
/*e*/GRANT SELECT ON t1, r1 TO peon1;

/*u0*/GRANT SELECT, INSERT ON t1 TO peon1;
/*u0*/GRANT r2, r3 TO peon2;
/*u0*/GRANT r12 TO peon3;

CONNECT USER peon1 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*e*/SELECT * FROM t2;
/*e*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER peon2 PASSWORD password;
/*e*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*c1*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER peon3 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*e*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER sa PASSWORD "";
/*u0*/GRANT r2 TO peon1;
/*u0*/GRANT r3 TO r12;  -- r12 held by peon3.  Nest r3 into it too.
/*u0*/GRANT SELECT ON t1 TO peon2;
CONNECT USER peon1 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*e*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER peon2 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*c1*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER peon3 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*c1*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;

-- Access to t3 has been granted only through r3, either directly or
-- indirectly (the latter through nesting r3 in another role).
CONNECT USER sa PASSWORD "";
DROP ROLE r3;
CONNECT USER peon1 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*e*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER peon2 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*e*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
CONNECT USER peon3 PASSWORD password;
/*c1*/SELECT * FROM t1;
/*c1*/SELECT * FROM t2;
/*e*/SELECT * FROM t3;
/*e*/SELECT * FROM t4;
