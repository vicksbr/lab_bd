--TESTE 2 DO GIT

--atualize o valor TOTAL_UNITARIO da tabela VENDA_ITEM
--http://www.adp-gmbh.ch/ora/plsql/coll/iterate.html

BEGIN
  FOR item IN (SELECT VENDA_ITEM_ID FROM VENDA_ITEM)
  LOOP
    dbms_output.put_line( item.VENDA_ITEM_ID );
  END LOOP;
END;


TOTAL_UNITARIO = QUANTIDADE * (PRECO_UNITARIO - DESCONTO_UNITARIO);


DECLARE
   CURSOR c1 is
   		SELECT VENDA_ITEM_ID, PRECO_UNITARIO,  DESCONTO_UNITARIO, TOTAL_UNITARIO,QUANTIDADE FROM VENDA_ITEM FOR UPDATE            
   u_venda_item_id NUMBER(38,2);
   u_preco_unitario NUMBER(38,2);
   u_desconto_unitario NUMBER(38,2);
   u_total_unitario   NUMBER(38,2);
   u_quantidade NUMBER(38,2);
BEGIN
   OPEN c1;
   LOOP
   		FETCH c1 INTO u_venda_item_id, u_preco, u_desconto_unitario, u_total_unitario,u_ quantidade;      
      	EXIT WHEN c1%NOTFOUND;  /* in case the number requested */ /* is more than the total       *//* number of employees          */	    	    
	    UPDATE VENDA_ITEM set TOTAL_UNITARIO= u_quantidade * (u_preco_unitario - u_desconto_unitario);      	
   END LOOP;
   CLOSE c1;
   COMMIT;
END;



--Atualize o valor de SUBTOTAL da tabela VENDA


DECLARE	
	CURSOR c1 is SELECT VENDA_ID, TOTAL_UNITARIO FROM VENDA_ITEM INNER JOIN VENDA ON VENDA_ITEM.VENDA_ID = VENDA.VENDA_ID;
	u_venda_id NUMBER(38,2);
	u_total_unitario NUMBER(38,2);

BEGIN
	OPEN c1;
	LOOP 
		FETCH c1 INTO u_venda_id, u_total_unitario;
		EXIT WHEN c1%NOTFOUND;
		UPDATE VENDA set SUBTOTAL=SUBTOTAL+u_total_unitario WHERE VENDA_ID = u_venda_id; 
	END LOOP;
	CLOSE c1;
	COMMIT;
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


