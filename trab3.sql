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
	u_total_unitario NUMBER(38,2);
  
  CURSOR vcursor IS SELECT VENDA_ID, TOTAL_UNITARIO FROM VENDA_ITEM;
 
BEGIN
  OPEN vcursor;
  LOOP
    FETCH vcursor INTO u_venda_id,u_total_unitario;
    EXIT WHEN vcursor%notfound;
    UPDATE VENDA set SUBTOTAL=(SUBTOTAL + u_total_unitario) WHERE VENDA.VENDA_ID = u_total_unitario;
    
  END LOOP;
  CLOSE vcursor;
END;

--Itere sobre a tabela 'PRODUTO' e imprima as seguintes mensagens 

PRODUTO EM FALTA: {PRODUTO_ID} - {ǸOME}, caso 	QUANTIDADE=0

PRODUTO EM BAIXA QUANTIDADE: {PRODUTO_ID} - {ǸOME} - {QUANTIDADE} caso 	QUANTIDADE<0



BEGIN
  FOR tabela IN (SELECT PRODUTO_ID, NOME, QUANTIDADE FROM PRODUTOS)
  LOOP
    dbms_output.put_line('PRUDUTO EM FALTA:' || tabela.PRODUTO_ID  || tabela.NOME || tabela.QUANTIDADE );
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


