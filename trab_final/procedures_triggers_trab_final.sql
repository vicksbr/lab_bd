create or replace PROCEDURE calcula_imposto (p_valor in number, p_estado_id in number) AS

  u_estado_id NUMBER(38,2);
  u_imposto_nome VARCHAR2(50);
  u_taxa NUMBER(38,2);
  u_valor_calculado NUMBER := 0;
  
  confere NUMBER(38,2);
  
  CURSOR vcursor IS SELECT ESTADO_ID, NOME, TAXA FROM IMPOSTO WHERE ESTADO_ID=p_estado_id AND TIPO BETWEEN 1 AND 3;
  
BEGIN
  
    OPEN vcursor;
    LOOP
      FETCH vcursor INTO u_estado_id, u_imposto_nome, u_taxa;
      EXIT WHEN vcursor%notfound;
      u_valor_calculado := u_valor_calculado + u_taxa*p_valor;
      dbms_output.put_line('Nome: ' || u_imposto_nome  || ', Valor: '|| p_valor*u_taxa ); 
    END LOOP;
    CLOSE vcursor;
     dbms_output.put_line('Valor sem imposto: ' || p_valor ); 
     dbms_output.put_line('Valor com imposto: ' || (u_valor_calculado + p_valor)); 
END;

create or replace PROCEDURE GERA_TABELA_SIMU AUTHID CURRENT_USER IS
BEGIN
declare
   v_sql varchar2(1000);

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


create or replace PROCEDURE PROC_CAT_MUD_PRECO(cat in varchar2, porc_alterracao in number) AS 

CURSOR vcursor IS SELECT pr.PRODUTO_ID, pr.PRECO FROM SIMU_PRODUTO pr INNER JOIN SIMU_SUBCATEGORIA subcat ON pr.SUBCATEGORIA=subcat.SUBCATEGORIA_ID WHERE subcat.CATEGORIA=cat;

v_new_preco NUMBER(38,2);

BEGIN
  FOR prod IN vcursor LOOP
    v_new_preco := prod.PRECO * (1 + (porc_alterracao/100));
    UPDATE SIMU_PRODUTO SET PRECO=v_new_preco WHERE PRODUTO_ID=prod.PRODUTO_ID;
  END LOOP;
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

create or replace PROCEDURE produto_altera_preco (prod_id in number, prod_valro in number) AS
    
  preco_antigo NUMBER(38,2);   
     
BEGIN 
  
    SELECT 
      PRECO            
    INTO 
      preco_antigo
    FROM 
      SIMU_PRODUTO 
    WHERE 
      PRODUTO_ID=prod_id;
    
    UPDATE SIMU_PRODUTO SET PRECO=prod_valro, ULTIMA_MODIFICACAO=SYSTIMESTAMP WHERE PRODUTO_ID=prod_id;            
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('nao existe produto com esse id=' || prod_id); 
END;

create or replace PROCEDURE PRODUTO_ALTERA_QUANTIDADE (prod_id in number, prod_quantidade in number) AS 
    
  quantidade_antiga NUMBER(38,2);   
  
  ex_quantidade_invalida  EXCEPTION;
BEGIN 
  
  IF prod_quantidade < 0 THEN
    RAISE ex_quantidade_invalida;
  END IF;
  
    SELECT 
      QUANTIDADE            
    INTO 
      quantidade_antiga
    FROM 
      SIMU_PRODUTO 
    WHERE 
      PRODUTO_ID=prod_id;
    
    UPDATE SIMU_PRODUTO SET QUANTIDADE=prod_quantidade, ULTIMA_MODIFICACAO=SYSTIMESTAMP WHERE PRODUTO_ID=prod_id;            
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('nao existe produto com esse id=' || prod_id);
      WHEN ex_quantidade_invalida THEN
        DBMS_OUTPUT.PUT_LINE('nova quantidade negativa');
      
END;


create or replace PROCEDURE PRODUTO_ALTERA_SUBCAT (prod_id in number, prod_subcat in number) AS 
    
  subcat_antiga NUMBER(38,2);
  confere_subcategoria_nova NUMBER(38, 2);
  confere_produto_id NUMBER(38, 2);
  
  ex_invalid_product_id  EXCEPTION;
  ex_invalid_subcat_id  EXCEPTION;


BEGIN 
    SELECT
      count(*)
    INTO
     confere_produto_id
    FROM
      PRODUTO
    WHERE
      PRODUTO_ID=prod_id;
    
    IF confere_produto_id = 0 THEN
      RAISE ex_invalid_product_id;
    end if;
    
    SELECT
      count(*)
    INTO
     confere_subcategoria_nova
    FROM
      SUBCATEGORIA
    WHERE
      SUBCATEGORIA_ID=prod_subcat;

  IF confere_subcategoria_nova = 1 THEN
    UPDATE SIMU_PRODUTO SET SUBCATEGORIA=prod_subcat, ULTIMA_MODIFICACAO=SYSTIMESTAMP WHERE PRODUTO_ID=prod_id;            
  ELSE
    RAISE ex_invalid_subcat_id;
  end if;
    
    EXCEPTION
      WHEN ex_invalid_product_id THEN
        DBMS_OUTPUT.PUT_LINE('nao existe produto com esse id=' || prod_id);
      WHEN ex_invalid_subcat_id THEN
        DBMS_OUTPUT.PUT_LINE('nao existe subcategoria com esse id=' || prod_subcat);
END;


create or replace PROCEDURE SUBCATEGORIA_ALTERA_CATEGORIA ( subcategoria_id_alter IN NUMBER, categoria_novo IN VARCHAR2) AS 
  confere_subcat NUMBER(38,2);
  confere_categoria_nova NUMBER(38, 2);
  
  ex_invalid_subcat_id  EXCEPTION;

BEGIN
    SELECT
      count(*)
    INTO
      confere_subcat
    FROM
      SUBCATEGORIA
    WHERE
      SUBCATEGORIA_ID=subcategoria_id_alter;
    
    IF confere_subcat = 0 THEN
      RAISE ex_invalid_subcat_id;
    end if;
    
    UPDATE SIMU_SUBCATEGORIA SET CATEGORIA=categoria_novo, ULTIMA_MODIFICACAO=SYSTIMESTAMP WHERE SUBCATEGORIA_ID=subcategoria_id_alter;
    
    EXCEPTION
      WHEN ex_invalid_subcat_id THEN
        DBMS_OUTPUT.PUT_LINE('nao existe subcategoria com esse id=' || subcategoria_id_alter);
      
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

create or replace PROCEDURE VENDA_DESCONTO_ENTRE_DATAS(inicio IN VARCHAR, fim IN VARCHAR, porc_alterracao IN NUMBER) AS 


v_new_preco NUMBER(38, 2);
CURSOR vcursor IS SELECT VENDA_ID, TOTAL_DEVIDO FROM SIMU_VENDA WHERE DATA_VENDA BETWEEN to_date(inicio) AND to_date(fim);

BEGIN
  FOR venda_cur IN vcursor LOOP
  
    v_new_preco := venda_cur.TOTAL_DEVIDO * (1 - (porc_alterracao/100));
    UPDATE SIMU_VENDA SET TOTAL_DEVIDO=v_new_preco WHERE VENDA_ID=venda_cur.VENDA_ID;
  END LOOP;
END;

create or replace PROCEDURE VENDA_DESCONTO_ESTADO (estado_desconto IN VARCHAR, alterracao_preco IN NUMBER) AS 

v_novo_total_devido NUMBER(38, 2);

CURSOR vcursor IS SELECT
  EST.PAIS AS PAIS,
  EST.NOME AS ESTADO,
  VE.VENDA_ID AS VENDA_ID,
  VE.TOTAL_DEVIDO AS TOTAL_DEVIDO
FROM
  SIMU_VENDA VE
  INNER JOIN ENDERECO ENDE ON VE.ENDERECO_COBRANCA = ENDE.ENDERECO_ID
  INNER JOIN ESTADO EST ON ENDE.ESTADO_ID = EST.ESTADO_ID
WHERE
EST.NOME=estado_desconto;

BEGIN
  FOR venda_cur IN vcursor LOOP
    v_novo_total_devido := venda_cur.TOTAL_DEVIDO - alterracao_preco;
    IF v_novo_total_devido < 0 THEN
      v_novo_total_devido := 0;
    END IF;
    
    UPDATE SIMU_VENDA SET TOTAL_DEVIDO=v_novo_total_devido WHERE VENDA_ID=venda_cur.VENDA_ID;
  END LOOP;
END;


create or replace PROCEDURE VENDA_DESCONTO_MAIS_DE_UMA_UN (porc_alterracao IN NUMBER) AS 

vi_novo_desconto NUMBER(38, 2);
CURSOR vcursor IS SELECT * FROM SIMU_VENDA_ITEM WHERE QUANTIDADE > 1;

BEGIN
  FOR venda_item_cur IN vcursor LOOP
    vi_novo_desconto := venda_item_cur.DESCONTO_UNITARIO + venda_item_cur.PRECO_UNITARIO * (porc_alterracao/100);
    VENDA_ITEM_ALTERA_DESCONTO(venda_item_cur.VENDA_ITEM_ID, vi_novo_desconto);
  END LOOP;
END;

create or replace PROCEDURE VENDA_DESCONTO_PAIS (pais_desconto IN VARCHAR, alterracao_preco IN NUMBER) AS 

vi_novo_desconto NUMBER(38, 2);
CURSOR vcursor IS SELECT NOME FROM ESTADO WHERE LOWER(PAIS) = LOWER(pais_desconto);

BEGIN
  FOR vendas_estado_cur IN vcursor LOOP
    dbms_output.put_line('australia');
    VENDA_DESCONTO_ESTADO(vendas_estado_cur.NOME, alterracao_preco);
  END LOOP;
END;

create or replace PROCEDURE VENDA_ITEM_ALTERA_DESCONTO(venda_item_id_alt in number, novo_venda_item_desconto in number) AS 
    
  quantidade_antigo NUMBER(38,2);
  preco_unitario_antigo NUMBER(38,2);
  
  ex_desconto_invalido_maior EXCEPTION;
  ex_desconto_invalido_menor EXCEPTION;
BEGIN 
    SELECT 
      QUANTIDADE, PRECO_UNITARIO
    INTO 
      quantidade_antigo, preco_unitario_antigo
    FROM 
      SIMU_VENDA_ITEM 
    WHERE 
      VENDA_ITEM_ID=venda_item_id_alt;
    if novo_venda_item_desconto > preco_unitario_antigo THEN
      RAISE ex_desconto_invalido_maior;
    END IF;
    if novo_venda_item_desconto < 0 THEN
      RAISE ex_desconto_invalido_menor;
    END IF;
    UPDATE SIMU_VENDA_ITEM SET
      DESCONTO_UNITARIO=novo_venda_item_desconto,
      TOTAL_UNITARIO=quantidade_antigo*(preco_unitario_antigo - novo_venda_item_desconto),
      ULTIMA_MODIFICACAO=SYSTIMESTAMP
    WHERE
      VENDA_ITEM_ID=venda_item_id_alt;            
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('nao existe venda de produto com esse id=' || venda_item_id_alt); 
      WHEN ex_desconto_invalido_maior THEN
        DBMS_OUTPUT.PUT_LINE('valor do desconto maior do que o valor do produto');
      WHEN ex_desconto_invalido_menor THEN
        DBMS_OUTPUT.PUT_LINE('valor do desconto menor do que zero');
END;


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