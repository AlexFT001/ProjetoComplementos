CREATE TABLESPACE Bightbank 
DATAFILE  '/home/oracle/brightbank/Bightbank_proj.DBF' SIZE 500M REUSE AUTOEXTEND ON NEXT 1M MAXSIZE 1000M
NOLOGGING
PERMANENT
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK OFF;
b.	CREATE USER projeto 
    IDENTIFIED BY projeto
    DEFAULT TABLESPACE Bightbank
    QUOTA UNLIMITED ON Bightbank
    QUOTA UNLIMITED ON SYSTEM
    TEMPORARY TABLESPACE TEMP;


GRANT "CONNECT" TO projeto;
GRANT "RESOURCE" TO projeto;
ALTER USER projeto DEFAULT ROLE "CONNECT";
ALTER USER projeto DEFAULT ROLE "RESOURCE";


GRANT CREATE SESSION TO projeto;
GRANT ALTER TABLESPACE TO projeto;
GRANT CREATE TABLESPACE TO projeto;
GRANT CREATE TABLE TO projeto;
GRANT DROP TABLESPACE TO projeto;
GRANT CREATE SEQUENCE TO projeto;

GRANT ALL PRIVILEGES TO projeto