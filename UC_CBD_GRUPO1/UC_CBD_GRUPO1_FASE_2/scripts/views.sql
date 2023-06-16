--View que apresenta as informações do cliente
CREATE VIEW V_InfoCliente AS
    SELECT c.vc_nome AS "Nome", c.nb_nif AS "NIF", c.vc_email AS "Email", c.vc_profissao AS "Profissão", c.dt_DataNascimento AS "Data de Nascimento", c.nb_idade AS "Idade",COUNT(e.nb_nendereco) AS "Nº de Moradas"
    FROM cliente c, moradacliente mc, endereco e
    WHERE c.nb_ncliente = mc.nb_ncliente AND mc.nb_nendereco = e.nb_nendereco
    group by c.vc_nome, c.nb_nif, c.vc_email, c.vc_profissao, c.dt_DataNascimento, c.nb_idade
    ;
    
--SELECT * FROM V_InfoCliente;
--DROP VIEW V_InfoCliente;



--View que apresenta o saldo e produto de cada conta de cada cliente
CREATE VIEW V_CarteiraSaldos AS
    SELECT c.nb_ncliente AS "NumCliente", c.vc_nome AS "NomeCliente", ct.nb_iban AS "IBAN", ct.nb_saldo || ' €' AS "Saldo", p.vc_tipoproduto AS "Produto"
    FROM cliente c, titular t, conta ct, produto p
    WHERE c.nb_ncliente = t.nb_ncliente and t.nb_iban = ct.nb_iban and ct.nb_nproduto = p.nb_nproduto
    ;
    
--SELECT * FROM V_CARTEIRASALDOS;
--DROP VIEW V_CarteiraSaldos;


--View que apresenta todas as transações acima de 10000 ou transações do tipo 'Levantamento' acima de 5000
CREATE VIEW V_LavagemDinheiroValor AS
    SELECT nb_numerotransacao AS "NumTransação", nb_iban AS "IBAN", nb_ncliente AS "NumCliente", nb_valor AS "Valor", nb_ibanrecetor AS "IBAN Recetor", dta_dtatransacao AS "Data", nb_operacao AS "Operação"
    FROM transacao 
    WHERE nb_valor > 10000 OR (nb_operacao = 1000 AND nb_valor > 5000)
;

--SELECT * FROM V_LavagemDinheiroValor;
--DROP VIEW V_LavagemDinheiroValor;




--View que apresenta todas as transações feitas por cliente estrangeiros
CREATE VIEW V_LavagemDinheiroClienteEXT AS
    SELECT t.nb_numerotransacao AS "NumTransação", t.nb_iban AS "IBAN", t.nb_ncliente AS "NumCliente", t.nb_valor AS "Valor", t.nb_ibanrecetor AS "IBAN Recetor", t.dta_dtatransacao AS "Data", e.vc_pais AS "País"
    FROM transacao t, titular tt, cliente c, moradacliente mc, endereco e
    WHERE t.nb_iban = tt.nb_iban AND tt.nb_ncliente = c.nb_ncliente AND c.nb_ncliente = mc.nb_ncliente AND mc.nb_nendereco = e.nb_nendereco AND e.vc_pais != 'Portugal'
    ;
	
--SELECT * FROM V_lavagemdinheiroclienteext;
--DROP VIEW V_LavagemDinheiroClienteEXT;


--View que apresenta o número de clientes por agência
CREATE VIEW V_ClientesPorAgencia AS 
    SELECT a.nb_nagencia AS "Agência", count(c.nb_ncliente) AS "Clientes"
    FROM agencia a, cliente c
    WHERE a.nb_nagencia = c.nb_nagencia
    GROUP BY a.nb_nagencia
    ;
    
--SELECT * FROM V_clientesporagencia;
--DROP VIEW V_ClientesPorAgencia;


--View que mostra os top 10 clientes do banco
CREATE VIEW V_TopClientesBanco AS
    SELECT c.nb_ncliente AS "NumCliente", c.vc_nome AS "Nome", SUM(ct.nb_saldo) || ' €' AS "Saldo total"
    FROM cliente c, titular t, conta ct
    WHERE c.nb_ncliente = t.nb_ncliente AND t.nb_iban = ct.nb_iban
    GROUP BY c.nb_ncliente, c.vc_nome
    ORDER BY SUM(ct.nb_saldo) DESC
    FETCH FIRST 10 ROWS ONLY
    ;

--SELECT * V_FROM TopClientesBanco;
--DROP VIEW V_topclientesbanco;


--View que mostra os top 10 clientes por agência
CREATE VIEW V_TopClientesPorAgencia AS
    SELECT a.nb_nagencia AS "Agencia", c.nb_ncliente AS "NumCliente", c.vc_nome AS "Nome", SUM(ct.nb_saldo) AS "Saldo total"
    FROM agencia a, cliente c, titular t, conta ct
    WHERE c.nb_ncliente = t.nb_ncliente AND t.nb_iban = ct.nb_iban AND ct.nb_nagencia = a.nb_nagencia
    GROUP BY a.nb_nagencia, c.nb_ncliente, c.vc_nome
    HAVING SUM(ct.nb_saldo) > 0
    ORDER BY a.nb_nagencia, SUM(ct.nb_saldo) DESC;
    
--Select * From V_TopClientesPorAgencia;
--DROP VIEW V_TopClientesPorAgencia