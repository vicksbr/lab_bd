/*PROCEDURES*/

create or replace PROCEDURE VENDA_DESCONTO_ENTRE_DATAS(inicio IN VARCHAR, fim IN VARCHAR, porc_alterracao IN NUMBER) AS 


v_new_preco NUMBER(38, 2);
CURSOR vcursor IS SELECT VENDA_ID, TOTAL_DEVIDO FROM SIMU_VENDA WHERE DATA_VENDA BETWEEN to_date(inicio) AND to_date(fim);

BEGIN
  FOR venda_cur IN vcursor LOOP
  
    v_new_preco := venda_cur.TOTAL_DEVIDO * (1 - (porc_alterracao/100));
    UPDATE SIMU_VENDA SET TOTAL_DEVIDO=v_new_preco WHERE VENDA_ID=venda_cur.VENDA_ID;
  END LOOP;
END;

create or replace PROCEDURE VENDA_DESC_FRETE_ACIMA_VALOR(valor_minimo IN NUMBER, porc_alterracao IN NUMBER) AS 

v_new_preco NUMBER(38, 2);
v_new_frete NUMBER(38, 2);
CURSOR vcursor IS SELECT VENDA_ID, FRETE, TOTAL_DEVIDO FROM SIMU_VENDA WHERE TOTAL_DEVIDO > valor_minimo;

BEGIN
  FOR venda_cur IN vcursor LOOP
    v_new_frete := venda_cur.FRETE * (1 - (porc_alterracao/100));
    v_new_preco := venda_cur.TOTAL_DEVIDO - venda_cur.FRETE + v_new_frete;
    UPDATE SIMU_VENDA SET TOTAL_DEVIDO=v_new_preco, FRETE=v_new_frete WHERE VENDA_ID=venda_cur.VENDA_ID;
  END LOOP;
END;

create or replace PROCEDURE produto_altera_preco (prod_id in number, prod_valro in number) AS
    
  confere NUMBER(38,2);
  preco_antigo NUMBER(38,2);   
     
BEGIN 
  
    SELECT 
      PRODUTO_ID,
      PRECO            
    INTO 
      confere, 
      preco_antigo
    FROM 
      PRODUTO 
    WHERE 
      PRODUTO_ID=prod_id;
    
    UPDATE SIMU_PRODUTO SET PRECO=prod_valro, ULTIMA_MODIFICACAO=SYSTIMESTAMP WHERE PRODUTO_ID=prod_id;            
    UPDATE SIMU_VENDA_ITEM SET PRECO_UNITARIO=prod_valro, ULTIMA_MODIFICACAO=SYSTIMESTAMP WHERE PRODUTO_ID=prod_id;            
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('nao existe produto com esse id=' || prod_id); 
END;


create or replace PROCEDURE PROC_SUBCAT_MUDA_PRECO (subcat in number, porc_alterracao in number) AS 

v_new_preco NUMBER(38,2);
CURSOR vcursor IS SELECT pr.PRODUTO_ID, pr.PRECO FROM SIMU_PRODUTO pr WHERE pr.SUBCATEGORIA=subcat;

BEGIN
  FOR prod IN vcursor LOOP
    v_new_preco := prod.PRECO * (1 + (porc_alterracao/100));
    UPDATE SIMU_PRODUTO SET PRECO=v_new_preco WHERE PRODUTO_ID=prod.PRODUTO_ID;
  END LOOP;
END;

create or replace PROCEDURE PROC_CAT_MUD_PRECO(cat in varchar2, porc_alterracao in number) AS 

CURSOR vcursor IS SELECT pr.PRODUTO_ID, pr.PRECO FROM SIMU_PRODUTO pr INNER JOIN SIMU_SUBCATEGORIA subcat ON pr.SUBCATEGORIA=subcat.SUBCATEGORIA_ID WHERE subcat.CATEGORIA=cat;

v_new_preco NUMBER(38,2);

BEGIN
  FOR prod IN vcursor LOOP
    v_new_preco := prod.PRECO * (1 + (porc_alterracao/100));
    UPDATE SIMU_PRODUTO SET PRECO=v_new_preco WHERE PRODUTO_ID=prod.PRODUTO_ID;
  END LOOP;
END;

create or replace PROCEDURE GERA_TABELA_SIMU AUTHID CURRENT_USER IS
BEGIN
declare
   c int;
begin
   select count(*) into c from user_tables where table_name = upper('simu_produto');
   if c = 1 then
      execute immediate 'drop table SIMU_PRODUTO';
   end if;

   select count(*) into c from user_tables where table_name = upper('simu_venda');
   if c = 1 then
      execute immediate 'drop table SIMU_VENDA';
   end if;

   select count(*) into c from user_tables where table_name = upper('SIMU_VENDA_ITEM');
   if c = 1 then
      execute immediate 'drop table SIMU_VENDA_ITEM';
   end if;

     select count(*) into c from user_tables where table_name = upper('SIMU_SUBCATEGORIA');
   if c = 1 then
      execute immediate 'drop table SIMU_SUBCATEGORIA';
   end if;

      select count(*) into c from user_tables where table_name = upper('SIMU_METODO_ENTREGA');
   if c = 1 then
      execute immediate 'drop table SIMU_METODO_ENTREGA';
   end if;
  
    execute immediate 'CREATE TABLE SIMU_PRODUTO AS SELECT * FROM PRODUTO';
    execute immediate 'CREATE TABLE SIMU_VENDA AS SELECT * FROM VENDA';
    execute immediate 'CREATE TABLE SIMU_VENDA_ITEM AS SELECT * FROM VENDA_ITEM';
    execute immediate 'CREATE TABLE SIMU_SUBCATEGORIA AS SELECT * FROM SUBCATEGORIA';
    execute immediate 'CREATE TABLE SIMU_METODO_ENTREGA AS SELECT * FROM METODO_ENTREGA';
  
  
  COMMIT;
end;
END GERA_TABELA_SIMU;


/*Triggers*/

create or replace TRIGGER "ALTERA_METODO_ENTREGA_CUSTO" AFTER UPDATE OF CUSTO_LIBRA ON SIMU_METODO_ENTREGA 
REFERENCING OLD AS OLD NEW AS NEW 
FOR EACH ROW
DECLARE
v_frete NUMBER(38,2);
v_novo_frete NUMBER(38,2);
CURSOR vcursor IS SELECT vi.VENDA_ID, vi.FRETE FROM SIMU_VENDA vi WHERE vi.METODO_ENTREGA_ID = :OLD.METODO_ENTREGA_ID;
BEGIN
FOR venda IN vcursor LOOP
v_novo_frete := (:NEW.CUSTO_LIBRA*venda.FRETE)/(:OLD.CUSTO_LIBRA);
UPDATE SIMU_VENDA SET FRETE=v_novo_frete WHERE VENDA_ID = venda.VENDA_ID;
END LOOP;
END;

create or replace TRIGGER ALTERA_PRODUTO_PRECO 
AFTER UPDATE OF PRECO 
ON SIMU_PRODUTO 
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
v_new_total_unitario NUMBER(38,2);
CURSOR vcursor IS SELECT vi.VENDA_ITEM_ID, vi.QUANTIDADE, vi.DESCONTO_UNITARIO FROM SIMU_VENDA_ITEM vi WHERE vi.PRODUTO_ID = :OLD.PRODUTO_ID;
BEGIN
FOR v_item IN vcursor LOOP
v_new_total_unitario := (:NEW.PRECO - v_item.DESCONTO_UNITARIO) * v_item.QUANTIDADE;
UPDATE SIMU_VENDA_ITEM SET TOTAL_UNITARIO=v_new_total_unitario, PRECO_UNITARIO=:NEW.PRECO WHERE VENDA_ITEM_ID = v_item.VENDA_ITEM_ID;
END LOOP;
END;

create or replace TRIGGER altera_venda_item
AFTER DELETE OR INSERT OR UPDATE OF DESCONTO_UNITARIO,QUANTIDADE,PRECO_UNITARIO,PRODUTO_ID 
ON SIMU_VENDA_ITEM 
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
u_frete NUMBER;
u_impostos NUMBER;
CURSOR vcursor IS SELECT subtotal,FRETE,IMPOSTOS FROM SIMU_VENDA WHERE VENDA_ID=:OLD.VENDA_ID;
BEGIN
u_conta_antiga := :OLD.QUANTIDADE*(:OLD.PRECO_UNITARIO - :OLD.DESCONTO_UNITARIO);
u_conta_nova := :NEW.QUANTIDADE*(:NEW.PRECO_UNITARIO - :NEW.DESCONTO_UNITARIO);
OPEN vcursor;
FETCH vcursor INTO u_subtotal,u_frete,u_impostos; 
CLOSE vcursor;  
UPDATE SIMU_VENDA set subtotal=u_subtotal + (u_conta_nova - u_conta_antiga) WHERE VENDA_ID=:OLD.VENDA_ID;
UPDATE SIMU_VENDA set total_devido=subtotal+FRETE+IMPOSTOS;
END;