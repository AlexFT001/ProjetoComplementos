--View que apresenta as informações do cliente
CREATE VIEW InfoCliente AS
    SELECT *
    FROM cliente;
    
--SELECT * FROM InfoCliente;


--View que apresenta o saldo e produto de cada conta de cada cliente
CREATE VIEW CarteiraSaldos AS
    SELECT c.nb_ncliente AS "NumCliente", c.vc_nome AS "NomeCliente", ct.nb_iban AS "IBAN", ct.nb_saldo AS "Saldo", p.vc_tipoproduto AS "Produto"
    FROM cliente c, titular t, conta ct, produto p
    WHERE c.nb_ncliente = t.nb_ncliente and t.nb_iban = ct.nb_iban and ct.nb_nproduto = p.nb_nproduto
    ;
    
--SELECT * FROM CARTEIRASALDOS;


--View que apresenta todas as transações acima de 10000 ou transações do tipo 'Levantamento' acima de 5000
CREATE VIEW LavagemDinheiroValor AS
    SELECT t.nb_numerotransacao AS "NumTransação", t.nb_iban AS "IBAN", t.nb_ncliente AS "NumCliente", t.nb_valor AS "Valor", t.nb_ibanrecetor AS "IBAN Recetor", t.dta_dtatransacao AS "Data", op.vc_nome_operacao AS "Operação"
    FROM transacao t, operacao op
    WHERE t.nb_valor > 5000 AND t.nb_operacao = op.nb_operacao AND op.vc_nome_operacao = 'Levantamento' OR t.nb_valor > 10000
    ;
    
--SELECT * FROM lavagemdinheirovalor;
--DROP VIEW lavagemdinheiroclienteext;

--View que apresenta todas as transações feitas por cliente estrangeiros
CREATE VIEW LavagemDinheiroClienteEXT AS
    SELECT t.nb_numerotransacao AS "NumTransação", t.nb_iban AS "IBAN", t.nb_ncliente AS "NumCliente", t.nb_valor AS "Valor", t.nb_ibanrecetor AS "IBAN Recetor", t.dta_dtatransacao AS "Data", e.vc_pais AS "País"
    FROM transacao t, titular tt, cliente c, moradacliente mc, endereco e
    WHERE t.nb_iban = tt.nb_iban AND tt.nb_ncliente = c.nb_ncliente AND c.nb_ncliente = mc.nb_ncliente AND mc.nb_nendereco = e.nb_nendereco AND e.vc_pais != 'Portugal'
    ;
    
--SELECT * FROM lavagemdinheiroclienteext;


--View que apresenta o número de clientes por agência
CREATE VIEW ClientesPorAgencia AS 
    SELECT a.nb_nagencia AS "Agência", count(c.nb_ncliente) AS "Clientes"
    FROM agencia a, cliente c
    WHERE a.nb_nagencia = c.nb_nagencia
    GROUP BY a.nb_nagencia
    ;
    
--SELECT * FROM clientesporagencia;


--View que apresenta o TOP 10 clientes por saldo do Banco
CREATE VIEW TopRankBanco AS
    SELECT c.nb_ncliente AS "NumCliente", c.vc_nome AS "Nome", ct.nb_iban AS "IBAN", ct.nb_saldo AS "Saldo", c.nb_nagencia AS "Agência"
    FROM cliente c, titular t, conta ct
    WHERE c.nb_ncliente = t.nb_ncliente AND t.nb_iban = ct.nb_iban
    ORDER BY ct.nb_saldo DESC
    FETCH FIRST 10 ROWS ONLY;
    
--SELECT * FROM toprankbanco;


--View que apresenta o TOP 10 clientes por saldo de cada agência
CREATE VIEW TopRankAgencias AS
SELECT *
FROM (
    SELECT c.nb_nagencia, c.nb_ncliente, c.vc_nome, ct.nb_saldo,
        ROW_NUMBER() OVER (PARTITION BY c.nb_nagencia ORDER BY ct.nb_saldo DESC) AS rn
    FROM cliente c
    JOIN titular t ON c.nb_ncliente = t.nb_ncliente
    JOIN conta ct ON t.nb_iban = ct.nb_iban
    JOIN agencia a ON c.nb_nagencia = a.nb_nagencia
) WHERE rn <= 10;

--ROW_NUMBER(): Função que atribui um número sequencial a cada linha resultante da consulta
--OVER: Diz em que consulta a função anterior vai atuar
--PARTITION BY c.nb_nagencia: Diz que a numeração feita vai ser reiniciada a cada valor único de cada agência
--ORDER BY ct.nb_saldo DESC: Vai ordenar os dados da consulta por ordem decrescente de saldo


--SELECT * FROM toprankagencias;