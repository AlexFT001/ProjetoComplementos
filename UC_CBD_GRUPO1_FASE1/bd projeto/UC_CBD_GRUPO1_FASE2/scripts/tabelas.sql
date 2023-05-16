/*
Código que cria a tabela de logs.
Que tem como objetivo guardar os dados de todos os erros durante a inserção
para posterior análise.
*/
create table loglog(
ordem number DEFAULT loglog_seq.NEXTVAL,
operation varchar2(100),
user_logged varchar2(100),
log_date date,
short_message varchar2(200),
CONSTRAINT loglog_pk PRIMARY KEY (ordem)
);

/*
Código que cria a tabela endereço.
Que tem como objetivo guardar os dados dos endereços das 10 agências
os endereços de cada cliente.
*/
CREATE TABLE endereco (
    nb_nendereco   NUMBER(4) DEFAULT endereco_nb_nendereco_seq.NEXTVAL,
    vc_rua         VARCHAR2(50) NOT NULL,
    nb_codpostal   NUMBER(7) NOT NULL,
    nb_numporta    NUMBER(2) NOT NULL,
    vc_cidade      VARCHAR2(50) NOT NULL,
    vc_conselho    VARCHAR2(50) NOT NULL,
    vc_distrito    VARCHAR2(50) NOT NULL,
    vc_pais        VARCHAR2(50) NOT NULL,
    CONSTRAINT endereco_pk PRIMARY KEY ( nb_nendereco )
)
TABLESPACE FE3C_gerais
PCTFREE 10
PCTUSED 40
;



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
PCTFREE 0
PCTUSED 40
;


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
PCTFREE 10
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
Código que cria a tabela categoria.
Está tem como objetivo possuir as categorias referentes a cada transferência.
*/
CREATE TABLE categoria (
    nb_categoria   NUMBER(4) DEFAULT categoria_nb_categoria.NEXTVAL,
    vc_nome_categoria    VARCHAR2(20) NOT NULL,
    CONSTRAINT categoria_pk PRIMARY KEY ( nb_categoria )
)
TABLESPACE PAC_gerais  
PCTFREE 5
PCTUSED 40;


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
PCTFREE 5
PCTUSED 40
;

/*
Código que cria a tabela cliente.
Está tem como objetivo possuir todas os dados de cada cliente.
*/
CREATE TABLE cliente (
    nb_ncliente NUMBER(4) DEFAULT cliente_nb_nif_seq.NEXTVAL,
    nb_nif             NUMBER(9) UNIQUE,
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
PCTFREE 5
PCTUSED 40;


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
PCTFREE 5
PCTUSED 40;


/*
Código que cria a tabela conta.
Está tem como objetivo possuir todas as contas existentes.
*/
CREATE TABLE conta
(
    nb_iban                  NUMBER(16) DEFAULT conta_nb_iban_seq.NEXTVAL,
    nb_saldo                 NUMBER(10) NOT NULL,
    nb_tipo                  VARCHAR2(10) NOT NULL,
    nb_produto_nb_numproduto NUMBER(4),
    NB_agencia_nb_nagencia      NUMBER(4),
    CONSTRAINT conta_pk PRIMARY KEY (nb_iban),
    CONSTRAINT conta_agencia_fk FOREIGN KEY (NB_agencia_nb_nagencia) REFERENCES agencia (nb_nagencia),
    CONSTRAINT conta_produto_fk FOREIGN KEY (nb_produto_nb_numproduto) REFERENCES produto (nb_numproduto),
    CONSTRAINT conta_tipo_ck CHECK(nb_tipo IN('PRAZO','ORDEM'))
)
TABLESPACE FE3C_gerais
PCTFREE 15
PCTUSED 40;


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
PCTFREE 10
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
PCTFREE 15
PCTUSED 40;

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
PCTFREE 10
PCTUSED 40
;

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
PCTFREE 15
PCTUSED 40;


CREATE TABLE codPostal_EXT(
    NB_CodPostal NUMBER(7),
    vc_cidade VARCHAR2(50),
    CONSTRAINT codPosta_pk PRIMARY KEY ( NB_CodPostal )
)
TABLESPACE cidadeexternal
PCTFREE 10
PCTUSED 40;


