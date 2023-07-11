/*
Código que cria a tabela de logs.
Esta tem como objetivo guardar os dados de todos os erros durante a inserção
para posterior análise.
*/
create table logErros(
nb_ordem number(4) DEFAULT loglog_seq.NEXTVAL,
vc_operacao varchar2(100),
vc_user varchar2(100),
dta_datalog date,
vc_short_message varchar2(200),
CONSTRAINT loglog_pk PRIMARY KEY (nb_ordem)
)
TABLESPACE FE3C_gerais
PCTFREE 0
PCTUSED 0
;

COMMENT on table logErros is 'Esta tem como objetivo guardar os dados de todos os erros durante a inserção para posterior análise.';

/*
Código que cria a tabela endereço.
Esta tem como objetivo guardar os dados dos endereços das 10 agências
os endereços de cada cliente.
*/
CREATE TABLE endereco (
    nb_nendereco   NUMBER(4) DEFAULT endereco_nb_nendereco_seq.NEXTVAL,
    vc_rua         VARCHAR2(50) NOT NULL,
    nb_codpostal   NUMBER(7) NOT NULL,
    nb_numporta    NUMBER(2) NOT NULL,
    vc_cidade      VARCHAR2(50) NOT NULL,
    vc_concelho    VARCHAR2(50) NOT NULL,
    vc_distrito    VARCHAR2(50) NOT NULL,
    vc_pais        VARCHAR2(50) NOT NULL,
    CONSTRAINT endereco_pk PRIMARY KEY ( nb_nendereco )
)
TABLESPACE FE3C_gerais
PCTFREE 10
PCTUSED 40
;

COMMENT on table endereco is 'Esta tem como objetivo guardar os dados dos endereços das 10 agências os endereços de cada cliente.';



/*
Código que cria a tabela agencia.
Esta possui 10 dados, sendo estas todas as agências que o banco
ira possuir.
*/
CREATE TABLE agencia (
    nb_nagencia            NUMBER(4) DEFAULT agencia_nb_nagencia_seq.NEXTVAL,
    nb_nendreco   NUMBER(4),
    CONSTRAINT agencia_pk PRIMARY KEY ( nb_nagencia ),
    CONSTRAINT agencia_endereco_fk FOREIGN KEY ( nb_nendreco ) REFERENCES endereco ( nb_nendereco ) ON DELETE SET NULL
)
TABLESPACE PAC_gerais
PCTFREE 5
PCTUSED 40
;

COMMENT on table agencia is 'Esta tem como objetivo possuir todos os dados referentes as agências que o banco ira possuir.';

/*
Código que cria a tabela funcionario.
Esta tem como objetivo possuir todos os funcionários do banco, sendo que estes são divididos apartir da chave estrangeira
da agencia.
*/
CREATE TABLE funcionario (
    nb_nfuncionario          NUMBER(4) DEFAULT funcionario_nb_nfuncionario.NEXTVAL,
    vc_nome                  VARCHAR2(20) NOT NULL,
    nb_nagencia   NUMBER(4),
    dta_dtanascimento DATE NOT NULL,
    nb_supervisor  NUMBER(10),
    CONSTRAINT funcionario_pk PRIMARY KEY ( nb_nfuncionario ),
    CONSTRAINT funcionario_agencia_fk FOREIGN KEY ( nb_nagencia ) REFERENCES agencia ( nb_nagencia ),
    CONSTRAINT funcionario_supervisor_fk FOREIGN KEY (nb_supervisor) REFERENCES funcionario ( nb_nfuncionario) ON DELETE SET NULL
)
TABLESPACE FE3C_gerais
PCTFREE 10
PCTUSED 40;

COMMENT on table funcionario is 'Esta tem como objetivo possuir todos os funcionários do banco, sendo que estes são divididos apartir da chave estrangeira
                                da agencia.';


/*
Código que adiciona a coluna de gerente a tabela agencia.
Desta forma cada agencia so podera ter 1 gerente.
Também adiciona a costraint á coluna, ligando assim Esta tabela á tabela
funcionário.
*/
ALTER TABLE agencia ADD
    nb_ngerente NUMBER(4);
ALTER TABLE agencia
    ADD  CONSTRAINT agencia__fk FOREIGN KEY ( nb_ngerente ) REFERENCES funcionario ( nb_nfuncionario ) ON DELETE SET NULL;


/*
Código que cria a tabela categoria.
Esta tem como objetivo possuir as categorias referentes a cada transferência.
*/
CREATE TABLE categoria (
    nb_categoria   NUMBER(4) DEFAULT categoria_nb_categoria.NEXTVAL,
    vc_nome_categoria    VARCHAR2(20) NOT NULL,
    CONSTRAINT categoria_pk PRIMARY KEY ( nb_categoria )
)
TABLESPACE PAC_gerais  
PCTFREE 5
PCTUSED 40;

COMMENT on table categoria is 'Esta tem como objetivo possuir as categorias referentes a cada transferência.';


/*
Código que cria a tabela operação.
Esta tem como objetivo possuir o tipo de operação referente a cada transferência.
*/
CREATE TABLE operacao (
    nb_operacao   NUMBER(4) DEFAULT operacao_nb_operacao.NEXTVAL,
    vc_nome_operacao    VARCHAR2(20) NOT NULL,
    CONSTRAINT operacao_pk PRIMARY KEY ( nb_operacao )
)
TABLESPACE otm_gerais
PCTFREE 5
PCTUSED 40
;

COMMENT on table categoria is 'Esta tem como objetivo possuir o tipo de operação referente a cada transferência.';

/*
Código que cria a tabela cliente.
Esta tem como objetivo possuir todas os dados de cada cliente.
*/
CREATE TABLE cliente (
    nb_ncliente NUMBER(4) DEFAULT cliente_nb_nif_seq.NEXTVAL,
    nb_nif             NUMBER(9) UNIQUE,
    vc_nome            VARCHAR2(20) NOT NULL,
    nb_idade           NUMBER(3) NOT NULL,
    vc_profissao       VARCHAR2(20) NOT NULL,
    dt_datanascimento  DATE NOT NULL,
    vc_email           VARCHAR2(20) UNIQUE NOT NULL,
    vc_password        VARCHAR2(10) NOT NULL,
    nb_nagencia   NUMBER(4),
    CONSTRAINT client_pk PRIMARY KEY ( nb_ncliente ),
    CONSTRAINT cliente_agencia_fk FOREIGN KEY ( nb_nagencia ) REFERENCES agencia ( nb_nagencia ) ON DELETE SET NULL
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
PCTFREE 10
PCTUSED 40;

COMMENT on table cliente is 'Esta tem como objetivo possuir todas os dados de cada cliente.';


/*
Código que cria a tabela produto.
Esta tem como objetivo possuir as produtos referentes a cada conta.
*/
CREATE TABLE produto (
    nb_nproduto    NUMBER(4) DEFAULT produto_nb_numproduto_seq.NEXTVAL,
    vc_tipoproduto   VARCHAR2(20) NOT NULL,
    CONSTRAINT produto_pk PRIMARY KEY ( nb_nproduto )
)
TABLESPACE PAC_gerais  
PCTFREE 5
PCTUSED 40;

COMMENT on table produto is 'Esta tem como objetivo possuir as produtos referentes a cada conta.';

/*
Código que cria a tabela conta.
Esta tem como objetivo possuir todas as contas existentes.
*/
CREATE TABLE conta
(
    nb_iban                  NUMBER(16) DEFAULT conta_nb_iban_seq.NEXTVAL,
    nb_saldo                 NUMBER(10,2) NOT NULL,
    vc_tipo                  VARCHAR2(10) NOT NULL,
    nb_nproduto              NUMBER(4),
    nb_nagencia              NUMBER(4),
    CONSTRAINT conta_pk PRIMARY KEY (nb_iban),
    CONSTRAINT conta_agencia_fk FOREIGN KEY (nb_nagencia) REFERENCES agencia (nb_nagencia) ON DELETE SET NULL,
    CONSTRAINT conta_produto_fk FOREIGN KEY (nb_nproduto) REFERENCES produto (nb_nproduto) ON DELETE SET NULL,
    CONSTRAINT conta_tipo_ck CHECK(vc_tipo IN('PRAZO','ORDEM'))
)
TABLESPACE FE3C_gerais
PCTFREE 5
PCTUSED 40;

COMMENT on table conta is 'Esta tem como objetivo possuir todas as contas existentes.';

/*
Código que cria a tabela moradacliente.
Esta tem como objetivo dar a possiblidadem de que cada cliente possa ter mais que uma morada.
*/
CREATE TABLE moradacliente (
    nb_ncliente   NUMBER(4) NOT NULL,
    nb_nendereco      NUMBER(4) NOT NULL,
    CONSTRAINT moradacliente_pk PRIMARY KEY ( nb_ncliente, nb_nendereco ),
    CONSTRAINT moradacliente_cliente_fk FOREIGN KEY ( nb_ncliente )  REFERENCES cliente ( nb_ncliente ) ON DELETE CASCADE,
    CONSTRAINT moradacliente_endereco_fk FOREIGN KEY ( nb_nendereco ) REFERENCES endereco ( nb_nendereco ) ON DELETE CASCADE
)
TABLESPACE otm_gerais
PCTFREE 0
PCTUSED 40;

COMMENT on table moradacliente is 'Esta tem como objetivo dar a possiblidadem de que cada cliente possa ter mais que uma morada.';

/*
Código que cria a tabela titular.
Esta tem como objetivo dar a possiblidadem de que cada cliente possa ter mais que uma conta.
Para além de identificar qual é a ordem de titularidade de uma conta especifica.
*/
CREATE TABLE titular (
    nb_ncliente   NUMBER(4) NOT NULL,
    nb_iban              NUMBER(16) NOT NULL,
    dta_dtaregistro               DATE NOT NULL,
    vc_ordemdetitularidade        VARCHAR2(20),
    CONSTRAINT contacliente_pk PRIMARY KEY (nb_ncliente, nb_iban),
    CONSTRAINT contacliente_cliente_fk FOREIGN KEY ( nb_ncliente ) REFERENCES cliente ( nb_ncliente ) ON DELETE CASCADE,
    CONSTRAINT contacliente_conta_fk FOREIGN KEY ( nb_iban ) REFERENCES conta ( nb_iban ) ON DELETE CASCADE
)
TABLESPACE otm_gerais
PCTFREE 0
PCTUSED 40;

COMMENT on table titular is 'Esta tem como objetivo dar a possiblidadem de que cada cliente possa ter mais que uma conta.
                            Para além de identificar qual é a ordem de titularidade de uma conta especifica.';


/*
Código que cria a tabela cartao.
Esta tem como objetivo guardar todos os cartões sendo cada um distiguindo pela conta a que pertencem e a que cliente pertence.
*/
CREATE TABLE cartao (
    nb_numeroCartao              NUMBER(4) DEFAULT cartao_nb_numero_seq.NEXTVAL,
    nb_pin                       NUMBER(4) NOT NULL,
    nb_cvv                       NUMBER(3) NOT NULL,
    vc_validade                  date NOT NULL,
    nb_ncliente                  NUMBER(4),
    nb_iban                     NUMBER(16),
    CONSTRAINT cartao_pk PRIMARY KEY ( nb_numeroCartao ),
    CONSTRAINT titular_fk FOREIGN KEY ( nb_ncliente, nb_iban ) REFERENCES titular ( nb_ncliente, nb_iban ) ON DELETE CASCADE
)
TABLESPACE FE3C_gerais
PCTFREE 5
PCTUSED 40
;

COMMENT on table cartao is 'Esta tem como objetivo guardar todos os cartões sendo cada um distiguindo pela conta a que pertencem e a que cliente pertence.';

/*
Código que cria a tabela transacao.
Esta tem como objetivo guardar todas as transações referentes tanto a conta como ao cliente.
*/
CREATE TABLE transacao (
    nb_numerotransacao             NUMBER(4) DEFAULT transacao_nb_numerotransacao.NEXTVAL,
    vc_plataforma                  VARCHAR2(3) NOT NULL,
    nb_valor                       NUMBER(9,2) NOT NULL,
    nb_categoria                   number(4),
    nb_operacao                    number(4),
    dta_dtatransacao               DATE NOT NULL,
    nb_IBANRecetor                 NUMBER(16),
    nb_ncliente                    NUMBER(4),
    nb_iban                        NUMBER(16),
    nb_Cartao                      NUMBER(4),
    CONSTRAINT transacao_pk PRIMARY KEY ( nb_numerotransacao ),
    CONSTRAINT transacao_categoria_fk FOREIGN KEY ( nb_categoria ) REFERENCES categoria ( nb_categoria ) ON DELETE SET NULL,
    CONSTRAINT transacao_operacao_fk FOREIGN KEY ( nb_operacao ) REFERENCES operacao ( nb_operacao ) ON DELETE SET NULL,
    CONSTRAINT transacao_conta_fk FOREIGN KEY ( nb_IBANRecetor ) REFERENCES conta ( nb_iban ) ON DELETE SET NULL,
    CONSTRAINT transacao_titular_fk FOREIGN KEY ( nb_ncliente, nb_iban ) REFERENCES titular ( nb_ncliente, nb_iban ) ON DELETE CASCADE,
    CONSTRAINT transacao_cartao_fk FOREIGN KEY ( nb_Cartao ) REFERENCES cartao ( nb_numeroCartao ) ON DELETE SET NULL,
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
PCTFREE 0
PCTUSED 0;

COMMENT on table transacao is 'Esta tem como objetivo guardar todas as transações referentes tanto a conta como ao cliente.';

/*
Código que cria a tabela de AlteracoesCliente.
Esta tem como objetivo guardar os dados de todos as alterações que iram ocorrer na tabela cliente.
*/
CREATE TABLE AlteracoesCliente(
nb_numero number(4) DEFAULT alteracoe_seq.NEXTVAL,
vc_operacao varchar2(6),
vc_user varchar2(100),
dta_dataAlteracao date,
nb_clientealterado NUMBER(4),
CONSTRAINT alteracoescliente_pk PRIMARY KEY (nb_numero)
)
TABLESPACE FE3C_gerais
PCTFREE 0
PCTUSED 0;

COMMENT on table AlteracoesCliente is 'Esta tem como objetivo guardar os dados de todos as alterações que iram ocorrer na tabela cliente.';

/*
Código que cria a tabela de Historicotransacao.
Esta tem como objetivo guardar os dados de todos as transações realizadas.
*/

CREATE TABLE Historicotransacao (
    nb_numerotransacao             NUMBER(4),
    vc_plataforma                  VARCHAR2(3) NOT NULL,
    nb_valor                       NUMBER(9,2) NOT NULL,
    nb_categoria                   number(4),
    nb_operacao                    number(4),
    dta_dtatransacao               DATE NOT NULL,
    nb_IBANRecetor                    NUMBER(16),
    nb_ncliente                    NUMBER(4),
    nb_iban                        NUMBER(16),
    nb_Cartao                      NUMBER(4),
    CONSTRAINT Historicotransacao_pk PRIMARY KEY ( nb_numerotransacao )
)
TABLESPACE transacao
PCTFREE 0
PCTUSED 0
;

COMMENT on table Historicotransacao is 'Esta tem como objetivo guardar os dados de todos as transações realizadas.';

ALTER SESSION ENABLE PARALLEL DML;