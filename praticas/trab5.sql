CREATE OR REPLACE TRIGGER altera_venda_item
AFTER DELETE OR INSERT OR UPDATE OF DESCONTO_UNITARIO,QUANTIDADE,PRECO_UNITARIO,PRODUTO_ID 
ON VENDA_ITEM 
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW

DECLARE
  u_preco_unitario NUMBER;
  u_desconto_unitario NUMBER;
  u_total_unitario NUMBER;
  u_quantidade NUMBER;
  
  u_conta_antiga NUMBER;
  u_conta_nova NUMBER;
  u_subtotal NUMBER;
  CURSOR vcursor IS SELECT subtotal FROM VENDA WHERE VENDA_ID=:OLD.VENDA_ID;
BEGIN
  u_conta_antiga := :OLD.QUANTIDADE*(:OLD.PRECO_UNITARIO - :OLD.DESCONTO_UNITARIO);
  u_conta_nova := :NEW.QUANTIDADE*(:NEW.PRECO_UNITARIO - :NEW.DESCONTO_UNITARIO); 
  dbms_output.put_line(u_conta_antiga);
  dbms_output.put_line(u_conta_nova);
  dbms_output.put_line(u_conta_nova - u_conta_antiga);
  OPEN vcursor;
  FETCH vcursor INTO u_subtotal; 
  CLOSE vcursor;  
  UPDATE VENDA set subtotal=u_subtotal + (u_conta_nova - u_conta_antiga) WHERE VENDA_ID=:OLD.VENDA_ID;
END;

2)

CREATE OR REPLACE TRIGGER status_revisao_venda 
BEFORE UPDATE OF CLIENTE_ID,CODIGO_APROVACAO_CARTAO,COMENTARIO,CONTA_NUMERO,DATA_ENVIO,DATA_VENCIMENTO,DATA_VENDA,ENDERECO_COBRANCA,ENDERECO_ENTREGA,FRETE,IMPOSTOS,METODO_ENTREGA_ID,NUMERO_REVISAO,SUBTOTAL,TOTAL_DEVIDO,ULTIMA_MODIFICACAO,VENDA_ID,VENDA_NUMERO,VENDEDOR_ID ON VENDA 
FOR EACH ROW
BEGIN
  :new.numero_revisao := :old.numero_revisao + 1; /* Trigger BEFORE permite atualizar NEW obrigado nathan!!*/
END;



