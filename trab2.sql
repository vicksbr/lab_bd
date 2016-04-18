para cada empregado liste seu nome, função, e o nome do departamento
	
	SELECT pes.NOME, emp.FUNCAO FROM EMPREGADO emp INNER JOIN PESSOA pes ON emp.pessoa_id = pes.pessoa_id INNER JOIN DEPARTAMENTO dep ON emp.DEPARTAMENTO_ID = dep.DEPARTAMENTO_ID;


– Para cada produto liste seu nome, preço, subcategoria e categoria;

	SELECT prod.NOME, prod.PRECO, sub.NOME, sub.CATEGORIA FROM PRODUTO prod INNER JOIN SUBCATEGORIA sub ON prod.SUBCATEGORIA = sub.SUBCATEGORIA_ID;

-QUantos clientes fizeram compra em 2014
	
	SELECT COUNT(*) FROM CLIENTE c INNER JOIN VENDA v ON c.CLIENTE_ID = v.CLIENTE_ID WHERE v.DATA_VENDA >= '01-01-14';
	

Calcule o total vendido no ano de 2014
	
	SELECT SUM(TOTAL_DEVIDO) FROM VENDA WHERE VENDA.DATA_VENDA >= '01-01-14';
	

Para cada imposto, liste seu nome, o valor da taxa, nome do estado e código do pais onde o imposto é aplicado.

	SELECT imp.NOME, imp.TAXA, est.NOME, est.CODIGO_PAIS FROM IMPOSTO imp INNER JOIN ESTADO est ON imp.ESTADO_ID = est.ESTADO_ID;

	
– Crie uma nova tabela chamada ‘telefone_us’ contendo os telefones das pessoas que residam nos Estados Unidos (código ‘US’), juntamente
com seu estado de residência

	CREATE TABLE telefone_us AS  (SELECT tel.NUMERO, est.NOME, est.PAIS FROM PESSOA pes INNER JOIN TELEFONE tel ON pes.PESSOA_ID = tel.PESSOA_ID  
                                            INNER JOIN ENDERECO end ON pes.PESSOA_ID = end.PESSOA_ID 
                                            INNER JOIN ESTADO est ON est.ESTADO_ID = end.ESTADO_ID
                                            where est.CODIGO_PAIS = 'US');

	

Update concatenando o numero 5 nos numeros da tabela TELEFONE_US com certos requisitos

	update TELEFONE_US telus set NUMERO=concat('5',NUMERO) where telus.NOME = 'California' OR telus.NOME = 'Colorado' OR telus.NOME = 'Florida' OR telus.NOME = 'Washington' OR telus.NOME = 'New York';


Deletar da tabela TELEFONE_US os telefones que possuem TIPO='Trabalho' verificado na tabela TELEFONE 

	
	DELETE FROM TELEFONE_US telus WHERE telus.NUMERO IN (SELECT TELEFONE.NUMERO FROM TELEFONE_US INNER JOIN TELEFONE ON TELEFONE.NUMERO = TELEFONE_US.NUMERO WHERE TELEFONE.TIPO = 'Trabalho');