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

set serveroutput on

create or replace PROCEDURE calcula_imposto (p_valor in number, p_estado_id in number) AS

  u_estado_id NUMBER(38,2);
  u_imposto_nome VARCHAR2(50);
  u_taxa NUMBER(38,2);
  u_valor_calculado NUMBER := 0;
  
  CURSOR vcursor IS SELECT ESTADO_ID, NOME, TAXA FROM IMPOSTO WHERE ESTADO_ID=p_estado_id AND TIPO BETWEEN 1 AND 3;
  
BEGIN
    OPEN vcursor;
    LOOP
      FETCH vcursor INTO u_estado_id, u_imposto_nome, u_taxa;
      EXIT WHEN vcursor%notfound;
      u_valor_calculado := u_valor_calculado + u_taxa*p_valor;
      dbms_output.put_line('Nome: ' || u_imposto_nome  || ' Valor: '|| p_valor*u_taxa ); 
    END LOOP;
    CLOSE vcursor;
     dbms_output.put_line('Valor sem imposto: ' || p_valor ); 
     dbms_output.put_line('Valor com imposto: ' || (u_valor_calculado + p_valor)); 
END;

