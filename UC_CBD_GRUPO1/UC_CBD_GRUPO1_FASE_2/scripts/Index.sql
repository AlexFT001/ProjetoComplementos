-- Index para a chave primária da tabela Cliente
CREATE INDEX idx_cliente_nb_ncliente ON cliente (nb_ncliente);

-- Index das chaves primárias da tabela moradacliente
CREATE INDEX idx_moradacliente_nb_ncliente ON moradacliente (nb_ncliente);
CREATE INDEX idx_moradacliente_nb_nendereco ON moradacliente (nb_nendereco);

-- Index da chave primária da tabela endereco
CREATE INDEX idx_endereco_nb_nendereco ON endereco (nb_nendereco);

-- Index das chaves primárias da tabela titular
CREATE INDEX idx_titular_nb_ncliente ON titular (nb_ncliente);
CREATE INDEX idx_titular_nb_iban ON titular (nb_iban);

-- Index das chave primária da tabela conta
CREATE INDEX idx_conta_nb_iban ON conta (nb_iban);

-- Index da chave primária da tabela produto
CREATE INDEX idx_produto_nb_nproduto ON produto (nb_nproduto);

-- Index da chave primária da tabela agencia
CREATE INDEX idx_agencia_nb_nagencia ON agencia (nb_nagencia);

-- Index da chave primária da tabela operacao
CREATE INDEX idx_operacao_nb_operacao ON operacao (nb_operacao);

-- Index da chave primária da tabela categoria
CREATE INDEX idx_categoria_nb_categoria ON categoria (nb_categoria);