EXECUTE sp_produto_insert('CONTA JOVEM');

EXECUTE sp_operacao_insert('LEVANTAMENTO');
EXECUTE sp_operacao_insert('DEPOSITO');
EXECUTE sp_operacao_insert('TRANSFERENCIA');

EXECUTE sp_categoria_insert('COMPRAS');
EXECUTE sp_categoria_insert('CARRO');

--rua,codigoPostal,numPorta,cidade,conselho,distrito,pais.
EXECUTE SP_AGENCIA_INSERT('casa', 3810120, 12, 'AVEIRO',  'Aveiro', 'Aveiro', 'Portugal');
EXECUTE SP_AGENCIA_INSERT('apartamento', 3810120, 15, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal');
EXECUTE SP_AGENCIA_INSERT('casa', 3810120, 25, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal');
EXECUTE SP_AGENCIA_INSERT('sobrado', 3810120, 8, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal');
EXECUTE SP_AGENCIA_INSERT('casa', 3810120, 9, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal');
EXECUTE SP_AGENCIA_INSERT('apartamento', 3810120, 21, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal');


--nome,agencia,dataNascimento,superior
EXECUTE SP_FUNCIONARIO_INSERT('Alex', 1000, '12/APR/2004', NULL);
EXECUTE SP_FUNCIONARIO_INSERT('Ana', 1001, '15/MAY/1990', 1000);
EXECUTE SP_FUNCIONARIO_INSERT('Carlos', 1002, '20/JUL/1985', 1000);
EXECUTE SP_FUNCIONARIO_INSERT('Marta', 1003, '10/JAN/1998', 1000);
EXECUTE SP_FUNCIONARIO_INSERT('Pedro', 1004, '05/NOV/1992', 1000);
EXECUTE SP_FUNCIONARIO_INSERT('Sara', 1005, '25/SEP/1996', 1000);


--nif,nome,profissao,dataNascimento,emailcliente,passWordcliente,rua,codigoPostal,numPorta,cidade,conselho,distrito,pais,saldo,tipodeConta,produto,agencia
EXECUTE SP_CLIENTE_INSERT(123456789, 'Alex', 'Trabalhador', '12/APR/2004', 'torres@gmail.com', '12345', 'rua das palmeiras', 3810120, 12, 'Aveiro','Aveiro', 'Aveiro','Portugal', 10000000, 'ORDEM', 1000, 1000);
EXECUTE SP_CLIENTE_INSERT(987654321, 'João', 'Estudante', '10/JUL/2002', 'joao@gmail.com', '54321', 'rua dos Lírios', 3810120, 5, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal', 500000, 'ORDEM', 1000, 1000);
EXECUTE SP_CLIENTE_INSERT(111111111, 'Maria', 'Advogada', '02/FEB/1980', 'maria@gmail.com', '11111', 'rua dos Cravos', 3810120, 10, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal', 1500000, 'ORDEM', 1000, 1000);
EXECUTE SP_CLIENTE_INSERT(222222222, 'Ricardo', 'Empresário', '20/MAR/1975', 'ricardo@gmail.com', '22222', 'rua dos Girassóis', 3810120, 7, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal', 2000000, 'ORDEM', 1000, 1000);
EXECUTE SP_CLIENTE_INSERT(333333333, 'Inês', 'Enfermeira', '12/DEC/1991', 'ines@gmail.com', '33333', 'rua das Violetas', 3810120, 30, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal', 100000, 'ORDEM', 1000, 1000);
EXECUTE SP_CLIENTE_INSERT(444444444, 'António', 'Engenheiro', '28/AUG/1988', 'antonio@gmail.com', '44444', 'rua dos Crisântemos', 3810120, 17, 'AVEIRO', 'Aveiro', 'Aveiro', 'Portugal', 800000, 'ORDEM', 1000, 1000);


--rua,codigoPostal,numPorta,cidade,conselho,distrito,pais,cliente.
EXECUTE SP_ENDERECO_INSERT('casa', 3100340, 12, 'POMBAL', 'Pombal', 'Leiria', 'Portugal', 1000);
EXECUTE SP_ENDERECO_INSERT('apartamento', 3100340, 5, 'POMBAL', 'Pombal', 'Leiria', 'Portugal', 1001);
EXECUTE SP_ENDERECO_INSERT('casa', 3100340, 8, 'POMBAL', 'Pombal', 'Leiria', 'Portugal', 1002);
EXECUTE SP_ENDERECO_INSERT('sobrado', 3100340, 11, 'POMBAL', 'Pombal', 'Leiria', 'Portugal', 1003);
EXECUTE SP_ENDERECO_INSERT('casa', 3100340, 20, 'POMBAL', 'Pombal', 'Leiria', 'Portugal', 1004);
EXECUTE SP_ENDERECO_INSERT('apartamento', 3100340, 9, 'POMBAL', 'Pombal', 'Leiria', 'Portugal', 1005);

--saldo,tipodeConta,agenciaConta,produto,cliente
EXECUTE SP_CONTA_INSERT(1000, 'PRAZO', 1000, 1000, 1000);
EXECUTE SP_CONTA_INSERT(2000, 'ORDEM', 1001, 1000, 1001);
EXECUTE SP_CONTA_INSERT(3000, 'PRAZO', 1002, 1000, 1002);
EXECUTE SP_CONTA_INSERT(4000, 'ORDEM', 1003, 1000, 1003);
EXECUTE SP_CONTA_INSERT(5000, 'PRAZO', 1004, 1000, 1004);
EXECUTE SP_CONTA_INSERT(6000, 'ORDEM', 1005, 1000, 1005);

--iban,cliente
EXECUTE SP_TITULAR_INSERT(1000000000000000, 1004);


--pin,iban,numerCliente
EXECUTE SP_CARTAO_INSERT(1234, 1000000000000000, 1000);
EXECUTE SP_CARTAO_INSERT(5678, 1000000000000001, 1001);
EXECUTE SP_CARTAO_INSERT(6789, 1000000000000002, 1002);
EXECUTE SP_CARTAO_INSERT(7890, 1000000000000003, 1003);
EXECUTE SP_CARTAO_INSERT(8901, 1000000000000004, 1004);
EXECUTE SP_CARTAO_INSERT(9012, 1000000000000005, 1005);


EXECUTE SP_TRANSACAO_ALEATORIO(5);

--plataforma,valor,operacao,categoria,clienteTransacao,contatransacao,contarecetora,cartao
EXECUTE SP_TRANSACAO_INSERT('ATM',1000, 1000, 1000, 1000, 1000000000000000, NULL, 1000);

EXECUTE mover_historico(2023);

EXECUTE update_specifc_register('cliente', 1000, 0 ,'vc_password', 123456);

EXECUTE delete_specifc_register('cliente', 1000,0);


