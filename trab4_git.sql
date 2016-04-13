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

3)

CREATE OR REPLACE FUNCTION venda_status_texto (cod_status IN NUMBER) RETURN VARCHAR2 IS
   
   resposta varchar2(50) := '';
   
BEGIN
  CASE
      WHEN cod_status = '1' THEN resposta := 'Processando';
      WHEN cod_status = '2' THEN resposta := 'Aprovado';
      WHEN cod_status = '3' THEN resposta := 'Em espera';
      WHEN cod_status = '4' THEN resposta := 'Rejeitado';
      WHEN cod_status = '5' THEN resposta := 'Enviado';
      WHEN cod_status = '6' THEN resposta := 'Cancelado';
      ELSE resposta := 'Invalido';
  END CASE;
  
  RETURN resposta;

END;

4)

set serveroutput on

CREATE OR REPLACE FUNCTION password_hash (senha VARCHAR2) return VARCHAR2 is 

 v_input varchar2(2000) := senha;   
 hexkey varchar2(32) := null;   

BEGIN   
   hexkey := rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(v_input)));   
   return nvl(hexkey,'');   
END; 

5)

CREATE OR REPLACE FUNCTION password_hash (senha VARCHAR2) return VARCHAR2 is 

 v_input varchar2(2000) := senha;   
 hexkey varchar2(32) := null;   

BEGIN   
   hexkey := rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(v_input)));   
   return nvl(hexkey,'');      
END;

6) 

create or replace FUNCTION login (p_login VARCHAR2, p_senha VARCHAR2) return VARCHAR2 is 

 resposta varchar2(100) := '';   
 u_pessoa_id NUMBER(38,2);
 u_password VARCHAR2(100);
 
 CURSOR vcursor IS SELECT PESSOA_ID, PASSWORD_HASH FROM PESSOA WHERE EMAIL=p_login; 
 CURSOR emp_cursor IS SELECT PESSOA_ID FROM EMPREGADO WHERE LOGIN_ID=p_login; 
 
BEGIN   
   
   OPEN vcursor;
   FETCH vcursor INTO u_pessoa_id, u_password;
   CLOSE vcursor;   
   IF u_pessoa_id IS NULL THEN 
      dbms_output.put_line('nao encontrou');    
   ELSE  
      dbms_output.put_line('encontrou');
   END IF;
   RETURN resposta;      

END;

