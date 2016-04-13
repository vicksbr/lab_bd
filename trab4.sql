1)

create or replace PROCEDURE produto_altera_preco (prod_id in number, prod_valro in number) AS
    
BEGIN
    UPDATE produto SET PRECO=prod_valro WHERE PRODUTO_ID=prod_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('nao existe produto com esse id'); 
END;


--calcula imposto do estado
--imprimir o valor com imposto e sem imposto
--utilizar só os tipo 1,2,3 de imposto no calculo

create or replace PROCEDURE calcula_imposto (valor_imposto in number, estado_id in number) AS

BEGIN
  FOR item IN (SELECT ESTADO_ID, NOME FROM IMPOSTO)
  LOOP
    dbms_output.put_line( item.ESTADO_ID || item.NOME );	
  END LOOP;
END;

