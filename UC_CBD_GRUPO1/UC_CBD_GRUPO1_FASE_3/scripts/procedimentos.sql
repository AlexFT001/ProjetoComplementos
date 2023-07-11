/*
	procedimento que adiciona na tabela de logs um registro de erro quando alguma restrição não é respeitada 
*/
CREATE OR REPLACE PROCEDURE insert_loglog (operation_value varchar2,short_messages varchar2) AS
  p_operation VARCHAR2(100) := operation_value;
  short_message VARCHAR2(200) := short_messages;
  p_user_logged VARCHAR2(100) := USER;
BEGIN
  INSERT INTO /*+ APPEND PARALLEL(logErros, DEFAULT)*/  logErros (vc_operacao, vc_user, dta_datalog,vc_short_message)
  VALUES (p_operation, p_user_logged, SYSDATE,short_message);
  COMMIT;
END;
/


/*
procedimento para transferir dados  e fazer purge das transações.
recebe o ano como parammetro de forma a inserir todos os dados referentes a esse ano na tabela histórico
e a eliminar os dados referentes a esse ano da tabela das transações.
*/

create or replace PROCEDURE mover_historico (ano NUMBER) IS
vaar number:=0;
anoformatado VARCHAR2(10);

BEGIN

   anoformatado := SUBSTR(TO_CHAR(ano), 3);

insert into /*+ APPEND PARALLEL(historicotransacao, DEFAULT)*/ historicotransacao SELECT /*+ parallel(t)*/t.*
FROM transacao t
WHERE EXTRACT(YEAR FROM DTA_DTATRANSACAO) = anoformatado;


delete from transacao WHERE EXTRACT(YEAR FROM DTA_DTATRANSACAO) = anoformatado;
END ;
/
--commit;
/*
este procedimento utiliza a tabela de metadados para eliminar dados dos registros da base de dados.
recebe por parâmetro o nome da tabela, e o/s id/s da linha a eliminar.


tabelaEscolhida_V = NOME DA TABELA DESEJADA
id_escolhido = NOME DA CHAVE PRIMÁRIA 1
id_escolhido2 = NOME DA CHAVE PRIMÁRIA 2 (Caso não possua enviar 0)
nome_pk_V = NOME DA CHAVE PRIMÁRIA QUE ELE BUSCA AUTOMATICAMENTE

*/
create or replace PROCEDURE delete_specifc_register (table_escolhida varchar2, id_escolhido number, id_escolhido2 number)
is
tabelaEscolhida varchar2(200) := '';
chavePrimaria varchar2(200) := '';
qtd number;
conta number := 1;
conta2 number := 1;
filho varchar2(200) := '';
parant_pk varchar2(200) := '';

--seleciona a tabela escolhida e a chave primária
cursor ids_regs is
    SELECT cols.table_name, cols.column_name
    into tabelaEscolhida,chavePrimaria
	FROM all_constraints cons, all_cons_columns cols
	WHERE cols.table_name = upper(table_escolhida)
	AND cons.constraint_type = 'P'
	AND cons.constraint_name = cols.constraint_name
	AND cons.owner = cols.owner
	ORDER BY cols.table_name, cols.position;
    

registros ids_regs%rowtype;

BEGIN
--seleciona a quantidade de chaves primárias da tabela. se for uma executa o primeiro if se for duas executa o segundo if
SELECT count(cols.table_name)
into qtd
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name = upper(table_escolhida)
AND cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
ORDER BY cols.table_name, cols.position
;

open ids_regs;

loop
fetch ids_regs into registros;
EXIT WHEN ids_regs%NOTFOUND;

if qtd = 1 then
    if conta =1 then
    EXECUTE IMMEDIATE 'DELETE FROM ' || registros.table_name || ' WHERE '|| registros.column_name ||' = '|| id_escolhido ;
    conta := conta +1;
    end if;
end if;



if qtd = 2 then
    if conta2 =1 then
    EXECUTE IMMEDIATE 'DELETE FROM ' ||registros.table_name || ' WHERE '||registros.column_name||' = '|| id_escolhido;

    conta2 := conta2 +1;
    end if;

    if conta2 =3 then
    EXECUTE IMMEDIATE 'DELETE FROM ' ||registros.table_name || ' WHERE '||registros.column_name||' = '|| id_escolhido2;

    conta2 := conta2 +1;
    end if;

    if conta2 =2  then
     conta2 := conta2 +1;
    end if;

    if conta2 =4 then
     conta2 := conta2 +1;
    end if;

end if;
end loop;
close ids_regs;
conta2:=1;
conta :=1;




 exception
 WHEN NO_DATA_FOUND THEN
	 
    insert_loglog('delete_specifc_register','O Primary Key recebido não existe.');
   
    RAISE_APPLICATION_ERROR(-20001, 'O Primary Key recebido não existe.');
    

END;
/

/*
este procedimento utiliza a tabela de metadados para atualizar dados dos registros da base de dados.
recebe por parâmetro o nome da tabela, o id do item, o campo que será atualizado e o novo valor.
quando o campo a ser atualizado é um number basta digitá-lo, entretanto, quando atualizamos um campo em varchar temos que
cercá-lo por aspas simples.


tabelaEscolhida_V = NOME DA TABELA DESEJADA
id_escolhido = NOME DA CHAVE PRIMÁRIA 1
id_escolhido2 = NOME DA CHAVE PRIMÁRIA 2 (Caso não possua enviar 0)
nome_pk_V = NOME DA CHAVE PRIMÁRIA QUE ELE BUSCA AUTOMATICAMENTE
*/
create or replace PROCEDURE update_specifc_register(tabela_escolhida varchar2, id_escolhido number, id_escolhido2 number, campo_escolhido varchar2, novo_valor varchar2)
is
tabelaEscolhida varchar2(200) := '';
chavePrimaria varchar2(200) := '';
qtd number;
conta number := 1;
conta2 number := 1;
filho varchar2(200) := '';
parant_pk varchar2(200) := '';

--seleciona a tabela escolhida e a chave primária
cursor C_Update is
    SELECT cols.table_name, cols.column_name
    into tabelaEscolhida,chavePrimaria
	FROM all_constraints cons, all_cons_columns cols
	WHERE cols.table_name = upper(tabela_escolhida)
	AND cons.constraint_type = 'P'
	AND cons.constraint_name = cols.constraint_name
	AND cons.owner = cols.owner
	ORDER BY cols.table_name, cols.position;



registros C_Update%rowtype;

BEGIN
--seleciona a quantidade de chaves primárias da tabela. se for uma executa o primeiro if se for duas executa o segundo if
SELECT count(cols.table_name)
into qtd
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name = upper(tabela_escolhida)
AND cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
ORDER BY cols.table_name, cols.position
;

open C_Update;

loop
fetch C_Update into registros;
EXIT WHEN C_Update%NOTFOUND;

if qtd = 1 then
    if conta =1 then

    EXECUTE IMMEDIATE 'UPDATE ' || registros.table_name  || ' SET ' ||campo_escolhido ||' = '|| novo_valor ||' WHERE '||registros.column_name||' ='|| id_escolhido ;
    conta := conta +1;
    end if;
end if;


if qtd = 2 then
    if conta2 =1 then

    EXECUTE IMMEDIATE 'UPDATE ' || registros.table_name  || ' SET ' ||campo_escolhido ||' = '|| novo_valor ||' WHERE '||registros.column_name||' ='|| id_escolhido ;

    conta2 := conta2 +1;
    end if;

    if conta2 =3 then

    EXECUTE IMMEDIATE 'UPDATE ' || registros.table_name  || ' SET ' ||campo_escolhido ||' = '|| novo_valor ||' WHERE '||registros.column_name||' ='|| id_escolhido2 ;

    conta2 := conta2 +1;
    end if;

    if conta2 =2  then
     conta2 := conta2 +1;
    end if;

    if conta2 =4 then
     conta2 := conta2 +1;
    end if;

end if;
end loop;
close C_Update;
conta2:=1;
conta :=1;

 exception
 WHEN NO_DATA_FOUND THEN
    insert_loglog('delete_specifc_register','O Primary Key recebido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Primary Key recebido não existe.');
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
     concelho endereco.vc_concelho%type,
     distrito endereco.vc_distrito%type,
     pais endereco.vc_pais%type,
     cliente cliente.nb_ncliente%type
     )
AS
    numeroEndereco endereco.nb_nendereco%type;
    cidadeVerificar ext_codPostal.vc_cidade%type;
    cidadeRecebida endereco.vc_cidade%type;
    distritoverificar endereco.vc_distrito%type;
    codDistrito ext_distrito.NB_CodDistrito%type;
    codConcelho ext_concelho.NB_CodConcelho%type;
	excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN
 IF UPPER(pais) LIKE 'PORTUGAL'
 THEN

     /*
    Bloco de código que seleciona o codigo do distrito e do conselho de acordo
    com o nome do conselho recebido.
    */
    Select /*+PARALLEL(ext_concelho, DEFAULT)*/  NB_CodConcelho, NB_CodDistrito
    INTO  codConcelho, codDistrito
    FROM ext_concelho
    WHERE vc_concelho = InitCap(concelho);

    /*
    Bloco de código que seleciona o nome do distrito de acordo com o codigo do mesmo recebido no
    coígo anterior.
    */
    SELECT /*+PARALLEL(ext_distrito, DEFAULT)*/ vc_distrito
    INTO distritoverificar
    FROM ext_distrito
    WHERE NB_CodDistrito = codDistrito;

    /*
    Verificação que o distrito recebido anteriormente corresponde com o distrido rcebido por
    parametro.
    */
    IF upper(distritoverificar) LIKE upper(distrito)
    THEN
    /*
        Se ambos distritos coincidirem é realizado um select para obter a cidade
        utilizando o codigo de distrito e de conselho obtidos anteriormente
        e o codigo postal recebido por parametro.
    */
    SELECT /*+PARALLEL(ext_codPostal, DEFAULT)*/ vc_cidade
    INTO cidadeverificar
    FROM ext_codPostal
    WHERE nb_codpostal = codigopostal and NB_CodConcelho = codConcelho and NB_CodDistrito = codDistrito;

    cidaderecebida := UPPER(cidade)||CHR(13);
            /*
            Verificação que a cidade recebido anteriormente corresponde com a cidade rcebido por
            parametro.
            */
             IF cidaderecebida LIKE cidadeverificar
             THEN
                INSERT INTO /*+ APPEND PARALLEL(ENDERECO, DEFAULT)*/ ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_concelho, vc_distrito, vc_pais)
                VALUES (rua, codigoPostal, numPorta, cidade, concelho, distrito, pais)
                RETURNING  nb_nendereco INTO numeroEndereco;

                INSERT INTO /*+ APPEND PARALLEL(moradacliente, DEFAULT)*/ moradacliente VALUES (cliente,numeroEndereco);
             ELSE
             insert_loglog('SP_ENDERECO_INSERT','A cidade inserida não corresponde com o código Postal');
                RAISE_APPLICATION_ERROR(-20001, 'A cidade inserida não corresponde com o código Postal');
            END IF;
    ELSE
        insert_loglog('SP_ENDERECO_INSERT','O distrito inserido não corresponde ao distrito  do concelho inserido.');
        RAISE_APPLICATION_ERROR(-20001, 'O distrito inserido não corresponde ao distrito do concelho inserido.');
    END IF;
ELSE
    INSERT INTO /*+ APPEND PARALLEL(ENDERECO, DEFAULT)*/ ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_concelho, vc_distrito, vc_pais)
    VALUES (rua, codigoPostal, numPorta, cidade, concelho, distrito, pais)
    RETURNING  nb_nendereco INTO numeroEndereco;

    INSERT INTO/*+ APPEND PARALLEL(MORADACLIENTE, DEFAULT)*/ moradacliente VALUES (cliente,numeroEndereco);
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
insert_loglog('SP_ENDERECO_INSERT','O Código Postal, concelho ou distrito inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Código Postal, concelho ou distrito inserido não existe.');
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
     tipodeConta conta.vc_tipo%type,
     agenciaConta conta.nb_nagencia%type,
     produto conta.nb_nproduto%type,
     cliente cliente.nb_ncliente%type
     )
AS
    numeroConta conta.nb_iban%type;
    titularidade varchar2(20);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN
    /*
    Verificação se o saldo recebido por parametro é maior que 0.
    */
IF saldo > 0
THEN
    /*
    Verificação que o tipo de conta recebido por parámetro é a 'ORDEM' ou a 'PRAZO'.
    */
    IF UPPER(tipodeConta) LIKE 'ORDEM' OR UPPER(tipodeConta) LIKE 'PRAZO'
    THEN
        INSERT INTO /*+ APPEND PARALLEL(CONTA, DEFAULT)*/ CONTA (nb_saldo, vc_tipo, nb_nagencia,nb_nproduto)
        VALUES (saldo, UPPER(tipodeConta), agenciaConta, produto)
        RETURNING  nb_iban INTO  numeroConta;

        /*
        Função que ira devolver a ordem de titularidade que deve ser inserida na tabela TITULAR.
        */
        titularidade := titularOrdem(numeroConta);

        INSERT INTO /*+ APPEND PARALLEL(TITULAR, DEFAULT)*/ titular
        VALUES (cliente, numeroConta, TO_DATE(CURRENT_DATE, 'dd/mm/yyyy'), titularidade);
    ELSE
        insert_loglog('SP_CONTA_INSERT','Tipo de Conta desconhecido.');
        RAISE_APPLICATION_ERROR(-20001, 'Tipo de Conta desconhecido.');
    END IF;
ELSE
    insert_loglog('SP_CONTA_INSERT','O saldo não pode ser negativo.');
    RAISE_APPLICATION_ERROR(-20001, 'O saldo não pode ser negativo.');

   END IF;
EXCEPTION
WHEN excepcao_existente
    THEN
	insert_loglog('SP_CONTA_INSERT','O prodoto ou o Cliente ou a agência inseridos não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O prodoto ou o Cliente ou a agência inseridos não existe.');

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

     /*
    Função que ira devolver a ordem de titularidade que deve ser inserida na tabela TITULAR.
    */
    titularidade := titularOrdem(iban);

    INSERT INTO /*+ APPEND PARALLEL(TITULAR, DEFAULT)*/ titular VALUES (cliente,iban,TO_DATE(current_date,'dd/mm/yyy'),titularidade);

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
     concelho endereco.vc_concelho%type,
     distrito endereco.vc_distrito%type,
     pais endereco.vc_pais%type,
     saldo conta.nb_saldo%type,
     tipodeConta conta.vc_tipo%type,
     produto conta.nb_nproduto%type,
     agencia agencia.nb_nagencia%type
     )
AS
    numeroCliente cliente.nb_ncliente%type;
    nomevalidacao cliente.vc_nome%type;
    tamanhoNif NUMBER(9);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN

    nomevalidacao := REPLACE(nome, ' ', '');
    /*
    Bloco de código que valida se o nome inserido possui um caracter numérico.
    Utiliza a função REGEXP_LIKE()  que está a ser utilizada para verificar se um caractere individual do nome, corresponde a uma letra alfabética
    para isso é utilizado o padrão '[[:alpha:]]'  que representa qualquer caractere alfabético.
    A funnção REGEXP_LIKE() tem como objetivo validar se o se uma determinada expressão corresponde a uma string.
    */
    FOR indice IN 1..LENGTH(nomevalidacao) LOOP
        IF NOT REGEXP_LIKE(SUBSTR(nomevalidacao, indice, 1), '[[:alpha:]]') THEN
            insert_loglog('SP_CLIENTE_INSERT','O nome não pode conter números ou caractéres especiais.');
            RAISE_APPLICATION_ERROR(-20001, 'O nome não pode conter números ou caractéres especiais.');
            EXIT;
        END IF;
    END LOOP;

    tamanhonif := tamanhoNumero(nif);

    /*
    Verificação do tamanho do nif.
    Caso este possua 9 digitos o INSERT do cliente será realizado.
    */
    IF tamanhonif = 9
    THEN
        INSERT INTO /*+ APPEND PARALLEL(CLIENTE, DEFAULT)*/ CLIENTE (NB_nif, vc_nome, nb_idade, vc_profissao, dt_datanascimento, vc_email, vc_password, nb_nagencia)
        VALUES (nif, nome, TRUNC(MONTHS_BETWEEN(sysdate, dataNascimento)/12), profissao, dataNascimento, emailcliente, passWordcliente, agencia)
        RETURNING  nb_ncliente into numeroCliente;

        SP_ENDERECO_INSERT (rua, codigoPostal, numPorta, cidade, concelho, distrito, pais, numeroCliente);

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
     iban cartao.nb_iban%type,
     numerCliente cartao.nb_ncliente%type)
AS
    tipoConta conta.vc_tipo%type;
    validade date;
    tamanho number(5);
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN
    /*
    Bloco de código que ira obter o tipo da conta recebida por
    parâmetro.
    */
    SELECT /*+PARALLEL(conta, DEFAULT)*/  vc_tipo
    INTO tipoConta
    FROM conta
    WHERE nb_iban = iban;


    validade := ADD_MONTHS(sysdate, 48); --Linha de código que ira gerar a validade do cartão.

    /*
    Verificação que o tipo de conta obtida anteriormente é do tipo 'ORDEM'.
    */
    IF UPPER(tipoConta) = 'ORDEM'
     THEN
         tamanho := tamanhoNumero(pin);
        /*
        Verificção que o pin recebido possui 4 dígitos.
        Caso este possua 4 dígitos o INSERT será realizado.
        */
        IF tamanho = 4
        THEN
            INSERT INTO /*+ APPEND PARALLEL(CARTAO, DEFAULT)*/ cartao (nb_pin, nb_cvv, vc_validade, nb_ncliente, nb_iban)
            VALUES (pin, cartao_cvv.nextval, TO_DATE(validade, 'DD/MM/YYYY'), numerCliente, iban);
        ELSE
		 insert_loglog('SP_CARTAO_INSERT','O PIN tem de possuir 4 dígitos');
         RAISE_APPLICATION_ERROR(-20001, 'O PIN tem de possuir 4 dígitos');
        END IF;
    ELSE
	    insert_loglog('SP_CARTAO_INSERT','Somente contas a Ordem podem possuir cartão.');
        RAISE_APPLICATION_ERROR(-20001, 'Somente contas a Ordem podem possuir cartão.');
		
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_CARTAO_INSERT','O Iban inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Iban inserido não existe.');
	
    WHEN excepcao_existente
    THEN
	insert_loglog('SP_CARTAO_INSERT','O Cliente inserido não possui a conta inserida.');
    RAISE_APPLICATION_ERROR(-20001, 'O Cliente inserido não possui a conta inserida.');
		
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
     agencia funcionario.nb_nagencia%type,
     dataNascimento funcionario.dta_dtanascimento%type,
     superior funcionario.nb_supervisor%type
    )
AS
    gerente funcionario.nb_nfuncionario%type;
    nomevalidacao funcionario.vc_nome%type;
    funcionarioId funcionario.nb_nfuncionario %type;
BEGIN

    nomevalidacao := REPLACE(nome, ' ', '');
     /*
    Bloco de código que valida se o nome inserido possui um caracter numérico.
    Utiliza a função REGEXP_LIKE()  que está a ser utilizada para verificar se um caractere individual do nome, corresponde a uma letra alfabética
    para isso é utilizado o padrão '[[:alpha:]]'  que representa qualquer caractere alfabético.
    A funnção REGEXP_LIKE() tem como objetivo validar se o se uma determinada expressão corresponde a uma string.
    */
    FOR indice IN 1..LENGTH(nomevalidacao) LOOP
        IF NOT REGEXP_LIKE(SUBSTR(nomevalidacao, indice, 1), '[[:alpha:]]') THEN
            insert_loglog('SP_CLIENTE_INSERT','O nome não pode conter números ou caractéres especiais.');
            RAISE_APPLICATION_ERROR(-20001, 'O nome não pode conter números ou caractéres especiais.');
            EXIT;
        END IF;
    END LOOP;

    /*
    Bloco de código que ira obter o gerente da agência inserida.
    */
    SELECT /*+PARALLEL(agencia, DEFAULT)*/ nb_ngerente
    INTO gerente
    FROM agencia
    WHERE nb_nagencia = agencia;

    INSERT INTO /*+ APPEND PARALLEL(FUNCIONARIO, DEFAULT)*/ FUNCIONARIO (vc_nome, nb_nagencia, dta_dtanascimento,nb_supervisor)
    VALUES (nome, agencia, TO_DATE(dataNascimento, 'dd/mm/yyyy'), superior)
    RETURNING nb_nfuncionario  INTO funcionarioid ;

    /*
    Verificação que o gerente obtido anteriormente possui o valor 'NULL'.
    Caso isto seja verdade será realizado um update na agencia que atualizara esse valor
    para o numero do funcionário que acabou de ser criado.
    */
    IF gerente IS NULL
    THEN
        update_specifc_register('agencia', agencia, 0 ,'nb_ngerente', funcionarioid);
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
    valor NUMBER;
    quantidadevalores1 number(4);
    quantidadevalores2 number(4);
    operacao transacao.nb_operacao%type;
    categoria transacao.nb_categoria%type;
    clienteTransacao transacao.nb_ncliente%type;
    contatransacao transacao.nb_iban%type;
    emailcliente varchar2(20);
    contarecetora number(16);
    operacaoNome varchar2(20);
    tipoconta varchar2(20);
    contaSaldo NUMBER(10,2);
    contaRecetoraSaldo NUMBER(10);
    cartao NUMBER(4);
    quantidadeCartoes NUMBER(10);
BEGIN
    FOR i in 1..quantidade
    LOOP

    /*
    Bloco de código que gera um numero aleatório de 1 e 2, de maneira a escolher aleatoriamente
    qual a plataforma utilizada na transação.
    */
    randomNumber := numeroaleatorio(1,3);

    IF randomNumber = 1 THEN
		plataforma := 'WEB';
	ELSE
		plataforma := 'ATM';
	END IF;

    /*
    Bloco de código que verifica quantas categorias existem na tabela operacao.
    */
    SELECT /*+PARALLEL(operacao, DEFAULT)*/ COUNT(nb_operacao)
    INTO quantidadevalores1
    FROM operacao;
    /*
    Linha de código que utiliza a função  numeroaleatorio() para escolher uma operação aleatória,
    realizando uma soma entre o numero de operações e 1000 para assim escolher um numero real.
    */
    quantidadevalores1 := numeroaleatorio(1000, (quantidadevalores1+1000));

    /*
    Bloco de código que da os valores da operacao, escolhida aleatoriamente no codigo anterior,
    para as variaveis operacao e operacaonome.
    */
    SELECT /*+PARALLEL(operacao, DEFAULT)*/ nb_operacao, vc_nome_operacao
    INTO operacao, operacaonome
    FROM operacao
    WHERE nb_operacao = quantidadevalores1;

    /*
    Bloco de código que verifica quantas categorias existem na tabela categoria.
    */
    SELECT /*+PARALLEL(categoria, DEFAULT)*/ COUNT(nb_categoria)
    INTO quantidadevalores2
    FROM categoria;

     /*
    Linha de código que utiliza a função  numeroaleatorio() para escolher uma categoria aleatória,
    realizando uma soma entre o numero de categorias e 1000 para assim escolher um numero real.
    */
    quantidadevalores2 := numeroaleatorio(1000, (quantidadevalores2+1000));

    /*
    Bloco de código que da a primary key da categoria, escolhida aleatoriamente no codigo anterior,
    para a variavel categoria.
    */
    SELECT /*+PARALLEL(categoria, DEFAULT)*/ nb_categoria
    INTO categoria
    FROM categoria
    WHERE nb_categoria = quantidadevalores2;
    /*
    Bloco de godigo que verifica em que plataforma é realizada a transferencia.
    */
IF plataforma = 'WEB'
    THEN

            valor := numerodecimalaleatorio(1,100000); --Linha de código que gera o valor da transação aleatoriamente
            /*
            Bloco de código que introduz na variavel contatransacao, uma conta aleatoria que possua um saldo maior ou igual ao
            valor da transação, isto porque uma vez que é uma transação a operação será obrigatoriamente uma transferência.
            */
            SELECT /*+ PARALLEL(DEFAULT)*/  a.nb_ncliente, a.nb_iban, c.nb_numerocartao
            INTO clienteTransacao, contatransacao, cartao
            FROM (SELECT  nb_ncliente, nb_iban FROM titular
            ORDER BY dbms_random.value) a, cartao c, conta t
            WHERE rownum =1 and a.nb_ncliente = c.nb_ncliente and a.nb_iban = c.nb_iban and t.nb_iban = a.nb_iban and t.nb_saldo >= valor;

            /*
            Bloco de código que introduz na variavel contarecetora, uma conta aleatoria que seja diferente da conta que realizou a transacao.
            */
            SELECT /*+ PARALLEL(DEFAULT)*/  nb_iban
            INTO contarecetora
            FROM
            (SELECT  nb_iban FROM conta
            ORDER BY dbms_random.value)
            WHERE rownum =1 AND nb_iban != contatransacao;

            /*
            Bloco de código que devolve a chave primaria da operação "TRANSFERENCIA".
            */
            SELECT /*+ PARALLEL(DEFAULT)*/  nb_operacao, vc_nome_operacao
            INTO operacao, operacaonome
            FROM operacao
            WHERE vc_nome_operacao LIKE 'TRANSFERENCIA';
ELSE
    IF operacaonome = 'TRANSFERENCIA'
    THEN
            valor := numerodecimalaleatorio(1,100000); --Linha de código que gera o valor da transação aleatoriamente
            /*
            Bloco de código que introduz na variavel contatransacao, uma conta aleatoria que possua um saldo maior ou igual ao
            valor da transação, isto porque a operação é uma transferência.
            */
            SELECT /*+ PARALLEL(DEFAULT)*/  a.nb_ncliente, a.nb_iban, c.nb_numerocartao
            INTO clienteTransacao, contatransacao, cartao
            FROM (SELECT  nb_ncliente, nb_iban FROM titular
            ORDER BY dbms_random.value) a, cartao c, conta t
            WHERE rownum =1 and a.nb_ncliente = c.nb_ncliente and a.nb_iban = c.nb_iban and t.nb_iban = a.nb_iban and t.nb_saldo > valor and t.vc_tipo = 'ORDEM';

            /*
            Bloco de código que introduz na variavel contarecetora, uma conta aleatoria que seja diferente da conta que realizou a transacao.
            */
            SELECT /*+ PARALLEL(DEFAULT)*/  nb_iban
            INTO contarecetora
            FROM
            (SELECT  nb_iban FROM conta
            ORDER BY dbms_random.value)
            WHERE rownum =1 AND nb_iban != contatransacao;

    ELSIF operacaonome = 'LEVANTAMENTO'
    THEN
        valor := numerodecimalaleatorio(1,10000); --Linha de código que gera o valor da transação aleatoriamente
        /*
            Bloco de código que introduz na variavel contatransacao, uma conta aleatoria que possua um saldo maior ou igual ao
            valor da transação, isto porque a operação é um levantamento.
        */
        SELECT /*+ PARALLEL(DEFAULT)*/  a.nb_ncliente, a.nb_iban, c.nb_numerocartao
        INTO clienteTransacao, contatransacao, cartao
        FROM (SELECT  nb_ncliente, nb_iban FROM titular
        ORDER BY dbms_random.value) a, cartao c, conta t
        WHERE rownum =1 and a.nb_ncliente = c.nb_ncliente and a.nb_iban = c.nb_iban and t.nb_iban = a.nb_iban and t.nb_saldo > valor and t.vc_tipo = 'ORDEM';

        contarecetora := null; --Código que da a variavel contarecetora o valor null.
    ELSE
        valor := numerodecimalaleatorio(1,100000); --Linha de código que gera o valor da transação aleatoriamente
        /*
            Bloco de código que introduz na variavel contatransacao, uma conta aleatoria.
        */
        SELECT /*+ PARALLEL(DEFAULT)*/  a.nb_ncliente, a.nb_iban, c.nb_numerocartao
        INTO clienteTransacao, contatransacao, cartao
        FROM (SELECT  nb_ncliente, nb_iban FROM titular
        ORDER BY dbms_random.value) a, cartao c, conta t
        WHERE rownum =1 and a.nb_ncliente = c.nb_ncliente and a.nb_iban = c.nb_iban and t.vc_tipo = 'ORDEM';

        contarecetora := null; --Código que da a variavel contarecetora o valor null.
    END IF;
END IF;

    /*
    Bloco de código insere na variavel contasaldo o valor da conta
    que realiza a transação.
    */
    SELECT /*+PARALLEL(conta, DEFAULT)*/ vc_tipo, nb_saldo
    INTO tipoconta, contasaldo
    FROM conta
    WHERE nb_iban = contatransacao;

    /*
    Bloco de código que valida se a conta recetora se encontra a null ou não e caso
    seja verdade insere na variavel contarecetorasaldo o saldo da conta recetora.
    */
    IF contarecetora IS NOT NULL
    THEN
        SELECT  /*+PARALLEL(conta, DEFAULT)*/ nb_saldo
        INTO contarecetorasaldo
        FROM conta
        WHERE nb_iban = contarecetora;
    END IF;


    INSERT INTO /*+ APPEND PARALLEL(TRANSACAO, DEFAULT)*/ TRANSACAO (VC_plataforma, nb_valor, dta_dtatransacao, nb_categoria, nb_operacao, nb_ncliente, nb_iban, nb_IBANRecetor, nb_Cartao)
    VALUES (plataforma, valor,TO_DATE(current_date,'dd/mm/yyyy'),categoria,operacao,clienteTransacao,contatransacao,contarecetora, cartao);
    IF contarecetora IS NULL
    THEN
        IF operacaonome LIKE 'LEVANTAMENTO'
        THEN
            update_specifc_register('CONTA', contatransacao, 0, 'nb_saldo' , (contasaldo-valor) );
        ELSE
            update_specifc_register('CONTA', contatransacao, 0, 'nb_saldo' , (contasaldo+valor) );
        END IF;
    ELSE
            update_specifc_register('CONTA', contarecetora, 0, 'nb_saldo' , (contarecetorasaldo+valor) );
            update_specifc_register('CONTA', contatransacao, 0, 'nb_saldo' , (contasaldo-valor) );
    END IF;

END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_TRANSACAO_ALEATORIO','Não existem dados sufciente nas tabelas para realizar transaferencias aleatorias.');
    RAISE_APPLICATION_ERROR(-20001, 'Não existem dados sufciente nas tabelas para realizar transaferencias aleatorias.');
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
     concelho endereco.vc_concelho%type,
     distrito endereco.vc_distrito%type,
     pais endereco.vc_pais%type
     )
AS
    numeroEndereco endereco.nb_nendereco%type;
    cidadeVerificar ext_codPostal.vc_cidade%type;
    cidadeRecebida endereco.vc_cidade%type;
    distritoverificar endereco.vc_distrito%type;
    codDistrito ext_distrito.NB_CodDistrito%type;
    codConcelho ext_concelho.NB_CodConcelho%type;

BEGIN

IF upper(pais) LIKE  'PORTUGAL'
THEN
    /*
    Bloco de código que seleciona o codigo do distrito e do conselho de acordo
    com o nome do conselho recebido.
    */
    Select /*+PARALLEL(ext_concelho, DEFAULT)*/ NB_CodConcelho, NB_CodDistrito
    INTO  codConcelho, codDistrito
    FROM ext_concelho
    WHERE vc_concelho = InitCap(concelho);

    /*
    Bloco de código que seleciona o nome do distrito de acordo com o codigo do mesmo recebido no
    coígo anterior.
    */
    SELECT /*+PARALLEL(ext_distrito, DEFAULT)*/ vc_distrito
    INTO distritoverificar
    FROM ext_distrito
    WHERE NB_CodDistrito = codDistrito;

    /*
    Verificação que o distrito recebido anteriormente corresponde com o distrido rcebido por
    parametro.
    */
    IF upper(distritoverificar) LIKE upper(distrito)
    THEN
        /*
        Se ambos distritos coincidirem é realizado um select para obter a cidade
        utilizando o codigo de distrito e de conselho obtidos anteriormente
        e o codigo postal recebido por parametro.
        */
        SELECT /*+PARALLEL(ext_codPostal, DEFAULT)*/ vc_cidade
        INTO cidadeverificar
        FROM ext_codPostal
        WHERE nb_codpostal = codigopostal;

        cidaderecebida := UPPER(cidade)||CHR(13);

            /*
            Verificação que a cidade recebido anteriormente corresponde com a cidade rcebido por
            parametro.
            */
             IF cidaderecebida LIKE cidadeverificar
             THEN
                INSERT INTO /*+ APPEND PARALLEL(ENDERECO, DEFAULT)*/ ENDERECO (VC_Rua, NB_CodPostal, NB_NumPorta, VC_Cidade, vc_concelho, vc_distrito, vc_pais)
                VALUES (rua, codigoPostal, numPorta, cidade, concelho, distrito, pais)
                RETURNING  nb_nendereco INTO numeroEndereco;

                INSERT INTO /*+ APPEND PARALLEL(AGENCIA, DEFAULT)*/ AGENCIA (nb_nendreco) VALUES (numeroEndereco);
            ELSE
                insert_loglog('SP_AGENCIA_INSERT','A cidade inserida não corresponde com o código Postal');
                 RAISE_APPLICATION_ERROR(-20001, 'A cidade inserida não corresponde com o código Postal');
            END IF;
    ELSE
        insert_loglog('SP_AGENCIA_INSERT','O distrito inserido não corresponde ao distrito do concelho inserido.');
        RAISE_APPLICATION_ERROR(-20001, 'O distrito inserido não corresponde ao distrito do concelho inserido.');
    END IF;
ELSE
    insert_loglog('SP_AGENCIA_INSERT','A agência tem de se encontrar em Portugal.');
    RAISE_APPLICATION_ERROR(-20001, 'A agência tem de se encontrar em Portugal.');
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_AGENCIA_INSERT','O Código Postal ou o concelho inserido não existe.');
    RAISE_APPLICATION_ERROR(-20001, 'O Código Postal ou o concelho inserido não existe.');
	
END SP_AGENCIA_INSERT;
/

/*
Procedimento de inserção manual de dados na tabela operações
execute sp_operacao_insert('operações');
*/
CREATE OR REPLACE PROCEDURE sp_operacao_insert(  nome_operacao varchar2)
IS

BEGIN

INSERT INTO /*+ APPEND PARALLEL(OPERACA, DEFAULT)*/ operacao (VC_NOME_OPERACAO) VALUES (nome_operacao );
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
INSERT INTO /*+ APPEND PARALLEL(PRODUTO, DEFAULT)*/ PRODUTO (VC_TIPOPRODUTO) VALUES (nome_ops);
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
INSERT INTO /*+ APPEND PARALLEL(CATEGORIA, DEFAULT)*/ categoria (VC_NOME_CATEGORIA) VALUES (nome_cat);
EXCEPTION
   WHEN OTHERS THEN
    insert_loglog('Insert',SQLERRM);
      dbms_output.put_line( SQLERRM );
	 
END sp_categoria_insert;
/


/*
    Este procedimento tem como objetivo associar um cliente a um endereço.
*/
CREATE OR REPLACE PROCEDURE SP_MORADACLIENTE_INSERT
    (
     numeroEndereco endereco.nb_nendereco%type,
     cliente cliente.nb_ncliente%type
     )
AS
    excepcao_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT (excepcao_existente, -2291);
BEGIN

    INSERT INTO /*+ APPEND PARALLEL(MORADACLIENTE, DEFAULT)*/ MORADACLIENTE VALUES (cliente,numeroEndereco);

EXCEPTION
WHEN excepcao_existente
    THEN
	insert_loglog('SP_MORADACLIENTE_INSERT','O Cliente ou o Endereço inseridos não existem.');
    RAISE_APPLICATION_ERROR(-20001, 'O Cliente ou o Endereço inseridos não existem.');

END SP_MORADACLIENTE_INSERT;
/

/*
    Este procedimento tem como objetivo realizar o registro de uma transação.
*/
CREATE OR REPLACE PROCEDURE SP_TRANSACAO_INSERT
    (
    plataforma transacao.vc_plataforma%type,
    valor NUMBER,
    operacao transacao.nb_operacao%type,
    categoria transacao.nb_categoria%type,
    clienteTransacao transacao.nb_ncliente%type,
    contatransacao transacao.nb_iban%type,
    contarecetora number,
    cartao NUMBER
    )
AS
    operacaoNome varchar2(20);
    tipoconta varchar2(20);
    contaSaldo NUMBER(10,2);
    contaRecetoraSaldo NUMBER(10);
    cartaoiban NUMBER(16);
    cartaoCliente NUMBER(4);
BEGIN
    /*
    Bloco de código que insere na váriavel operacaonome o nome da operação recebida por parametro.
    */
    SELECT /*+PARALLEL(operacao, DEFAULT)*/ vc_nome_operacao
    INTO operacaonome
    FROM operacao
    WHERE nb_operacao = operacao;

/*
Verificação se a plataforma recebida por parámetro é 'WEB'.
*/
IF upper(plataforma) = 'WEB'
    THEN
        /*
        Verificação se operacão é diferente de transferência.
        Caso seja verdade ira ser gerado um erro, uma vez que, apartir da 'WEB' somente se pode realizar operações de transferência.
        */
        IF operacaoNome != 'TRANSFERENCIA'
        THEN
            insert_loglog('SP_TRANSACAO_INSERT','Não se pode realizar operações de Levantamento e de Depósito pela WEB.');
             RAISE_APPLICATION_ERROR(-20001, 'Não se pode realizar operações de Levantamento e de Depósito pela WEB.');
        END IF;
        /*
        Verificação se a conta recetora e a conta transação, ambas recebidas por parâmetro, são iguais.
        Caso seja verdade ira ser gerado um erro, uma vez que, não se podere realizar transferências atravês da mesma conta.
        */
        IF contarecetora = contatransacao
        THEN
            insert_loglog('SP_TRANSACAO_INSERT','Não se pode realizar transferências pela mesma conta.');
            RAISE_APPLICATION_ERROR(-20001, 'Não se pode realizar transferências pela mesma conta.');
        END IF;
ELSE
    /*
    Caso a plataforma recebida por parámetro não seja ´WEB',
    ira ser feita uma verificação para saber se a operação é uma transferência.
    */
    IF operacaonome = 'TRANSFERENCIA'
    THEN
            /*
            Caso seja, será feita uma verificação para saber  se a conta recetora e a conta transação, ambas recebidas por parâmetro, são iguais.
            Caso seja verdade ira ser gerado um erro, uma vez que, não se podere realizar transferências atravês da mesma conta.
            */
            IF contarecetora = contatransacao
            THEN
                insert_loglog('SP_TRANSACAO_INSERT','Não se pode realizar transferências entre a mesma conta.');
                RAISE_APPLICATION_ERROR(-20001, 'Não se pode realizar transferências entre a mesma conta.');
            END IF;

    ELSE
        /*
        Caso não seja, será feita uma verificação para saber  se a conta recetora, recebida por parámetro possui o valor 'NULL' ou não.
        Caso seja verdade ira ser gerado um erro, uma vez que, operações de depósito e levantamento não possuem conta recetora.
        */
        IF contarecetora IS NOT NULL
        THEN
            insert_loglog('SP_TRANSACAO_INSERT','Uma transação de Levantamento/Deposito não possui uma conta recetora.');
            RAISE_APPLICATION_ERROR(-20001, 'Uma transação de Levantamento/Deposito não possui uma conta recetora.');
        END IF;
    END IF;
END IF;

    /*
    Bloco de código que insere na váriavel contaSaldo o saldo da conta que realizara a transação
    e insere na váriavel tipoConta o tipo de conta que realizara a transação.
    */
    SELECT /*+PARALLEL(conta, DEFAULT)*/ vc_tipo, nb_saldo
    INTO tipoConta, contaSaldo
    FROM conta
    WHERE nb_iban = contatransacao;

    /*
    Bloco de código que insere na váriavel cartaoiban o iban relacionado ao cortão recebido por parámetro
    e insere na váriavel cartaoCliente o cliente relacionado ao cortão recebido por parámetro.
    */
    SELECT  /*+PARALLEL(cartao, DEFAULT)*/ nb_iban, nb_ncliente
    INTO cartaoiban, cartaoCliente
    FROM cartao
    WHERE nb_numeroCartao = cartao;

    /*
    Bloco de código que verifica se a conta recetora possui o valor 'NULL' ou não.
    Caso possua ira inserir na variável contarecetorasaldo o saldo da conta recetora.
    */
    IF contarecetora IS NOT NULL
    THEN
        SELECT /*+PARALLEL(conta, DEFAULT)*/ nb_saldo
        INTO contarecetorasaldo
        FROM conta
        WHERE nb_iban = contarecetora;
    END IF;


/*
Verificação que valida se o cartão pertence a conta que realizara a transação
e se pertence ao cliente que está a realizar a transação.
*/
IF cartaoiban = contatransacao and cartaoCliente = clienteTransacao
THEN
    /*
    Verificação feita para saber se a operação da transação é uma transferência ou um levantamento.
    Caso seja será feita outra verificação para sabermos se a conta que realizara a transação possui saldo sufciente
    */
    IF operacaonome IN('TRANSFERENCIA', 'LEVANTAMENTO')
    THEN
        IF contaSaldo < valor
        then
            insert_loglog('SP_TRANSACAO_INSERT','A conta não possui saldo sufciente para realizar um Levantamento/Transferencia.');
            RAISE_APPLICATION_ERROR(-20001, 'A conta não possui saldo sufciente para realizar um Levantamento/Transferencia.');
        END IF;
    END IF;
        /*
        Verificação para saber se a conta que está a realizar uma transação é uma conta a 'ORDEM'.
        Caso seja sera realizado o INSERT.
        */
        IF tipoConta LIKE 'ORDEM'
        THEN
        INSERT INTO /*+ APPEND PARALLEL(TRANSACAO, DEFAULT)*/ TRANSACAO (VC_plataforma, nb_valor, dta_dtatransacao, nb_categoria, nb_operacao, nb_ncliente, nb_iban, nb_IBANRecetor, nb_Cartao)
        VALUES (plataforma, valor,TO_DATE(current_date,'dd/mm/yyyy'),categoria,operacao,clienteTransacao,contatransacao,contarecetora, cartao);

            IF contarecetora IS NULL
            THEN
                IF operacaonome LIKE 'LEVANTAMENTO'
                THEN
                    update_specifc_register('CONTA', contatransacao, 0, 'nb_saldo' , (contasaldo-valor) );
                ELSE
                    update_specifc_register('CONTA', contatransacao, 0, 'nb_saldo' , (contasaldo+valor) );
                END IF;
            ELSE
                    update_specifc_register('CONTA', contarecetora, 0, 'nb_saldo' , (contarecetorasaldo+valor) );
                    update_specifc_register('CONTA', contatransacao, 0, 'nb_saldo' , (contasaldo-valor) );
            END IF;
        ELSE
            insert_loglog('SP_TRANSACAO_INSERT','Não se pode realizar Transferência com contas a prazo.');
            RAISE_APPLICATION_ERROR(-20001, 'Não se pode realizar Transferência com contas a prazo.');
        END IF;
ELSE
    insert_loglog('SP_TRANSACAO_INSERT','O cartão tem de estar associado a conta que está a realizar a transação.');
    RAISE_APPLICATION_ERROR(-20001, 'O cartão tem de estar associado a conta que está a realizar a transação.');
END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	insert_loglog('SP_TRANSACAO_ALEATORIO','Por favor, insira daods existentes.');
    RAISE_APPLICATION_ERROR(-20001, 'Por favor, insira daodos existentes.');
END SP_TRANSACAO_INSERT;
/
