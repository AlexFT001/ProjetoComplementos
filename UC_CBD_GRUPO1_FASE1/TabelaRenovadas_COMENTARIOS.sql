-- executar mkdir brightbank

--select 'drop table ', table_name, 'cascade constraints;' from user_tables ;

--DROP TABLESPACE BankingStart INCLUDING CONTENTS AND DATAFILES;

--Tablespaces



--transacao
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

CREATE DIRECTORY externals AS '/home/oracle/brightbank/externals';

CREATE TABLE ext_distrito(
    cod_distrito number(2),
    nome_distrito varchar2(200)
)
    ORGANIZATION EXTERNAL(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY externals
    ACCESS PARAMETERS
    (FIELDS TERMINATED BY ',')
    LOCATION('distrito.txt')
    );

CREATE TABLE DISTRITO_EXT(
    cod_distrito number(2),
    nome_distrito varchar2(200),
    CONSTRAINT distrito_pk PRIMARY KEY ( cod_distrito )
);

INSERT INTO  distrito_ext SELECT * FROM ext_distrito;


CREATE TABLE ext_concelho(
cod_distrito number(2),
cod_concelho number(2),
nome_concelho varchar2(200)

)
ORGANIZATION EXTERNAL(
TYPE ORACLE_LOADER
DEFAULT DIRECTORY externals
ACCESS PARAMETERS
(FIELDS TERMINATED BY ',')
LOCATION('concelho.txt')
);

CREATE TABLE CONSELHO_EXT(
    cod_distrito number(2),
    cod_concelho number(2),
    nome_concelho varchar2(200),
    CONSTRAINT conselho_pk PRIMARY KEY ( cod_concelho ),
    CONSTRAINT conselho_distrito_fk FOREIGN KEY ( cod_distrito ) REFERENCES DISTRITO_EXT ( cod_distrito )
);

INSERT INTO  conselho_ext SELECT * FROM ext_concelho;

CREATE TABLE ext_codPostal(
    cod_concelho NUMBER(2),
    vc_cidade VARCHAR2(50),
    nb_numPorta NUMBER(3),
    VC_Rua VARCHAR2(50),
    NB_CodPostal NUMBER(7)
)
    ORGANIZATION EXTERNAL(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY externals
    ACCESS PARAMETERS
    (FIELDS TERMINATED BY ',')
    LOCATION('codPostal.txt')
    );

CREATE TABLE codPostal_EXT(
    cod_concelho NUMBER(2),
    vc_cidade VARCHAR2(50),
    nb_numPorta NUMBER(3),
    VC_Rua VARCHAR2(50),
    NB_CodPostal NUMBER(7),
    CONSTRAINT codPosta_pk PRIMARY KEY ( NB_CodPostal ),
    CONSTRAINT codPostal_conselho_fk FOREIGN KEY ( cod_concelho ) REFERENCES conselho_ext ( cod_concelho )
);

    INSERT INTO codpostal_ext SELECT * FROM ext_codpostal;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela endereço.
*/
CREATE SEQUENCE endereco_nb_nendereco_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela endereço.
Que tem como objetivo guardar os dados dos endereços das 10 agências
os endereços de cada cliente.
*/
CREATE TABLE endereco (
    nb_nendereco   NUMBER(4) DEFAULT endereco_nb_nendereco_seq.NEXTVAL,
    vc_rua         VARCHAR2(50) NOT NULL,
    nb_codpostal   NUMBER(7) NOT NULL,
    nb_numporta    NUMBER(3) NOT NULL,
    vc_cidade      VARCHAR2(50) NOT NULL,
    vc_conselho    VARCHAR2(50) NOT NULL,
    vc_distrito    VARCHAR2(50) NOT NULL,
    vc_pais        VARCHAR2(50) NOT NULL,
    CONSTRAINT endereco_pk PRIMARY KEY ( nb_nendereco )
)
TABLESPACE FE3C_gerais
PCTFREE 5 -- podem ocorrer eventuais alterações
PCTUSED 40
;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela agencia.
*/
CREATE SEQUENCE agencia_nb_nagencia_seq START WITH 1000  INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela agencia.
Está possui 10 dados, sendo estas todas as agências que o banco t
ira possuir.
*/
CREATE TABLE agencia (
    nb_nagencia            NUMBER(4) DEFAULT agencia_nb_nagencia_seq.NEXTVAL,
    nb_endereco_nendreco   NUMBER(4),
    CONSTRAINT agencia_pk PRIMARY KEY ( nb_nagencia ),
    CONSTRAINT agencia_endereco_fk FOREIGN KEY ( nb_endereco_nendreco ) REFERENCES endereco ( nb_nendereco )
)
TABLESPACE PAC_gerais
PCTFREE 0 --podemos eventualmente alterar dados
PCTUSED 40
;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela categoria.
*/
CREATE SEQUENCE categoria_nb_categoria START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela categoria.
Está tem como objetivo possuir as categorias referentes a cada transferência.
*/
CREATE TABLE categoria (
    nb_categoria   NUMBER(4) DEFAULT categoria_nb_categoria.NEXTVAL,
    vc_nome_categoria    VARCHAR2(20) NOT NULL,
    CONSTRAINT categoria_pk PRIMARY KEY ( nb_categoria )
)
TABLESPACE PAC_gerais  
PCTFREE 5 --podemos eventualmente alterar dados 
PCTUSED 40;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela operação.
*/
CREATE SEQUENCE operacao_nb_operacao START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela operação.
Está tem como objetivo possuir o tipo de operação referente a cada transferência.
*/
CREATE TABLE operacao (
    nb_operacao   NUMBER(4) DEFAULT operacao_nb_operacao.NEXTVAL,
    vc_nome_operacao    VARCHAR2(20) NOT NULL,
    CONSTRAINT operacao_pk PRIMARY KEY ( nb_operacao )
)
TABLESPACE otm_gerais
PCTFREE 0 -- histórico
PCTUSED 40
;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela cliente.
*/
CREATE SEQUENCE cliente_nb_nif_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela cliente.
Está tem como objetivo possuir todas os dados de cada cliente.
*/
CREATE TABLE cliente (
    nb_ncliente NUMBER(4) DEFAULT cliente_nb_nif_seq.NEXTVAL,
    nb_nif             NUMBER(9),
    vc_nome            VARCHAR2(20) NOT NULL,
    nb_idade           NUMBER(3) NOT NULL,
    vc_profissao       VARCHAR2(20) NOT NULL,
    dt_datanascimento  DATE NOT NULL,
    vc_email           VARCHAR2(20) UNIQUE,
    vc_password        VARCHAR2(10),
    nb_agencia_nb_nagencia   NUMBER(4),
    CONSTRAINT client_pk PRIMARY KEY ( nb_ncliente ),
     CONSTRAINT cliente_agencia_fk FOREIGN KEY ( nb_agencia_nb_nagencia ) REFERENCES agencia ( nb_nagencia )
) PARTITION BY RANGE (nb_idade)
(
    PARTITION MENOR18 VALUES LESS THAN (18) TABLESPACE FE3C_gerais,
    PARTITION MENOR30 VALUES LESS THAN (30) TABLESPACE FE3C_gerais,
    PARTITION MENOR50 VALUES LESS THAN (50) TABLESPACE FE3C_gerais,
    PARTITION MENOR80 VALUES LESS THAN (80) TABLESPACE FE3C_gerais,
    PARTITION MENOR100 VALUES LESS THAN (100) TABLESPACE FE3C_gerais,
    PARTITION  ALL_MONTHS_2024 VALUES LESS THAN (MAXVALUE) TABLESPACE FE3C_gerais
)
TABLESPACE FE3C_gerais
PCTFREE 5 --caso ocorram problemas pedimos outro
PCTUSED 40;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela produto.
*/
CREATE SEQUENCE produto_nb_numproduto_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela produto.
Está tem como objetivo possuir as produtos referentes a cada conta.
*/
CREATE TABLE produto (
    nb_numproduto    NUMBER(4) DEFAULT produto_nb_numproduto_seq.NEXTVAL,
    vc_tipoproduto   VARCHAR2(20) NOT NULL,
    CONSTRAINT produto_pk PRIMARY KEY ( nb_numproduto )
)
TABLESPACE PAC_gerais  
PCTFREE 5 --podemos eventualmente alterar dados 
PCTUSED 40;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela conta.
*/
CREATE SEQUENCE conta_nb_iban_seq START WITH 100000000000000 INCREMENT BY 1 NOCACHE;


/*
Código que cria a tabela conta.
Está tem como objetivo possuir todas as contas existentes.
*/
CREATE TABLE conta
(
    nb_iban                  NUMBER(16) DEFAULT conta_nb_iban_seq.NEXTVAL,
    nb_saldo                 NUMBER(10, 3) NOT NULL,
    vc_tipo                  VARCHAR2(10) NOT NULL,
    nb_produto_nb_numproduto NUMBER(4),
    NB_agencia_nb_nagencia      NUMBER(4),
    CONSTRAINT conta_pk PRIMARY KEY (nb_iban),
    CONSTRAINT conta_agencia_fk FOREIGN KEY (NB_agencia_nb_nagencia) REFERENCES agencia (nb_nagencia),
    CONSTRAINT conta_produto_fk FOREIGN KEY (nb_produto_nb_numproduto) REFERENCES produto (nb_numproduto),
    CONSTRAINT conta_tipo_ck CHECK(vc_tipo IN('CREDITO','ORDEM'))
)
TABLESPACE FE3C_gerais
PCTFREE 5 -- podem ocorrer updates de dados
PCTUSED 40;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela funcionario.
*/
CREATE SEQUENCE funcionario_nb_nfuncionario START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela funcionario.
Está tem como objetivo possuir todos os funcionários do banco, sendo que estes são divididos apartir da chave estrangeira
da agencia.
*/
CREATE TABLE funcionario (
    nb_nfuncionario          NUMBER(4) DEFAULT funcionario_nb_nfuncionario.NEXTVAL,
    vc_nome                  VARCHAR2(20) NOT NULL,
    nb_agencia_nb_nagencia   NUMBER(4),
    dta_dtanascimento DATE NOT NULL,
    nb_funcionario_nb_nsupervisor NUMBER(4),
    CONSTRAINT funcionario_pk PRIMARY KEY ( nb_nfuncionario ),
    CONSTRAINT funcionario_agencia_fk FOREIGN KEY ( nb_agencia_nb_nagencia ) REFERENCES agencia ( nb_nagencia ),
    CONSTRAINT funcionario_funcionario_fk FOREIGN KEY ( nb_funcionario_nb_nsupervisor ) REFERENCES funcionario ( nb_nfuncionario )
)
TABLESPACE FE3C_gerais
PCTFREE 5 --caso ocorram problemas pedimos outro
PCTUSED 40;


/*
Código que adiciona a coluna de gerente a tabela agencia.
Desta forma cada agencia so podera ter 1 gerente.
Também adiciona a costraint á coluna, ligando assim está tabela á tabela
funcionário.
*/
ALTER TABLE agencia ADD
    nb_funcionario_nb_ngerente NUMBER(4);
ALTER TABLE agencia
    ADD  CONSTRAINT agencia__fk FOREIGN KEY ( nb_funcionario_nb_ngerente ) REFERENCES funcionario ( nb_nfuncionario );

/*
Código que cria a tabela moradacliente.
Está tem como objetivo dar a possiblidadem de que cada cliente possa ter mais que uma morada.
*/
CREATE TABLE moradacliente (
    nb_cliente_nb_numerocliente   NUMBER(4) NOT NULL,
    nb_endereco_nb_nendereco      NUMBER(4) NOT NULL,
    CONSTRAINT moradacliente_pk PRIMARY KEY ( nb_cliente_nb_numerocliente, nb_endereco_nb_nendereco ),
    CONSTRAINT moradacliente_cliente_fk FOREIGN KEY ( nb_cliente_nb_numerocliente )  REFERENCES cliente ( nb_ncliente ),
    CONSTRAINT moradacliente_endereco_fk FOREIGN KEY ( nb_endereco_nb_nendereco ) REFERENCES endereco ( nb_nendereco )
)
TABLESPACE otm_gerais
PCTFREE 5 -- podem ocorrer eventuais alterações
PCTUSED 40;

/*
Código que cria a tabela titular.
Está tem como objetivo dar a possiblidadem de que cada cliente possa ter mais que uma conta.
Para além de identificar qual é a ordem de titularidade de uma conta especifica.
*/
CREATE TABLE titular (
    nb_cliente_nb_ncliente   NUMBER(4) NOT NULL,
    nb_conta_nb_iban              NUMBER(16) NOT NULL,
    dta_dtaregistro               DATE NOT NULL,
    vc_ordemdetitularidade        VARCHAR2(20),
    CONSTRAINT contacliente_pk PRIMARY KEY (nb_cliente_nb_ncliente, nb_conta_nb_iban),
    CONSTRAINT contacliente_cliente_fk FOREIGN KEY ( nb_cliente_nb_ncliente ) REFERENCES cliente ( nb_ncliente ),
    CONSTRAINT contacliente_conta_fk FOREIGN KEY ( nb_conta_nb_iban ) REFERENCES conta ( nb_iban )
)
TABLESPACE otm_gerais
PCTFREE 5 -- podem ocorrer eventuais alterações
PCTUSED 40;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela cartao.
*/
CREATE SEQUENCE cartao_nb_numero_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela cartao.

*/
CREATE TABLE cartao (
    nb_numeroCartao                    NUMBER(4) DEFAULT cartao_nb_numero_seq.NEXTVAL,
    nb_pin                       NUMBER(4) NOT NULL,
    nb_cvv                       NUMBER(3) NOT NULL,
    vc_validade                  date NOT NULL,
    nb_titular_nb_ncliente       NUMBER(4),
    nb_titular_nb_iban           NUMBER(16),
    CONSTRAINT cartao_pk PRIMARY KEY ( nb_numeroCartao ),
    CONSTRAINT titular_fk FOREIGN KEY ( nb_titular_nb_ncliente, nb_titular_nb_iban ) REFERENCES titular ( nb_cliente_nb_ncliente, nb_conta_nb_iban )
)
TABLESPACE FE3C_gerais
PCTFREE 0 --caso ocorram problemas pedimos outro
PCTUSED 40
;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela transacao.
*/
CREATE SEQUENCE transacao_nb_numerotransacao START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a tabela transacao.

*/
CREATE TABLE transacao (
    nb_numerotransacao             NUMBER(4) DEFAULT transacao_nb_numerotransacao.NEXTVAL,
    vc_plataforma                  VARCHAR2(3) NOT NULL,
    nb_valor                       NUMBER(4) NOT NULL,
    nb_categoria                   number(4),
    nb_operacao                    number(4),
    dta_dtatransacao               DATE NOT NULL,
    nb_conta_IBANRecetor         NUMBER(16),
    nb_titular_nb_ncliente         NUMBER(4),
    nb_titular_nb_iban             NUMBER(16),
    CONSTRAINT transacao_pk PRIMARY KEY ( nb_numerotransacao ),
    CONSTRAINT transacao_categoria_fk FOREIGN KEY ( nb_categoria ) REFERENCES categoria ( nb_categoria ),
    CONSTRAINT transacao_operacao_fk FOREIGN KEY ( nb_operacao ) REFERENCES operacao ( nb_operacao ),
    CONSTRAINT transacao_conta_fk FOREIGN KEY ( nb_conta_IBANRecetor ) REFERENCES conta ( nb_iban ),
    CONSTRAINT transacao_titular_fk FOREIGN KEY ( nb_titular_nb_ncliente, nb_titular_nb_iban ) REFERENCES titular ( nb_cliente_nb_ncliente, nb_conta_nb_iban ),
    CONSTRAINT transacao_plataforma_ck CHECK(VC_plataforma IN('ATM','WEB'))
)
PARTITION BY RANGE (dta_dtatransacao)
(
    PARTITION JAN_2023 VALUES LESS THAN (TO_DATE('01/02/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION FEB_2023 VALUES LESS THAN (TO_DATE('01/03/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION MAR_2023 VALUES LESS THAN (TO_DATE('01/04/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION ABR_2023 VALUES LESS THAN (TO_DATE('01/05/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION MAI_2023 VALUES LESS THAN (TO_DATE('01/06/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION JUN_2023 VALUES LESS THAN (TO_DATE('01/07/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION JUL_2023 VALUES LESS THAN (TO_DATE('01/08/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION AGO_2023 VALUES LESS THAN (TO_DATE('01/09/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION SET_2023 VALUES LESS THAN (TO_DATE('01/10/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION OUT_2023 VALUES LESS THAN (TO_DATE('01/11/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION NOV_2023 VALUES LESS THAN (TO_DATE('01/12/2023', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION DEZ_2023 VALUES LESS THAN (TO_DATE('01/01/2024', 'dd/mm/yyyy')) TABLESPACE transacao,
    PARTITION  ALL_MONTHS_2024 VALUES LESS THAN  (MAXVALUE) TABLESPACE transacao
)
TABLESPACE transacao
PCTFREE 0 --vai ser historico
PCTUSED 40;


--Procedimentos

CREATE OR REPLACE PROCEDURE update_specifc_register (tabela_escolhida varchar2, id_escolhido number, campo_escolhido varchar2, novo_valor varchar2)
is
tabelaEscolhida_V varchar2(200) := '';
campo_escolhido_V varchar2(200) := '';
nome_pk_V varchar2(200) := '';
BEGIN

SELECT cols.table_name,cols.column_name
into tabelaEscolhida_V,campo_escolhido_V
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name = upper(tabela_escolhida)
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
and cols.column_name = upper(campo_escolhido)
ORDER BY cols.table_name, cols.position;


SELECT cols.column_name
into nome_pk_V
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name = upper(tabela_escolhida)
AND cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
ORDER BY cols.table_name, cols.position;
EXECUTE IMMEDIATE 'UPDATE ' || DBMS_ASSERT.SIMPLE_SQL_NAME(tabelaEscolhida_V) || ' SET ' ||DBMS_ASSERT.SIMPLE_SQL_NAME(campo_escolhido_V) ||' = '|| novo_valor ||' WHERE '||DBMS_ASSERT.SIMPLE_SQL_NAME(nome_pk_V)||' ='|| id_escolhido ;
END;
/


/*
    Este procedimento tem como objetivo adicionar um enderenço a tabela com o mesmo nome.
    Está possui como parametro todas as colunas da tabela ENDERECO e ainda possui como
    parametro o a chave primaria do cliente, uma vez que está é a morada do mesmo.
    Ainda é validade se o Conselho corresponde ao Distrito certo, utilizando duas External Tables
    que possuem esses dados.
*/

CREATE OR REPLACE PROCEDURE addEndereco
    (
     rua endereco.vc_rua%type,
     codigoPostal endereco.nb_codpostal%type,
     numPorta endereco.nb_numporta%type,
     cidade endereco.vc_cidade%type,
     conselho endereco.vc_conselho%type,
     distrito endereco.vc_distrito%type,
     pais endereco.vc_pais%type,
     cliente cliente.nb_ncliente%type
     )
AS
    numeroEndereco endereco.nb_nendereco%type;
    codigoDistrito distrito_ext.cod_distrito%type;
    nomeDistrito distrito_ext.nome_distrito%type;
    codigoConselho conselho_ext.cod_concelho%type;
    codigoPostalVerificar codpostal_ext.nb_codpostal%type;

BEGIN
 IF pais LIKE 'PORTUGAL'
 THEN
    SELECT cod_distrito, cod_concelho
    INTO codigoDistrito, codigoconselho
    FROM conselho_ext
    WHERE nome_concelho LIKE conselho;

    SELECT nome_distrito
    INTO nomeDistrito
    FROM distrito_ext
    WHERE cod_distrito = codigoDistrito;

    SELECT nb_codpostal
    INTO codigopostalverificar
    FROM codpostal_ext
    WHERE cod_concelho = codigoconselho;


    IF distrito like nomeDistrito
    THEN
     IF codigopostal = codigopostalverificar
     THEN
        INSERT INTO ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_conselho, vc_distrito, vc_pais)
        VALUES (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais)
        RETURNING  nb_nendereco INTO numeroEndereco;

        INSERT INTO moradacliente VALUES (cliente,numeroEndereco);
        ELSE
        RAISE_APPLICATION_ERROR(-20001, 'O código Postal inserido não se encontra certo');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'O Conselho inserido, não corresponde Distrito certo');
    END IF;
ELSE
    INSERT INTO ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_conselho, vc_distrito, vc_pais)
    VALUES (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais)
    RETURNING  nb_nendereco INTO numeroEndereco;

    INSERT INTO moradacliente VALUES (cliente,numeroEndereco);
END IF;

END addEndereco;
/

/*
    Esta função tem como objetivo manipular a ordem de titularidade entre contas, sendo que somente
    possui como parametro o numero de contas e a partir dai ira realizar uma contagem de quantas pessoas
    já se encontram associadas à mesma, e comforma a contagem fara sumara +1 e concatnara com a strimg
    'º Titular', desta forma se a contagem der 0 o clinte será o 1º Titular, se a contagem der
    1 o cliente será o 2º Titular.
    Está é chamada nos procedimentos: addConta e associarContaCliente.
*/

CREATE OR REPLACE FUNCTION titularOrdem (numeroConta conta.nb_iban%type)  RETURN VARCHAR2 IS
    pessoasConta number(10);
    titular varchar2(20);
BEGIN
    SELECT  COUNT(nb_conta_nb_iban)
    INTO pessoasConta
    FROM titular
    WHERE nb_conta_nb_iban = numeroConta;

    titular := (pessoasConta+1)||'º Titular';

    RETURN  titular;
END titularOrdem;
/


/*
    Este procedimento tem como objetivo adicionar uma conta a tabela com o mesmo nome.
    Está possui como parametro todos os parametros da tabela CONTA ainda possui como
    parametro o a chave primaria do cliente, uma vez que a conta tem de estar associada
    a alguém.
*/
CREATE OR REPLACE PROCEDURE addConta
    (
     saldo conta.nb_saldo%type,
     tipodeConta conta.vc_tipo%type,
     agenciaConta conta.NB_agencia_nb_nagencia%type,
     produto conta.nb_produto_nb_numproduto%type,
     cliente cliente.nb_ncliente%type
     )
AS
    numeroConta conta.nb_iban%type;
    titularidade varchar2(20);
BEGIN

    IF tipodeConta LIKE 'ORDEM' OR tipodeConta LIKE 'CREDITO'
    THEN
    INSERT INTO CONTA (nb_saldo, vc_tipo, NB_agencia_nb_nagencia,nb_produto_nb_numproduto)
    VALUES (saldo, UPPER(tipodeConta), agenciaConta, produto)
    RETURNING  nb_iban INTO  numeroConta;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Tipo de Conta desconhecido.');
    END IF;

    titularidade := titularOrdem(numeroConta);

    INSERT INTO titular
    VALUES (cliente, numeroConta, TO_DATE(CURRENT_DATE, 'dd/mm/yyyy'), titularidade);

END addConta;
/



/*
    Este procedimento tem como associar uma conta a um cliente desta forma
    um cliente (que já possui uma conta) podera ficar associado a outra conta.
*/
CREATE OR REPLACE PROCEDURE associarContaCliente
    (
     iban conta.nb_iban%type,
     cliente cliente.nb_ncliente%type
     )
AS
    titularidade varchar2(20);
BEGIN

    titularidade := titularOrdem(iban);

    INSERT INTO titular VALUES (cliente,iban,TO_DATE(current_date,'dd/mm/yyy'),titularidade);

END associarContaCliente;
/


/*
    Este procedimento tem como objetivo adicionar um Cliente a tabela com o mesmo nome.
    Está possui como parametro quase todas as colunas da tabela CLIENTE e ainda possui como
    parametro as colunas da tabela ENDERECO e da tabela CONTA, isto porque quando um cliente
    é registrado num banco o mesmo tem de se encontrar associado tanto a um endereço como a uma
    conta, deste modo dentro deste procedure os procedure de addEnderco e addConta são chamados.
    Caso um cliente não possua E-mail e por sua vez PassWord, ambos parametros deverão ser recebidos
    como null.
*/
CREATE OR REPLACE PROCEDURE addCliente
    (nif cliente.nb_nif%type,
     nome cliente.vc_nome%type,
     profissao cliente.vc_profissao%type,
     dataNascimento cliente.dt_datanascimento%type,
     emailcliente cliente.vc_email%type,
     passWordcliente cliente.vc_password%type,
     rua endereco.vc_rua%type,
     codigoPostal endereco.nb_codpostal%type,
     numPorta endereco.nb_numporta%type,
     cidade endereco.vc_cidade%type,
     conselho endereco.vc_conselho%type,
     distrito endereco.vc_distrito%type,
     pais endereco.vc_pais%type,
     saldo conta.nb_saldo%type,
     tipodeConta conta.vc_tipo%type,
     agenciaConta conta.NB_agencia_nb_nagencia%type,
     produto conta.nb_produto_nb_numproduto%type,
     agencia funcionario.nb_agencia_nb_nagencia%type
     )
AS
    numeroCliente cliente.nb_ncliente%type;
BEGIN

    INSERT INTO CLIENTE (NB_nif, vc_nome, nb_idade, vc_profissao, dt_datanascimento, vc_email, vc_password, nb_agencia_nb_nagencia)
    VALUES (nif, nome, TRUNC(MONTHS_BETWEEN(sysdate, dataNascimento)/12), profissao, dataNascimento, emailcliente, passWordcliente, agencia)
    RETURNING  nb_ncliente into numeroCliente;

    addEndereco (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais, numeroCliente);

    addConta(saldo, tipodeConta, agenciaConta, produto, numeroCliente);


END addCliente;
/

/*
    Este procedimento tem como objetivo adicionar um cartão a tabela com o mesmo nome.
    Está possui como parametro alguma  colunas da tabela CARTAO e ainda possui como
    parametro o a chave primaria do cliente e da conta, uma vez que o este tem de estar
    associado tanto com um cliente, tanto como uma conta, é verificado se o PIN recebido possui
    4 digitos a data de validade é gerada tendo em conta a data de criação + 4 anos, e o cvv
    é gerado conforme a partir de uma sequência.
    Ainda é verificado se a conta é à Ordem uma vez que somente está pode possuir cartões.
*/

CREATE SEQUENCE cartao_cvv START WITH 100 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE PROCEDURE addCartao
    (pin  cartao.nb_pin%type,
     iban cartao.nb_titular_nb_iban%type,
     numerCliente cartao.nb_titular_nb_ncliente%type)
AS
    tipoConta conta.vc_tipo%type;
    validade date;
    tamanho number(5);
BEGIN
    SELECT vc_tipo
    INTO tipoConta
    FROM conta
    WHERE nb_iban = iban;

    validade := ADD_MONTHS(sysdate, 48);

    IF UPPER(tipoConta) = 'ORDEM'
     THEN
         tamanho := tamanhoNumero(pin);
         IF tamanho = 4 THEN
            INSERT INTO cartao (nb_pin, nb_cvv, vc_validade, nb_titular_nb_ncliente, nb_titular_nb_iban)
            VALUES (pin, cartao_cvv.nextval, TO_DATE(validade, 'DD/MM/YYYY'), numerCliente, iban);
        ELSE
             RAISE_APPLICATION_ERROR(-20001, 'O PIN tem de possuir 4 dígitos');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Conta a Crédito');
    end if;
END addCartao;
/

/*
    Este procedimento tem como objetivo adicionar um Funcionario a tabela com o mesmo nome.
    Está possui como parametro todas as colunas da tabela FUNCIONARIO e ainda possui como
    parametro o a chave primaria da agencia, uma vez que está é a que indica em qual destas
    o Funcionário trabalha.
*/
CREATE OR REPLACE PROCEDURE addFuncionario
    (nome funcionario.vc_nome%type,
     agencia funcionario.nb_agencia_nb_nagencia%type,
     dataNascimento funcionario.dta_dtanascimento%type,
     superior funcionario.nb_funcionario_nb_nsupervisor%type)
AS
BEGIN
    INSERT INTO FUNCIONARIO (vc_nome, nb_agencia_nb_nagencia, dta_dtanascimento,nb_funcionario_nb_nsupervisor)
    VALUES (nome, agencia, TO_DATE(dataNascimento, 'dd/mm/yyyy'), superior);
END addFuncionario;
/

/*
    Este função tem como objetivo gerar um numero aleatório conforme os parametros que está recebe.
    O numero que devolve é um numero inteiro.
    Foi criada uma função para este codigo, uma vez que o mesmo é usada diversas vezes no
    procedure randomTransacao.

*/
CREATE OR REPLACE FUNCTION numeroaleatorio (min number, max number) RETURN NUMBER IS
    resultado number;
BEGIN
    SELECT DBMS_RANDOM.VALUE(min, max)
    INTO resultado
    FROM DUAL;

    RETURN  TRUNC(resultado);
END numeroaleatorio;
/

/*
    Este procedimento tem como objetivo adicionar um número de registros aleatórios na tabela
    TRANSACAO, o numero de registros é recebido atráves de um parametro, e todos os outros os
    outros dados é gerado de forma aleatória mas conforme os dados existentes nas outras tabelas.
*/
CREATE OR REPLACE PROCEDURE randomTransacao
    (
    quantidade number
    )
AS
    randomNumber NUMBER(10);
    plataforma transacao.vc_plataforma%type;
    valor NUMBER(10);
    quantidadevalores1 number(4);
    quantidadevalores2 number(4);
    operacao transacao.nb_operacao%type;
    categoria transacao.nb_categoria%type;
    clienteTransacao transacao.nb_titular_nb_ncliente%type;
    contatransacao transacao.nb_titular_nb_iban%type;
    emailcliente varchar2(20);
    contarecetora number(16);
    operacaoNome varchar2(20);
    tipoconta varchar2(20);
    contaSaldo NUMBER(10);
    contaRecetoraSaldo NUMBER(10);
BEGIN
    FOR i in 1..quantidade
    LOOP
    randomNumber := numeroaleatorio(1,2);

    IF randomNumber = 1 THEN
		plataforma := 'WEB';
	ELSE
		plataforma := 'ATM';
	END IF;
    valor := numeroaleatorio(10,999);

    SELECT COUNT(nb_operacao)
    INTO quantidadevalores1
    FROM operacao;

    quantidadevalores1 := numeroaleatorio(1, (quantidadevalores1+1000));

    SELECT nb_operacao, vc_nome_operacao
    INTO operacao, operacaonome
    FROM operacao
    WHERE nb_operacao = quantidadevalores1;

    SELECT COUNT(nb_categoria)
    INTO quantidadevalores2
    FROM categoria;

    quantidadevalores2 := numeroaleatorio(1, (quantidadevalores2+1000));

    SELECT nb_categoria
    INTO categoria
    FROM categoria
    WHERE nb_categoria = quantidadevalores2;

    SELECT nb_cliente_nb_ncliente, nb_conta_nb_iban
    INTO clienteTransacao, contatransacao
    FROM
    (SELECT  nb_cliente_nb_ncliente, nb_conta_nb_iban FROM titular
    ORDER BY dbms_random.value)
    WHERE rownum =1;
IF plataforma = 'WEB'
    THEN
    SELECT vc_email
    INTO emailcliente
    FROM cliente
    WHERE nb_ncliente = clienteTransacao;

        IF emailcliente IS NOT NULL
        THEN
            SELECT nb_iban
            INTO contarecetora
            FROM
            (SELECT  nb_iban FROM conta
            ORDER BY dbms_random.value)
            WHERE rownum =1;
        end if;
ELSE
    IF operacaonome = 'Transferencia'
    THEN
            SELECT nb_iban
            INTO contarecetora
            FROM
            (SELECT  nb_iban FROM conta
            ORDER BY dbms_random.value)
            WHERE rownum =1;
    ELSE
        contarecetora := null;
    END IF;
END IF;
    SELECT vc_tipo, nb_saldo
    INTO tipoconta, contasaldo
    FROM conta
    WHERE nb_iban = contatransacao;

    SELECT nb_saldo
    INTO contarecetorasaldo
    FROM conta
    WHERE nb_iban = contarecetora;

IF emailcliente IS NOT NULL
   OR tipoconta LIKE 'ORDEM'
   OR valor <= contasaldo
THEN
    INSERT INTO TRANSACAO (VC_plataforma, nb_valor, dta_dtatransacao, nb_categoria, nb_operacao, nb_titular_nb_ncliente, nb_titular_nb_iban, nb_conta_IBANRecetor)
    VALUES (plataforma, valor,TO_DATE(current_date,'dd/mm/yyyy'),categoria,operacao,clienteTransacao,contatransacao,contarecetora);
    IF contarecetora IS NULL
    THEN
        IF operacaonome LIKE 'LEVANTAMENTO'
        THEN
            EXECUTE IMMEDIATE update_specifc_register('CONTA', contatransacao,'nb_saldo' , (contasaldo-valor) );
        ELSE
            EXECUTE IMMEDIATE update_specifc_register('CONTA', contatransacao,'nb_saldo' , (contasaldo+valor) );
        END IF;
    ELSE
        EXECUTE IMMEDIATE update_specifc_register('CONTA', contarecetora,'nb_saldo' , (contarecetorasaldo+valor) );
    END IF;

END IF;
END LOOP;
END randomTransacao;
/

CREATE VIEW NumeroCliente AS
    SELECT a.nb_nagencia AS "AGENCIA", count(c.nb_ncliente) AS "Numero de Clientes"
    FROM cliente c, agencia a
    WHERE c.nb_agencia_nb_nagencia = a.nb_nagencia
    GROUP BY a.nb_nagencia;

/*
    Este função tem como devolver o tamanho de uma string enviada, é utilizada
    no procedure addCartao para verificar que o PIN possui 4 dígitos.
*/
CREATE OR REPLACE FUNCTION tamanhoNumero (string Varchar2) RETURN NUMBER IS
    resultado number;
BEGIN
     resultado := LENGTH(string);

    RETURN  resultado;
END tamanhoNumero;
/











