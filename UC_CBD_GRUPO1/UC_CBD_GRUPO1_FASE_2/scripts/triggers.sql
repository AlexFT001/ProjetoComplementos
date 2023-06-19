
CREATE OR REPLACE TRIGGER alteracoes
  AFTER
    INSERT OR
    UPDATE OR
    DELETE
  ON CLIENTE
FOR EACH ROW
DECLARE
  operacao VARCHAR2(10);
  cliente_pk NUMBER;
BEGIN
    --Valida que tipo de operação o trigger esta a realizar, utilizando Boolean variable do proprio TRIGGER
    IF INSERTING THEN
      operacao := 'INSERT';
      cliente_pk := :NEW.nb_ncliente;
    ELSIF  UPDATING THEN
      operacao := 'UPDATE';
      cliente_pk := :NEW.nb_ncliente;
    ELSIF  DELETING THEN
      operacao := 'DELETE';
      cliente_pk := :OLD.nb_ncliente;
  END IF;
  INSERT INTO /*+ APPEND PARALLEL(AlteracoesCliente, DEFAULT)*/  AlteracoesCliente (vc_operacao, vc_user, dta_dataAlteracao, nb_clientealterado)
  VALUES (operacao, USER, TO_DATE(SYSDATE, 'DD-MM-YYYY HH24:MI'), cliente_pk);

END alteracoes;
/