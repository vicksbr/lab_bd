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






