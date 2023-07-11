-- Cliente
CREATE INDEX idx_cliente_nb_ncliente ON cliente (nb_ncliente);
CREATE INDEX idx_cliente_nb_nagencia ON cliente (nb_nagencia);


-- MoradaCliente
CREATE INDEX idx_moradacliente_nb_ncliente ON moradacliente (nb_ncliente);
CREATE INDEX idx_moradacliente_nb_nendereco ON moradacliente (nb_nendereco);

-- Endereco
CREATE INDEX idx_endereco_nb_nendereco ON endereco (nb_nendereco);
CREATE INDEX idx_endereco_vc_pais ON endereco (vc_pais);

-- Titular
CREATE INDEX idx_titular_nb_ncliente ON titular (nb_ncliente);
CREATE INDEX idx_titular_nb_iban ON titular (nb_iban);

-- Conta
CREATE INDEX idx_conta_nb_iban ON conta (nb_iban);
CREATE INDEX idx_conta_nb_nproduto ON conta (nb_nproduto);
CREATE INDEX idx_conta_nb_nagencia ON conta (nb_nagencia);

-- Produto
CREATE INDEX idx_produto_nb_nproduto ON produto (nb_nproduto);

-- Agencia
CREATE INDEX idx_agencia_nb_nagencia ON agencia (nb_nagencia);

-- Operacao
CREATE INDEX idx_operacao_nb_operacao ON operacao (nb_operacao);

-- Categora
CREATE INDEX idx_categoria_nb_categoria ON categoria (nb_categoria);

-- Transacao
CREATE INDEX idx_transacao_nb_iban ON transacao (nb_iban);
CREATE INDEX idx_transacao_nb_ncliente ON transacao (nb_ncliente);
CREATE INDEX idx_transacao_nb_ibanrecetor ON transacao (nb_ibanrecetor);
CREATE INDEX idx_transacao_nb_operacao ON transacao (nb_operacao);
CREATE INDEX idx_transacao_nb_valor ON transacao (nb_valor);


