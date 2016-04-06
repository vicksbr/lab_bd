--TESTE 2 DO GIT

--atualize o valor TOTAL_UNITARIO da tabela VENDA_ITEM
--http://www.adp-gmbh.ch/ora/plsql/coll/iterate.html

SET SERVEROUTPUT ON

DECLARE 
  c_item_venda_id number(38,2);
  c_item_venda_total number(38,2);
  c_item_venda_preco number(38,2);
  c_item_venda_desconto number(38,2);
  c_item_venda_quantidade number(38,2);
  
  CURSOR vcursor IS SELECT VENDA_ITEM_ID, TOTAL_UNITARIO, PRECO_UNITARIO, DESCONTO_UNITARIO, QUANTIDADE FROM VENDA_ITEM vi;
 
BEGIN
  OPEN vcursor;
  LOOP
    FETCH vcursor INTO c_item_venda_id,c_item_venda_total,c_item_venda_preco,c_item_venda_desconto,c_item_venda_quantidade;
    EXIT WHEN vcursor%notfound;
    UPDATE VENDA_ITEM set TOTAL_UNITARIO=(c_item_venda_quantidade*(c_item_venda_preco-c_item_venda_desconto)) WHERE VENDA_ITEM.VENDA_ITEM_ID = c_item_venda_id;
    
  END LOOP;
  CLOSE vcursor;
END;


--Atualize o valor de SUBTOTAL da tabela VENDA

SET SERVEROUTPUT ON

DECLARE 
  u_venda_id NUMBER(38,2);
  u_venda_item_id NUMBER(38,2);
  u_total_unitario NUMBER(38,2);
  
  CURSOR vcursor IS SELECT VENDA_ID, VENDA_ITEM_ID, TOTAL_UNITARIO FROM VENDA_ITEM;
 
BEGIN
  OPEN vcursor;
  LOOP
    FETCH vcursor INTO u_venda_id,u_venda_item_id,u_total_unitario;
    EXIT WHEN vcursor%notfound;
    UPDATE VENDA set SUBTOTAL=(SUBTOTAL + u_total_unitario) WHERE VENDA.VENDA_ID = u_venda_id;
  END LOOP;
  CLOSE vcursor;
END;


--Itere sobre a tabela 'PRODUTO' e imprima as seguintes mensagens 

PRODUTO EM FALTA: {PRODUTO_ID} - {ǸOME}, caso 	QUANTIDADE=0

PRODUTO EM BAIXA QUANTIDADE: {PRODUTO_ID} - {ǸOME} - {QUANTIDADE} caso 	QUANTIDADE<0

SET SERVEROUTPUT ON

BEGIN
  FOR tabela IN (SELECT PRODUTO_ID, NOME, QUANTIDADE FROM PRODUTO WHERE QUANTIDADE=0)
  LOOP
    dbms_output.put_line('PRUDUTO EM FALTA:' || tabela.PRODUTO_ID  || tabela.NOME || tabela.QUANTIDADE );
  END LOOP;
END;

BEGIN
  FOR tabela IN (SELECT PRODUTO_ID, NOME, QUANTIDADE FROM PRODUTO WHERE (QUANTIDADE!=0 AND QUANTIDADE<10))
  LOOP
    dbms_output.put_line('PRUDUTO EM BAIXA: ' || tabela.PRODUTO_ID || ' ' || tabela.NOME || ' ' || tabela.QUANTIDADE );
  END LOOP;
END;




--Usando o PL/SQL crie um programa que obtenha um VENDA_ID pelo teclado do usuario
--Caso não exista imprima uma mensagem 'Não existe venda com esse identificador'

--Caso exista, imprima a data de venda, o nome do cliente, os endereços de cobrança e entrega, subtotal
--imposto, frete e total devido. E para cada produto nessa venda, exiba o nome do produto, a quantidade
--o preço unitario, o valor do desconto, o total unitario e o código de rastreio.


Venda ID: {VENDA_ID}
Data Venda: {DATA_VENDA}
Cliente: {NOME || SOBRENOME}
Endereço Cobrança: {ENDERECO_LINHA1 || ENDERECO_LINHA2 ||
CIDADE}
Endereço Entrega: {ENDERECO_LINHA1 || ENDERECO_LINHA2 ||
CIDADE}
Subtotal: {SUBTOTAL}
Impostos: {IMPOSTOS}
Frete:{FRETE}
Total Devido: {TOTAL_DEVIDO}


Produto: {NOME}
Quantidade: {QUANTIDADE}
Preço Unitário: {PRECO_UNITARIO}
Desconto Unitário: {DESCONTO_UNITARIO}
Total Unitário: {TOTAL_UNITARIO}
Código de Rastreio: {CODIGO_RASTREIO}
. . .
Produto: {NOME}
Quantidade: {QUANTIDADE}
Preço Unitário: {PRECO_UNITARIO}
Desconto Unitário: {DESCONTO_UNITARIO}
Total Unitário: {TOTAL_UNITARIO}
Código de Rastreio: {CODIGO_RASTREIO}

set serveroutput on

accept vstring prompt "Entre com o numero venda";  

DECLARE
   m_venda_id VENDA.VENDA_ID%TYPE;
   m_data VENDA.DATA_VENDA%TYPE;
   m_cliente VENDA.CLIENTE_ID%TYPE;
   m_end_cob VENDA.ENDERECO_COBRANCA%TYPE;
   m_end_ent VENDA.ENDERECO_ENTREGA%TYPE;
   m_subtotal VENDA.SUBTOTAL%TYPE;
   m_imposto VENDA.IMPOSTOS%TYPE;
   m_frete VENDA.FRETE%TYPE;
   m_total VENDA.TOTAL_DEVIDO%TYPE;
BEGIN
  SELECT VENDA_ID,DATA_VENDA,CLIENTE_ID,ENDERECO_COBRANCA,ENDERECO_ENTREGA,SUBTOTAL,IMPOSTOS,FRETE,TOTAL_DEVIDO
  INTO m_venda_id, m_data, m_cliente, m_end_cob, m_end_ent, m_subtotal, m_imposto, m_frete, m_total
  FROM VENDA 
  WHERE VENDA_ID = &vstring;
  dbms_output.put_line('VENDA_ID ' || m_venda_id);
  dbms_output.put_line('DATA VENDA ' || m_data);
  dbms_output.put_line('CLIENTE_ID ' || m_cliente);
  dbms_output.put_line('END COBR ' || m_end_cob);
  dbms_output.put_line('END ENT ' || m_end_ent);
  dbms_output.put_line('SUBTOTAL ' || m_subtotal);
  dbms_output.put_line('IMPOSTO ' || m_imposto);
  dbms_output.put_line('FRETE ' || m_frete);
  dbms_output.put_line('TOTAL DEV ' || m_total);

  EXCEPTION WHEN NO_DATA_FOUND THEN  dbms_output.put_line('NAO EXISTE VENDA COM ESSE IDENTIFICADOR');
END;


