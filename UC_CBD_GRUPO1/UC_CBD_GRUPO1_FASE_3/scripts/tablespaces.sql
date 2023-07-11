CREATE TABLESPACE
transacao  DATAFILE
'/home/oracle/brightbank/transacao.dbf'
SIZE 350M
REUSE
AUTOEXTEND ON NEXT 350M;

--produto agencia categoria
CREATE TABLESPACE
PAC_gerais  DATAFILE
'/home/oracle/brightbank/PAC_gerais.dbf'
SIZE 1M
REUSE
AUTOEXTEND ON NEXT 1M;

--Funcionários cliente conta endereço cartão
CREATE TABLESPACE
FE3C_gerais  DATAFILE
'/home/oracle/brightbank/FE3C_gerais.dbf'
SIZE 72M
REUSE
AUTOEXTEND ON NEXT 72M;

--operação titular moradacliente
CREATE TABLESPACE
otm_gerais  DATAFILE
'/home/oracle/brightbank/PTM_gerais.dbf'
SIZE 1M
REUSE
AUTOEXTEND ON NEXT 1M;

