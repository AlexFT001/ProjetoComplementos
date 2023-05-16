/*
	procedimento que adiciona na tabela de logs um registro de erro quando alguma restrição não é respeitada 
*/
CREATE OR REPLACE PROCEDURE insert_loglog (operation_value varchar2,short_messages varchar2) AS
  p_operation VARCHAR2(100) := operation_value;
  short_message VARCHAR2(200) := short_messages;
  p_user_logged VARCHAR2(100) := USER;
BEGIN
  INSERT INTO loglog (operation, user_logged, log_date,short_message)
  VALUES (p_operation, p_user_logged, SYSDATE,short_message);
  COMMIT;
END;
/





/*
esse procedimento utiliza a tabela de metadados para deletar registros da base de dados.
recebe por parâmetro o nome da tabela e o id do item a ser deletado.

todos os parâmetros são do tipo varchar2

*/

CREATE OR REPLACE PROCEDURE delete_specifc_register (table_escolhida varchar2, id_escolhido number)
is
tabelaEscolhida varchar2(200) := '';
chavePrimaria varchar2(200) := '';
BEGIN
	SELECT cols.table_name, cols.column_name
	into tabelaEscolhida,chavePrimaria
	FROM all_constraints cons, all_cons_columns cols
	WHERE cols.table_name = upper(table_escolhida)
	AND cons.constraint_type = 'P'
	AND cons.constraint_name = cols.constraint_name
	AND cons.owner = cols.owner
	ORDER BY cols.table_name, cols.position;
--dbms_output.put_line('DELETE FROM ' ||DBMS_ASSERT.SIMPLE_SQL_NAME(tabelaEscolhida) || ' WHERE '||DBMS_ASSERT.SIMPLE_SQL_NAME(chavePrimaria)||' = :'|| id_escolhido);
 EXECUTE IMMEDIATE 'DELETE FROM ' ||DBMS_ASSERT.SIMPLE_SQL_NAME(tabelaEscolhida) || ' WHERE '||DBMS_ASSERT.SIMPLE_SQL_NAME(chavePrimaria)||' = '|| id_escolhido;
 
 exception
 WHEN NO_DATA_FOUND THEN
	insert_loglog('delete_specifc_register','O Código Postal inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Código Postal inserido não existe.');
	
END;
/



/*
este procedimento utiliza a tabela de metadados para atualizar dados dos registros da base de dados.
recebe por parâmetro o nome da tabela, o id do item, o campo que será atualizado e o novo valor.
quando o campo a ser atualizado é um number basta digitá-lo, entretanto, quando atualizamos um campo em varchar temos que
sercalo por aspas simples.
*/

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


--DBMS_OUTPUT.PUT_LINE('UPDATE ' || tabelaEscolhida_V || ' SET ' ||campo_escolhido_V ||' = '|| novo_valor ||' WHERE '||nome_pk_V||' ='|| id_escolhido ||';');
EXECUTE IMMEDIATE 'UPDATE ' || tabelaEscolhida_V || ' SET ' ||campo_escolhido_V ||' = '||
novo_valor ||' WHERE '||nome_pk_V||' ='|| id_escolhido ;

exception
 WHEN NO_DATA_FOUND THEN
 insert_loglog('update_specifc_register','O Código Postal inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Código Postal inserido não existe.');
	
END;
/

/*
    Este procedimento tem como objetivo adicionar um enderenço a tabela de ENDERECO.
    Esta possui como parametro todas as colunas da tabela ENDERECO para além
    de ainda possui como parametro o a chave primaria do cliente, uma vez que esta
    também associa este mesmo cliente com o endereço criado, adicionando esta associação
    na tabela MORADACLIENTE.
    Ainda é validade se o a cidade corresponde ao codigo postal inserido.
*/

CREATE OR REPLACE PROCEDURE SP_ENDERECO_INSERT
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
    cidadeVerificar codpostal_ext.vc_cidade%type;
    cidadeRecebida endereco.vc_cidade%type;
	excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN
 IF UPPER(pais) LIKE 'PORTUGAL'
 THEN

    SELECT vc_cidade
    INTO cidadeverificar
    FROM codPostal_EXT
    WHERE nb_codpostal = codigopostal;

    cidaderecebida := UPPER(cidade)||CHR(13);

         IF cidaderecebida LIKE cidadeverificar
         THEN
            INSERT INTO ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_conselho, vc_distrito, vc_pais)
            VALUES (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais)
            RETURNING  nb_nendereco INTO numeroEndereco;

            INSERT INTO moradacliente VALUES (cliente,numeroEndereco);
         ELSE
		 insert_loglog('SP_ENDERECO_INSERT','A cidade inserida não corresponde com o código Postal');
            RAISE_APPLICATION_ERROR(-20001, 'A cidade inserida não corresponde com o código Postal');
        END IF;
ELSE
    INSERT INTO ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_conselho, vc_distrito, vc_pais)
    VALUES (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais)
    RETURNING  nb_nendereco INTO numeroEndereco;

    INSERT INTO moradacliente VALUES (cliente,numeroEndereco);
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
insert_loglog('SP_ENDERECO_INSERT','O Código Postal inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Código Postal inserido não existe.');
WHEN excepcao_existente
    THEN
	insert_loglog('SP_ENDERECO_INSERT','O Cliente inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Cliente inserido não existe.');
		
	
END SP_ENDERECO_INSERT;
/

/*
    Este procedimento tem como objetivo adicionar uma conta a tabela de CONTA.
    Esta possui como parametros todas as colunas tabela CONTA sendo que ainda possui como
    parametro a chave primaria do cliente, uma vez que esta
    também associa este mesmo cliente com a conta criada, adicionando esta associação
    na tabela TITULAR.
    Também é utilizada a função titularOrdem() para defenir a ordem de titularidade.
*/

CREATE OR REPLACE PROCEDURE SP_CONTA_INSERT
    (
     saldo conta.nb_saldo%type,
     tipodeConta conta.nb_tipo%type,
     agenciaConta conta.NB_agencia_nb_nagencia%type,
     produto conta.nb_produto_nb_numproduto%type,
     cliente cliente.nb_ncliente%type
     )
AS
    numeroConta conta.nb_iban%type;
    titularidade varchar2(20);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN
   IF saldo > 0
   THEN
    IF UPPER(tipodeConta) LIKE 'ORDEM' OR UPPER(tipodeConta) LIKE 'PRAZO'
    THEN
    INSERT INTO CONTA (nb_saldo, nb_tipo, NB_agencia_nb_nagencia,nb_produto_nb_numproduto)
    VALUES (saldo, UPPER(tipodeConta), agenciaConta, produto)
    RETURNING  nb_iban INTO  numeroConta;
    ELSE
	insert_loglog('SP_CONTA_INSERT','Tipo de Conta desconhecido.');
        RAISE_APPLICATION_ERROR(-20001, 'Tipo de Conta desconhecido.');
    END IF;

    titularidade := titularOrdem(numeroConta);

    INSERT INTO titular
    VALUES (cliente, numeroConta, TO_DATE(CURRENT_DATE, 'dd/mm/yyyy'), titularidade);
   ELSE
    insert_loglog('SP_CONTA_INSERT','O saldo não pode ser negativo.');
       RAISE_APPLICATION_ERROR(-20001, 'O saldo não pode ser negativo.');
	  
   END IF;
EXCEPTION
WHEN excepcao_existente
    THEN
	insert_loglog('SP_CONTA_INSERT','O prodotu ou o Cliente ou a agência inseridos não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O prodotu ou o Cliente ou a agência inseridos não existe.');
	
END SP_CONTA_INSERT;
/


/*
    Este procedimento tem como associar uma conta a um cliente desta forma
    um cliente (que já possui uma conta) podera ficar associado a outra conta.
*/
CREATE OR REPLACE PROCEDURE SP_TITULAR_INSERT
    (
     iban conta.nb_iban%type,
     cliente cliente.nb_ncliente%type
     )
AS
    titularidade varchar2(20);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN

    titularidade := titularOrdem(iban);

    INSERT INTO titular VALUES (cliente,iban,TO_DATE(current_date,'dd/mm/yyy'),titularidade);

EXCEPTION
WHEN excepcao_existente
    THEN
	insert_loglog('SP_TITULAR_INSERT','O iban ou o Cliente inseridos não existem.');
    RAISE_APPLICATION_ERROR(-20001, 'O iban ou o Cliente inseridos não existem.');
	
END SP_TITULAR_INSERT;
/


/*
    Este procedimento tem como objetivo adicionar um Cliente a tabela CLIENTE.
    Esta possui como parametro, quase todas as colunas da tabela CLIENTE e ainda possui como
    parametro as colunas da tabela ENDERECO e da tabela CONTA, isto porque quando um cliente
    é registrado num banco o mesmo tem de se encontrar associado tanto a um endereço como a uma
    conta, deste modo dentro deste procedure  são utilizados os procedure SP_ENDERECO_INSERT e SP_CONTA_INSERT são chamados.
    Caso um cliente não possua E-mail e por sua vez PassWord, ambos parametros deverão ser recebidos
    como null.
*/

CREATE OR REPLACE PROCEDURE SP_CLIENTE_INSERT
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
     tipodeConta conta.nb_tipo%type,
     produto conta.nb_produto_nb_numproduto%type,
     agencia agencia.nb_nagencia%type
     )
AS
    numeroCliente cliente.nb_ncliente%type;
    tamanhoNif NUMBER(9);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN

    tamanhonif := tamanhoNumero(nif);

    IF tamanhonif = 9
    THEN
        INSERT INTO CLIENTE (NB_nif, vc_nome, nb_idade, vc_profissao, dt_datanascimento, vc_email, vc_password, nb_agencia_nb_nagencia)
        VALUES (nif, nome, TRUNC(MONTHS_BETWEEN(sysdate, dataNascimento)/12), profissao, dataNascimento, emailcliente, passWordcliente, agencia)
        RETURNING  nb_ncliente into numeroCliente;

        SP_ENDERECO_INSERT (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais, numeroCliente);

        SP_CONTA_INSERT(saldo, tipodeConta, agencia, produto, numeroCliente);
    ELSE
		insert_loglog('SP_CLIENTE_INSERT','O NIF tem de possuir 9 digitos');
        RAISE_APPLICATION_ERROR(-20001, 'O NIF tem de possuir 9 digitos');
    END IF;
EXCEPTION
WHEN excepcao_existente
    THEN
	insert_loglog('SP_CLIENTE_INSERT','O produto ou a agência inserida não existem.');
    RAISE_APPLICATION_ERROR(-20001, 'O produto ou a agência inserida não existem.');
	
WHEN DUP_VAL_ON_INDEX
THEN
insert_loglog('SP_CLIENTE_INSERT','O email ou o NIF inseridos já se encontram inseridos.');
    RAISE_APPLICATION_ERROR(-20001, 'O email ou o NIF inseridos já se encontram inseridos.');
	
END SP_CLIENTE_INSERT;
/

/*
    Este procedimento tem como objetivo adicionar um cartão a tabela CARTAO.
    Esta possui, como parametro algumas colunas da tabela CARTAO e ainda possui como
    parametro a chave primaria da tabela CLIENTE e da tabela CONTA, uma vez que o este tem de estar
    associado tanto com um cliente, tanto como uma conta, é verificado se o PIN recebido possui
    4 digitos, a data de validade é gerada tendo em conta a data de criação + 4 anos, e o cvv
    é gerado a partir de uma sequência.
    Ainda é verificado se a conta é à Ordem uma vez que somente esta pode possuir cartões.
*/

CREATE OR REPLACE PROCEDURE SP_CARTAO_INSERT
    (pin  cartao.nb_pin%type,
     iban cartao.nb_titular_nb_iban%type,
     numerCliente cartao.nb_titular_nb_ncliente%type)
AS
    tipoConta conta.nb_tipo%type;
    validade date;
    tamanho number(5);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN
    SELECT nb_tipo
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
		 insert_loglog('SP_CARTAO_INSERT','O PIN tem de possuir 4 dígitos');
             RAISE_APPLICATION_ERROR(-20001, 'O PIN tem de possuir 4 dígitos');
			
        END IF;
    ELSE
	insert_loglog('SP_CARTAO_INSERT','Conta a Crédito');
        RAISE_APPLICATION_ERROR(-20001, 'Conta a Crédito');
		
    end if;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_CARTAO_INSERT','O Iban inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Iban inserido não existe.');
	
    WHEN excepcao_existente
    THEN
	insert_loglog('SP_CARTAO_INSERT','O Cliente inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Cliente inserido não existe.');
		
END SP_CARTAO_INSERT;
/


/*
    Este procedimento tem como objetivo adicionar um Funcionario a tabela FUNCIONARIO.
    Esta possui como parametro todas as colunas da tabela FUNCIONARIO e ainda possui como
    parametro a chave primaria da tabela AGENCIA, uma vez que é a partir deste parametro que
    se sabe em que agência o Funcionário trabalha.
*/
CREATE OR REPLACE PROCEDURE SP_FUNCIONARIO_INSERT
    (nome funcionario.vc_nome%type,
     agencia funcionario.nb_agencia_nb_nagencia%type,
     dataNascimento funcionario.dta_dtanascimento%type,
     superior funcionario.nb_funcionario_nb_nsupervisor%type
    )
AS
    gerente funcionario.nb_nfuncionario%type;
    agenciaId  NUMBER(4);
    funcionarioId funcionario.nb_nfuncionario %type;

BEGIN
    SELECT nb_funcionario_nb_ngerente, nb_nagencia
    INTO gerente, agenciaid
    FROM agencia
    WHERE nb_nagencia = agencia;

    IF agenciaid IS NOT NULL
    THEN
    INSERT INTO FUNCIONARIO (vc_nome, nb_agencia_nb_nagencia, dta_dtanascimento,nb_funcionario_nb_nsupervisor)
    VALUES (nome, agencia, TO_DATE(dataNascimento, 'dd/mm/yyyy'), superior)
    RETURNING nb_nfuncionario  INTO funcionarioid ;

    IF gerente IS NULL
        THEN
        update_specifc_register('agencia', agencia,'nb_funcionario_nb_ngerente', funcionarioid);
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_FUNCIONARIO_INSERT','A agência inserida não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'A agência inserida não existe.');
	
END SP_FUNCIONARIO_INSERT;
/

/*
    Este procedimento tem como objetivo adicionar um número de registros, que é recebido por parametro,
    com dados aleatórios na tabela TRANSACAO.
*/
CREATE OR REPLACE PROCEDURE SP_TRANSACAO_ALEATORIO
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
    randomNumber := numeroaleatorio(1,3);

    IF randomNumber = 1 THEN
		plataforma := 'WEB';
	ELSE
		plataforma := 'ATM';
	END IF;
    valor := numeroaleatorio(10,999);

    SELECT COUNT(nb_operacao)
    INTO quantidadevalores1
    FROM operacao;

    quantidadevalores1 := numeroaleatorio(1000, (quantidadevalores1+1000));

    SELECT nb_operacao, vc_nome_operacao
    INTO operacao, operacaonome
    FROM operacao
    WHERE nb_operacao = quantidadevalores1;

    SELECT COUNT(nb_categoria)
    INTO quantidadevalores2
    FROM categoria;

    quantidadevalores2 := numeroaleatorio(1000, (quantidadevalores2+1000));

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
            WHERE rownum =1 AND nb_iban != contatransacao;
         ELSE
            RETURN;
        end if;

            SELECT nb_operacao, vc_nome_operacao
            INTO operacao, operacaonome
            FROM operacao
            WHERE vc_nome_operacao LIKE 'TRANSFERENCIA';
ELSE
    IF operacaonome = 'TRANSFERENCIA'
    THEN
            SELECT nb_iban
            INTO contarecetora
            FROM
            (SELECT  nb_iban FROM conta
            ORDER BY dbms_random.value)
            WHERE rownum =1 AND nb_iban != contatransacao;
    ELSE
        contarecetora := null;
    END IF;
END IF;

    SELECT nb_tipo, nb_saldo
    INTO tipoconta, contasaldo
    FROM conta
    WHERE nb_iban = contatransacao;

    IF contarecetora IS NOT NULL
    THEN
        SELECT nb_saldo
        INTO contarecetorasaldo
        FROM conta
        WHERE nb_iban = contarecetora;
    END IF;

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
            update_specifc_register('CONTA', contatransacao,'nb_saldo' , (contasaldo-valor) );
        ELSE
            update_specifc_register('CONTA', contatransacao,'nb_saldo' , (contasaldo+valor) );
        END IF;
    ELSE
            update_specifc_register('CONTA', contarecetora,'nb_saldo' , (contarecetorasaldo+valor) );
    END IF;

END IF;
END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
insert_loglog('SP_TRANSACAO_ALEATORIO','Não existem dados na base de dados sufcientes para gerar uma transação.');
    RAISE_APPLICATION_ERROR(-20001, 'Não existem dados na base de dados sufcientes para gerar uma transação.');
	
END SP_TRANSACAO_ALEATORIO;
/

/*
    Este procedimento tem como objetivo adicionar uma Agencia a tabela AGENCIA,
    sendo que como uma agência é diferenciada a partir de um endereço, este procedure
    também insere este endereço na tabela ENDERECO.
*/
CREATE OR REPLACE PROCEDURE SP_AGENCIA_INSERT
    (
     rua endereco.vc_rua%type,
     codigoPostal endereco.nb_codpostal%type,
     numPorta endereco.nb_numporta%type,
     cidade endereco.vc_cidade%type,
     conselho endereco.vc_conselho%type,
     distrito endereco.vc_distrito%type,
     pais endereco.vc_pais%type
     )
AS
    numeroEndereco endereco.nb_nendereco%type;
    cidadeVerificar codpostal_ext.vc_cidade%type;
    cidadeRecebida endereco.vc_cidade%type;

BEGIN

    SELECT  vc_cidade
    INTO cidadeverificar
    FROM codpostal_ext
    WHERE nb_codpostal = codigopostal;

    cidaderecebida := UPPER(cidade)||CHR(13);

         IF cidaderecebida LIKE cidadeverificar
         THEN
            INSERT INTO ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_conselho, vc_distrito, vc_pais)
            VALUES (rua, codigoPostal, numPorta, cidade, conselho, distrito, pais)
            RETURNING  nb_nendereco INTO numeroEndereco;

            INSERT INTO AGENCIA (nb_endereco_nendreco) VALUES (numeroEndereco);
        ELSE
			insert_loglog('SP_AGENCIA_INSERT','A cidade inserida não corresponde com o código Postal');
             RAISE_APPLICATION_ERROR(-20001, 'A cidade inserida não corresponde com o código Postal');
        END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_AGENCIA_INSERT','O Código Postal inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Código Postal inserido não existe.');
	
END SP_AGENCIA_INSERT;
/

/*
Procedimento de inserção manual de dados na tabela operações
execute sp_operacao_insert('operações');
*/
CREATE OR REPLACE PROCEDURE sp_operacao_insert(  nome_operacao varchar2)
IS

BEGIN

INSERT INTO operacao (VC_NOME_OPERACAO) VALUES (nome_operacao );
EXCEPTION
   WHEN OTHERS THEN
    insert_loglog('Insert',SQLERRM);
      dbms_output.put_line( SQLERRM );
	 
END sp_operacao_insert;
/

/*
Procedimento de inserção manual de dados na tabela produto
execute sp_produto_insert('produtos');
*/
CREATE OR REPLACE PROCEDURE sp_produto_insert(nome_ops varchar2)
IS
BEGIN
INSERT INTO PRODUTO (VC_TIPOPRODUTO) VALUES (nome_ops);
EXCEPTION
   WHEN OTHERS THEN
    insert_loglog('Insert',SQLERRM);
      dbms_output.put_line( SQLERRM );
	 
END sp_produto_insert;
/

/*
Procedimento de inserção manual de dados na tabela categoria
execute sp_produto_insert('categoria');
*/
CREATE OR REPLACE PROCEDURE sp_categoria_insert(nome_cat varchar2)
IS
BEGIN
INSERT INTO categoria (VC_NOME_CATEGORIA) VALUES (nome_cat);
EXCEPTION
   WHEN OTHERS THEN
    insert_loglog('Insert',SQLERRM);
      dbms_output.put_line( SQLERRM );
	 
END sp_categoria_insert;
/



