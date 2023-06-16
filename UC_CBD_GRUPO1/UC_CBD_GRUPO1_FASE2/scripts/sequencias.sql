/*
Código que cria a sequencia para a PRIMARY KEY da tabela endereço.
*/
CREATE SEQUENCE endereco_nb_nendereco_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela agencia.
*/
CREATE SEQUENCE agencia_nb_nagencia_seq START WITH 1000  INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela categoria.
*/
CREATE SEQUENCE categoria_nb_categoria START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela operação.
*/
CREATE SEQUENCE operacao_nb_operacao START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela cliente.
*/
CREATE SEQUENCE cliente_nb_nif_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela produto.
*/
CREATE SEQUENCE produto_nb_numproduto_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela conta.
*/
CREATE SEQUENCE conta_nb_iban_seq START WITH 1000000000000000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela funcionario.
*/
CREATE SEQUENCE funcionario_nb_nfuncionario START WITH 1000 INCREMENT BY 1 NOCACHE;
/*
Código que cria a sequencia para a PRIMARY KEY da tabela cartao.
*/
CREATE SEQUENCE cartao_nb_numero_seq START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a PRIMARY KEY da tabela transacao.
*/
CREATE SEQUENCE transacao_nb_numerotransacao START WITH 1000 INCREMENT BY 1 NOCACHE;

/*
Código que cria a sequencia para a inserção automática do cvv no procedimento
*/
CREATE SEQUENCE cartao_cvv START WITH 100 INCREMENT BY 1 NOCACHE;

/*

Código que cria a sequencia para a PRIMARY KEY da tabela loglog.

*/

CREATE SEQUENCE loglog_seq START WITH 1 INCREMENT BY 1 NOCACHE;


/*

Código que cria a sequencia para a PRIMARY KEY da tabela alteracoe_seq.

*/
CREATE SEQUENCE alteracoe_seq START WITH 1 INCREMENT BY 1 NOCACHE;