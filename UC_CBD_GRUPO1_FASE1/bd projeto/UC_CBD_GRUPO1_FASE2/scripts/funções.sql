/*
    Este função tem como objetivo devolver o tamanho da String que recebe, é utilizada
    no procedure SP_CARTAO_INSERT para verificar que o PIN possui 4 dígitos e no procedimento
    SP_CLIENTE_INSERT para verificar que o NIF tem 9 digitos.
*/
CREATE OR REPLACE FUNCTION tamanhoNumero (string Varchar2) RETURN NUMBER IS
    resultado number;
BEGIN
     resultado := LENGTH(string);

    RETURN  resultado;
END tamanhoNumero;
/

/*
    Esta função tem como objetivo manipular a ordem de titularidade entre contas, sendo que somente
    possui como parametro, sendo este o numero de contas. A partir dai ira realizar uma contagem de quantas pessoas
    já se encontram associadas a esta conta, e comforme a contagem devolvera a posição do próximo titular.
    Está função é chamada nos procedimentos: SP_CONTA_INSERT e SP_TITULAR_INSERT.
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
    Este função tem como objetivo gerar um numero aleatório conforme os parametros que está recebe.
    O numero que devolve é um numero inteiro.
    Foi criada uma função para este codigo, uma vez que o mesmo é usada diversas vezes no
    procedure SP_TRANSACAO_ALEATORIO.

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