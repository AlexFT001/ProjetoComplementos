--External Tables

CREATE DIRECTORY externals AS '/home/oracle/brightbank/externals';

CREATE TABLE ext_codPostal(
    NB_CodPostal NUMBER(7),
    vc_cidade VARCHAR2(50)
)
    ORGANIZATION EXTERNAL(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY externals
    ACCESS PARAMETERS
    (RECORDS DELIMITED BY NEWLINE
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL)
    LOCATION('codPostal.txt')
    );

